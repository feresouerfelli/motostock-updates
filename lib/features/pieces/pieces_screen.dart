import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:motostock_pro/shared/widgets/stock_badge.dart';
import 'package:motostock_pro/shared/widgets/empty_state.dart';
import 'package:motostock_pro/shared/widgets/data_table_widget.dart';
import 'package:motostock_pro/shared/widgets/confirm_dialog.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';
import 'package:motostock_pro/core/utils/formatters.dart';
import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/core/database/app_database.dart';
import 'package:motostock_pro/features/auth/providers/auth_provider.dart';
import 'package:motostock_pro/features/pieces/providers/pieces_provider.dart';

class PiecesScreen extends ConsumerWidget {
  const PiecesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PiecesContent();
  }
}

class _PiecesContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final filter = ref.watch(piecesFilterProvider);
    final piecesAsync = ref.watch(piecesListProvider);
    final catsAsync = ref.watch(categoriesProvider);
    ref.watch(fournisseursListProvider); // Keep fournisseurs loaded
    final viewMode = ref.watch(piecesViewModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ─── Top Bar ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Catalogue de Pièces',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 26,
                                fontWeight: FontWeight.w700)),
                        Text(
                            'Gérez votre inventaire de pièces et périphériques',
                            style:
                                TextStyle(color: textSecondary, fontSize: 13)),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/pieces/add'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Nouvelle pièce'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Filters row
                Row(
                  children: [
                    // Search
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText:
                              'Rechercher par référence, nom, description...',
                          prefixIcon: Icon(Icons.search_rounded, size: 18),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onChanged: (v) => ref
                            .read(piecesFilterProvider.notifier)
                            .state = filter.copyWith(searchQuery: v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Categorie filter
                    Expanded(
                      child: catsAsync.when(
                        data: (cats) => DropdownButtonFormField<String>(
                          initialValue: filter.categorie,
                          hint: const Text('Catégorie'),
                          decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12)),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('Toutes')),
                            ...cats.map((c) =>
                                DropdownMenuItem(value: c, child: Text(c))),
                          ],
                          onChanged: (v) =>
                              ref.read(piecesFilterProvider.notifier).state =
                                  v == null
                                      ? filter.copyWith(clearCategorie: true)
                                      : filter.copyWith(categorie: v),
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Stock filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: filter.stockFilter,
                        decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12)),
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('Tout le stock')),
                          DropdownMenuItem(
                              value: 'ok', child: Text('En stock')),
                          DropdownMenuItem(
                              value: 'low', child: Text('Stock faible')),
                          DropdownMenuItem(value: 'out', child: Text('Épuisé')),
                        ],
                        onChanged: (v) => ref
                            .read(piecesFilterProvider.notifier)
                            .state = filter.copyWith(stockFilter: v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // View mode toggle
                    Container(
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          _ViewModeButton(
                            icon: Icons.view_list_rounded,
                            active: viewMode == PiecesViewMode.list,
                            onTap: () => ref
                                .read(piecesViewModeProvider.notifier)
                                .state = PiecesViewMode.list,
                          ),
                          _ViewModeButton(
                            icon: Icons.grid_view_rounded,
                            active: viewMode == PiecesViewMode.grid,
                            onTap: () => ref
                                .read(piecesViewModeProvider.notifier)
                                .state = PiecesViewMode.grid,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // ─── Content ──────────────────────────────────────────
          Expanded(
            child: piecesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(
                  child: Text('Erreur: $e',
                      style: const TextStyle(color: AppColors.danger))),
              data: (pieces) {
                if (pieces.isEmpty) {
                  return EmptyState(
                    icon: FontAwesomeIcons.gears,
                    title: 'Aucune pièce trouvée',
                    subtitle: filter.searchQuery.isNotEmpty
                        ? 'Aucun résultat pour "${filter.searchQuery}"'
                        : 'Commencez par ajouter vos premières pièces',
                    actionLabel: 'Ajouter une pièce',
                    onAction: () => context.go('/pieces/add'),
                  );
                }
                if (viewMode == PiecesViewMode.grid) {
                  return _PiecesGrid(pieces: pieces, ref: ref);
                }
                return _PiecesTable(pieces: pieces, ref: ref);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PiecesTable extends ConsumerWidget {
  final List<Piece> pieces;
  final WidgetRef ref;
  const _PiecesTable({required this.pieces, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final authState = widgetRef.watch(authProvider);
    final isCashier = authState?.role == UserRole.cashier;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: AppDataTable<Piece>(
        columns: [
          const DataColumn(label: Text('Référence')),
          const DataColumn(label: Text('Nom')),
          const DataColumn(label: Text('Catégorie')),
          const DataColumn(label: Text('Stock')),
          if (!isCashier)
            const DataColumn(label: Text('Prix Achat'), numeric: true),
          const DataColumn(label: Text('Prix Vente'), numeric: true),
          const DataColumn(label: Text('Emplacement')),
          const DataColumn(label: Text('Actions')),
        ],
        rows: pieces,
        emptyMessage: 'Aucune pièce',
        rowBuilder: (p, _) => DataRow(cells: [
          DataCell(Text(p.reference,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12))),
          DataCell(Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.nom,
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              if (p.description != null)
                Text(p.description!,
                    style: TextStyle(color: textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
            ],
          )),
          DataCell(_CategoryChip(categorie: p.categorie)),
          DataCell(StockBadge(
              quantity: p.quantiteEnStock, minQuantity: p.quantiteMinimale)),
          if (!isCashier)
            DataCell(Text(AppFormatters.formatCurrency(p.prixAchat),
                style: TextStyle(color: textColor, fontSize: 13))),
          DataCell(Text(AppFormatters.formatCurrency(p.prixVente),
              style: TextStyle(color: textColor, fontSize: 13))),
          DataCell(Text(p.emplacement ?? '—',
              style: TextStyle(color: textSecondary, fontSize: 13))),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCashier)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  onPressed: () => context.go('/pieces/edit/${p.id}'),
                  tooltip: 'Modifier',
                  style:
                      IconButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              if (!isCashier)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  onPressed: () => _deletePiece(context, widgetRef, p),
                  tooltip: 'Supprimer',
                  style:
                      IconButton.styleFrom(foregroundColor: AppColors.danger),
                ),
            ],
          )),
        ]),
      ),
    );
  }

  Future<void> _deletePiece(
      BuildContext context, WidgetRef ref, Piece p) async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Supprimer cette pièce ?',
      message:
          'La pièce "${p.nom}" (${p.reference}) sera supprimée définitivement.',
      confirmLabel: 'Supprimer',
      icon: FontAwesomeIcons.trash,
    );
    if (ok && context.mounted) {
      try {
        await ref.read(databaseProvider).deletePiece(p.id);
        ref.invalidate(piecesListProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La pièce "${p.nom}" a été supprimée avec succès.'),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible de supprimer la pièce : $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }
}

class _PiecesGrid extends ConsumerWidget {
  final List<Piece> pieces;
  final WidgetRef ref;
  const _PiecesGrid({required this.pieces, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemCount: pieces.length,
        itemBuilder: (ctx, i) => _PieceCard(piece: pieces[i], ref: widgetRef),
      ),
    );
  }
}

class _PieceCard extends ConsumerWidget {
  final Piece piece;
  final WidgetRef ref;
  const _PieceCard({required this.piece, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Center(
              child: FaIcon(FontAwesomeIcons.gears,
                  color: AppColors.primary.withOpacity(0.4), size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(piece.reference,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(piece.nom,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                _CategoryChip(categorie: piece.categorie),
                const SizedBox(height: 8),
                StockBadge(
                    quantity: piece.quantiteEnStock,
                    minQuantity: piece.quantiteMinimale),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(AppFormatters.formatCurrency(piece.prixVente),
                          style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ),
                    if (widgetRef.watch(authProvider)?.role != UserRole.cashier)
                      InkWell(
                        onTap: () => context.go('/pieces/edit/${piece.id}'),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.edit_outlined,
                              size: 16, color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String categorie;
  const _CategoryChip({required this.categorie});

  Color _categoryColor(String cat) {
    final map = {
      'Freinage': const Color(0xFFFF4757),
      'Transmission': const Color(0xFFFFBE33),
      'Électrique': const Color(0xFF3D8BFF),
      'Carrosserie': const Color(0xFFAA56FF),
      'Moteur': const Color(0xFFFF6B35),
    };
    return map[cat] ?? AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(categorie);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(categorie,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ViewModeButton(
      {required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon,
            size: 18,
            color: active ? Colors.white : AppColors.darkTextSecondary),
      ),
    );
  }
}
