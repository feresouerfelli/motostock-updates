import 'package:flutter/material.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';

class AppDataTable<T> extends StatefulWidget {
  final List<DataColumn> columns;
  final List<T> rows;
  final DataRow Function(T item, int index) rowBuilder;
  final int rowsPerPage;
  final bool selectable;
  final String? emptyMessage;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowBuilder,
    this.rowsPerPage = 15,
    this.selectable = false,
    this.emptyMessage,
  });

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  int _currentPage = 0;
  final int _sortColumnIndex = 0;
  final bool _sortAscending = true;

  int get _totalPages =>
      (widget.rows.length / widget.rowsPerPage).ceil().clamp(1, 999999);

  List<T> get _currentRows {
    final start = _currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, widget.rows.length);
    if (start >= widget.rows.length) return [];
    return widget.rows.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final headerBg = isDark ? const Color(0xFF13151F) : const Color(0xFFF5F7FF);
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (widget.rows.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Text(
            widget.emptyMessage ?? 'Aucune donnée',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(headerBg),
                dataRowColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return AppColors.primary.withOpacity(0.04);
                  }
                  return Colors.transparent;
                }),
                border: TableBorder(
                  horizontalInside: BorderSide(color: border, width: 0.5),
                ),
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                headingTextStyle: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                dataTextStyle: TextStyle(color: textColor, fontSize: 13),
                columnSpacing: 24,
                horizontalMargin: 20,
                columns: widget.columns,
                rows: _currentRows
                    .asMap()
                    .entries
                    .map((e) => widget.rowBuilder(e.value, e.key))
                    .toList(),
              ),
            ),
          ),
          // Pagination
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Text(
                  '${widget.rows.length} résultat${widget.rows.length > 1 ? 's' : ''}  •  Page ${_currentPage + 1} / $_totalPages',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
                const Spacer(),
                _PaginationButton(
                  icon: Icons.first_page_rounded,
                  enabled: _currentPage > 0,
                  onTap: () => setState(() => _currentPage = 0),
                  isDark: isDark,
                ),
                const SizedBox(width: 4),
                _PaginationButton(
                  icon: Icons.chevron_left_rounded,
                  enabled: _currentPage > 0,
                  onTap: () => setState(() => _currentPage--),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                ...List.generate(_totalPages.clamp(0, 5), (i) {
                  final page = (_currentPage - 2 + i).clamp(0, _totalPages - 1);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => setState(() => _currentPage = page),
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: page == _currentPage
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${page + 1}',
                            style: TextStyle(
                              color: page == _currentPage
                                  ? Colors.white
                                  : textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                _PaginationButton(
                  icon: Icons.chevron_right_rounded,
                  enabled: _currentPage < _totalPages - 1,
                  onTap: () => setState(() => _currentPage++),
                  isDark: isDark,
                ),
                const SizedBox(width: 4),
                _PaginationButton(
                  icon: Icons.last_page_rounded,
                  enabled: _currentPage < _totalPages - 1,
                  onTap: () => setState(() => _currentPage = _totalPages - 1),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool isDark;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon,
            size: 18, color: enabled ? color : color.withOpacity(0.3)),
      ),
    );
  }
}
