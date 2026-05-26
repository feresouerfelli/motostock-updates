import 'dart:io';

import 'package:csv/csv.dart' as csv;
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';
import 'package:motostock_pro/core/utils/formatters.dart';
import 'package:motostock_pro/features/rapports/providers/sales_report_provider.dart';

class RapportsScreen extends ConsumerWidget {
  const RapportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final salesAsync = ref.watch(salesReportProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: salesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Text(
            'Erreur fin journée: $e',
            style: const TextStyle(color: AppColors.danger),
          ),
          data: (report) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fin journée',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        AppFormatters.formatDate(DateTime.now()),
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _exportSalesCsv(context, report),
                    icon: const FaIcon(FontAwesomeIcons.fileExport, size: 13),
                    label: const Text('Exporter CSV'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisExtent: 120,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                children: [
                  _DailyCard(
                    title: 'Nombre ventes',
                    value: '${report.salesToday}',
                    icon: FontAwesomeIcons.receipt,
                    color: AppColors.primary,
                    surface: surface,
                    border: border,
                    textColor: textColor,
                    textSecondary: textSecondary,
                  ),
                  _DailyCard(
                    title: 'Chiffre d\'affaires',
                    value: AppFormatters.formatCurrency(report.revenueToday),
                    icon: FontAwesomeIcons.cashRegister,
                    color: AppColors.secondary,
                    surface: surface,
                    border: border,
                    textColor: textColor,
                    textSecondary: textSecondary,
                  ),
                  _DailyCard(
                    title: 'Remises',
                    value: AppFormatters.formatCurrency(report.discountsToday),
                    icon: FontAwesomeIcons.percent,
                    color: AppColors.warning,
                    surface: surface,
                    border: border,
                    textColor: textColor,
                    textSecondary: textSecondary,
                  ),
                  _DailyCard(
                    title: 'Bénéfice estimé',
                    value: AppFormatters.formatCurrency(report.profitToday),
                    icon: FontAwesomeIcons.sackDollar,
                    color: AppColors.success,
                    surface: surface,
                    border: border,
                    textColor: textColor,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ventes enregistrées',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (report.recentSales.isEmpty)
                      Text('Aucune vente aujourd\'hui',
                          style: TextStyle(color: textSecondary, fontSize: 13))
                    else
                      ...report.recentSales
                          .where((s) {
                            final now = DateTime.now();
                            final start =
                                DateTime(now.year, now.month, now.day);
                            return !s.date.isBefore(start);
                          })
                          .take(20)
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.receipt_long_rounded,
                                      size: 18, color: AppColors.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Vente #${s.txId} - ${AppFormatters.formatDateTime(s.date)}',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    AppFormatters.formatCurrency(s.total),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportSalesCsv(BuildContext context, SalesReport report) async {
    try {
      final rows = <List<dynamic>>[
        [
          'Référence vente',
          'Date',
          'Total (DT)',
          'Remise (DT)',
          'Bénéfice (DT)',
          'Articles'
        ],
        ...report.recentSales.map((s) => [
              s.txId,
              AppFormatters.formatDateTime(s.date),
              s.total.toStringAsFixed(3),
              s.discount.toStringAsFixed(3),
              s.profit.toStringAsFixed(3),
              s.itemCount,
            ]),
      ];
      final csvData =
          const csv.ListToCsvConverter(fieldDelimiter: ';').convert(rows);
      final path = await fp.FilePicker.saveFile(
        dialogTitle: 'Enregistrer fin journée',
        fileName: 'fin_journee_motostock.csv',
        type: fp.FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (path != null) {
        await File(path).writeAsString(csvData);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fin journée enregistrée: $path'),
              backgroundColor: AppColors.secondary,
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur export: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

class _DailyCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color surface;
  final Color border;
  final Color textColor;
  final Color textSecondary;

  const _DailyCard({
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
