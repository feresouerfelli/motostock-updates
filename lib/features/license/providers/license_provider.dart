import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:motostock_pro/core/utils/device_info.dart';

class LicenseState {
  final bool isActivated;
  final String machineCode;
  final String macAddress;
  final String? activationKey;
  final String
      syncStatus; // 'idle' | 'syncing' | 'activated_online' | 'offline' | 'blocked'

  const LicenseState({
    required this.isActivated,
    required this.machineCode,
    required this.macAddress,
    this.activationKey,
    this.syncStatus = 'idle',
  });

  LicenseState copyWith({
    bool? isActivated,
    String? machineCode,
    String? macAddress,
    String? activationKey,
    String? syncStatus,
  }) {
    return LicenseState(
      isActivated: isActivated ?? this.isActivated,
      machineCode: machineCode ?? this.machineCode,
      macAddress: macAddress ?? this.macAddress,
      activationKey: activationKey ?? this.activationKey,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

class LicenseNotifier extends StateNotifier<AsyncValue<LicenseState>> {
  LicenseNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await initLicense();
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  static const String _prefMachineKey = 'motostock_machine_code';
  static const String _prefMacKey = 'motostock_mac_address';
  static const String _prefActivationKey = 'motostock_activation_key';
  static const String _salt = 'MOTO_PRO_200DT_TUNISIA_2026';

  RealtimeChannel? _realtimeSubscription;

  Future<void> initLicense() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Get physical MAC address
      final mac = await DeviceInfoHelper.getMacAddress();
      await prefs.setString(_prefMacKey, mac);

      // 2. Get or generate the machine code deterministically based on MAC
      String? machineCode = prefs.getString(_prefMachineKey);
      if (machineCode == null) {
        if (mac != 'UNKNOWN-MAC') {
          // Generate a deterministic machine code from MAC
          final cleanMac = mac.replaceAll(':', '').toUpperCase();
          int hash = 0;
          for (int i = 0; i < cleanMac.length; i++) {
            hash = ((hash * 31 + cleanMac.codeUnitAt(i)).toUnsigned(32));
          }
          final part = hash
              .toRadixString(16)
              .padLeft(8, '0')
              .toUpperCase()
              .substring(0, 8);
          machineCode = 'MOTO-${part.substring(0, 4)}-${part.substring(4, 8)}';
        } else {
          // Absolute fallback: generate a random recognizable MOTO-XXXX-XXXX and persist it
          final rawUuid = const Uuid()
              .v4()
              .replaceAll('-', '')
              .substring(0, 8)
              .toUpperCase();
          machineCode =
              'MOTO-${rawUuid.substring(0, 4)}-${rawUuid.substring(4, 8)}';
        }
        await prefs.setString(_prefMachineKey, machineCode);
      }

      // 3. Get the stored activation key
      final storedKey = prefs.getString(_prefActivationKey);
      bool isActivated = false;

      if (storedKey != null) {
        isActivated = _verifyKey(machineCode, storedKey);
      }

      final newState = LicenseState(
        isActivated: isActivated,
        machineCode: machineCode,
        macAddress: mac,
        activationKey: storedKey,
        syncStatus: 'idle',
      );

      if (mounted) {
        state = AsyncValue.data(newState);
      }

      // 4. ALWAYS start online sync & realtime subscription
      //    (even if activated locally — to support remote blocking)
      _syncAndSubscribeOnline(machineCode, mac);
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  /// Registers client machine in Supabase if not exists, and listens for real-time activation updates.
  /// Checks by MAC address on startup:
  /// - If MAC exists and is_activated is true -> opens normally.
  /// - If MAC exists and is_activated is false -> blocks and waits for activation.
  /// - If MAC does not exist -> sends MAC, registers the machine and waits for activation.
  Future<void> _syncAndSubscribeOnline(String machineCode, String mac) async {
    try {
      final current = state.valueOrNull;
      if (current == null) return;

      state = AsyncValue.data(current.copyWith(syncStatus: 'syncing'));

      final client = Supabase.instance.client;

      // 1. Check if already registered by MAC address
      final existing = await client
          .from('motostock_licenses')
          .select()
          .eq('mac_address', mac)
          .maybeSingle();

      if (existing == null) {
        // 2. MAC Address does not exist -> Register it now and wait for activation
        debugPrint('MAC Address does not exist on Supabase. Registering client machine...');
        await client.from('motostock_licenses').insert({
          'machine_code': machineCode,
          'mac_address': mac,
          'device_name':
              '${DeviceInfoHelper.getDeviceName()} (${Platform.operatingSystem})',
          'is_activated': false,
          'payment_status': 'pending',
        });
        
        await deactivate(triggerOnlineSync: false);
      } else {
        // MAC Address exists in Supabase — check server activation state
        final isActivatedOnServer = existing['is_activated'] as bool? ?? false;
        final activationKeyOnServer = existing['activation_key'] as String?;

        if (isActivatedOnServer) {
          // 3. Activated online -> Auto-activate locally and open normally!
          final finalKey = activationKeyOnServer ?? generateKeyForMachine(machineCode);
          debugPrint('MAC Address is activated online! Key: $finalKey');
          await activate(finalKey);
          
          final updated = state.valueOrNull;
          if (updated != null) {
            state = AsyncValue.data(
                updated.copyWith(syncStatus: 'activated_online'));
          }
        } else {
          // 4. Exists but is NOT activated -> Do not open, ensure deactivated and wait for admin
          debugPrint('MAC Address exists but is NOT activated. Waiting for admin...');
          await deactivate(triggerOnlineSync: false);
        }
      }

      final afterCheck = state.valueOrNull;
      if (afterCheck != null && afterCheck.syncStatus == 'syncing') {
        state = AsyncValue.data(afterCheck.copyWith(syncStatus: 'idle'));
      }

      // Subscribe to Realtime database updates for this machine row
      // This handles BOTH remote activation AND remote blocking
      debugPrint(
          'Listening to Supabase Realtime channel for remote license changes...');

      // Clean up any previous subscription before creating a new one
      _cleanupSubscription();

      _realtimeSubscription = client
          .channel('public:motostock_licenses:machine_code=$machineCode')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'motostock_licenses',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'machine_code',
              value: machineCode,
            ),
            callback: (payload) async {
              try {
                final newRecord = payload.newRecord;
                if (newRecord.isNotEmpty) {
                  final serverActivated =
                      newRecord['is_activated'] as bool? ?? false;
                  final serverKey = newRecord['activation_key'] as String?;

                  if (serverActivated && serverKey != null) {
                    // Remote ACTIVATION triggered
                    debugPrint(
                        'Remote Realtime Activation triggered! Key: $serverKey');
                    await activate(serverKey);
                    final currentData = state.valueOrNull;
                    if (currentData != null) {
                      state = AsyncValue.data(
                          currentData.copyWith(syncStatus: 'activated_online'));
                    }
                  } else if (!serverActivated) {
                    // Remote BLOCKING triggered! Admin cut access.
                    debugPrint(
                        'REMOTE BLOCK via Realtime! Admin has disabled this machine.');
                    await deactivate();
                  }
                }
              } catch (e) {
                debugPrint('Error in Realtime callback: $e');
              }
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Supabase syncing error (Client running offline mode): $e');
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(current.copyWith(syncStatus: 'offline'));
      }
    }
  }

  // Verify if a key matches the machine code
  bool _verifyKey(String machineCode, String key) {
    return generateKeyForMachine(machineCode) == key.trim().toUpperCase();
  }

  // The custom secure key generator algorithm
  String generateKeyForMachine(String machineCode) {
    final cleanId = machineCode.replaceAll('-', '').toUpperCase();

    // Hash code using standard integer operations
    int hash1 = 0;
    final combined1 = "$cleanId$_salt";
    for (int i = 0; i < combined1.length; i++) {
      hash1 = (hash1 * 31 + combined1.codeUnitAt(i)) & 0xFFFFFFFF;
    }

    int hash2 = 0;
    final combined2 = "$_salt$cleanId";
    for (int i = 0; i < combined2.length; i++) {
      hash2 = (hash2 * 17 + combined2.codeUnitAt(i)) & 0xFFFFFFFF;
    }

    final part1 =
        hash1.toRadixString(16).padLeft(8, '0').toUpperCase().substring(0, 8);
    final part2 =
        hash2.toRadixString(16).padLeft(8, '0').toUpperCase().substring(0, 8);
    final rawKey = "$part1$part2";

    return "${rawKey.substring(0, 4)}-${rawKey.substring(4, 8)}-${rawKey.substring(8, 12)}-${rawKey.substring(12, 16)}";
  }

  // Attempt to activate the application
  Future<bool> activate(String key) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return false;

    final isValid = _verifyKey(currentState.machineCode, key);
    if (isValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefActivationKey, key.trim().toUpperCase());

      state = AsyncValue.data(currentState.copyWith(
        isActivated: true,
        activationKey: key.trim().toUpperCase(),
      ));

      // DO NOT cleanup subscription — keep listening for remote blocking!
      return true;
    }
    return false;
  }

  // Deactivate — called by remote blocking or for testing
  Future<void> deactivate({bool triggerOnlineSync = true}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefActivationKey);
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(
        isActivated: false,
        activationKey: null,
        syncStatus: 'blocked',
      ));
      if (triggerOnlineSync) {
        // Re-trigger sync and subscription
        _syncAndSubscribeOnline(
            currentState.machineCode, currentState.macAddress);
      }
    }
  }

  void _cleanupSubscription() {
    final sub = _realtimeSubscription;
    if (sub != null) {
      Supabase.instance.client.removeChannel(sub);
      _realtimeSubscription = null;
    }
  }

  @override
  void dispose() {
    _cleanupSubscription();
    super.dispose();
  }
}

final licenseProvider =
    StateNotifierProvider<LicenseNotifier, AsyncValue<LicenseState>>((ref) {
  return LicenseNotifier();
});
