import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drift/drift.dart' show Value;
import 'package:motostock_pro/shared/widgets/empty_state.dart';
import 'package:motostock_pro/shared/widgets/confirm_dialog.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';
import 'package:motostock_pro/core/utils/validators.dart';
import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/core/database/app_database.dart';
import 'package:motostock_pro/features/pieces/providers/pieces_provider.dart';

class FournisseursScreen extends ConsumerWidget {
  const FournisseursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _FournisseursContent();
  }
}

class _FournisseursContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fournAsync = ref.watch(fournisseursListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Fournisseurs',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w700)),
              Text('Gérez vos fournisseurs et partenaires',
                  style: TextStyle(color: textSecondary, fontSize: 13)),
            ]),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showFournisseurDialog(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nouveau fournisseur'),
            ),
          ]),
        ),
        Expanded(
            child: fournAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(
              child: Text('Erreur: $e',
                  style: const TextStyle(color: AppColors.danger))),
          data: (fournisseurs) {
            if (fournisseurs.isEmpty) {
              return const EmptyState(
                icon: FontAwesomeIcons.truck,
                title: 'Aucun fournisseur',
                subtitle:
                    'Ajoutez vos fournisseurs pour gérer vos approvisionnements',
              );
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 380,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.6,
                ),
                itemCount: fournisseurs.length,
                itemBuilder: (ctx, i) => _FournisseurCard(
                  fournisseur: fournisseurs[i],
                  isDark: isDark,
                  onEdit: () => _showFournisseurDialog(context, ref,
                      fournisseur: fournisseurs[i]),
                  onDelete: () =>
                      _deleteFournisseur(context, ref, fournisseurs[i]),
                ),
              ),
            );
          },
        )),
      ]),
    );
  }

  void _showFournisseurDialog(BuildContext context, WidgetRef ref,
      {Fournisseur? fournisseur}) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _FournisseurDialog(ref: ref, fournisseur: fournisseur),
    );
  }

  Future<void> _deleteFournisseur(
      BuildContext context, WidgetRef ref, Fournisseur f) async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Supprimer ce fournisseur ?',
      message: '${f.nom} sera supprimé définitivement.',
      confirmLabel: 'Supprimer',
      icon: FontAwesomeIcons.trash,
    );
    if (ok) {
      await ref.read(databaseProvider).deleteFournisseur(f.id);
      ref.invalidate(fournisseursListProvider);
    }
  }
}

class _FournisseurCard extends StatefulWidget {
  final Fournisseur fournisseur;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _FournisseurCard(
      {required this.fournisseur,
      required this.isDark,
      required this.onEdit,
      required this.onDelete});

  @override
  State<_FournisseurCard> createState() => _FournisseurCardState();
}

class _FournisseurCardState extends State<_FournisseurCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final surface =
        widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = widget.isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final f = widget.fournisseur;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _hovered ? AppColors.primary.withOpacity(0.5) : border),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: FaIcon(FontAwesomeIcons.truck,
                      color: AppColors.primary, size: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(f.nom,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16),
                onPressed: widget.onEdit,
                style:
                    IconButton.styleFrom(foregroundColor: AppColors.primary)),
            IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                onPressed: widget.onDelete,
                style: IconButton.styleFrom(foregroundColor: AppColors.danger)),
          ]),
          const SizedBox(height: 14),
          if (f.contact != null)
            _InfoRow(
                icon: Icons.person_outline_rounded,
                text: f.contact!,
                textSecondary: textSecondary),
          if (f.telephone != null)
            _InfoRow(
                icon: Icons.phone_outlined,
                text: f.telephone!,
                textSecondary: textSecondary),
          if (f.email != null)
            _InfoRow(
                icon: Icons.email_outlined,
                text: f.email!,
                textSecondary: textSecondary),
          const Spacer(),
          if (f.delaiLivraisonMoyen != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Délai: ${f.delaiLivraisonMoyen} jours',
                  style: const TextStyle(
                      color: AppColors.info,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color textSecondary;
  const _InfoRow(
      {required this.icon, required this.text, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 14, color: textSecondary),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(color: textSecondary, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

class _FournisseurDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final Fournisseur? fournisseur;
  const _FournisseurDialog({required this.ref, this.fournisseur});

  @override
  ConsumerState<_FournisseurDialog> createState() => _FournisseurDialogState();
}

class _FournisseurDialogState extends ConsumerState<_FournisseurDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _delaiCtrl = TextEditingController();
  bool _loading = false;

  bool get _isEdit => widget.fournisseur != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final f = widget.fournisseur!;
      _nomCtrl.text = f.nom;
      _contactCtrl.text = f.contact ?? '';
      _emailCtrl.text = f.email ?? '';
      _telCtrl.text = f.telephone ?? '';
      _adresseCtrl.text = f.adresse ?? '';
      _conditionsCtrl.text = f.conditionsPaiement ?? '';
      _delaiCtrl.text = f.delaiLivraisonMoyen?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _adresseCtrl.dispose();
    _conditionsCtrl.dispose();
    _delaiCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final db = ref.read(databaseProvider);
      if (_isEdit) {
        await db.updateFournisseur(widget.fournisseur!.copyWith(
          nom: _nomCtrl.text.trim(),
          contact: Value(_contactCtrl.text.trim().isEmpty
              ? null
              : _contactCtrl.text.trim()),
          email: Value(
              _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim()),
          telephone:
              Value(_telCtrl.text.trim().isEmpty ? null : _telCtrl.text.trim()),
          adresse: Value(_adresseCtrl.text.trim().isEmpty
              ? null
              : _adresseCtrl.text.trim()),
          conditionsPaiement: Value(_conditionsCtrl.text.trim().isEmpty
              ? null
              : _conditionsCtrl.text.trim()),
          delaiLivraisonMoyen: Value(int.tryParse(_delaiCtrl.text)),
        ));
      } else {
        await db.insertFournisseur(FournisseursCompanion.insert(
          nom: _nomCtrl.text.trim(),
          contact: Value(_contactCtrl.text.trim().isEmpty
              ? null
              : _contactCtrl.text.trim()),
          email: Value(
              _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim()),
          telephone:
              Value(_telCtrl.text.trim().isEmpty ? null : _telCtrl.text.trim()),
          adresse: Value(_adresseCtrl.text.trim().isEmpty
              ? null
              : _adresseCtrl.text.trim()),
          conditionsPaiement: Value(_conditionsCtrl.text.trim().isEmpty
              ? null
              : _conditionsCtrl.text.trim()),
          delaiLivraisonMoyen: Value(int.tryParse(_delaiCtrl.text)),
        ));
      }
      ref.invalidate(fournisseursListProvider);
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

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
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
                Text(
                    _isEdit ? 'Modifier le fournisseur' : 'Nouveau fournisseur',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _nomCtrl,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (v) => AppValidators.required(v, 'Le nom')),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                          controller: _contactCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Contact'))),
                  const SizedBox(width: 14),
                  Expanded(
                      child: TextFormField(
                          controller: _telCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Téléphone'),
                          validator: AppValidators.phone)),
                ]),
                const SizedBox(height: 14),
                TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: AppValidators.email),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                          controller: _conditionsCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Conditions paiement',
                              hintText: 'ex: 30 jours'))),
                  const SizedBox(width: 14),
                  Expanded(
                      child: TextFormField(
                          controller: _delaiCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Délai livraison (jours)'))),
                ]),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('Annuler'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: _loading ? null : _save,
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text(_isEdit ? 'Enregistrer' : 'Créer'))),
                ]),
              ]),
        ),
      ),
    );
  }
}
