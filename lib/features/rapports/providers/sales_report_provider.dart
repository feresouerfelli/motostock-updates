import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motostock_pro/app.dart';

class SaleRecord {
  final String txId;
  final DateTime date;
  final double total;
  final double discount;
  final double cost;
  final double profit;
  final int itemCount;
  final bool fromWeb;

  const SaleRecord({
    required this.txId,
    required this.date,
    required this.total,
    required this.discount,
    required this.cost,
    required this.profit,
    required this.itemCount,
    required this.fromWeb,
  });
}

class SalesReport {
  final double revenueToday;
  final double revenueMonth;
  final double discountsToday;
  final double profitToday;
  final int salesToday;
  final int salesMonth;
  final List<SaleRecord> recentSales;

  const SalesReport({
    required this.revenueToday,
    required this.revenueMonth,
    required this.discountsToday,
    required this.profitToday,
    required this.salesToday,
    required this.salesMonth,
    required this.recentSales,
  });
}

final salesReportProvider = FutureProvider<SalesReport>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final startOfMonth = DateTime(now.year, now.month, 1);

  final mouvements = await db.getMouvementsByDateRange(
    startOfMonth.subtract(const Duration(days: 365)),
    now.add(const Duration(days: 1)),
  );

  final Map<String, SaleRecord> byTx = {};
  final allPieces = await db.getAllPieces();
  final pieceMap = {for (final p in allPieces) p.id: p};

  for (final m in mouvements) {
    if (m.motif == null || !m.motif!.contains('Vente caisse #')) continue;

    final parsed = _parseSaleMotif(m.motif!);
    if (parsed == null) continue;
    final piece = pieceMap[m.pieceId];
    final lineCost = (parsed.purchasePrice > 0
            ? parsed.purchasePrice
            : (piece?.prixAchat ?? 0.0)) *
        m.quantite;

    final existing = byTx[parsed.txId];
    if (existing != null) {
      final cost = existing.cost + lineCost;
      byTx[parsed.txId] = SaleRecord(
        txId: parsed.txId,
        date: existing.date.isAfter(m.date) ? existing.date : m.date,
        total: parsed.total > 0 ? parsed.total : existing.total,
        discount: parsed.discount > 0 ? parsed.discount : existing.discount,
        cost: cost,
        profit: (parsed.total > 0 ? parsed.total : existing.total) - cost,
        itemCount: existing.itemCount + 1,
        fromWeb: existing.fromWeb || parsed.fromWeb,
      );
    } else {
      byTx[parsed.txId] = SaleRecord(
        txId: parsed.txId,
        date: m.date,
        total: parsed.total,
        discount: parsed.discount,
        cost: lineCost,
        profit: parsed.total - lineCost,
        itemCount: 1,
        fromWeb: parsed.fromWeb,
      );
    }
  }

  final sales = byTx.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  double revenueToday = 0;
  double revenueMonth = 0;
  double discountsToday = 0;
  double profitToday = 0;
  int salesToday = 0;
  int salesMonth = 0;

  for (final s in sales) {
    if (!s.date.isBefore(startOfDay)) {
      revenueToday += s.total;
      discountsToday += s.discount;
      profitToday += s.profit;
      salesToday++;
    }
    if (!s.date.isBefore(startOfMonth)) {
      revenueMonth += s.total;
      salesMonth++;
    }
  }

  return SalesReport(
    revenueToday: revenueToday,
    revenueMonth: revenueMonth,
    discountsToday: discountsToday,
    profitToday: profitToday,
    salesToday: salesToday,
    salesMonth: salesMonth,
    recentSales: sales.take(20).toList(),
  );
});

({
  String txId,
  double total,
  double discount,
  double purchasePrice,
  bool fromWeb
})? _parseSaleMotif(String motif) {
  final parts = motif.split('|').map((s) => s.trim()).toList();
  String? txId;
  double total = 0;
  double discount = 0;
  double purchasePrice = 0;
  var fromWeb = motif.contains('Commande Web');

  double extractNumber(String text) {
    final match = RegExp(r'[\d\.]+').firstMatch(text);
    return match != null ? (double.tryParse(match.group(0) ?? '0') ?? 0) : 0;
  }

  for (final part in parts) {
    if (part.contains('Vente caisse #')) {
      txId = part.replaceAll('Vente caisse #', '').trim();
    } else if (part.contains('Remise:')) {
      discount = extractNumber(part);
    } else if (part.contains('PA:')) {
      purchasePrice = extractNumber(part);
    } else if (part.contains('Total Vente:')) {
      total = extractNumber(part);
    }
  }

  if (txId == null || txId.isEmpty) return null;
  return (
    txId: txId,
    total: total,
    discount: discount,
    purchasePrice: purchasePrice,
    fromWeb: fromWeb
  );
}

