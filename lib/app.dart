import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motostock_pro/core/database/app_database.dart';
import 'package:motostock_pro/core/router/app_router.dart';
import 'package:motostock_pro/core/theme/app_theme.dart';
import 'package:motostock_pro/core/services/supabase_sync_service.dart';

// ─── Database Provider ─────────────────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ─── Sync Service Provider ─────────────────────────────────────────────────
final syncServiceProvider = Provider<SupabaseSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = SupabaseSyncService(db);
  service.startSync();
  ref.onDispose(service.stopSync);
  return service;
});

// ─── Theme Provider ────────────────────────────────────────────────────────
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class MotoStockApp extends ConsumerWidget {
  const MotoStockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _MotoStockAppShell();
  }
}

class _MotoStockAppShell extends ConsumerWidget {
  const _MotoStockAppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly initialize the background sync service loop
    ref.watch(syncServiceProvider);
    
    // Force light theme only
    const themeMode = ThemeMode.light;
    return MaterialApp.router(
      title: 'Motostock',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
    );
  }
}
