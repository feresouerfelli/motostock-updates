import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

@DataClassName('Piece')
class Pieces extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get reference => text()();
  TextColumn get nom => text()();
  TextColumn get description => text().nullable()();
  TextColumn get categorie => text()();
  TextColumn get compatibilitesMotos => text().nullable()();
  IntColumn get quantiteEnStock => integer().withDefault(const Constant(0))();
  IntColumn get quantiteMinimale => integer().withDefault(const Constant(5))();
  RealColumn get prixAchat => real().withDefault(const Constant(0.0))();
  RealColumn get prixVente => real().withDefault(const Constant(0.0))();
  TextColumn get imagePath => text().nullable()();
  TextColumn get emplacement => text().nullable()();
  IntColumn get garantieDuree => integer().withDefault(const Constant(0))();
  IntColumn get fournisseurId => integer().nullable()();
  DateTimeColumn get dateLastMaj => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Fournisseur')
class Fournisseurs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text()();
  TextColumn get contact => text().nullable()();
  TextColumn get telephone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get adresse => text().nullable()();
  IntColumn get delaiLivraisonMoyen => integer().nullable()(); // en jours
  TextColumn get conditionsPaiement => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('MouvementStock')
class MouvementsStock extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pieceId => integer().references(Pieces, #id)();
  TextColumn get type => text()(); // 'entree', 'sortie', 'ajustement'
  IntColumn get quantite => integer()();
  TextColumn get motif => text().nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Commande')
class Commandes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fournisseurId => integer().references(Fournisseurs, #id)();
  DateTimeColumn get dateCreation =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get statut => text().withDefault(
      const Constant('brouillon'))(); // 'brouillon', 'envoyée', 'reçue'
  TextColumn get notes => text().nullable()();
}

@DriftDatabase(tables: [Pieces, Fournisseurs, MouvementsStock, Commandes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(commandes);
            // In case prixAchat was missing in version 1
            try {
              await m.addColumn(pieces, pieces.prixAchat);
            } catch (_) {}
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await _repairLegacyNullPieceValues();
        },
      );

  Future<void> _repairLegacyNullPieceValues() async {
    try {
      await _ensureColumn('pieces', 'description', 'description TEXT');
      await _ensureColumn(
        'pieces',
        'compatibilites_motos',
        'compatibilites_motos TEXT',
      );
      await _ensureColumn(
        'pieces',
        'quantite_en_stock',
        'quantite_en_stock INTEGER DEFAULT 0',
      );
      await _ensureColumn(
        'pieces',
        'quantite_minimale',
        'quantite_minimale INTEGER DEFAULT 5',
      );
      await _ensureColumn('pieces', 'prix_achat', 'prix_achat REAL DEFAULT 0');
      await _ensureColumn('pieces', 'prix_vente', 'prix_vente REAL DEFAULT 0');
      await _ensureColumn('pieces', 'image_path', 'image_path TEXT');
      await _ensureColumn('pieces', 'emplacement', 'emplacement TEXT');
      await _ensureColumn(
        'pieces',
        'garantie_duree',
        'garantie_duree INTEGER DEFAULT 0',
      );
      await _ensureColumn('pieces', 'fournisseur_id', 'fournisseur_id INTEGER');
      await _ensureColumn('pieces', 'date_last_maj', 'date_last_maj INTEGER');
      await _ensureColumn('pieces', 'created_at', 'created_at INTEGER');

      await customStatement(
        "UPDATE pieces SET reference = 'REF-' || id WHERE reference IS NULL OR reference = ''",
      );
      await customStatement(
        "UPDATE pieces SET nom = 'Article sans nom' WHERE nom IS NULL OR nom = ''",
      );
      await customStatement(
        "UPDATE pieces SET categorie = 'Autre' WHERE categorie IS NULL OR categorie = ''",
      );
      await customStatement(
        'UPDATE pieces SET quantite_en_stock = 0 WHERE quantite_en_stock IS NULL',
      );
      await customStatement(
        'UPDATE pieces SET quantite_minimale = 5 WHERE quantite_minimale IS NULL',
      );
      await customStatement(
        'UPDATE pieces SET prix_achat = 0 WHERE prix_achat IS NULL',
      );
      await customStatement(
        'UPDATE pieces SET prix_vente = 0 WHERE prix_vente IS NULL',
      );
      await customStatement(
        'UPDATE pieces SET garantie_duree = 0 WHERE garantie_duree IS NULL',
      );
      await customStatement(
        "UPDATE pieces SET created_at = CAST(strftime('%s', 'now') AS INTEGER) WHERE created_at IS NULL",
      );
      await customStatement(
        "UPDATE mouvements_stock SET type = 'ajustement' WHERE type IS NULL OR type = ''",
      );
      await customStatement(
        'UPDATE mouvements_stock SET quantite = 0 WHERE quantite IS NULL',
      );
      await customStatement(
        "UPDATE mouvements_stock SET date = CAST(strftime('%s', 'now') AS INTEGER) WHERE date IS NULL",
      );
      await customStatement(
        "DELETE FROM mouvements_stock WHERE piece_id IS NULL OR piece_id NOT IN (SELECT id FROM pieces)",
      );
      await customStatement(
        "UPDATE fournisseurs SET nom = 'Fournisseur sans nom' WHERE nom IS NULL OR nom = ''",
      );
      await customStatement(
        "UPDATE fournisseurs SET created_at = CAST(strftime('%s', 'now') AS INTEGER) WHERE created_at IS NULL",
      );
      await customStatement(
        "UPDATE commandes SET statut = 'brouillon' WHERE statut IS NULL OR statut = ''",
      );
      await customStatement(
        "UPDATE commandes SET date_creation = CAST(strftime('%s', 'now') AS INTEGER) WHERE date_creation IS NULL",
      );
      await customStatement(
        "DELETE FROM commandes WHERE fournisseur_id IS NULL OR fournisseur_id NOT IN (SELECT id FROM fournisseurs)",
      );

      // --- Self-Healing: Fix any existing text/string timestamps by converting them to unix epoch integers ---
      await customStatement(
        "UPDATE pieces SET created_at = CAST(strftime('%s', created_at) AS INTEGER) WHERE typeof(created_at) = 'text' OR created_at LIKE '%-%'",
      );
      await customStatement(
        "UPDATE pieces SET date_last_maj = CAST(strftime('%s', date_last_maj) AS INTEGER) WHERE typeof(date_last_maj) = 'text' OR date_last_maj LIKE '%-%'",
      );
      await customStatement(
        "UPDATE mouvements_stock SET date = CAST(strftime('%s', date) AS INTEGER) WHERE typeof(date) = 'text' OR date LIKE '%-%'",
      );
      await customStatement(
        "UPDATE fournisseurs SET created_at = CAST(strftime('%s', created_at) AS INTEGER) WHERE typeof(created_at) = 'text' OR created_at LIKE '%-%'",
      );
      await customStatement(
        "UPDATE commandes SET date_creation = CAST(strftime('%s', date_creation) AS INTEGER) WHERE typeof(date_creation) = 'text' OR date_creation LIKE '%-%'",
      );
    } catch (_) {
      // Older or empty databases may not have the pieces table yet.
    }
  }

  Future<void> _ensureColumn(
    String table,
    String column,
    String definition,
  ) async {
    final columns = await customSelect('PRAGMA table_info($table)').get();
    final exists = columns.any((row) => row.read<String>('name') == column);
    if (!exists) {
      await customStatement('ALTER TABLE $table ADD COLUMN $definition');
    }
  }

  // --- Pieces Methods ---
  Future<List<Piece>> getAllPieces() {
    return _safePiecesQuery(orderBy: 'nom COLLATE NOCASE ASC').get();
  }

  Stream<List<Piece>> watchAllPieces() {
    return _safePiecesQuery(orderBy: 'nom COLLATE NOCASE ASC').watch();
  }

  Future<List<Piece>> searchPieces(String query) {
    final like = '%${query.trim()}%';
    return _safePiecesQuery(
      where: '''
        COALESCE(nom, '') LIKE ?
        OR COALESCE(reference, '') LIKE ?
        OR COALESCE(categorie, '') LIKE ?
      ''',
      variables: [
        Variable.withString(like),
        Variable.withString(like),
        Variable.withString(like)
      ],
      orderBy: 'nom COLLATE NOCASE ASC',
    ).get();
  }

  Future<int> insertPiece(PiecesCompanion piece) => into(pieces).insert(piece);
  Future<bool> updatePiece(Piece piece) => update(pieces).replace(piece);
  Future<int> deletePiece(int id) {
    return transaction(() async {
      await (delete(mouvementsStock)..where((t) => t.pieceId.equals(id))).go();
      return await (delete(pieces)..where((t) => t.id.equals(id))).go();
    });
  }
  Future<Piece?> getPieceById(int id) {
    return _safePiecesQuery(
      where: 'id = ?',
      variables: [Variable.withInt(id)],
    ).getSingleOrNull();
  }

  Future<Piece?> getPieceByReference(String refCode) {
    return _safePiecesQuery(
      where: "COALESCE(reference, '') = ?",
      variables: [Variable.withString(refCode)],
    ).getSingleOrNull();
  }

  Selectable<Piece> _safePiecesQuery({
    String? where,
    List<Variable<Object>> variables = const [],
    String? orderBy,
  }) {
    final buffer = StringBuffer('''
      SELECT
        COALESCE(id, 0) AS id,
        COALESCE(reference, 'REF-' || id) AS reference,
        COALESCE(nom, 'Article sans nom') AS nom,
        description,
        COALESCE(categorie, 'Autre') AS categorie,
        compatibilites_motos,
        COALESCE(quantite_en_stock, 0) AS quantite_en_stock,
        COALESCE(quantite_minimale, 5) AS quantite_minimale,
        COALESCE(prix_achat, 0) AS prix_achat,
        COALESCE(prix_vente, 0) AS prix_vente,
        image_path,
        emplacement,
        COALESCE(garantie_duree, 0) AS garantie_duree,
        fournisseur_id,
        date_last_maj,
        created_at
      FROM pieces
    ''');
    if (where != null && where.trim().isNotEmpty) {
      buffer.write(' WHERE $where');
    }
    if (orderBy != null && orderBy.trim().isNotEmpty) {
      buffer.write(' ORDER BY $orderBy');
    }

    return customSelect(
      buffer.toString(),
      variables: variables,
      readsFrom: {pieces},
    ).map((row) {
      final id = row.read<int>('id');
      return Piece(
        id: id,
        reference: row.read<String>('reference'),
        nom: row.read<String>('nom'),
        description: row.readNullable<String>('description'),
        categorie: row.read<String>('categorie'),
        compatibilitesMotos: row.readNullable<String>('compatibilites_motos'),
        quantiteEnStock: row.read<int>('quantite_en_stock'),
        quantiteMinimale: row.read<int>('quantite_minimale'),
        prixAchat: row.read<double>('prix_achat'),
        prixVente: row.read<double>('prix_vente'),
        imagePath: row.readNullable<String>('image_path'),
        emplacement: row.readNullable<String>('emplacement'),
        garantieDuree: row.read<int>('garantie_duree'),
        fournisseurId: row.readNullable<int>('fournisseur_id'),
        dateLastMaj: _safeParseDate(row.data['date_last_maj']),
        createdAt: _safeParseDate(row.data['created_at']) ?? DateTime.now(),
      );
    });
  }

  Future<Map<String, int>> getStockParCategorie() async {
    final all = await getAllPieces();
    final Map<String, int> stats = {};
    for (final p in all) {
      final cat = p.categorie;
      stats[cat] = (stats[cat] ?? 0) + p.quantiteEnStock;
    }
    return stats;
  }

  Future<List<Piece>> getPiecesSousSeuilMinimal() {
    return _safePiecesQuery(
      where: 'COALESCE(quantite_en_stock, 0) < COALESCE(quantite_minimale, 5)',
      orderBy: 'nom COLLATE NOCASE ASC',
    ).get();
  }

  // --- Fournisseurs Methods ---
  Future<List<Fournisseur>> getAllFournisseurs() => select(fournisseurs).get();
  Stream<List<Fournisseur>> watchAllFournisseurs() =>
      select(fournisseurs).watch();
  Future<int> insertFournisseur(FournisseursCompanion fournisseur) =>
      into(fournisseurs).insert(fournisseur);
  Future<bool> updateFournisseur(Fournisseur fournisseur) =>
      update(fournisseurs).replace(fournisseur);
  Future<int> deleteFournisseur(int id) =>
      (delete(fournisseurs)..where((t) => t.id.equals(id))).go();

  // --- Mouvements Methods ---
  Future<List<MouvementStock>> getAllMouvements() =>
      select(mouvementsStock).get();

  Future<List<MouvementStock>> getMouvements30Jours() {
    final start = DateTime.now().subtract(const Duration(days: 30));
    return (select(mouvementsStock)
          ..where((t) => t.date.isBiggerOrEqualValue(start)))
        .get();
  }

  Stream<List<MouvementStock>> watchRecentMouvements({int limit = 100}) {
    return (select(mouvementsStock)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .watch();
  }

  Future<List<MouvementStock>> getMouvementsByDateRange(
      DateTime start, DateTime end) {
    return (select(mouvementsStock)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<int> insertMouvement(MouvementsStockCompanion mouvement) =>
      into(mouvementsStock).insert(mouvement);

  // --- Commandes Methods ---
  Future<List<Commande>> getAllCommandes() => select(commandes).get();
  Stream<List<Commande>> watchAllCommandes() =>
      (select(commandes)..orderBy([(t) => OrderingTerm.desc(t.dateCreation)]))
          .watch();
  Future<int> insertCommande(CommandesCompanion commande) =>
      into(commandes).insert(commande);
  Future<bool> updateCommande(Commande commande) =>
      update(commandes).replace(commande);

  Future<void> receptionnerCommande(int id) async {
    await transaction(() async {
      final c = await (select(commandes)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (c != null && c.statut != 'reçue') {
        // Here we could add logic to increment stock for items in the order
        // But the current schema doesn't have CommandeItems.
        // If the user wants simple reception, we just change status.
        await update(commandes).replace(c.copyWith(statut: 'reçue'));
      }
    });
  }

  /// Deletes a movement and Reverts its stock effect!
  Future<void> deleteMouvement(int id) async {
    await transaction(() async {
      final m = await (select(mouvementsStock)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (m != null) {
        final piece = await getPieceById(m.pieceId);
        if (piece != null) {
          int newQty = piece.quantiteEnStock;
          if (m.type == 'entree') {
            newQty -= m.quantite;
          } else if (m.type == 'sortie') {
            newQty += m.quantite;
          }
          await updatePiece(piece.copyWith(quantiteEnStock: newQty));
        }
        await (delete(mouvementsStock)..where((t) => t.id.equals(id))).go();
      }
    });
  }

  // Business Logic: Add Stock
  Future<void> addStock(int pieceId, int qty, String? motif) async {
    await transaction(() async {
      final piece = await getPieceById(pieceId);
      if (piece != null) {
        await updatePiece(
            piece.copyWith(quantiteEnStock: piece.quantiteEnStock + qty));
        await insertMouvement(MouvementsStockCompanion.insert(
          pieceId: pieceId,
          type: 'entree',
          quantite: qty,
          motif: Value(motif),
          date: Value(DateTime.now()),
        ));
      }
    });
  }

  // Business Logic: Remove Stock
  Future<void> removeStock(int pieceId, int qty, String? motif) async {
    await transaction(() async {
      final piece = await getPieceById(pieceId);
      if (piece != null) {
        await updatePiece(
            piece.copyWith(quantiteEnStock: piece.quantiteEnStock - qty));
        await insertMouvement(MouvementsStockCompanion.insert(
          pieceId: pieceId,
          type: 'sortie',
          quantite: qty,
          motif: Value(motif),
          date: Value(DateTime.now()),
        ));
      }
    });
  }
}

/// Safely parse a date value that may be stored as int (epoch seconds),
/// double, text (ISO-8601 or epoch string), or null.
DateTime? _safeParseDate(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
  if (raw is double) {
    return DateTime.fromMillisecondsSinceEpoch(raw.toInt() * 1000);
  }
  if (raw is String) {
    final asInt = int.tryParse(raw);
    if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt * 1000);
    return DateTime.tryParse(raw);
  }
  return null;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'motostock.sqlite'));
    return NativeDatabase(file);
  });
}
