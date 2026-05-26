import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { admin, cashier, none }

class AppUser {
  final String id;
  final String email;
  final UserRole role;

  const AppUser({required this.id, required this.email, required this.role});
}

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier() : super(null);

  bool _restored = false;
  bool get isRestored => _restored;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('auth_email');
    final roleName = prefs.getString('auth_role');
    final id = prefs.getString('auth_id');
    if (email != null && roleName != null && id != null) {
      final role = UserRole.values.firstWhere(
        (r) => r.name == roleName,
        orElse: () => UserRole.none,
      );
      if (role != UserRole.none) {
        state = AppUser(id: id, email: email, role: role);
      }
    }
    _restored = true;
  }

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final normalized = email.trim().toLowerCase();
    AppUser? user;

    if (normalized == 'admin@motostock.com' && password == 'admin') {
      user = const AppUser(
          id: '1', email: 'admin@motostock.com', role: UserRole.admin);
    } else if (normalized == 'caisse@motostock.com' && password == 'caisse') {
      user = const AppUser(
          id: '2', email: 'caisse@motostock.com', role: UserRole.cashier);
    } else {
      throw Exception(
        'Identifiants invalides. Utilisez admin@motostock.com / admin ou caisse@motostock.com / caisse',
      );
    }

    state = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_email', user.email);
    await prefs.setString('auth_role', user.role.name);
    await prefs.setString('auth_id', user.id);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_email');
    await prefs.remove('auth_role');
    await prefs.remove('auth_id');
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier();
});

final authRestoreProvider = FutureProvider<void>((ref) async {
  await ref.read(authProvider.notifier).restoreSession();
});
