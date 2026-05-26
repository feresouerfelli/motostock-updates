import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart' as fp;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';
import 'package:motostock_pro/core/utils/validators.dart';
import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/core/database/app_database.dart';
import 'package:motostock_pro/core/budget/budget_validator.dart';
import 'package:motostock_pro/features/pieces/providers/pieces_provider.dart';

class PieceFormScreen extends ConsumerStatefulWidget {
  final int? pieceId;
  const PieceFormScreen({super.key, this.pieceId});

  @override
  ConsumerState<PieceFormScreen> createState() => _PieceFormScreenState();
}

class _PieceFormScreenState extends ConsumerState<PieceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _initialized = false;

  final _refCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _categorie = 'Freinage';
  final _compatCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '0');
  final _qtyMinCtrl = TextEditingController(text: '5');
  final _prixAchatCtrl = TextEditingController(text: '0');
  final _prixVenteCtrl = TextEditingController(text: '0');
  final _garantieCtrl = TextEditingController(text: '0');
  final _emplacementCtrl = TextEditingController();
  int? _selectedFournisseurId;

  final List<String> _selectedBrands = [];

  bool get _isEdit => widget.pieceId != null;

  static const _brands = [
    'Yamaha',
    'Honda',
    'Suzuki',
    'Kawasaki',
    'Forza / XTF',
    'Zimota',
    'Sanya',
    'KTM',
    'BMW Motorrad',
    'SYM',
    'CFMOTO',
    'Peugeot Scooters',
    'Vespa / Piaggio',
    'TGB',
    'Aprilia',
    'Kymco',
    'Benelli'
  ];

  static const _categories = [
    'Accessoires',
    'Autre',
    'Batteries',
    'Bougies',
    'Carrosserie',
    'Câbles',
    'Échappement',
    'Éclairage',
    'Électrique',
    'Filtres',
    'Freinage',
    'Kit Chaîne',
    'Lubrifiants',
    'Moteur',
    'Outillage',
    'Plaquettes',
    'Pneus',
    'Roulements',
    'Suspension',
    'Transmission',
  ];

  @override
  void dispose() {
    _refCtrl.dispose();
    _nomCtrl.dispose();
    _descCtrl.dispose();
    _compatCtrl.dispose();
    _imageUrlCtrl.dispose();
    _qtyCtrl.dispose();
    _qtyMinCtrl.dispose();
    _prixAchatCtrl.dispose();
    _prixVenteCtrl.dispose();
    _garantieCtrl.dispose();
    _emplacementCtrl.dispose();
    super.dispose();
  }

  void _initFromPiece(Piece p) {
    if (_initialized) return;
    _initialized = true;
    _refCtrl.text = p.reference;
    _nomCtrl.text = p.nom;
    _descCtrl.text = p.description ?? '';
    _categorie = p.categorie;
    _compatCtrl.text = p.compatibilitesMotos ?? '';
    _imageUrlCtrl.text = p.imagePath ?? '';
    _qtyCtrl.text = p.quantiteEnStock.toString();
    _qtyMinCtrl.text = p.quantiteMinimale.toString();
    _prixAchatCtrl.text = p.prixAchat.toString();
    _prixVenteCtrl.text = p.prixVente.toString();
    _emplacementCtrl.text = p.emplacement ?? '';
    _garantieCtrl.text = p.garantieDuree.toString();
    _selectedFournisseurId = p.fournisseurId;

    if (p.compatibilitesMotos != null) {
      final list =
          p.compatibilitesMotos!.split(',').map((s) => s.trim()).toList();
      _selectedBrands.clear();
      for (final b in list) {
        if (_brands.contains(b) && !_selectedBrands.contains(b)) {
          _selectedBrands.add(b);
        }
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final db = ref.read(databaseProvider);
      final budget = ref.read(budgetValidatorProvider);

      final newRef = _refCtrl.text.trim();

      // Vérification d'unicité de la référence
      final existingWithRef = await db.getPieceByReference(newRef);
      if (existingWithRef != null) {
        if (!_isEdit || (existingWithRef.id != widget.pieceId)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Une pièce avec la référence "$newRef" existe déjà (${existingWithRef.nom}).'),
              backgroundColor: AppColors.danger,
            ));
          }
          setState(() => _loading = false);
          return;
        }
      }

      final prixAchat =
          double.tryParse(_prixAchatCtrl.text.replaceAll(',', '.')) ?? 0;
      final quantite = int.tryParse(_qtyCtrl.text) ?? 0;

      // Budget Validation
      if (!_isEdit) {
        final canAdd =
            await budget.canAdd(newPrice: prixAchat, newQty: quantite);
        if (!canAdd) {
          final remaining = await budget.remainingBudget();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Budget insuffisant ! Limite: 200 DT. Reste: ${remaining.toStringAsFixed(2)} DT'),
              backgroundColor: AppColors.danger,
            ));
          }
          setState(() => _loading = false);
          return;
        }
      } else {
        // For edit, we check if the increase in value exceeds the remaining budget
        final piece = (await db.getAllPieces())
            .firstWhere((p) => p.id == widget.pieceId!);
        final oldValue = piece.prixAchat * piece.quantiteEnStock;
        final newValue = prixAchat * quantite;

        if (newValue > oldValue) {
          final diff = newValue - oldValue;
          final remaining = await budget.remainingBudget();
          if (diff > remaining) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Modification impossible: Le nouveau stock dépasse le budget de 200 DT total.'),
                backgroundColor: AppColors.danger,
              ));
            }
            setState(() => _loading = false);
            return;
          }
        }
      }

      final compatString = _selectedBrands.isNotEmpty
          ? _selectedBrands.join(', ')
          : (_compatCtrl.text.trim().isEmpty ? null : _compatCtrl.text.trim());

      if (_isEdit) {
        final all = await db.getAllPieces();
        final piece = all.firstWhere((p) => p.id == widget.pieceId!);
        await db.updatePiece(piece.copyWith(
          reference: _refCtrl.text.trim(),
          nom: _nomCtrl.text.trim(),
          description: Value(
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim()),
          categorie: _categorie,
          compatibilitesMotos: Value(compatString),
          quantiteEnStock: int.tryParse(_qtyCtrl.text) ?? 0,
          quantiteMinimale: int.tryParse(_qtyMinCtrl.text) ?? 5,
          prixAchat:
              double.tryParse(_prixAchatCtrl.text.replaceAll(',', '.')) ?? 0,
          prixVente:
              double.tryParse(_prixVenteCtrl.text.replaceAll(',', '.')) ?? 0,
          emplacement: Value(_emplacementCtrl.text.trim().isEmpty
              ? null
              : _emplacementCtrl.text.trim()),
          garantieDuree: int.tryParse(_garantieCtrl.text) ?? 0,
          fournisseurId: Value(_selectedFournisseurId),
          imagePath: Value(_imageUrlCtrl.text.trim().isEmpty
              ? null
              : _imageUrlCtrl.text.trim()),
          dateLastMaj: Value(DateTime.now()),
        ));
      } else {
        await db.insertPiece(PiecesCompanion.insert(
          reference: _refCtrl.text.trim(),
          nom: _nomCtrl.text.trim(),
          categorie: _categorie,
          description: Value(
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim()),
          compatibilitesMotos: Value(compatString),
          quantiteEnStock: Value(int.tryParse(_qtyCtrl.text) ?? 0),
          quantiteMinimale: Value(int.tryParse(_qtyMinCtrl.text) ?? 5),
          prixAchat: Value(
              double.tryParse(_prixAchatCtrl.text.replaceAll(',', '.')) ?? 0),
          prixVente: Value(
              double.tryParse(_prixVenteCtrl.text.replaceAll(',', '.')) ?? 0),
          emplacement: Value(_emplacementCtrl.text.trim().isEmpty
              ? null
              : _emplacementCtrl.text.trim()),
          garantieDuree: Value(int.tryParse(_garantieCtrl.text) ?? 0),
          fournisseurId: Value(_selectedFournisseurId),
          imagePath: Value(_imageUrlCtrl.text.trim().isEmpty
              ? null
              : _imageUrlCtrl.text.trim()),
        ));
      }
      ref.invalidate(piecesListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Pièce modifiée' : 'Pièce créée'),
          backgroundColor: AppColors.secondary,
        ));
        context.go('/pieces');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    if (_isEdit) {
      final pieceAsync = ref.watch(selectedPieceProvider(widget.pieceId!));
      if (pieceAsync is AsyncLoading) {
        return const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }
      pieceAsync.whenData((p) {
        if (p != null) _initFromPiece(p);
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: textSecondary),
                  onPressed: () => context.go('/pieces'),
                ),
                const SizedBox(width: 8),
                Text(_isEdit ? 'Modifier la pièce' : 'Nouvelle pièce',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary))
                    : ElevatedButton.icon(
                        onPressed: _save,
                        icon:
                            const FaIcon(FontAwesomeIcons.floppyDisk, size: 14),
                        label: Text(_isEdit ? 'Enregistrer' : 'Créer'),
                      ),
              ]),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 3,
                      child: _section(
                        surface,
                        border,
                        textColor,
                        icon: FontAwesomeIcons.circleInfo,
                        title: 'Informations générales',
                        children: [
                          Row(children: [
                            Expanded(
                                child: _field('Référence (SKU) *', _refCtrl,
                                    validator: AppValidators.sku,
                                    hint: 'ex: FR-001')),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _field('Nom *', _nomCtrl,
                                    hint: 'ex: Plaquettes de frein',
                                    validator: (v) =>
                                        AppValidators.required(v, 'Le nom'))),
                          ]),
                          const SizedBox(height: 16),
                          _field('Description', _descCtrl, maxLines: 3),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(
                                child: DropdownButtonFormField<String>(
                              initialValue: _categorie,
                              decoration: const InputDecoration(
                                  labelText: 'Catégorie *'),
                              items: _categories
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _categorie = v ?? _categorie),
                              validator: (v) => v == null ? 'Requis' : null,
                            )),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _field('Emplacement', _emplacementCtrl,
                                    hint: 'ex: A3-R2')),
                          ]),
                          const SizedBox(height: 16),
                          Text(
                            'Marques de moto compatibles',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _brands.map((brand) {
                              final isSelected =
                                  _selectedBrands.contains(brand);
                              return FilterChip(
                                label: Text(brand),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedBrands.add(brand);
                                    } else {
                                      _selectedBrands.remove(brand);
                                    }
                                  });
                                },
                                selectedColor:
                                    AppColors.primary.withOpacity(0.2),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : textColor,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          _field('Autres compatibilités (modèles spécifiques)',
                              _compatCtrl,
                              maxLines: 2,
                              hint: 'ex: CBR600, R6, Zimota Z-One'),
                        ],
                      )),
                  const SizedBox(width: 20),
                  Expanded(
                      flex: 2,
                      child: Column(children: [
                        _section(
                          surface,
                          border,
                          textColor,
                          icon: FontAwesomeIcons.boxesStacked,
                          title: 'Stock & Prix',
                          children: [
                            Row(children: [
                              Expanded(
                                  child: _field('Qté en stock', _qtyCtrl,
                                      keyboard: TextInputType.number,
                                      validator: (v) =>
                                          AppValidators.positiveInteger(
                                              v, 'La quantité'))),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _field('Seuil minimum', _qtyMinCtrl,
                                      keyboard: TextInputType.number,
                                      validator: (v) =>
                                          AppValidators.positiveInteger(
                                              v, 'Le seuil'))),
                            ]),
                            const SizedBox(height: 16),
                            _field('Prix achat (DT)', _prixAchatCtrl,
                                keyboard: TextInputType.number,
                                validator: (v) =>
                                    AppValidators.positiveNumber(v, 'Le prix')),
                            const SizedBox(height: 16),
                            _field('Prix vente (DT)', _prixVenteCtrl,
                                keyboard: TextInputType.number,
                                validator: (v) =>
                                    AppValidators.positiveNumber(v, 'Le prix')),
                            const SizedBox(height: 16),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _prixAchatCtrl,
                              builder: (context, achat, _) {
                                return ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _prixVenteCtrl,
                                  builder: (context, vente, _) {
                                    final pa = double.tryParse(
                                            achat.text.replaceAll(',', '.')) ??
                                        0;
                                    final pv = double.tryParse(
                                            vente.text.replaceAll(',', '.')) ??
                                        0;
                                    final marge = pv - pa;
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary
                                            .withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Différence / bénéfice par article',
                                            style: TextStyle(
                                                color: textSecondary,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            '${marge.toStringAsFixed(3)} DT',
                                            style: TextStyle(
                                              color: marge >= 0
                                                  ? AppColors.secondary
                                                  : AppColors.danger,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoInput(
      Color textColor, Color textSecondary, Color surface, Color border) {
    final hasImage = _imageUrlCtrl.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    _imageUrlCtrl.text.startsWith('http')
                        ? Image.network(
                            _imageUrlCtrl.text,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Icon(Icons.broken_image_rounded,
                                  color: AppColors.danger, size: 40),
                            ),
                          )
                        : Image.file(
                            File(_imageUrlCtrl.text),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Icon(Icons.broken_image_rounded,
                                  color: AppColors.danger, size: 40),
                            ),
                          ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _imageUrlCtrl.clear()),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined,
                          color: AppColors.primary, size: 36),
                      SizedBox(height: 8),
                      Text('Aucune photo',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickAndUploadPhoto,
                icon: const Icon(Icons.upload_file_rounded, size: 16),
                label: const Text('Choisir une photo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _field('Lien de l\'image (URL ou Chemin local)', _imageUrlCtrl,
            hint: 'https://example.com/photo.jpg'),
      ],
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final result = await fp.FilePicker.pickFiles(
        type: fp.FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;

      if (file.path != null) {
        setState(() => _loading = true);

        // Try uploading to Supabase Storage if configured
        try {
          final fileBytes = await File(file.path!).readAsBytes();
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

          debugPrint('Uploading image to Supabase storage...');
          await Supabase.instance.client.storage.from('parts').uploadBinary(
              fileName, fileBytes,
              fileOptions: const FileOptions(contentType: 'image/png'));

          final publicUrl = Supabase.instance.client.storage
              .from('parts')
              .getPublicUrl(fileName);

          setState(() {
            _imageUrlCtrl.text = publicUrl;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Photo téléchargée sur Supabase Storage avec succès !'),
              backgroundColor: AppColors.secondary,
            ));
          }
        } catch (storageError) {
          debugPrint(
              'Supabase storage upload failed, using local path: $storageError');
          setState(() {
            _imageUrlCtrl.text = file.path!;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Upload impossible. Photo enregistrée localement : ${file.name}'),
              backgroundColor: AppColors.warning,
            ));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur sélection photo : $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _section(Color surface, Color border, Color textColor,
      {required IconData icon,
      required String title,
      required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          FaIcon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
