import 'package:flutter/foundation.dart';
import 'package:motostock_pro/core/database/app_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mysql_client/mysql_client.dart';
import 'dart:async';

/// Service de synchronisation bidirectionnelle :
///   Drift (SQLite) ──> WampServer (MySQL local) ──> Supabase (Cloud)
///
/// - Si WampServer n'est pas démarré, l'app continue normalement sur Drift.
/// - Si internet n'est pas disponible, les données restent dans WampServer/SQLite.
/// - Dès que la connexion est rétablie, tout est poussé vers Supabase.
class SupabaseSyncService {
  final AppDatabase db;
  Timer? _syncTimer;

  // WampServer MySQL connection settings
  static const String _mysqlHost = 'localhost';
  static const int _mysqlPort = 3306;
  static const String _mysqlUser = 'root';
  static const String _mysqlPassword = ''; // WampServer default
  static const String _mysqlDatabase = 'motostock';

  SupabaseSyncService(this.db);

  void startSync() {
    // Initial sync after a short delay to let the app initialize
    Future.delayed(const Duration(seconds: 3), () => _sync());

    // Periodic sync every 2 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _sync();
    });
  }

  void stopSync() {
    _syncTimer?.cancel();
  }

  Future<void> _sync() async {
    debugPrint('[SyncService] Starting sync cycle...');

    // Step 1: SQLite (Drift) --> WampServer MySQL
    await _syncToWampServer();

    // Step 2: WampServer MySQL / SQLite --> Supabase Cloud
    await _syncToSupabase();

    debugPrint('[SyncService] Sync cycle completed.');
  }

  // ════════════════════════════════════════════════════════════
  //  STEP 1: Drift (SQLite) ──> WampServer MySQL
  // ════════════════════════════════════════════════════════════

  Future<void> _syncToWampServer() async {
    MySQLConnection? conn;
    try {
      conn = await MySQLConnection.createConnection(
        host: _mysqlHost,
        port: _mysqlPort,
        userName: _mysqlUser,
        password: _mysqlPassword,
        databaseName: _mysqlDatabase,
      );
      await conn.connect();
      debugPrint('[SyncService] Connected to WampServer MySQL.');

      // Sync fournisseurs
      final fournisseurs = await db.getAllFournisseurs();
      for (final f in fournisseurs) {
        await conn.execute(
          'INSERT INTO fournisseurs (id, nom, contact, telephone, email, adresse, delai_livraison_moyen, conditions_paiement, created_at) '
          'VALUES (:id, :nom, :contact, :tel, :email, :adresse, :delai, :conditions, :created) '
          'ON DUPLICATE KEY UPDATE nom=:nom, contact=:contact, telephone=:tel, email=:email, '
          'adresse=:adresse, delai_livraison_moyen=:delai, conditions_paiement=:conditions',
          {
            'id': f.id,
            'nom': f.nom,
            'contact': f.contact ?? '',
            'tel': f.telephone ?? '',
            'email': f.email ?? '',
            'adresse': f.adresse ?? '',
            'delai': f.delaiLivraisonMoyen ?? 0,
            'conditions': f.conditionsPaiement ?? '',
            'created': f.createdAt.toIso8601String(),
          },
        );
      }
      debugPrint(
          '[SyncService] Synced ${fournisseurs.length} fournisseurs to MySQL.');

      // Sync pieces
      final pieces = await db.getAllPieces();
      for (final p in pieces) {
        await conn.execute(
          'INSERT INTO pieces (id, reference, nom, description, categorie, compatibilites_motos, '
          'quantite_en_stock, quantite_minimale, prix_achat, prix_vente, image_path, emplacement, '
          'garantie_duree, fournisseur_id, date_last_maj, created_at) '
          'VALUES (:id, :ref, :nom, :desc, :cat, :compat, :qte, :qmin, :pa, :pv, :img, :empl, :gar, :fid, :maj, :created) '
          'ON DUPLICATE KEY UPDATE nom=:nom, description=:desc, categorie=:cat, compatibilites_motos=:compat, '
          'quantite_en_stock=:qte, quantite_minimale=:qmin, prix_achat=:pa, prix_vente=:pv, '
          'image_path=:img, emplacement=:empl, garantie_duree=:gar, fournisseur_id=:fid, date_last_maj=:maj',
          {
            'id': p.id,
            'ref': p.reference,
            'nom': p.nom,
            'desc': p.description ?? '',
            'cat': p.categorie,
            'compat': p.compatibilitesMotos ?? '',
            'qte': p.quantiteEnStock,
            'qmin': p.quantiteMinimale,
            'pa': p.prixAchat,
            'pv': p.prixVente,
            'img': p.imagePath ?? '',
            'empl': p.emplacement ?? '',
            'gar': p.garantieDuree,
            'fid': p.fournisseurId,
            'maj': p.dateLastMaj?.toIso8601String(),
            'created': p.createdAt.toIso8601String(),
          },
        );
      }
      debugPrint('[SyncService] Synced ${pieces.length} pieces to MySQL.');

      // Sync mouvements_stock
      final mouvements = await db.getAllMouvements();
      for (final m in mouvements) {
        await conn.execute(
          'INSERT INTO mouvements_stock (id, piece_id, type, quantite, motif, date) '
          'VALUES (:id, :pid, :type, :qty, :motif, :date) '
          'ON DUPLICATE KEY UPDATE piece_id=:pid, type=:type, quantite=:qty, motif=:motif, date=:date',
          {
            'id': m.id,
            'pid': m.pieceId,
            'type': m.type,
            'qty': m.quantite,
            'motif': m.motif ?? '',
            'date': m.date.toIso8601String(),
          },
        );
      }
      debugPrint(
          '[SyncService] Synced ${mouvements.length} mouvements to MySQL.');

      // Sync commandes
      final commandes = await db.getAllCommandes();
      for (final c in commandes) {
        await conn.execute(
          'INSERT INTO commandes (id, fournisseur_id, date_creation, statut, notes) '
          'VALUES (:id, :fid, :dc, :statut, :notes) '
          'ON DUPLICATE KEY UPDATE fournisseur_id=:fid, date_creation=:dc, statut=:statut, notes=:notes',
          {
            'id': c.id,
            'fid': c.fournisseurId,
            'dc': c.dateCreation.toIso8601String(),
            'statut': c.statut,
            'notes': c.notes ?? '',
          },
        );
      }
      debugPrint(
          '[SyncService] Synced ${commandes.length} commandes to MySQL.');
    } catch (e) {
      debugPrint(
          '[SyncService] WampServer MySQL unavailable (app continues on Drift): $e');
    } finally {
      try {
        await conn?.close();
      } catch (_) {}
    }
  }

  // ════════════════════════════════════════════════════════════
  //  STEP 2: Drift (SQLite) ──> Supabase Cloud
  // ════════════════════════════════════════════════════════════

  Future<void> _syncToSupabase() async {
    try {
      final supabase = Supabase.instance.client;

      // Sync pieces to Supabase 'pieces' table
      final pieces = await db.getAllPieces();
      for (final p in pieces) {
        await supabase.from('pieces').upsert(
          {
            'id': p.id,
            'reference': p.reference,
            'nom': p.nom,
            'description': p.description,
            'categorie': p.categorie,
            'compatibilites_motos': p.compatibilitesMotos,
            'quantite_en_stock': p.quantiteEnStock,
            'quantite_minimale': p.quantiteMinimale,
            'prix_achat': p.prixAchat,
            'prix_vente': p.prixVente,
            'image_path': p.imagePath,
            'emplacement': p.emplacement,
            'garantie_duree': p.garantieDuree,
            'fournisseur_id': p.fournisseurId,
            'date_last_maj': p.dateLastMaj?.toIso8601String(),
            'created_at': p.createdAt.toIso8601String(),
          },
          onConflict: 'id',
        );
      }
      debugPrint(
          '[SyncService] Synced ${pieces.length} pieces to Supabase.');

      // Sync fournisseurs to Supabase
      final fournisseurs = await db.getAllFournisseurs();
      for (final f in fournisseurs) {
        await supabase.from('fournisseurs').upsert(
          {
            'id': f.id,
            'nom': f.nom,
            'contact': f.contact,
            'telephone': f.telephone,
            'email': f.email,
            'adresse': f.adresse,
            'delai_livraison_moyen': f.delaiLivraisonMoyen,
            'conditions_paiement': f.conditionsPaiement,
            'created_at': f.createdAt.toIso8601String(),
          },
          onConflict: 'id',
        );
      }
      debugPrint(
          '[SyncService] Synced ${fournisseurs.length} fournisseurs to Supabase.');

      // Sync mouvements_stock to Supabase
      final mouvements = await db.getAllMouvements();
      for (final m in mouvements) {
        await supabase.from('mouvements_stock').upsert(
          {
            'id': m.id,
            'piece_id': m.pieceId,
            'type': m.type,
            'quantite': m.quantite,
            'motif': m.motif,
            'date': m.date.toIso8601String(),
          },
          onConflict: 'id',
        );
      }
      debugPrint(
          '[SyncService] Synced ${mouvements.length} mouvements to Supabase.');

      // Sync commandes to Supabase
      final commandes = await db.getAllCommandes();
      for (final c in commandes) {
        await supabase.from('commandes').upsert(
          {
            'id': c.id,
            'fournisseur_id': c.fournisseurId,
            'date_creation': c.dateCreation.toIso8601String(),
            'statut': c.statut,
            'notes': c.notes,
          },
          onConflict: 'id',
        );
      }
      debugPrint(
          '[SyncService] Synced ${commandes.length} commandes to Supabase.');

      // Also sync pieces to the web 'parts' + 'stock' tables for the storefront
      for (final p in pieces) {
        await supabase.from('parts').upsert(
          {
            'name': p.nom,
            'description': p.description,
            'price': p.prixVente,
            'category': p.categorie,
            'reference': p.reference,
            'compatibility': p.compatibilitesMotos,
            'image_url': p.imagePath,
          },
          onConflict: 'reference',
        );
      }

      // Update stock levels on web 'stock' table
      final partsResponse =
          await supabase.from('parts').select('id, reference');
      final partsMap = <String, String>{}; // reference -> uuid
      for (final row in partsResponse) {
        partsMap[row['reference'] as String] = row['id'] as String;
      }

      for (final p in pieces) {
        final partUuid = partsMap[p.reference];
        if (partUuid != null) {
          await supabase.from('stock').upsert(
            {
              'part_id': partUuid,
              'quantity': p.quantiteEnStock,
              'min_threshold': p.quantiteMinimale,
            },
            onConflict: 'part_id',
          );
        }
      }
      debugPrint(
          '[SyncService] Synced parts & stock to Supabase web storefront.');
    } catch (e) {
      debugPrint(
          '[SyncService] Supabase sync error (no internet or server down): $e');
    }
  }

  Future<void> syncNow() => _sync();
  Future<void> syncFromCloud() => _sync();
}
