import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motostock_pro/shared/widgets/empty_state.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';
import 'package:motostock_pro/core/utils/formatters.dart';
import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/core/database/app_database.dart';
import 'package:motostock_pro/features/pieces/providers/pieces_provider.dart';
import 'package:motostock_pro/features/dashboard/providers/dashboard_provider.dart';
import 'package:motostock_pro/features/caisse/invoice_generator.dart';
import 'package:motostock_pro/features/caisse/providers/cart_provider.dart';
import 'package:motostock_pro/features/caisse/models/cart_item.dart';
import 'package:motostock_pro/features/commandes_web/providers/commandes_web_provider.dart';
import 'package:motostock_pro/features/rapports/providers/sales_report_provider.dart';

// Stream of recent stock movements to build transactional POS history
final _mouvementsHistoryProvider = StreamProvider<List<MouvementStock>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecentMouvements(limit: 500);
});

class CaisseScreen extends ConsumerStatefulWidget {
  const CaisseScreen({super.key});

  @override
  ConsumerState<CaisseScreen> createState() => _CaisseScreenState();
}

class _CaisseScreenState extends ConsumerState<CaisseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _searchCtrl = TextEditingController();
  final _receivedCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '0');
  String _searchQuery = '';
  String? _selectedCategory;

  // Cart is now managed via shared cartProvider (allows pre-fill from web orders)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _receivedCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  void _addToCart(Piece piece) {
    if (piece.quantiteEnStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ce produit est en rupture de stock !'),
        backgroundColor: AppColors.danger,
      ));
      return;
    }

    final cart = ref.read(cartProvider);
    final existing = cart[piece.id];
    if (existing != null && existing.qty >= piece.quantiteEnStock) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Quantité maximale disponible en stock atteinte (${piece.quantiteEnStock}) !'),
        backgroundColor: AppColors.warning,
      ));
      return;
    }
    ref.read(cartProvider.notifier).addItem(piece);
  }

  void _decrementQty(int pieceId) {
    ref.read(cartProvider.notifier).decrementQty(pieceId);
  }

  void _removeFromCart(int pieceId) {
    ref.read(cartProvider.notifier).removeItem(pieceId);
  }

  double _productsTotalPriceOf(Map<int, CartItem> cart) {
    return cart.values
        .fold(0.0, (sum, item) => sum + (item.piece.prixVente * item.qty));
  }

  double _discountAmountOf(Map<int, CartItem> cart) {
    final raw = double.tryParse(_discountCtrl.text.replaceAll(',', '.')) ?? 0.0;
    if (raw <= 0) return 0.0;
    final productsTotal = _productsTotalPriceOf(cart);
    final percentage = raw > 100 ? 100.0 : raw;
    return productsTotal * (percentage / 100.0);
  }

  double _totalPriceOf(Map<int, CartItem> cart) {
    final productsTotal = _productsTotalPriceOf(cart);
    final discount = _discountAmountOf(cart);
    return productsTotal > 0 ? (productsTotal - discount) + 1.0 : 0.0;
  }

  double get _receivedAmount {
    return double.tryParse(_receivedCtrl.text.replaceAll(',', '.')) ?? 0.0;
  }

  bool _canCheckoutWith(Map<int, CartItem> cart) {
    return cart.isNotEmpty && _receivedAmount >= _totalPriceOf(cart);
  }

  Future<void> _processCheckout() async {
    final cart = ref.read(cartProvider);
    if (!_canCheckoutWith(cart)) return;

    final total = _totalPriceOf(cart);
    final discount = _discountAmountOf(cart);
    final received = _receivedAmount;
    final change = received - total >= 0 ? received - total : 0.0;

    // Generate unique transaction ID (e.g. TX-49201)
    final txId =
        'TX-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final webOrderId = ref.read(activeWebOrderIdProvider);

    try {
      final db = ref.read(databaseProvider);

      // 1. Complete order on Supabase if it was initiated from a Web Order
      if (webOrderId != null) {
        try {
          await ref.read(webOrderActionsProvider).completeOrder(webOrderId);
        } catch (e) {
          throw Exception(
            'Impossible de finaliser la commande web sur Supabase. '
            'Exécutez orders_desktop_fix.sql dans Supabase, puis réessayez. '
            'Détail: $e',
          );
        }
      }

      // 2. Insert stock movements and UPDATE stock for each item in the order
      for (final item in cart.values) {
        // Embed detailed transaction meta inside the motif
        final webOrderPart =
            webOrderId != null ? 'Commande Web #$webOrderId | ' : '';
        final motifStr =
            '${webOrderPart}Vente caisse #$txId | PU: ${item.piece.prixVente} DT | PA: ${item.piece.prixAchat} DT | Remise: $discount DT | Total Vente: $total DT | Reçu: $received DT | Rendu: $change DT';

        await db.removeStock(item.piece.id, item.qty, motifStr);
      }

      // Invalidate pieces lists to trigger UI refreshes
      ref.invalidate(piecesListProvider);
      ref.invalidate(allPiecesMapProvider);
      ref.invalidate(salesReportProvider);

      if (webOrderId != null) {
        ref.invalidate(commandesWebProvider);
        ref.read(activeWebOrderIdProvider.notifier).state = null;
        ref.read(activeWebOrderClientDetailsProvider.notifier).state = null;
      }

      // Build items for invoice
      final invoiceItems = cart.values
          .map((item) => {
                'nom': item.piece.nom,
                'ref': item.piece.reference,
                'qty': item.qty,
                'pu': item.piece.prixVente,
              })
          .toList();

      // Déclencher automatiquement l'impression de la facture
      InvoiceGenerator.generateAndPrintInvoice(
        txId: txId,
        total: total,
        discount: discount,
        received: received,
        change: change,
        items: invoiceItems,
      ).catchError((e) {
        debugPrint('Erreur impression automatique: $e');
      });

      if (mounted) {
        _showSuccessDialog(
            total, discount, received, change, txId, invoiceItems);
      }

      ref.read(cartProvider.notifier).clearCart();
      setState(() {
        _receivedCtrl.clear();
        _discountCtrl.text = '0';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors de la validation : $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  void _showSuccessDialog(double total, double discount, double received,
      double change, String txId, List<Map<String, dynamic>> invoiceItems) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        final textColor = isDark ? AppColors.darkText : AppColors.lightText;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle_rounded,
                        color: AppColors.secondary, size: 44),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Vente Encaissée !',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transaction #$txId',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground)
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _dialogRow(
                          'Total Articles (TTC)',
                          '${(total + discount - 1.0).toStringAsFixed(3)} DT',
                          isDark),
                      if (discount > 0) ...[
                        const SizedBox(height: 6),
                        _dialogRow('Remise',
                            '-${discount.toStringAsFixed(3)} DT', isDark),
                      ],
                      const SizedBox(height: 6),
                      _dialogRow('Timbre Fiscal', '1.000 DT', isDark),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      _dialogRow('Net à Payer',
                          '${total.toStringAsFixed(3)} DT', isDark,
                          isBold: true),
                      const SizedBox(height: 6),
                      _dialogRow('Montant Reçu',
                          '${received.toStringAsFixed(3)} DT', isDark),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'À RENDRE AU CLIENT',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${change.toStringAsFixed(3)} DT',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await InvoiceGenerator.generateAndPrintInvoice(
                          txId: txId,
                          total: total,
                          discount: discount,
                          received: received,
                          change: change,
                          items: invoiceItems,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Erreur lors de la génération de la facture: $e'),
                            backgroundColor: AppColors.danger,
                          ));
                        }
                      }
                    },
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text(
                      'Imprimer la facture',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: textColor,
                      side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                    child: const Text(
                      'Terminé (OK)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogRow(String label, String value, bool isDark,
      {bool isBold = false}) {
    final valStyle = TextStyle(
      fontSize: isBold ? 18 : 15,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: isDark ? AppColors.darkText : AppColors.lightText,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: 13,
          ),
        ),
        Text(value, style: valStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Caisse & Ventes',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    tabs: const [
                      Tab(text: 'Nouvelle Vente'),
                      Tab(text: 'Historique des Ventes'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPOSCheckout(context),
          _buildSalesHistory(context),
        ],
      ),
    );
  }

  // TAB 1: POS Checkout
  Widget _buildPOSCheckout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final piecesAsync = ref.watch(piecesListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cart = ref.watch(cartProvider);
    final totalPrice = _totalPriceOf(cart);
    final productsTotalPrice = _productsTotalPriceOf(cart);
    final discountAmount = _discountAmountOf(cart);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                          ref.read(piecesFilterProvider.notifier).update(
                                (state) => state.copyWith(searchQuery: val),
                              );
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher par Nom, SKU, Référence...',
                          prefixIcon:
                              const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon:
                                      const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _searchCtrl.clear();
                                      _searchQuery = '';
                                    });
                                    ref
                                        .read(piecesFilterProvider.notifier)
                                        .update(
                                          (state) =>
                                              state.copyWith(searchQuery: ''),
                                        );
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                categoriesAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (cats) {
                    return SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ChoiceChip(
                            label: const Text('Tout'),
                            selected: _selectedCategory == null,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = null);
                                ref.read(piecesFilterProvider.notifier).update(
                                      (state) =>
                                          state.copyWith(clearCategorie: true),
                                    );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ...cats.map((cat) {
                            final isSel = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSel,
                                onSelected: (selected) {
                                  setState(() => _selectedCategory =
                                      selected ? cat : null);
                                  ref
                                      .read(piecesFilterProvider.notifier)
                                      .update(
                                        (state) => selected
                                            ? state.copyWith(categorie: cat)
                                            : state.copyWith(
                                                clearCategorie: true),
                                      );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: piecesAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                    error: (e, _) => Center(
                        child: Text('Erreur : $e',
                            style: const TextStyle(color: AppColors.danger))),
                    data: (pieces) {
                      if (pieces.isEmpty) {
                        return const EmptyState(
                          icon: FontAwesomeIcons.magnifyingGlass,
                          title: 'Aucun produit trouvé',
                          subtitle:
                              'Modifiez votre recherche ou ajoutez un produit au catalogue.',
                        );
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: pieces.length,
                        itemBuilder: (ctx, i) {
                          final p = pieces[i];
                          final inStock = p.quantiteEnStock > 0;
                          return Container(
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _addToCart(p),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: inStock
                                                ? AppColors.secondary
                                                    .withOpacity(0.1)
                                                : AppColors.danger
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            inStock
                                                ? '${p.quantiteEnStock} en stock'
                                                : 'Rupture',
                                            style: TextStyle(
                                              color: inStock
                                                  ? AppColors.secondary
                                                  : AppColors.danger,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          p.reference,
                                          style: TextStyle(
                                              color: textSecondary,
                                              fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      p.nom,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.categorie,
                                      style: TextStyle(
                                          color: textSecondary, fontSize: 11),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${p.prixVente.toStringAsFixed(0)} DT',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add_rounded,
                                              color: AppColors.primary,
                                              size: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.cartShopping,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        'Panier de Caisse',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (cart.isNotEmpty)
                        TextButton(
                          onPressed: () =>
                              ref.read(cartProvider.notifier).clearCart(),
                          child: const Text('Vider',
                              style: TextStyle(color: AppColors.danger)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Active Web Order Banner
                  if (ref.watch(activeWebOrderIdProvider) != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.language_rounded,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Commande Web #${ref.watch(activeWebOrderIdProvider)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Client: ${ref.watch(activeWebOrderClientDetailsProvider)?['name'] ?? 'Inconnu'} | Tél: ${ref.watch(activeWebOrderClientDetailsProvider)?['phone'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.danger, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Annuler et vider',
                            onPressed: () {
                              ref
                                  .read(activeWebOrderIdProvider.notifier)
                                  .state = null;
                              ref
                                  .read(activeWebOrderClientDetailsProvider
                                      .notifier)
                                  .state = null;
                              ref.read(cartProvider.notifier).clearCart();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  Expanded(
                    child: cart.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.cartPlus,
                                    color: textSecondary.withOpacity(0.3),
                                    size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  'Le panier est vide',
                                  style: TextStyle(
                                      color: textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: cart.length,
                            itemBuilder: (ctx, i) {
                              final item = cart.values.elementAt(i);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? AppColors.darkBackground
                                          : AppColors.lightBackground)
                                      .withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.piece.nom,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.piece.prixVente.toStringAsFixed(0)} DT/u',
                                            style: TextStyle(
                                                color: textSecondary,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_rounded,
                                              size: 16),
                                          onPressed: () =>
                                              _decrementQty(item.piece.id),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                        ),
                                        Text(
                                          '${item.qty}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_rounded,
                                              size: 16),
                                          onPressed: () =>
                                              _addToCart(item.piece),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(item.piece.prixVente * item.qty).toStringAsFixed(0)} DT',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () =>
                                          _removeFromCart(item.piece.id),
                                      child: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppColors.danger,
                                          size: 18),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),

                  const SizedBox(height: 10),

                  if (cart.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sous-total Articles (TTC)',
                                style: TextStyle(
                                    color: textSecondary, fontSize: 12),
                              ),
                              Text(
                                '${productsTotalPrice.toStringAsFixed(3)} DT',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _discountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Remise (%)',
                              hintText: '0',
                              suffixText: '%',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                          if (discountAmount > 0) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Remise appliquée',
                                  style: TextStyle(
                                      color: textSecondary, fontSize: 12),
                                ),
                                Text(
                                  '-${discountAmount.toStringAsFixed(3)} DT',
                                  style: const TextStyle(
                                      color: AppColors.warning,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Timbre Fiscal',
                                style: TextStyle(
                                    color: textSecondary, fontSize: 12),
                              ),
                              const Text(
                                '1.000 DT',
                                style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NET À PAYER',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${totalPrice.toStringAsFixed(3)} DT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground)
                          .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ENCAISSEMENT',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _receivedCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Argent donné par le client (DT)',
                            hintText: '0',
                            labelStyle: const TextStyle(fontSize: 11),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'DT',
                                style: TextStyle(
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _presetButton('Exact', totalPrice),
                            const SizedBox(width: 4),
                            _presetButton('+10', 10, relative: true),
                            const SizedBox(width: 4),
                            _presetButton('+20', 20, relative: true),
                            const SizedBox(width: 4),
                            _presetButton('+50', 50, relative: true),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_receivedAmount > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _receivedAmount >= totalPrice
                                    ? 'Rendu monnaie :'
                                    : 'Reste à payer :',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _receivedAmount >= totalPrice
                                    ? '${(_receivedAmount - totalPrice).toStringAsFixed(0)} DT'
                                    : '${(totalPrice - _receivedAmount).toStringAsFixed(0)} DT',
                                style: TextStyle(
                                  color: _receivedAmount >= totalPrice
                                      ? AppColors.secondary
                                      : AppColors.danger,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          _canCheckoutWith(cart) ? _processCheckout : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Valider l\'encaissement',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Sales History (The specific feature requested by the user!)
  Widget _buildSalesHistory(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final movementsAsync = ref.watch(_mouvementsHistoryProvider);
    final piecesMapAsync = ref.watch(allPiecesMapProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: movementsAsync.when(
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
            // Group raw movements by Transaction ID TX-XXXXX
            final Map<String, _CaisseTransaction> groupedTransactions = {};

            for (final m in mouvements) {
              if (m.motif != null && m.motif!.contains('Vente caisse #')) {
                final piece = piecesMap[m.pieceId];
                final tx = _parseTransaction(m, piece);
                if (tx != null) {
                  final existing = groupedTransactions[tx.txId];
                  if (existing != null) {
                    existing.items.addAll(tx.items);
                  } else {
                    groupedTransactions[tx.txId] = tx;
                  }
                }
              }
            }

            final txList = groupedTransactions.values.toList();
            txList.sort((a, b) => b.date.compareTo(a.date)); // Newest first

            if (txList.isEmpty) {
              return const EmptyState(
                icon: FontAwesomeIcons.receipt,
                title: 'Aucune vente enregistrée',
                subtitle:
                    'Les reçus de caisse et détails financiers apparaîtront ici après encaissement.',
              );
            }

            return ListView.builder(
              itemCount: txList.length,
              itemBuilder: (ctx, i) {
                final tx = txList[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.receipt_long_rounded,
                              color: AppColors.secondary, size: 22),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Vente #${tx.txId}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${tx.items.length} article(s)',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Effectuée le ${AppFormatters.formatDateTime(tx.date)}',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${tx.totalVente.toStringAsFixed(0)} DT',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Reçu: ${tx.recu.toStringAsFixed(0)} DT / Rendu: ${tx.rendu.toStringAsFixed(0)} DT',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _showReceiptDetailsDialog(tx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground),
                          foregroundColor: textColor,
                          elevation: 0,
                          side: BorderSide(color: border),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                        child: const Text('Détails',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Parse transaction meta out of stock movement motif string
  _CaisseTransaction? _parseTransaction(MouvementStock m, Piece? p) {
    if (m.motif == null || !m.motif!.contains('Vente caisse #')) return null;
    try {
      final parts = m.motif!.split('|').map((s) => s.trim()).toList();
      if (parts.isEmpty) return null;

      double extractNumber(String text) {
        final match = RegExp(r'[\d\.]+').firstMatch(text);
        if (match != null) {
          return double.tryParse(match.group(0) ?? '0') ?? 0.0;
        }
        return 0.0;
      }

      String? txId;
      double unitPrice = 0;
      double totalVente = 0;
      double remise = 0;
      double recu = 0;
      double rendu = 0;

      for (final part in parts) {
        if (part.contains('Vente caisse #')) {
          txId = part.replaceAll('Vente caisse #', '').trim();
        } else if (part.contains('PU:')) {
          unitPrice = extractNumber(part);
        } else if (part.contains('Remise:')) {
          remise = extractNumber(part);
        } else if (part.contains('Total Vente:')) {
          totalVente = extractNumber(part);
        } else if (part.contains('Reçu:')) {
          recu = extractNumber(part);
        } else if (part.contains('Rendu:')) {
          rendu = extractNumber(part);
        }
      }

      if (txId == null || txId.isEmpty) return null;

      return _CaisseTransaction(
        txId: txId,
        date: m.date,
        totalVente: totalVente,
        remise: remise,
        recu: recu,
        rendu: rendu,
        items: [
          _CaisseTransactionItem(
            pieceId: m.pieceId,
            pieceName: p?.nom ?? 'Produit inconnu',
            reference: p?.reference ?? '',
            quantity: m.quantite,
            unitPrice: unitPrice,
          )
        ],
      );
    } catch (e) {
      return null;
    }
  }

  void _showReceiptDetailsDialog(_CaisseTransaction tx) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        final textColor = isDark ? AppColors.darkText : AppColors.lightText;
        final textSecondary =
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Material(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Receipt style
                  Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.receipt,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ticket de Caisse',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Transaction #${tx.txId}',
                            style:
                                TextStyle(color: textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: border, height: 1),
                  const SizedBox(height: 14),

                  Text(
                    'Date : ${AppFormatters.formatDateTime(tx.date)}',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Table Header
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text('Article',
                            style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Qté',
                            style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('Total',
                            style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: border.withOpacity(0.5), height: 1),
                  const SizedBox(height: 10),

                  // Items list
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tx.items.length,
                      itemBuilder: (context, idx) {
                        final item = tx.items[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.pieceName,
                                      style: TextStyle(
                                          color: textColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${item.unitPrice.toStringAsFixed(0)} DT / u',
                                      style: TextStyle(
                                          color: textSecondary, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'x${item.quantity}',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${(item.unitPrice * item.quantity).toStringAsFixed(0)} DT',
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Divider(color: border, height: 1),
                  const SizedBox(height: 14),

                  // Finance Summary
                  _summaryRow(
                      'Total Articles (TTC)',
                      '${(tx.totalVente + tx.remise - 1.0).toStringAsFixed(3)} DT',
                      textColor),
                  if (tx.remise > 0) ...[
                    const SizedBox(height: 6),
                    _summaryRow('Remise', '-${tx.remise.toStringAsFixed(3)} DT',
                        AppColors.warning),
                  ],
                  const SizedBox(height: 6),
                  _summaryRow('Timbre Fiscal', '1.000 DT', textColor),
                  const SizedBox(height: 8),
                  Divider(color: border.withOpacity(0.5), height: 1),
                  const SizedBox(height: 8),
                  _summaryRow(
                      'Net à Payer',
                      '${tx.totalVente.toStringAsFixed(3)} DT',
                      AppColors.primary,
                      isBold: true),
                  const SizedBox(height: 6),
                  _summaryRow('Argent Reçu', '${tx.recu.toStringAsFixed(3)} DT',
                      textSecondary),
                  const SizedBox(height: 6),
                  _summaryRow('Rendu Monnaie',
                      '${tx.rendu.toStringAsFixed(3)} DT', AppColors.secondary,
                      isBold: true),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              final invoiceItems = tx.items
                                  .map((item) => {
                                        'nom': item.pieceName,
                                        'ref': item.reference,
                                        'qty': item.quantity,
                                        'pu': item.unitPrice,
                                      })
                                  .toList();
                              await InvoiceGenerator.generateAndPrintInvoice(
                                txId: tx.txId,
                                total: tx.totalVente,
                                discount: tx.remise,
                                received: tx.recu,
                                change: tx.rendu,
                                items: invoiceItems,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      'Erreur lors de la réimpression : $e'),
                                  backgroundColor: AppColors.danger,
                                ));
                              }
                            }
                          },
                          icon: const Icon(Icons.print_rounded, size: 16),
                          label: const Text(
                            'Imprimer',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: textColor,
                            side: BorderSide(color: border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, Color valColor,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            color: valColor,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _presetButton(String text, double val, {bool relative = false}) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          if (ref.read(cartProvider).isEmpty) return;
          setState(() {
            if (relative) {
              final cur = double.tryParse(_receivedCtrl.text) ?? 0.0;
              _receivedCtrl.text = (cur + val).toStringAsFixed(0);
            } else {
              _receivedCtrl.text = val.toStringAsFixed(0);
            }
          });
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          foregroundColor: AppColors.primary,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          maxLines: 1,
        ),
      ),
    );
  }
}

// _CartItem removed — replaced by shared CartItem in models/cart_item.dart

// Transaction Model representation
class _CaisseTransaction {
  final String txId;
  final DateTime date;
  final double totalVente;
  final double remise;
  final double recu;
  final double rendu;
  final List<_CaisseTransactionItem> items;

  _CaisseTransaction({
    required this.txId,
    required this.date,
    required this.totalVente,
    required this.remise,
    required this.recu,
    required this.rendu,
    required this.items,
  });
}

class _CaisseTransactionItem {
  final int pieceId;
  final String pieceName;
  final String reference;
  final int quantity;
  final double unitPrice;

  _CaisseTransactionItem({
    required this.pieceId,
    required this.pieceName,
    required this.reference,
    required this.quantity,
    required this.unitPrice,
  });
}
