import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motostock_pro/core/database/app_database.dart';
import 'package:motostock_pro/features/caisse/models/cart_item.dart';

class CartNotifier extends StateNotifier<Map<int, CartItem>> {
  CartNotifier() : super({});

  Future<void> setCartFromOrder(
      List<Map<String, dynamic>> items, AppDatabase db) async {
    final Map<int, CartItem> newCart = {};
    for (final item in items) {
      final part = item['parts'] as Map<String, dynamic>? ?? {};
      final refCode = (part['reference'] as String?)?.trim();
      final partName = (part['name'] as String?)?.trim();
      final qty = (item['quantity'] ?? 0) as int;
      if (qty <= 0) continue;

      Piece? piece;
      if (refCode != null && refCode.isNotEmpty) {
        piece = await (db.select(db.pieces)
              ..where((p) => p.reference.equals(refCode)))
            .getSingleOrNull();
      }
      if (piece == null && partName != null && partName.isNotEmpty) {
        piece = await (db.select(db.pieces)
              ..where((p) => p.nom.equals(partName)))
            .getSingleOrNull();
      }
      if (piece != null) {
        newCart[piece.id] = CartItem(piece: piece, qty: qty);
      }
    }

    if (newCart.isEmpty) {
      throw StateError(
        'Aucun article du catalogue local ne correspond à cette commande web. '
        'Vérifiez que les références sont synchronisées avec Supabase.',
      );
    }
    state = newCart;
  }

  void addItem(Piece piece) {
    final existing = state[piece.id];
    if (existing != null) {
      if (existing.qty < piece.quantiteEnStock) {
        state = {
          ...state,
          piece.id: CartItem(piece: piece, qty: existing.qty + 1)
        };
      }
    } else {
      state = {...state, piece.id: CartItem(piece: piece, qty: 1)};
    }
  }

  void decrementQty(int pieceId) {
    final existing = state[pieceId];
    if (existing != null) {
      if (existing.qty > 1) {
        state = {
          ...state,
          pieceId: CartItem(piece: existing.piece, qty: existing.qty - 1)
        };
      } else {
        final newState = {...state};
        newState.remove(pieceId);
        state = newState;
      }
    }
  }

  void removeItem(int pieceId) {
    final newState = {...state};
    newState.remove(pieceId);
    state = newState;
  }

  void clearCart() {
    state = {};
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, Map<int, CartItem>>(
    (ref) => CartNotifier());

final activeWebOrderIdProvider = StateProvider<String?>((ref) => null);

final activeWebOrderClientDetailsProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);
