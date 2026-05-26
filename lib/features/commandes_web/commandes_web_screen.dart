import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:motostock_pro/features/caisse/providers/cart_provider.dart';
import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';
import 'package:motostock_pro/features/commandes_web/providers/commandes_web_provider.dart';

class CommandesWebScreen extends ConsumerWidget {
  const CommandesWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _CommandesWebContent();
  }
}

class _CommandesWebContent extends ConsumerStatefulWidget {
  const _CommandesWebContent();

  @override
  ConsumerState<_CommandesWebContent> createState() =>
      _CommandesWebContentState();
}

class _CommandesWebContentState extends ConsumerState<_CommandesWebContent> {
  /// pending | all | completed | cancelled
  String _statusFilter = 'pending';

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(commandesWebProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Commandes Web 🌐'),
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'En attente',
                  selected: _statusFilter == 'pending',
                  onTap: () => setState(() => _statusFilter = 'pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Toutes',
                  selected: _statusFilter == 'all',
                  onTap: () => setState(() => _statusFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Soldées',
                  selected: _statusFilter == 'completed',
                  onTap: () => setState(() => _statusFilter = 'completed'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Annulées',
                  selected: _statusFilter == 'cancelled',
                  onTap: () => setState(() => _statusFilter = 'cancelled'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Actualiser',
            onPressed: () {
              ref.invalidate(commandesWebProvider);
              ref.invalidate(orderItemsWebProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Données rechargées.'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.danger, size: 48),
              const SizedBox(height: 16),
              Text('Erreur: $e',
                  style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(commandesWebProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
        data: (orders) {
          final filtered = _statusFilter == 'all'
              ? orders
              : orders
                  .where((o) => (o['status'] as String? ?? '') == _statusFilter)
                  .toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_rounded,
                      color: AppColors.darkTextSecondary, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    orders.isEmpty
                        ? 'Aucune commande web pour le moment.'
                        : 'Aucune commande pour ce filtre.',
                    style: const TextStyle(
                        color: AppColors.darkTextSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Les commandes passées sur le site apparaîtront ici.',
                    style: TextStyle(
                        color: AppColors.darkTextSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final sorted = [...filtered]..sort((a, b) {
              int rank(String? s) {
                switch (s) {
                  case 'pending':
                    return 0;
                  case 'completed':
                    return 1;
                  case 'cancelled':
                    return 2;
                  default:
                    return 3;
                }
              }

              final byStatus = rank(a['status'] as String?)
                  .compareTo(rank(b['status'] as String?));
              if (byStatus != 0) return byStatus;
              final da = DateTime.tryParse(a['created_at'] as String? ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              final db = DateTime.tryParse(b['created_at'] as String? ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              return db.compareTo(da);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final order = sorted[index];
              return _OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.darkTextSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;

  const _OrderCard({required this.order});

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _expanded = false;
  bool _isProcessing = false;

  Future<void> _completeOrderFlow(BuildContext context, String orderId,
      List<Map<String, dynamic>> items) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final db = ref.read(databaseProvider);

    try {
      // 1. Store web order context in Riverpod state
      ref.read(activeWebOrderIdProvider.notifier).state = orderId;
      ref.read(activeWebOrderClientDetailsProvider.notifier).state = {
        'name': widget.order['client_name'],
        'phone': widget.order['client_phone'],
        'email': widget.order['client_email'],
      };

      // 2. Populate the POS cart from the web order items
      await ref.read(cartProvider.notifier).setCartFromOrder(items, db);

      // 3. Navigate to Caisse screen
      if (mounted) {
        context.go('/caisse');
      }
    } catch (e) {
      // Reset providers on failure
      ref.read(activeWebOrderIdProvider.notifier).state = null;
      ref.read(activeWebOrderClientDetailsProvider.notifier).state = null;
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la préparation du panier : $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Annuler la commande ?',
            style: TextStyle(
                color: AppColors.darkText, fontWeight: FontWeight.bold)),
        content: const Text(
          'Voulez-vous vraiment annuler cette commande ?\n\n'
          'Le stock gelé (réservé) sera automatiquement libéré sur le site web.',
          style: TextStyle(color: AppColors.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Retour',
                style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _cancelOrderFlow(context, orderId);
            },
            child: const Text('Oui, Annuler',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrderFlow(BuildContext context, String orderId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      await ref.read(webOrderActionsProvider).cancelOrder(orderId);
      if (mounted) Navigator.of(context).pop();
      ref.invalidate(commandesWebProvider);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'annulation : $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.order['id'] as String? ?? '';
    final date = DateTime.tryParse(widget.order['created_at'] as String? ?? '');
    final dateStr = date != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal())
        : '';
    final total = (widget.order['total'] as num?) ?? 0;
    final status = widget.order['status'] as String? ?? 'pending';

    Color statusColor;
    String statusText;
    switch (status) {
      case 'completed':
        statusColor = AppColors.secondary;
        statusText = 'Soldée / Acceptée';
        break;
      case 'cancelled':
        statusColor = AppColors.danger;
        statusText = 'Annulée';
        break;
      case 'pending':
      default:
        statusColor = AppColors.warning;
        statusText = 'En attente';
        break;
    }

    return Card(
      color: AppColors.darkSurface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.order['client_name'] ?? 'Client Inconnu',
              style: const TextStyle(
                  color: AppColors.darkText, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Tél: ${widget.order['client_phone'] ?? ''}',
                    style: const TextStyle(color: AppColors.darkTextSecondary)),
                if (widget.order['client_email'] != null)
                  Text('Email: ${widget.order['client_email']}',
                      style:
                          const TextStyle(color: AppColors.darkTextSecondary)),
                const SizedBox(height: 4),
                Text(dateStr,
                    style: const TextStyle(
                        color: AppColors.darkTextSecondary, fontSize: 12)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${total.toStringAsFixed(3)} DT',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(16.0).copyWith(top: 0),
              child: ref.watch(orderItemsWebProvider(orderId)).when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary)),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Erreur: $e',
                          style: const TextStyle(color: AppColors.danger)),
                    ),
                    data: (items) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: AppColors.darkBorder),
                          ...items.map((item) {
                            final part =
                                item['parts'] as Map<String, dynamic>? ?? {};
                            final name = part['name'] ?? 'Pièce inconnue';
                            final qty = (item['quantity'] ?? 0) as int;
                            final price = (item['unit_price'] ?? 0) as num;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('$qty × $name',
                                        style: const TextStyle(
                                            color:
                                                AppColors.darkTextSecondary)),
                                  ),
                                  Text(
                                      '${(qty * price.toDouble()).toStringAsFixed(3)} DT',
                                      style: const TextStyle(
                                          color: AppColors.darkTextSecondary)),
                                ],
                              ),
                            );
                          }),
                          if (status == 'pending') ...[
                            const SizedBox(height: 16),
                            const Divider(color: AppColors.darkBorder),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : () =>
                                          _showCancelDialog(context, orderId),
                                  icon: const Icon(Icons.cancel_rounded,
                                      color: AppColors.danger, size: 20),
                                  label: const Text('Annuler',
                                      style: TextStyle(
                                          color: AppColors.danger,
                                          fontWeight: FontWeight.bold)),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : () => _completeOrderFlow(
                                          context, orderId, items),
                                  icon: _isProcessing
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : const Icon(Icons.check_circle_rounded,
                                          color: Colors.white, size: 20),
                                  label: Text(
                                    _isProcessing
                                        ? 'Chargement...'
                                        : 'Solder / Accepter',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
            ),
        ],
      ),
    );
  }
}
