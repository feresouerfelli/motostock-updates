import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motostock_pro/features/license/providers/license_provider.dart';
import 'package:motostock_pro/shared/widgets/app_sidebar.dart';
import 'package:motostock_pro/features/dashboard/dashboard_screen.dart';
import 'package:motostock_pro/features/pieces/pieces_screen.dart';
import 'package:motostock_pro/features/pieces/piece_form_screen.dart';
import 'package:motostock_pro/features/caisse/caisse_screen.dart';
import 'package:motostock_pro/features/rapports/rapports_screen.dart';
import 'package:motostock_pro/features/license/activation_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final licenseState = ref.watch(licenseProvider).valueOrNull;

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isActivating = state.uri.path == '/activation';

      if (licenseState != null && !licenseState.isActivated && !isActivating) {
        return '/activation';
      }

      if (licenseState?.isActivated == true && isActivating) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/activation',
        builder: (context, state) => const ActivationScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppSidebar(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/pieces',
            builder: (context, state) => const PiecesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const PieceFormScreen(),
              ),
              GoRoute(
                path: 'new',
                builder: (context, state) => const PieceFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final idString = state.pathParameters['id'];
                  final id = idString != null ? int.tryParse(idString) : null;
                  return PieceFormScreen(pieceId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/caisse',
            builder: (context, state) => const CaisseScreen(),
          ),
          GoRoute(
            path: '/rapports',
            builder: (context, state) => const RapportsScreen(),
          ),
        ],
      ),
    ],
  );
});
