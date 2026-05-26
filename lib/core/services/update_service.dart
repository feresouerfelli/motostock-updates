import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/pending_command_provider.dart';

// ── Riverpod provider ──────────────────────────────────────────────────────
final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService(ref));

class UpdateService {
  final Ref _ref;
  UpdateService(this._ref);

  static const _latestJsonUrl =
      'https://raw.githubusercontent.com/feresouerfelli/motostock-updates/master/latest.json';

  // Returns true if an update was found and downloaded
  Future<UpdateResult> checkForUpdates() async {
    try {
      // 1. Get current local version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 2. Fetch remote latest.json
      final response = await http.get(Uri.parse(_latestJsonUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return UpdateResult.noUpdate;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final remoteVersion = data['version'] as String? ?? '';
      final downloadUrl   = data['exe_url']  as String? ?? '';

      if (remoteVersion.isEmpty || downloadUrl.isEmpty) return UpdateResult.noUpdate;

      // 3. Compare versions
      if (!_isNewer(remoteVersion, currentVersion)) return UpdateResult.noUpdate;

      // 4. Download installer
      final dlResponse = await http.get(Uri.parse(downloadUrl))
          .timeout(const Duration(minutes: 5));
      if (dlResponse.statusCode != 200) return UpdateResult.error;

      final dir = await getApplicationSupportDirectory();
      final filePath = '${dir.path}\\motostock_setup_$remoteVersion.exe';
      await File(filePath).writeAsBytes(dlResponse.bodyBytes);

      // 5. Store silent-install command in state
      _ref.read(pendingCommandProvider.notifier).state = '"$filePath" /VERYSILENT /SUPPRESSMSGBOXES';

      return UpdateResult.available;
    } catch (_) {
      return UpdateResult.error;
    }
  }

  bool _isNewer(String remote, String local) {
    final r = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final l = local.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (var i = 0; i < r.length; i++) {
      final rv = r[i];
      final lv = i < l.length ? l[i] : 0;
      if (rv > lv) return true;
      if (rv < lv) return false;
    }
    return false;
  }
}

enum UpdateResult { available, noUpdate, error }
