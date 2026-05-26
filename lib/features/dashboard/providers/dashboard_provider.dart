import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/core/database/app_database.dart';

// ─── Dashboard Stats ────────────────────────────────────────────────────────

class DashboardStats {
  final int totalPieces;
  final double valeurStock;
  final int alertesRupture;
  final int mouvementsAujourdhui;
  final List<Piece> piecesSousSeuilMinimal;
  final List<MouvementStock> derniersMovements;

  const DashboardStats({
    required this.totalPieces,
    required this.valeurStock,
    required this.alertesRupture,
    required this.mouvementsAujourdhui,
    required this.piecesSousSeuilMinimal,
    required this.derniersMovements,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final db = ref.watch(databaseProvider);

  final allPieces = await db.getAllPieces();
  final piecesSous = await db.getPiecesSousSeuilMinimal();
  final mouvements30j = await db.getMouvements30Jours();

  final today = DateTime.now();
  final debutAujourdhui = DateTime(today.year, today.month, today.day);
  final mouvHui =
      mouvements30j.where((m) => m.date.isAfter(debutAujourdhui)).length;

  double valeur = 0;
  for (final p in allPieces) {
    valeur += p.quantiteEnStock * p.prixAchat;
  }

  // Derniers mouvements (5 max)
  final derniersMouvements = await (db.select(db.mouvementsStock)
        ..orderBy([(t) => OrderingTerm.desc(t.date)])
        ..limit(5))
      .get();

  return DashboardStats(
    totalPieces: allPieces.length,
    valeurStock: valeur,
    alertesRupture: piecesSous.where((p) => p.quantiteEnStock == 0).length,
    mouvementsAujourdhui: mouvHui,
    piecesSousSeuilMinimal: piecesSous.take(5).toList(),
    derniersMovements: derniersMouvements,
  );
});

// ─── Stock Chart Data ────────────────────────────────────────────────────────

class ChartPoint {
  final DateTime date;
  final int entrees;
  final int sorties;
  const ChartPoint(
      {required this.date, required this.entrees, required this.sorties});
}

final stockChartProvider = FutureProvider<List<ChartPoint>>((ref) async {
  final db = ref.watch(databaseProvider);
  final mouvements = await db.getMouvements30Jours();

  final map = <String, ChartPoint>{};
  final now = DateTime.now();

  // Pre-fill 30 days
  for (int i = 29; i >= 0; i--) {
    final d = now.subtract(Duration(days: i));
    final key = '${d.year}-${d.month}-${d.day}';
    map[key] = ChartPoint(date: d, entrees: 0, sorties: 0);
  }

  for (final m in mouvements) {
    final key = '${m.date.year}-${m.date.month}-${m.date.day}';
    final existing = map[key];
    if (existing != null) {
      map[key] = ChartPoint(
        date: existing.date,
        entrees: existing.entrees + (m.type == 'entree' ? m.quantite : 0),
        sorties: existing.sorties + (m.type == 'sortie' ? m.quantite : 0),
      );
    }
  }

  return map.values.toList();
});

// ─── Category Stats ──────────────────────────────────────────────────────────

final categoryStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getStockParCategorie();
});

// ─── Piece name lookup ───────────────────────────────────────────────────────

final allPiecesMapProvider = FutureProvider<Map<int, Piece>>((ref) async {
  final db = ref.watch(databaseProvider);
  final pieces = await db.getAllPieces();
  return {for (final p in pieces) p.id: p};
});
