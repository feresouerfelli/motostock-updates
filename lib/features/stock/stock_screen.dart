import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motostock_pro/shared/widgets/empty_state.dart';
import 'package:motostock_pro/shared/widgets/confirm_dialog.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';
import 'package:motostock_pro/core/utils/formatters.dart';
import 'package:motostock_pro/core/utils/validators.dart';

import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/core/database/app_database.dart';
import 'package:motostock_pro/features/auth/providers/auth_provider.dart';
import 'package:motostock_pro/features/dashboard/providers/dashboard_provider.dart';
import 'package:motostock_pro/features/pieces/providers/pieces_provider.dart';

final _mouvementsProvider = StreamProvider<List<MouvementStock>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecentMouvements(limit: 100);
});

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StockContent();
  }
}

class _StockContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final mouvAsync = ref.watch(_mouvementsProvider);
    final piecesMapAsync = ref.watch(allPiecesMapProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Gestion des Stocks',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w700)),
              Text('Entrées, sorties et ajustements d\'inventaire',
                  style: TextStyle(color: textSecondary, fontSize: 13)),
              // TODO: Display profit (bénéfice) here
            ]),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showMouvementDialog(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nouveau mouvement'),
            ),
          ]),
        ),
        Expanded(
          child: mouvAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Center(
                child: Text('Erreur: $e',
                    style: const TextStyle(color: AppColors.danger))),
            data: (mouvements) => piecesMapAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, __) => const SizedBox(),
              data: (piecesMap) {
                if (mouvements.isEmpty) {
                  return const EmptyState(
                    icon: FontAwesomeIcons.boxesStacked,
                    title: 'Aucun mouvement de stock',
                    subtitle:
                        'Les entrées et sorties de stock apparaîtront ici',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  itemCount: mouvements.length,
                  itemBuilder: (ctx, i) {
                    final m = mouvements[i];
                    final piece = piecesMap[m.pieceId];
                    return _MouvementTile(
                        mouvement: m, piece: piece, isDark: isDark);
                  },
                );
              },
            ),
          ),
        ),
      ]),
    );
  }

  void _showMouvementDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _MouvementDialog(ref: ref),
    );
  }
}

class _MouvementTile extends ConsumerWidget {
  final MouvementStock mouvement;
  final Piece? piece;
  final bool isDark;
  const _MouvementTile(
      {required this.mouvement, required this.piece, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final isEntree = mouvement.type == 'entree';
    final isAjust = mouvement.type == 'ajustement';
    final color = isAjust
        ? AppColors.warning
        : (isEntree ? AppColors.secondary : AppColors.danger);
    final icon = isAjust
        ? Icons.tune_rounded
        : (isEntree ? Icons.add_rounded : Icons.remove_rounded);
    final label = isAjust ? 'Ajustement' : (isEntree ? 'Entrée' : 'Sortie');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(piece?.nom ?? 'Pièce #${mouvement.pieceId}',
              style: TextStyle(
                  color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Row(children: [
            _TypeBadge(label: label, color: color),
            if (mouvement.motif != null) ...[
              const SizedBox(width: 8),
              Expanded(
                  child: Text(mouvement.motif!,
                      style: TextStyle(color: textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
            ],
          ]),
        ])),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${isEntree ? '+' : (isAjust ? '=' : '-')}${mouvement.quantite}',
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w700)),
          Text(AppFormatters.formatDateTime(mouvement.date),
              style: TextStyle(color: textSecondary, fontSize: 11)),
        ]),
        const SizedBox(width: 8),
        if (ref.watch(authProvider)?.role != UserRole.cashier)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: AppColors.danger.withOpacity(0.7),
            tooltip: 'Supprimer ce mouvement',
            onPressed: () async {
              final ok = await ConfirmDialog.show(
                context,
                title: 'Supprimer ce mouvement ?',
                message:
                    'Voulez-vous vraiment supprimer et annuler ce mouvement ? Cela ajustera automatiquement la quantité en stock de la pièce.',
                confirmLabel: 'Confirmer',
                icon: FontAwesomeIcons.trash,
              );
              if (ok == true) {
                final currentPiece = piece;
                if (mouvement.type == 'sortie' && currentPiece != null) {
                  final budget = ref.read(budgetValidatorProvider);
                  final canAdd = await budget.canAdd(
                      newPrice: currentPiece.prixAchat,
                      newQty: mouvement.quantite);
                  if (!canAdd) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Action impossible: l\'annulation de cette sortie dépasserait le budget de 200 DT.'),
                        backgroundColor: AppColors.danger,
                      ));
                    }
                    return;
                  }
                }
                await ref.read(databaseProvider).deleteMouvement(mouvement.id);
                ref.invalidate(piecesListProvider);
                ref.invalidate(allPiecesMapProvider);
              }
            },
          ),
      ]),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _MouvementDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _MouvementDialog({required this.ref});

  @override
  ConsumerState<_MouvementDialog> createState() => _MouvementDialogState();
}

