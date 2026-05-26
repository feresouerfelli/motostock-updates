import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final commandesWebProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

  Future<void> loadOrders() async {
    try {
      final response = await supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);
      if (!controller.isClosed) {
        controller.add(List<Map<String, dynamic>>.from(response));
      }
    } catch (e, st) {
      if (!controller.isClosed) {
        controller.addError(e, st);
      }
    }
  }

  // Best-effort cleanup; must not block the UI stream.
  unawaited(
    supabase.rpc('cancel_expired_orders').catchError((Object e) {
      debugPrint('CommandesWebProvider: cancel_expired_orders: $e');
    }),
  );

  unawaited(loadOrders());

  final channel = supabase
      .channel('desktop:orders')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'orders',
        callback: (_) => loadOrders(),
      )
      .subscribe();

  ref.onDispose(() {
    unawaited(supabase.removeChannel(channel));
    unawaited(controller.close());
  });

  return controller.stream;
});

final pendingWebOrdersCountProvider = Provider<int>((ref) {
  final orders = ref.watch(commandesWebProvider);
  return orders.maybeWhen(
    data: (list) =>
        list.where((o) => (o['status'] as String? ?? '') == 'pending').length,
    orElse: () => 0,
  );
});

final orderItemsWebProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, orderId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('order_items')
      .select('*, parts(name, reference)')
      .eq('order_id', orderId);
  return List<Map<String, dynamic>>.from(response);
});

final webOrderActionsProvider = Provider((ref) => WebOrderActions());

class WebOrderActions {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> completeOrder(String orderId) async {
    await _supabase.rpc('complete_order', params: {'order_id_input': orderId});
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _supabase.rpc('cancel_order', params: {'order_id_input': orderId});
    } catch (e) {
      debugPrint('WebOrderActions.cancelOrder error: $e');
      rethrow;
    }
  }
}
