import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:motostock_pro/core/theme/app_colors.dart';
import 'package:motostock_pro/core/utils/formatters.dart';
import 'package:motostock_pro/features/pieces/providers/pieces_provider.dart';
import 'package:motostock_pro/features/rapports/providers/sales_report_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final piecesAsync = ref.watch(piecesListProvider);
    final salesAsync = ref.watch(salesReportProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Motostock',
              style: TextStyle(
                color: textColor,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Articles, vente, remise et fin journée',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            piecesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erreur stock: $e',
                  style: const TextStyle(color: AppColors.danger)),
              data: (pieces) {
                final stockValue = pieces.fold<double>(
                  0,
                  (sum, p) => sum + p.prixAchat * p.quantiteEnStock,
                );
                final lowStock = pieces
                    .where((p) => p.quantiteEnStock <= p.quantiteMinimale)
                    .length;
                return GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 260,
                        mainAxisExtent: 118,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      children: [
                        _MetricCard(
                          title: 'Articles',
                          value: '${pieces.length}',
                          icon: FontAwesomeIcons.boxesStacked,
                          color: AppColors.primary,
                          surface: surface,
                          border: border,
                          textColor: textColor,
                          textSecondary: textSecondary,
                        ),
                        _MetricCard(
                          title: 'Valeur achat',
                          value: AppFormatters.formatCurrency(stockValue),
                          icon: FontAwesomeIcons.sackDollar,
                          color: AppColors.secondary,
                          surface: surface,
                          border: border,
                          textColor: textColor,
                          textSecondary: textSecondary,
                        ),
                        _MetricCard(
                          title: 'Stock faible',
                          value: '$lowStock',
                          icon: FontAwesomeIcons.triangleExclamation,
                          color: lowStock == 0
                              ? AppColors.success
                              : AppColors.warning,
                          surface: surface,
                          border: border,
                          textColor: textColor,
                          textSecondary: textSecondary,
                        ),
                      ],
                    );
              },
            ),
            const SizedBox(height: 20),
            salesAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (report) => Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.today_rounded,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aujourd\'hui: ${report.salesToday} vente(s), CA ${AppFormatters.formatCurrency(report.revenueToday)}, bénéfice ${AppFormatters.formatCurrency(report.profitToday)}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionButton(
                  label: 'Nouvel article',
                  icon: FontAwesomeIcons.plus,
                  onTap: () => context.go('/pieces/add'),
                ),
                _ActionButton(
                  label: 'Faire une vente',
                  icon: FontAwesomeIcons.cashRegister,
                  onTap: () => context.go('/caisse'),
                ),
                _ActionButton(
                  label: 'Fin journée',
                  icon: FontAwesomeIcons.fileInvoiceDollar,
                  onTap: () => context.go('/rapports'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color surface;
  final Color border;
  final Color textColor;
  final Color textSecondary;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.surface,
    required this.border,
    required this.textColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const Spacer(),
          Text(title, style: TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: FaIcon(icon, size: 13),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
