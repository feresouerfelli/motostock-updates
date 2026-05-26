import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motostock_pro/core/database/app_database.dart';
import 'package:motostock_pro/app.dart';

final lowStockPiecesProvider = StreamProvider<List<Piece>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.pieces).watch().map((pieces) =>
      pieces.where((p) => p.quantiteEnStock < p.quantiteMinimale).toList());
});
