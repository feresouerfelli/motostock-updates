import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drift/drift.dart' show Value;
import 'package:motostock_pro/shared/widgets/empty_state.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';
import 'package:motostock_pro/core/utils/formatters.dart';
import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/core/database/app_database.dart';
import 'package:motostock_pro/features/pieces/providers/pieces_provider.dart';

final _commandesProvider = StreamProvider<List<Commande>>((ref) {
  return ref.watch(databaseProvider).watchAllCommandes();
});

class CommandesScreen extends ConsumerWidget {
  const CommandesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CommandesContent();
  }
}

class _CommandesContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final commandesAsync = ref.watch(_commandesProvider);
    final fournAsync = ref.watch(fournisseursListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Commandes',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w700)),
              Text('Gérez vos commandes fournisseurs',
                  style: TextStyle(color: textSecondary, fontSize: 13)),
            ]),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showNewCommandeDialog(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nouvelle commande'),
            ),
          ]),
        ),
        Expanded(
            child: commandesAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(
              child: Text('Erreur: $e',
                  style: const TextStyle(color: AppColors.danger))),
          data: (commandes) {
            if (commandes.isEmpty) {
              return const EmptyState(
                icon: FontAwesomeIcons.clipboardList,
                title: 'Aucune commande',
                subtitle: 'Créez votre première commande fournisseur',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              itemCount: commandes.length,
              itemBuilder: (ctx, i) => fournAsync.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (fns) {
                  final fournisseur = fns
                      .where((f) => f.id == commandes[i].fournisseurId)
                      .firstOrNull;
                  return _CommandeCard(
                    commande: commandes[i],
                    fournisseur: fournisseur,
                    isDark: isDark,
                    surface: surface,
                    border: border,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    onReceive: () => _recevoir(context, ref, commandes[i]),
                  );
                },
              ),
            );
          },
        )),
      ]),
    );
  }

  Future<void> _recevoir(
      BuildContext context, WidgetRef ref, Commande c) async {
    if (c.statut == 'reçue') return;
    final db = ref.read(databaseProvider);
    await db.receptionnerCommande(c.id);
    ref.invalidate(piecesListProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Commande réceptionnée — Stock mis à jour'),
        backgroundColor: AppColors.secondary,
      ));
    }
  }

  void _showNewCommandeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _NewCommandeDialog(ref: ref),
    );
  }
}

class _CommandeCard extends StatelessWidget {
  final Commande commande;
  final Fournisseur? fournisseur;
  final bool isDark;
  final Color surface, border, textColor, textSecondary;
  final VoidCallback onReceive;

  const _CommandeCard({
    required this.commande,
    required this.fournisseur,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textColor,
    required this.textSecondary,
    required this.onReceive,
  });

  Color get _statutColor => switch (commande.statut) {
        'brouillon' => AppColors.warning,
        'envoyée' => AppColors.info,
        'reçue' => AppColors.secondary,
        _ => AppColors.darkTextSecondary,
      };

  IconData get _statutIcon => switch (commande.statut) {
        'brouillon' => Icons.edit_outlined,
        'envoyée' => Icons.send_outlined,
        'reçue' => Icons.check_circle_outline_rounded,
        _ => Icons.circle_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border)),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: _statutColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(_statutIcon, color: _statutColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Commande #${commande.id}',
                style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            _StatutBadge(statut: commande.statut, color: _statutColor),
          ]),
          const SizedBox(height: 4),
          Text(fournisseur?.nom ?? 'Fournisseur inconnu',
              style: TextStyle(color: textSecondary, fontSize: 13)),
          Text('Créée le ${AppFormatters.formatDate(commande.dateCreation)}',
              style: TextStyle(color: textSecondary, fontSize: 11)),
        ])),
        if (commande.statut != 'reçue')
          ElevatedButton.icon(
            onPressed: onReceive,
            icon: const Icon(Icons.check_rounded, size: 14),
            label: const Text('Réceptionner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
      ]),
    );
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;
  final Color color;
  const _StatutBadge({required this.statut, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Text(statut.toUpperCase(),
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}

class _NewCommandeDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _NewCommandeDialog({required this.ref});

  @override
  ConsumerState<_NewCommandeDialog> createState() => _NewCommandeDialogState();
}

class _NewCommandeDialogState extends ConsumerState<_NewCommandeDialog> {
  int? _selectedFournisseurId;
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedFournisseurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez sélectionner un fournisseur'),
          backgroundColor: AppColors.warning));
      return;
    }
    setState(() => _loading = true);
    try {
      final db = ref.read(databaseProvider);
      await db.insertCommande(CommandesCompanion.insert(
        fournisseurId: _selectedFournisseurId!,
        notes: Value(
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
      ));
      ref.invalidate(_commandesProvider);
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
    final fournAsync = ref.watch(fournisseursListProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border)),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nouvelle commande',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              fournAsync.when(
                loading: () =>
                    const CircularProgressIndicator(color: AppColors.primary),
                error: (_, __) => const SizedBox(),
                data: (fns) => DropdownButtonFormField<int>(
                  initialValue: _selectedFournisseurId,
                  decoration: const InputDecoration(labelText: 'Fournisseur *'),
                  hint: const Text('Sélectionner'),
                  items: fns
                      .map((f) =>
                          DropdownMenuItem(value: f.id, child: Text(f.nom)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedFournisseurId = v),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Instructions, références...'),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Annuler'))),
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
                            : const Text('Créer la commande'))),
              ]),
            ]),
      ),
    );
  }
}
