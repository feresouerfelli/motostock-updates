import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/core/database/app_database.dart';

// ─── Filters state ─────────────────────────────────────────────────────────

class PiecesFilter {
  final String searchQuery;
  final String? categorie;
  final int? fournisseurId;
  final String stockFilter; // 'all' | 'ok' | 'low' | 'out'

  const PiecesFilter({
    this.searchQuery = '',
    this.categorie,
    this.fournisseurId,
    this.stockFilter = 'all',
  });

  PiecesFilter copyWith({
    String? searchQuery,
    String? categorie,
    int? fournisseurId,
    String? stockFilter,
    bool clearCategorie = false,
    bool clearFournisseur = false,
  }) {
    return PiecesFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      categorie: clearCategorie ? null : (categorie ?? this.categorie),
      fournisseurId:
          clearFournisseur ? null : (fournisseurId ?? this.fournisseurId),
      stockFilter: stockFilter ?? this.stockFilter,
    );
  }
}

final piecesFilterProvider =
    StateProvider<PiecesFilter>((ref) => const PiecesFilter());

// ─── Pieces list ──────────────────────────────────────────────────────────

final piecesListProvider = FutureProvider<List<Piece>>((ref) async {
  final db = ref.watch(databaseProvider);
  final filter = ref.watch(piecesFilterProvider);

  List<Piece> pieces;
  if (filter.searchQuery.isNotEmpty) {
    pieces = await db.searchPieces(filter.searchQuery);
  } else {
    pieces = await db.getAllPieces();
  }

  if (filter.categorie != null) {
    pieces = pieces.where((p) => p.categorie == filter.categorie).toList();
  }
  if (filter.fournisseurId != null) {
    pieces =
        pieces.where((p) => p.fournisseurId == filter.fournisseurId).toList();
  }
  switch (filter.stockFilter) {
    case 'ok':
      pieces =
          pieces.where((p) => p.quantiteEnStock >= p.quantiteMinimale).toList();
      break;
    case 'low':
      pieces = pieces
          .where((p) =>
              p.quantiteEnStock > 0 && p.quantiteEnStock < p.quantiteMinimale)
          .toList();
      break;
    case 'out':
      pieces = pieces.where((p) => p.quantiteEnStock == 0).toList();
      break;
  }
  return pieces;
});

// ─── Categories ───────────────────────────────────────────────────────────

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.watch(databaseProvider);
  final pieces = await db.getAllPieces();
  final cats = pieces.map((p) => p.categorie).toSet().toList();
  cats.sort();
  return cats;
});

// ─── Fournisseurs for filter ──────────────────────────────────────────────

final fournisseursListProvider = FutureProvider<List<Fournisseur>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllFournisseurs();
});

// ─── View mode ────────────────────────────────────────────────────────────

enum PiecesViewMode { list, grid }

final piecesViewModeProvider =
    StateProvider<PiecesViewMode>((ref) => PiecesViewMode.list);

// ─── Selected piece (for edit) ────────────────────────────────────────────

final selectedPieceProvider =
    FutureProvider.family<Piece?, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  final pieces = await db.getAllPieces();
  try {
    return pieces.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});
