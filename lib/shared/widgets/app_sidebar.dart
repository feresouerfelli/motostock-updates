import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';
import 'package:motostock_pro/features/alerts/providers/alerts_provider.dart';
import 'package:motostock_pro/features/pieces/providers/pieces_provider.dart';
import 'package:motostock_pro/core/services/update_service.dart';
import 'package:motostock_pro/core/providers/pending_command_provider.dart';

class AppSidebar extends ConsumerStatefulWidget {
  final Widget child;
  const AppSidebar({super.key, required this.child});

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  static const _navItems = [
    _NavItem(
        path: '/dashboard', icon: FontAwesomeIcons.house, label: 'Accueil'),
    _NavItem(
        path: '/caisse', icon: FontAwesomeIcons.cashRegister, label: 'Vente'),
    _NavItem(
        path: '/pieces',
        icon: FontAwesomeIcons.boxesStacked,
        label: 'Articles'),
    _NavItem(
        path: '/rapports',
        icon: FontAwesomeIcons.fileInvoiceDollar,
        label: 'Fin journée'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
// themeMode provider removed, app forced to light mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        // ─── Custom Title Bar ──────────────────────────────────
        _TitleBar(
          isDark: isDark,
          isMaximized: _isMaximized,
          onMaximize: () async {
            if (kIsWeb) return;
            if (_isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
        // ─── Body ─────────────────────────────────────────────
        Expanded(
          child: Row(
            children: [
              // ─── Sidebar ──────────────────────────────────────
              Material(
                color: surface,
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: border),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Logo
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(FontAwesomeIcons.motorcycle,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Motostock',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    )),
                                const Text('Gestion simple',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(color: border, height: 1),
                      ),
                      const SizedBox(height: 8),
                      // Nav items
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          children: _navItems.map((item) {
                            final isActive = item.path == '/'
                                ? location == '/'
                                : location.startsWith(item.path);
                            return _SidebarItem(
                              item: item,
                              isActive: isActive,
                              isDark: isDark,
                              onTap: () => context.go(item.path),
                            );
                          }).toList(),
                        ),
                      ),
                      // Bottom: theme toggle + version + updates
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Divider(color: border, height: 1),
                            const SizedBox(height: 10),
                            // Licence Active Badge (Perceived value 200 DT)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF2E7D32).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF2E7D32)
                                        .withOpacity(0.2)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified_rounded,
                                      color: Color(0xFF4CAF50), size: 13),
                                  SizedBox(width: 6),
                                  Text(
                                    'Licence Active (200 DT)',
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text('v${AppConfig.appVersion}',
                                        style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 11,
                                        )),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        final svc = ref.read(updateServiceProvider);
                                        final updated = await svc.checkForUpdates();
                                        if (!updated) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Aucune mise à jour disponible.')),
                                          );
                                        }
                                      },
                                      child: Icon(Icons.system_update, size: 14, color: textSecondary),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (!kIsWeb) ...[
                                  const SizedBox(width: 6),
                                  Tooltip(
                                    message: 'Fermer l\'application',
                                    child: InkWell(
                                      onTap: () async {
                                        await windowManager.close();
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          FontAwesomeIcons.powerOff,
                                          size: 14,
                                          color: AppColors.danger,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ─── Main Content ─────────────────────────────────
              Expanded(
                child: Material(
                  color: bg,
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool isDark;
  final int badgeCount;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.isDark,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primary;
    final activeBg = AppColors.primary.withOpacity(0.12);
    final hoverBg = widget.isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.black.withOpacity(0.04);
    final textColor = widget.isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? activeBg
                : _hovered
                    ? hoverBg
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isActive
                ? Border.all(color: activeColor.withOpacity(0.3))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 15,
                color: widget.isActive
                    ? activeColor
                    : _hovered
                        ? textColor
                        : textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    color: widget.isActive
                        ? activeColor
                        : _hovered
                            ? textColor
                            : textSecondary,
                    fontSize: 13,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (widget.badgeCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.badgeCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (widget.isActive)
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleBar extends ConsumerWidget {
  final bool isDark;
  final bool isMaximized;
  final VoidCallback onMaximize;

  const _TitleBar({
    required this.isDark,
    required this.isMaximized,
    required this.onMaximize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg = isDark ? const Color(0xFF0D0F1A) : const Color(0xFFEEF0F8);
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final lowStockAsync = ref.watch(lowStockPiecesProvider);

    return GestureDetector(
      onPanStart: (_) {
        if (!kIsWeb) windowManager.startDragging();
      },
      child: Material(
        color: bg,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: border)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 220), // align with sidebar width
              Expanded(
                child: Text(
                  'Motostock',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Alerts Bell
              lowStockAsync.when(
                data: (pieces) {
                  if (pieces.isEmpty) return const SizedBox();
                  return Tooltip(
                    message: '${pieces.length} pièces en stock faible',
                    child: InkWell(
                      onTap: () {
                        _showLowStockDialog(context, pieces);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.bell,
                              size: 14,
                              color: iconColor,
                            ),
                            Positioned(
                              top: 8,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.danger,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  pieces.length.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              // Window controls
              if (!kIsWeb) ...[
                _WindowButton(
                  icon: FontAwesomeIcons.windowMinimize,
                  color: iconColor,
                  onTap: () => windowManager.minimize(),
                ),
                _WindowButton(
                  icon: isMaximized
                      ? FontAwesomeIcons.windowRestore
                      : FontAwesomeIcons.windowMaximize,
                  color: iconColor,
                  onTap: onMaximize,
                ),
                _WindowButton(
                  icon: FontAwesomeIcons.xmark,
                  color: iconColor,
                  hoverColor: AppColors.danger,
                  onTap: () => windowManager.close(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLowStockDialog(BuildContext context, List<dynamic> pieces) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: Row(
            children: [
              const Icon(FontAwesomeIcons.triangleExclamation,
                  color: AppColors.danger, size: 20),
              const SizedBox(width: 10),
              Text('Alertes Stock (${pieces.length})',
                  style: const TextStyle(fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
              itemCount: pieces.length,
              itemBuilder: (context, index) {
                final piece = pieces[index];
                return ListTile(
                  leading: const Icon(FontAwesomeIcons.boxOpen, size: 16),
                  title: Text(piece.nom, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(piece.reference,
                      style: const TextStyle(fontSize: 12)),
                  trailing: Text(
                    '${piece.quantiteEnStock} / ${piece.quantiteMinimale}',
                    style: const TextStyle(
                        color: AppColors.danger, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/pieces/edit/${piece.id}');
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color? hoverColor;
  final VoidCallback onTap;

  const _WindowButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.hoverColor,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 46,
          height: 40,
          color: _hovered
              ? (widget.hoverColor ?? Colors.white.withOpacity(0.08))
              : Colors.transparent,
          child: Center(
            child: Icon(
              widget.icon,
              size: 11,
              color: _hovered
                  ? (widget.hoverColor != null ? Colors.white : widget.color)
                  : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final String label;
  const _NavItem({required this.path, required this.icon, required this.label});
}