class _MouvementDialogState extends ConsumerState<_MouvementDialog> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'entree';
  int? _selectedPieceId;
  final _qtyCtrl = TextEditingController(text: '1');
  final _motifCtrl = TextEditingController();
  bool _loading = false;

  double? _selectedPrice;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _motifCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPieceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez sélectionner une pièce'),
          backgroundColor: AppColors.warning));
      return;
    }
    setState(() => _loading = true);
    try {
      final db = ref.read(databaseProvider);
      final validator = ref.read(budgetValidatorProvider);
      final canAdd = await validator.canAdd(
          newPrice: _selectedPrice ?? 0,
          newQty: int.tryParse(_qtyCtrl.text) ?? 1);
      if (!canAdd) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Budget dépassé : le total dépasserait 200 DT'),
            backgroundColor: AppColors.danger));
        return;
      }
      final motif =
          _motifCtrl.text.trim().isEmpty ? null : _motifCtrl.text.trim();
      final qty = int.tryParse(_qtyCtrl.text) ?? 1;

      if (_type == 'entree') {
        await db.addStock(_selectedPieceId!, qty, motif);
      } else if (_type == 'sortie') {
        await db.removeStock(_selectedPieceId!, qty, motif);
      } else {
        // ajustement (par exemple on met la valeur exacte)
        // Pour l'instant on traite comme entrée si positif, sortie si négatif
        // mais le plus simple est d'utiliser add/remove stock
        await db.addStock(_selectedPieceId!, qty, motif);
      }

      ref.invalidate(piecesListProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur: $e'), backgroundColor: AppColors.danger));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final piecesAsync = ref.watch(piecesListProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border)),
        child: Form(
          key: _formKey,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nouveau mouvement de stock',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                // Type selector
                Row(children: [
                  _TypeButton(
                      label: 'Entrée',
                      type: 'entree',
                      selected: _type,
                      color: AppColors.secondary,
                      icon: Icons.add_rounded,
                      onTap: () => setState(() => _type = 'entree')),
                  const SizedBox(width: 10),
                  _TypeButton(
                      label: 'Sortie',
                      type: 'sortie',
                      selected: _type,
                      color: AppColors.danger,
                      icon: Icons.remove_rounded,
                      onTap: () => setState(() => _type = 'sortie')),
                  const SizedBox(width: 10),
                  _TypeButton(
                      label: 'Ajustement',
                      type: 'ajustement',
                      selected: _type,
                      color: AppColors.warning,
                      icon: Icons.tune_rounded,
                      onTap: () => setState(() => _type = 'ajustement')),
                ]),
                const SizedBox(height: 16),
                piecesAsync.when(
                  loading: () =>
                      const CircularProgressIndicator(color: AppColors.primary),
                  error: (_, __) => const SizedBox(),
                  data: (pieces) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: _selectedPieceId,
                        decoration: const InputDecoration(
                            labelText: 'Pièce sélectionnée *'),
                        hint: const Text('Ou sélectionnez manuellement'),
                        items: pieces
                            .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.reference} — ${p.nom}',
                                    overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedPieceId = v;
                          if (v != null) {
                            final p = pieces.firstWhere((p) => p.id == v);
                            _selectedPrice = p.prixAchat;
                          }
                        }),
                        validator: (v) => v == null ? 'Pièce requise' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantité *'),
                  validator: (v) =>
                      AppValidators.positiveInteger(v, 'La quantité'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _motifCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Motif',
                      hintText: 'ex: Vente client, Réception commande...'),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Annuler'),
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Enregistrer'),
                  )),
                ]),
              ]),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label, type, selected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _TypeButton(
      {required this.label,
      required this.type,
      required this.selected,
      required this.color,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = type == selected;
    return Expanded(
        child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: isSelected ? color : Colors.grey, size: 18),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    ));
  }
}