// ─── TOP SELLING PRODUCTS ────────────────────────────────────────────────────

class TopProductRecord {
  final int pieceId;
  final String pieceName;
  final String reference;
  final String categorie;
  final double prixVente;
  final int totalQty;
  final double totalRevenue;

  const TopProductRecord({
    required this.pieceId,
    required this.pieceName,
    required this.reference,
    required this.categorie,
    required this.prixVente,
    required this.totalQty,
    required this.totalRevenue,
  });
}

class TopSellingData {
  final List<TopProductRecord> week;
  final List<TopProductRecord> month;
  final List<TopProductRecord> year;

  const TopSellingData({
    required this.week,
    required this.month,
    required this.year,
  });
}

final topSellingProvider = FutureProvider<TopSellingData>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  // Period boundaries
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final weekStart =
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final monthStart = DateTime(now.year, now.month, 1);
  final yearStart = DateTime(now.year, 1, 1);

  // Fetch all sale movements for this year
  final mouvements = await db.getMouvementsByDateRange(
    yearStart,
    now.add(const Duration(days: 1)),
  );

  // Load all pieces for name/reference lookup
  final allPieces = await db.getAllPieces();
  final pieceMap = {for (final p in allPieces) p.id: p};

  // Aggregation maps: pieceId -> {totalQty, totalRevenue}
  final Map<int, _AggEntry> weekMap = {};
  final Map<int, _AggEntry> monthMap = {};
  final Map<int, _AggEntry> yearMap = {};

  for (final m in mouvements) {
    if (m.type != 'sortie') continue;
    if (m.motif == null || !m.motif!.contains('Vente caisse #')) continue;

    // Extract unit price from motif if available (fallback to piece.prixVente)
    final piece = pieceMap[m.pieceId];
    if (piece == null) continue;

    // Parse price per unit from motif: "PU: 1200 DT"
    double unitPrice = piece.prixVente;
    final puMatch = RegExp(r'PU:\s*([\d\.]+)').firstMatch(m.motif ?? '');
    if (puMatch != null) {
      unitPrice = double.tryParse(puMatch.group(1) ?? '') ?? piece.prixVente;
    }

    final revenue = unitPrice * m.quantite;

    // Year accumulation
    if (!m.date.isBefore(yearStart)) {
      yearMap[m.pieceId] = _AggEntry(
        qty: (yearMap[m.pieceId]?.qty ?? 0) + m.quantite,
        revenue: (yearMap[m.pieceId]?.revenue ?? 0) + revenue,
      );
    }
    // Month accumulation
    if (!m.date.isBefore(monthStart)) {
      monthMap[m.pieceId] = _AggEntry(
        qty: (monthMap[m.pieceId]?.qty ?? 0) + m.quantite,
        revenue: (monthMap[m.pieceId]?.revenue ?? 0) + revenue,
      );
    }
    // Week accumulation
    if (!m.date.isBefore(weekStart)) {
      weekMap[m.pieceId] = _AggEntry(
        qty: (weekMap[m.pieceId]?.qty ?? 0) + m.quantite,
        revenue: (weekMap[m.pieceId]?.revenue ?? 0) + revenue,
      );
    }
  }

  List<TopProductRecord> buildRanking(Map<int, _AggEntry> map) {
    final list = map.entries
        .map((e) {
          final p = pieceMap[e.key];
          if (p == null) return null;
          return TopProductRecord(
            pieceId: p.id,
            pieceName: p.nom,
            reference: p.reference,
            categorie: p.categorie,
            prixVente: p.prixVente,
            totalQty: e.value.qty,
            totalRevenue: e.value.revenue,
          );
        })
        .whereType<TopProductRecord>()
        .toList();
    list.sort((a, b) => b.totalQty.compareTo(a.totalQty));
    return list.take(10).toList();
  }

  return TopSellingData(
    week: buildRanking(weekMap),
    month: buildRanking(monthMap),
    year: buildRanking(yearMap),
  );
});

class _AggEntry {
  final int qty;
  final double revenue;
  const _AggEntry({required this.qty, required this.revenue});
}
