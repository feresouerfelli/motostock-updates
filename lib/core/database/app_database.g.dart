// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PiecesTable extends Pieces with TableInfo<$PiecesTable, Piece> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PiecesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categorieMeta =
      const VerificationMeta('categorie');
  @override
  late final GeneratedColumn<String> categorie = GeneratedColumn<String>(
      'categorie', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _compatibilitesMotosMeta =
      const VerificationMeta('compatibilitesMotos');
  @override
  late final GeneratedColumn<String> compatibilitesMotos =
      GeneratedColumn<String>('compatibilites_motos', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantiteEnStockMeta =
      const VerificationMeta('quantiteEnStock');
  @override
  late final GeneratedColumn<int> quantiteEnStock = GeneratedColumn<int>(
      'quantite_en_stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quantiteMinimaleMeta =
      const VerificationMeta('quantiteMinimale');
  @override
  late final GeneratedColumn<int> quantiteMinimale = GeneratedColumn<int>(
      'quantite_minimale', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _prixAchatMeta =
      const VerificationMeta('prixAchat');
  @override
  late final GeneratedColumn<double> prixAchat = GeneratedColumn<double>(
      'prix_achat', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _prixVenteMeta =
      const VerificationMeta('prixVente');
  @override
  late final GeneratedColumn<double> prixVente = GeneratedColumn<double>(
      'prix_vente', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emplacementMeta =
      const VerificationMeta('emplacement');
  @override
  late final GeneratedColumn<String> emplacement = GeneratedColumn<String>(
      'emplacement', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _garantieDureeMeta =
      const VerificationMeta('garantieDuree');
  @override
  late final GeneratedColumn<int> garantieDuree = GeneratedColumn<int>(
      'garantie_duree', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fournisseurIdMeta =
      const VerificationMeta('fournisseurId');
  @override
  late final GeneratedColumn<int> fournisseurId = GeneratedColumn<int>(
      'fournisseur_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateLastMajMeta =
      const VerificationMeta('dateLastMaj');
  @override
  late final GeneratedColumn<DateTime> dateLastMaj = GeneratedColumn<DateTime>(
      'date_last_maj', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        reference,
        nom,
        description,
        categorie,
        compatibilitesMotos,
        quantiteEnStock,
        quantiteMinimale,
        prixAchat,
        prixVente,
        imagePath,
        emplacement,
        garantieDuree,
        fournisseurId,
        dateLastMaj,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pieces';
  @override
  VerificationContext validateIntegrity(Insertable<Piece> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('categorie')) {
      context.handle(_categorieMeta,
          categorie.isAcceptableOrUnknown(data['categorie']!, _categorieMeta));
    } else if (isInserting) {
      context.missing(_categorieMeta);
    }
    if (data.containsKey('compatibilites_motos')) {
      context.handle(
          _compatibilitesMotosMeta,
          compatibilitesMotos.isAcceptableOrUnknown(
              data['compatibilites_motos']!, _compatibilitesMotosMeta));
    }
    if (data.containsKey('quantite_en_stock')) {
      context.handle(
          _quantiteEnStockMeta,
          quantiteEnStock.isAcceptableOrUnknown(
              data['quantite_en_stock']!, _quantiteEnStockMeta));
    }
    if (data.containsKey('quantite_minimale')) {
      context.handle(
          _quantiteMinimaleMeta,
          quantiteMinimale.isAcceptableOrUnknown(
              data['quantite_minimale']!, _quantiteMinimaleMeta));
    }
    if (data.containsKey('prix_achat')) {
      context.handle(_prixAchatMeta,
          prixAchat.isAcceptableOrUnknown(data['prix_achat']!, _prixAchatMeta));
    }
    if (data.containsKey('prix_vente')) {
      context.handle(_prixVenteMeta,
          prixVente.isAcceptableOrUnknown(data['prix_vente']!, _prixVenteMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('emplacement')) {
      context.handle(
          _emplacementMeta,
          emplacement.isAcceptableOrUnknown(
              data['emplacement']!, _emplacementMeta));
    }
    if (data.containsKey('garantie_duree')) {
      context.handle(
          _garantieDureeMeta,
          garantieDuree.isAcceptableOrUnknown(
              data['garantie_duree']!, _garantieDureeMeta));
    }
    if (data.containsKey('fournisseur_id')) {
      context.handle(
          _fournisseurIdMeta,
          fournisseurId.isAcceptableOrUnknown(
              data['fournisseur_id']!, _fournisseurIdMeta));
    }
    if (data.containsKey('date_last_maj')) {
      context.handle(
          _dateLastMajMeta,
          dateLastMaj.isAcceptableOrUnknown(
              data['date_last_maj']!, _dateLastMajMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Piece map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Piece(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      categorie: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categorie'])!,
      compatibilitesMotos: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}compatibilites_motos']),
      quantiteEnStock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantite_en_stock'])!,
      quantiteMinimale: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantite_minimale'])!,
      prixAchat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}prix_achat'])!,
      prixVente: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}prix_vente'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      emplacement: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emplacement']),
      garantieDuree: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}garantie_duree'])!,
      fournisseurId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fournisseur_id']),
      dateLastMaj: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_last_maj']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PiecesTable createAlias(String alias) {
    return $PiecesTable(attachedDatabase, alias);
  }
}

class Piece extends DataClass implements Insertable<Piece> {
  final int id;
  final String reference;
  final String nom;
  final String? description;
  final String categorie;
  final String? compatibilitesMotos;
  final int quantiteEnStock;
  final int quantiteMinimale;
  final double prixAchat;
  final double prixVente;
  final String? imagePath;
  final String? emplacement;
  final int garantieDuree;
  final int? fournisseurId;
  final DateTime? dateLastMaj;
  final DateTime createdAt;
  const Piece(
      {required this.id,
      required this.reference,
      required this.nom,
      this.description,
      required this.categorie,
      this.compatibilitesMotos,
      required this.quantiteEnStock,
      required this.quantiteMinimale,
      required this.prixAchat,
      required this.prixVente,
      this.imagePath,
      this.emplacement,
      required this.garantieDuree,
      this.fournisseurId,
      this.dateLastMaj,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['reference'] = Variable<String>(reference);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['categorie'] = Variable<String>(categorie);
    if (!nullToAbsent || compatibilitesMotos != null) {
      map['compatibilites_motos'] = Variable<String>(compatibilitesMotos);
    }
    map['quantite_en_stock'] = Variable<int>(quantiteEnStock);
    map['quantite_minimale'] = Variable<int>(quantiteMinimale);
    map['prix_achat'] = Variable<double>(prixAchat);
    map['prix_vente'] = Variable<double>(prixVente);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || emplacement != null) {
      map['emplacement'] = Variable<String>(emplacement);
    }
    map['garantie_duree'] = Variable<int>(garantieDuree);
    if (!nullToAbsent || fournisseurId != null) {
      map['fournisseur_id'] = Variable<int>(fournisseurId);
    }
    if (!nullToAbsent || dateLastMaj != null) {
      map['date_last_maj'] = Variable<DateTime>(dateLastMaj);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PiecesCompanion toCompanion(bool nullToAbsent) {
    return PiecesCompanion(
      id: Value(id),
      reference: Value(reference),
      nom: Value(nom),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      categorie: Value(categorie),
      compatibilitesMotos: compatibilitesMotos == null && nullToAbsent
          ? const Value.absent()
          : Value(compatibilitesMotos),
      quantiteEnStock: Value(quantiteEnStock),
      quantiteMinimale: Value(quantiteMinimale),
      prixAchat: Value(prixAchat),
      prixVente: Value(prixVente),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      emplacement: emplacement == null && nullToAbsent
          ? const Value.absent()
          : Value(emplacement),
      garantieDuree: Value(garantieDuree),
      fournisseurId: fournisseurId == null && nullToAbsent
          ? const Value.absent()
          : Value(fournisseurId),
      dateLastMaj: dateLastMaj == null && nullToAbsent
          ? const Value.absent()
          : Value(dateLastMaj),
      createdAt: Value(createdAt),
    );
  }

  factory Piece.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Piece(
      id: serializer.fromJson<int>(json['id']),
      reference: serializer.fromJson<String>(json['reference']),
      nom: serializer.fromJson<String>(json['nom']),
      description: serializer.fromJson<String?>(json['description']),
      categorie: serializer.fromJson<String>(json['categorie']),
      compatibilitesMotos:
          serializer.fromJson<String?>(json['compatibilitesMotos']),
      quantiteEnStock: serializer.fromJson<int>(json['quantiteEnStock']),
      quantiteMinimale: serializer.fromJson<int>(json['quantiteMinimale']),
      prixAchat: serializer.fromJson<double>(json['prixAchat']),
      prixVente: serializer.fromJson<double>(json['prixVente']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      emplacement: serializer.fromJson<String?>(json['emplacement']),
      garantieDuree: serializer.fromJson<int>(json['garantieDuree']),
      fournisseurId: serializer.fromJson<int?>(json['fournisseurId']),
      dateLastMaj: serializer.fromJson<DateTime?>(json['dateLastMaj']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reference': serializer.toJson<String>(reference),
      'nom': serializer.toJson<String>(nom),
      'description': serializer.toJson<String?>(description),
      'categorie': serializer.toJson<String>(categorie),
      'compatibilitesMotos': serializer.toJson<String?>(compatibilitesMotos),
      'quantiteEnStock': serializer.toJson<int>(quantiteEnStock),
      'quantiteMinimale': serializer.toJson<int>(quantiteMinimale),
      'prixAchat': serializer.toJson<double>(prixAchat),
      'prixVente': serializer.toJson<double>(prixVente),
      'imagePath': serializer.toJson<String?>(imagePath),
      'emplacement': serializer.toJson<String?>(emplacement),
      'garantieDuree': serializer.toJson<int>(garantieDuree),
      'fournisseurId': serializer.toJson<int?>(fournisseurId),
      'dateLastMaj': serializer.toJson<DateTime?>(dateLastMaj),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Piece copyWith(
          {int? id,
          String? reference,
          String? nom,
          Value<String?> description = const Value.absent(),
          String? categorie,
          Value<String?> compatibilitesMotos = const Value.absent(),
          int? quantiteEnStock,
          int? quantiteMinimale,
          double? prixAchat,
          double? prixVente,
          Value<String?> imagePath = const Value.absent(),
          Value<String?> emplacement = const Value.absent(),
          int? garantieDuree,
          Value<int?> fournisseurId = const Value.absent(),
          Value<DateTime?> dateLastMaj = const Value.absent(),
          DateTime? createdAt}) =>
      Piece(
        id: id ?? this.id,
        reference: reference ?? this.reference,
        nom: nom ?? this.nom,
        description: description.present ? description.value : this.description,
        categorie: categorie ?? this.categorie,
        compatibilitesMotos: compatibilitesMotos.present
            ? compatibilitesMotos.value
            : this.compatibilitesMotos,
        quantiteEnStock: quantiteEnStock ?? this.quantiteEnStock,
        quantiteMinimale: quantiteMinimale ?? this.quantiteMinimale,
        prixAchat: prixAchat ?? this.prixAchat,
        prixVente: prixVente ?? this.prixVente,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        emplacement: emplacement.present ? emplacement.value : this.emplacement,
        garantieDuree: garantieDuree ?? this.garantieDuree,
        fournisseurId:
            fournisseurId.present ? fournisseurId.value : this.fournisseurId,
        dateLastMaj: dateLastMaj.present ? dateLastMaj.value : this.dateLastMaj,
        createdAt: createdAt ?? this.createdAt,
      );
  Piece copyWithCompanion(PiecesCompanion data) {
    return Piece(
      id: data.id.present ? data.id.value : this.id,
      reference: data.reference.present ? data.reference.value : this.reference,
      nom: data.nom.present ? data.nom.value : this.nom,
      description:
          data.description.present ? data.description.value : this.description,
      categorie: data.categorie.present ? data.categorie.value : this.categorie,
      compatibilitesMotos: data.compatibilitesMotos.present
          ? data.compatibilitesMotos.value
          : this.compatibilitesMotos,
      quantiteEnStock: data.quantiteEnStock.present
          ? data.quantiteEnStock.value
          : this.quantiteEnStock,
      quantiteMinimale: data.quantiteMinimale.present
          ? data.quantiteMinimale.value
          : this.quantiteMinimale,
      prixAchat: data.prixAchat.present ? data.prixAchat.value : this.prixAchat,
      prixVente: data.prixVente.present ? data.prixVente.value : this.prixVente,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      emplacement:
          data.emplacement.present ? data.emplacement.value : this.emplacement,
      garantieDuree: data.garantieDuree.present
          ? data.garantieDuree.value
          : this.garantieDuree,
      fournisseurId: data.fournisseurId.present
          ? data.fournisseurId.value
          : this.fournisseurId,
      dateLastMaj:
          data.dateLastMaj.present ? data.dateLastMaj.value : this.dateLastMaj,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Piece(')
          ..write('id: $id, ')
          ..write('reference: $reference, ')
          ..write('nom: $nom, ')
          ..write('description: $description, ')
          ..write('categorie: $categorie, ')
          ..write('compatibilitesMotos: $compatibilitesMotos, ')
          ..write('quantiteEnStock: $quantiteEnStock, ')
          ..write('quantiteMinimale: $quantiteMinimale, ')
          ..write('prixAchat: $prixAchat, ')
          ..write('prixVente: $prixVente, ')
          ..write('imagePath: $imagePath, ')
          ..write('emplacement: $emplacement, ')
          ..write('garantieDuree: $garantieDuree, ')
          ..write('fournisseurId: $fournisseurId, ')
          ..write('dateLastMaj: $dateLastMaj, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      reference,
      nom,
      description,
      categorie,
      compatibilitesMotos,
      quantiteEnStock,
      quantiteMinimale,
      prixAchat,
      prixVente,
      imagePath,
      emplacement,
      garantieDuree,
      fournisseurId,
      dateLastMaj,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Piece &&
          other.id == this.id &&
          other.reference == this.reference &&
          other.nom == this.nom &&
          other.description == this.description &&
          other.categorie == this.categorie &&
          other.compatibilitesMotos == this.compatibilitesMotos &&
          other.quantiteEnStock == this.quantiteEnStock &&
          other.quantiteMinimale == this.quantiteMinimale &&
          other.prixAchat == this.prixAchat &&
          other.prixVente == this.prixVente &&
          other.imagePath == this.imagePath &&
          other.emplacement == this.emplacement &&
          other.garantieDuree == this.garantieDuree &&
          other.fournisseurId == this.fournisseurId &&
          other.dateLastMaj == this.dateLastMaj &&
          other.createdAt == this.createdAt);
}

class PiecesCompanion extends UpdateCompanion<Piece> {
  final Value<int> id;
  final Value<String> reference;
  final Value<String> nom;
  final Value<String?> description;
  final Value<String> categorie;
  final Value<String?> compatibilitesMotos;
  final Value<int> quantiteEnStock;
  final Value<int> quantiteMinimale;
  final Value<double> prixAchat;
  final Value<double> prixVente;
  final Value<String?> imagePath;
  final Value<String?> emplacement;
  final Value<int> garantieDuree;
  final Value<int?> fournisseurId;
  final Value<DateTime?> dateLastMaj;
  final Value<DateTime> createdAt;
  const PiecesCompanion({
    this.id = const Value.absent(),
    this.reference = const Value.absent(),
    this.nom = const Value.absent(),
    this.description = const Value.absent(),
    this.categorie = const Value.absent(),
    this.compatibilitesMotos = const Value.absent(),
    this.quantiteEnStock = const Value.absent(),
    this.quantiteMinimale = const Value.absent(),
    this.prixAchat = const Value.absent(),
    this.prixVente = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.emplacement = const Value.absent(),
    this.garantieDuree = const Value.absent(),
    this.fournisseurId = const Value.absent(),
    this.dateLastMaj = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PiecesCompanion.insert({
    this.id = const Value.absent(),
    required String reference,
    required String nom,
    this.description = const Value.absent(),
    required String categorie,
    this.compatibilitesMotos = const Value.absent(),
    this.quantiteEnStock = const Value.absent(),
    this.quantiteMinimale = const Value.absent(),
    this.prixAchat = const Value.absent(),
    this.prixVente = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.emplacement = const Value.absent(),
    this.garantieDuree = const Value.absent(),
    this.fournisseurId = const Value.absent(),
    this.dateLastMaj = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : reference = Value(reference),
        nom = Value(nom),
        categorie = Value(categorie);
  static Insertable<Piece> custom({
    Expression<int>? id,
    Expression<String>? reference,
    Expression<String>? nom,
    Expression<String>? description,
    Expression<String>? categorie,
    Expression<String>? compatibilitesMotos,
    Expression<int>? quantiteEnStock,
    Expression<int>? quantiteMinimale,
    Expression<double>? prixAchat,
    Expression<double>? prixVente,
    Expression<String>? imagePath,
    Expression<String>? emplacement,
    Expression<int>? garantieDuree,
    Expression<int>? fournisseurId,
    Expression<DateTime>? dateLastMaj,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reference != null) 'reference': reference,
      if (nom != null) 'nom': nom,
      if (description != null) 'description': description,
      if (categorie != null) 'categorie': categorie,
      if (compatibilitesMotos != null)
        'compatibilites_motos': compatibilitesMotos,
      if (quantiteEnStock != null) 'quantite_en_stock': quantiteEnStock,
      if (quantiteMinimale != null) 'quantite_minimale': quantiteMinimale,
      if (prixAchat != null) 'prix_achat': prixAchat,
      if (prixVente != null) 'prix_vente': prixVente,
      if (imagePath != null) 'image_path': imagePath,
      if (emplacement != null) 'emplacement': emplacement,
      if (garantieDuree != null) 'garantie_duree': garantieDuree,
      if (fournisseurId != null) 'fournisseur_id': fournisseurId,
      if (dateLastMaj != null) 'date_last_maj': dateLastMaj,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PiecesCompanion copyWith(
      {Value<int>? id,
      Value<String>? reference,
      Value<String>? nom,
      Value<String?>? description,
      Value<String>? categorie,
      Value<String?>? compatibilitesMotos,
      Value<int>? quantiteEnStock,
      Value<int>? quantiteMinimale,
      Value<double>? prixAchat,
      Value<double>? prixVente,
      Value<String?>? imagePath,
      Value<String?>? emplacement,
      Value<int>? garantieDuree,
      Value<int?>? fournisseurId,
      Value<DateTime?>? dateLastMaj,
      Value<DateTime>? createdAt}) {
    return PiecesCompanion(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      categorie: categorie ?? this.categorie,
      compatibilitesMotos: compatibilitesMotos ?? this.compatibilitesMotos,
      quantiteEnStock: quantiteEnStock ?? this.quantiteEnStock,
      quantiteMinimale: quantiteMinimale ?? this.quantiteMinimale,
      prixAchat: prixAchat ?? this.prixAchat,
      prixVente: prixVente ?? this.prixVente,
      imagePath: imagePath ?? this.imagePath,
      emplacement: emplacement ?? this.emplacement,
      garantieDuree: garantieDuree ?? this.garantieDuree,
      fournisseurId: fournisseurId ?? this.fournisseurId,
      dateLastMaj: dateLastMaj ?? this.dateLastMaj,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categorie.present) {
      map['categorie'] = Variable<String>(categorie.value);
    }
    if (compatibilitesMotos.present) {
      map['compatibilites_motos'] = Variable<String>(compatibilitesMotos.value);
    }
    if (quantiteEnStock.present) {
      map['quantite_en_stock'] = Variable<int>(quantiteEnStock.value);
    }
    if (quantiteMinimale.present) {
      map['quantite_minimale'] = Variable<int>(quantiteMinimale.value);
    }
    if (prixAchat.present) {
      map['prix_achat'] = Variable<double>(prixAchat.value);
    }
    if (prixVente.present) {
      map['prix_vente'] = Variable<double>(prixVente.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (emplacement.present) {
      map['emplacement'] = Variable<String>(emplacement.value);
    }
    if (garantieDuree.present) {
      map['garantie_duree'] = Variable<int>(garantieDuree.value);
    }
    if (fournisseurId.present) {
      map['fournisseur_id'] = Variable<int>(fournisseurId.value);
    }
    if (dateLastMaj.present) {
      map['date_last_maj'] = Variable<DateTime>(dateLastMaj.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PiecesCompanion(')
          ..write('id: $id, ')
          ..write('reference: $reference, ')
          ..write('nom: $nom, ')
          ..write('description: $description, ')
          ..write('categorie: $categorie, ')
          ..write('compatibilitesMotos: $compatibilitesMotos, ')
          ..write('quantiteEnStock: $quantiteEnStock, ')
          ..write('quantiteMinimale: $quantiteMinimale, ')
          ..write('prixAchat: $prixAchat, ')
          ..write('prixVente: $prixVente, ')
          ..write('imagePath: $imagePath, ')
          ..write('emplacement: $emplacement, ')
          ..write('garantieDuree: $garantieDuree, ')
          ..write('fournisseurId: $fournisseurId, ')
          ..write('dateLastMaj: $dateLastMaj, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FournisseursTable extends Fournisseurs
    with TableInfo<$FournisseursTable, Fournisseur> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FournisseursTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactMeta =
      const VerificationMeta('contact');
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
      'contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _telephoneMeta =
      const VerificationMeta('telephone');
  @override
  late final GeneratedColumn<String> telephone = GeneratedColumn<String>(
      'telephone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _adresseMeta =
      const VerificationMeta('adresse');
  @override
  late final GeneratedColumn<String> adresse = GeneratedColumn<String>(
      'adresse', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _delaiLivraisonMoyenMeta =
      const VerificationMeta('delaiLivraisonMoyen');
  @override
  late final GeneratedColumn<int> delaiLivraisonMoyen = GeneratedColumn<int>(
      'delai_livraison_moyen', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _conditionsPaiementMeta =
      const VerificationMeta('conditionsPaiement');
  @override
  late final GeneratedColumn<String> conditionsPaiement =
      GeneratedColumn<String>('conditions_paiement', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nom,
        contact,
        telephone,
        email,
        adresse,
        delaiLivraisonMoyen,
        conditionsPaiement,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fournisseurs';
  @override
  VerificationContext validateIntegrity(Insertable<Fournisseur> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('contact')) {
      context.handle(_contactMeta,
          contact.isAcceptableOrUnknown(data['contact']!, _contactMeta));
    }
    if (data.containsKey('telephone')) {
      context.handle(_telephoneMeta,
          telephone.isAcceptableOrUnknown(data['telephone']!, _telephoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('adresse')) {
      context.handle(_adresseMeta,
          adresse.isAcceptableOrUnknown(data['adresse']!, _adresseMeta));
    }
    if (data.containsKey('delai_livraison_moyen')) {
      context.handle(
          _delaiLivraisonMoyenMeta,
          delaiLivraisonMoyen.isAcceptableOrUnknown(
              data['delai_livraison_moyen']!, _delaiLivraisonMoyenMeta));
    }
    if (data.containsKey('conditions_paiement')) {
      context.handle(
          _conditionsPaiementMeta,
          conditionsPaiement.isAcceptableOrUnknown(
              data['conditions_paiement']!, _conditionsPaiementMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fournisseur map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fournisseur(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      contact: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact']),
      telephone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telephone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      adresse: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}adresse']),
      delaiLivraisonMoyen: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}delai_livraison_moyen']),
      conditionsPaiement: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conditions_paiement']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FournisseursTable createAlias(String alias) {
    return $FournisseursTable(attachedDatabase, alias);
  }
}

class Fournisseur extends DataClass implements Insertable<Fournisseur> {
  final int id;
  final String nom;
  final String? contact;
  final String? telephone;
  final String? email;
  final String? adresse;
  final int? delaiLivraisonMoyen;
  final String? conditionsPaiement;
  final DateTime createdAt;
  const Fournisseur(
      {required this.id,
      required this.nom,
      this.contact,
      this.telephone,
      this.email,
      this.adresse,
      this.delaiLivraisonMoyen,
      this.conditionsPaiement,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    if (!nullToAbsent || telephone != null) {
      map['telephone'] = Variable<String>(telephone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || adresse != null) {
      map['adresse'] = Variable<String>(adresse);
    }
    if (!nullToAbsent || delaiLivraisonMoyen != null) {
      map['delai_livraison_moyen'] = Variable<int>(delaiLivraisonMoyen);
    }
    if (!nullToAbsent || conditionsPaiement != null) {
      map['conditions_paiement'] = Variable<String>(conditionsPaiement);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FournisseursCompanion toCompanion(bool nullToAbsent) {
    return FournisseursCompanion(
      id: Value(id),
      nom: Value(nom),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
      telephone: telephone == null && nullToAbsent
          ? const Value.absent()
          : Value(telephone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      adresse: adresse == null && nullToAbsent
          ? const Value.absent()
          : Value(adresse),
      delaiLivraisonMoyen: delaiLivraisonMoyen == null && nullToAbsent
          ? const Value.absent()
          : Value(delaiLivraisonMoyen),
      conditionsPaiement: conditionsPaiement == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionsPaiement),
      createdAt: Value(createdAt),
    );
  }

  factory Fournisseur.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fournisseur(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      contact: serializer.fromJson<String?>(json['contact']),
      telephone: serializer.fromJson<String?>(json['telephone']),
      email: serializer.fromJson<String?>(json['email']),
      adresse: serializer.fromJson<String?>(json['adresse']),
      delaiLivraisonMoyen:
          serializer.fromJson<int?>(json['delaiLivraisonMoyen']),
      conditionsPaiement:
          serializer.fromJson<String?>(json['conditionsPaiement']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'contact': serializer.toJson<String?>(contact),
      'telephone': serializer.toJson<String?>(telephone),
      'email': serializer.toJson<String?>(email),
      'adresse': serializer.toJson<String?>(adresse),
      'delaiLivraisonMoyen': serializer.toJson<int?>(delaiLivraisonMoyen),
      'conditionsPaiement': serializer.toJson<String?>(conditionsPaiement),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Fournisseur copyWith(
          {int? id,
          String? nom,
          Value<String?> contact = const Value.absent(),
          Value<String?> telephone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> adresse = const Value.absent(),
          Value<int?> delaiLivraisonMoyen = const Value.absent(),
          Value<String?> conditionsPaiement = const Value.absent(),
          DateTime? createdAt}) =>
      Fournisseur(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        contact: contact.present ? contact.value : this.contact,
        telephone: telephone.present ? telephone.value : this.telephone,
        email: email.present ? email.value : this.email,
        adresse: adresse.present ? adresse.value : this.adresse,
        delaiLivraisonMoyen: delaiLivraisonMoyen.present
            ? delaiLivraisonMoyen.value
            : this.delaiLivraisonMoyen,
        conditionsPaiement: conditionsPaiement.present
            ? conditionsPaiement.value
            : this.conditionsPaiement,
        createdAt: createdAt ?? this.createdAt,
      );
  Fournisseur copyWithCompanion(FournisseursCompanion data) {
    return Fournisseur(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      contact: data.contact.present ? data.contact.value : this.contact,
      telephone: data.telephone.present ? data.telephone.value : this.telephone,
      email: data.email.present ? data.email.value : this.email,
      adresse: data.adresse.present ? data.adresse.value : this.adresse,
      delaiLivraisonMoyen: data.delaiLivraisonMoyen.present
          ? data.delaiLivraisonMoyen.value
          : this.delaiLivraisonMoyen,
      conditionsPaiement: data.conditionsPaiement.present
          ? data.conditionsPaiement.value
          : this.conditionsPaiement,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fournisseur(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('contact: $contact, ')
          ..write('telephone: $telephone, ')
          ..write('email: $email, ')
          ..write('adresse: $adresse, ')
          ..write('delaiLivraisonMoyen: $delaiLivraisonMoyen, ')
          ..write('conditionsPaiement: $conditionsPaiement, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nom, contact, telephone, email, adresse,
      delaiLivraisonMoyen, conditionsPaiement, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fournisseur &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.contact == this.contact &&
          other.telephone == this.telephone &&
          other.email == this.email &&
          other.adresse == this.adresse &&
          other.delaiLivraisonMoyen == this.delaiLivraisonMoyen &&
          other.conditionsPaiement == this.conditionsPaiement &&
          other.createdAt == this.createdAt);
}

class FournisseursCompanion extends UpdateCompanion<Fournisseur> {
  final Value<int> id;
  final Value<String> nom;
  final Value<String?> contact;
  final Value<String?> telephone;
  final Value<String?> email;
  final Value<String?> adresse;
  final Value<int?> delaiLivraisonMoyen;
  final Value<String?> conditionsPaiement;
  final Value<DateTime> createdAt;
  const FournisseursCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.contact = const Value.absent(),
    this.telephone = const Value.absent(),
    this.email = const Value.absent(),
    this.adresse = const Value.absent(),
    this.delaiLivraisonMoyen = const Value.absent(),
    this.conditionsPaiement = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FournisseursCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    this.contact = const Value.absent(),
    this.telephone = const Value.absent(),
    this.email = const Value.absent(),
    this.adresse = const Value.absent(),
    this.delaiLivraisonMoyen = const Value.absent(),
    this.conditionsPaiement = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : nom = Value(nom);
  static Insertable<Fournisseur> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<String>? contact,
    Expression<String>? telephone,
    Expression<String>? email,
    Expression<String>? adresse,
    Expression<int>? delaiLivraisonMoyen,
    Expression<String>? conditionsPaiement,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (contact != null) 'contact': contact,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      if (adresse != null) 'adresse': adresse,
      if (delaiLivraisonMoyen != null)
        'delai_livraison_moyen': delaiLivraisonMoyen,
      if (conditionsPaiement != null) 'conditions_paiement': conditionsPaiement,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FournisseursCompanion copyWith(
      {Value<int>? id,
      Value<String>? nom,
      Value<String?>? contact,
      Value<String?>? telephone,
      Value<String?>? email,
      Value<String?>? adresse,
      Value<int?>? delaiLivraisonMoyen,
      Value<String?>? conditionsPaiement,
      Value<DateTime>? createdAt}) {
    return FournisseursCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      contact: contact ?? this.contact,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      adresse: adresse ?? this.adresse,
      delaiLivraisonMoyen: delaiLivraisonMoyen ?? this.delaiLivraisonMoyen,
      conditionsPaiement: conditionsPaiement ?? this.conditionsPaiement,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (telephone.present) {
      map['telephone'] = Variable<String>(telephone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (adresse.present) {
      map['adresse'] = Variable<String>(adresse.value);
    }
    if (delaiLivraisonMoyen.present) {
      map['delai_livraison_moyen'] = Variable<int>(delaiLivraisonMoyen.value);
    }
    if (conditionsPaiement.present) {
      map['conditions_paiement'] = Variable<String>(conditionsPaiement.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FournisseursCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('contact: $contact, ')
          ..write('telephone: $telephone, ')
          ..write('email: $email, ')
          ..write('adresse: $adresse, ')
          ..write('delaiLivraisonMoyen: $delaiLivraisonMoyen, ')
          ..write('conditionsPaiement: $conditionsPaiement, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MouvementsStockTable extends MouvementsStock
    with TableInfo<$MouvementsStockTable, MouvementStock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MouvementsStockTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _pieceIdMeta =
      const VerificationMeta('pieceId');
  @override
  late final GeneratedColumn<int> pieceId = GeneratedColumn<int>(
      'piece_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES pieces (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantiteMeta =
      const VerificationMeta('quantite');
  @override
  late final GeneratedColumn<int> quantite = GeneratedColumn<int>(
      'quantite', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _motifMeta = const VerificationMeta('motif');
  @override
  late final GeneratedColumn<String> motif = GeneratedColumn<String>(
      'motif', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, pieceId, type, quantite, motif, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mouvements_stock';
  @override
  VerificationContext validateIntegrity(Insertable<MouvementStock> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('piece_id')) {
      context.handle(_pieceIdMeta,
          pieceId.isAcceptableOrUnknown(data['piece_id']!, _pieceIdMeta));
    } else if (isInserting) {
      context.missing(_pieceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(_quantiteMeta,
          quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta));
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('motif')) {
      context.handle(
          _motifMeta, motif.isAcceptableOrUnknown(data['motif']!, _motifMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MouvementStock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MouvementStock(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      pieceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}piece_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      quantite: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantite'])!,
      motif: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motif']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $MouvementsStockTable createAlias(String alias) {
    return $MouvementsStockTable(attachedDatabase, alias);
  }
}

class MouvementStock extends DataClass implements Insertable<MouvementStock> {
  final int id;
  final int pieceId;
  final String type;
  final int quantite;
  final String? motif;
  final DateTime date;
  const MouvementStock(
      {required this.id,
      required this.pieceId,
      required this.type,
      required this.quantite,
      this.motif,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['piece_id'] = Variable<int>(pieceId);
    map['type'] = Variable<String>(type);
    map['quantite'] = Variable<int>(quantite);
    if (!nullToAbsent || motif != null) {
      map['motif'] = Variable<String>(motif);
    }
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  MouvementsStockCompanion toCompanion(bool nullToAbsent) {
    return MouvementsStockCompanion(
      id: Value(id),
      pieceId: Value(pieceId),
      type: Value(type),
      quantite: Value(quantite),
      motif:
          motif == null && nullToAbsent ? const Value.absent() : Value(motif),
      date: Value(date),
    );
  }

  factory MouvementStock.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MouvementStock(
      id: serializer.fromJson<int>(json['id']),
      pieceId: serializer.fromJson<int>(json['pieceId']),
      type: serializer.fromJson<String>(json['type']),
      quantite: serializer.fromJson<int>(json['quantite']),
      motif: serializer.fromJson<String?>(json['motif']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pieceId': serializer.toJson<int>(pieceId),
      'type': serializer.toJson<String>(type),
      'quantite': serializer.toJson<int>(quantite),
      'motif': serializer.toJson<String?>(motif),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  MouvementStock copyWith(
          {int? id,
          int? pieceId,
          String? type,
          int? quantite,
          Value<String?> motif = const Value.absent(),
          DateTime? date}) =>
      MouvementStock(
        id: id ?? this.id,
        pieceId: pieceId ?? this.pieceId,
        type: type ?? this.type,
        quantite: quantite ?? this.quantite,
        motif: motif.present ? motif.value : this.motif,
        date: date ?? this.date,
      );
  MouvementStock copyWithCompanion(MouvementsStockCompanion data) {
    return MouvementStock(
      id: data.id.present ? data.id.value : this.id,
      pieceId: data.pieceId.present ? data.pieceId.value : this.pieceId,
      type: data.type.present ? data.type.value : this.type,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      motif: data.motif.present ? data.motif.value : this.motif,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MouvementStock(')
          ..write('id: $id, ')
          ..write('pieceId: $pieceId, ')
          ..write('type: $type, ')
          ..write('quantite: $quantite, ')
          ..write('motif: $motif, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pieceId, type, quantite, motif, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MouvementStock &&
          other.id == this.id &&
          other.pieceId == this.pieceId &&
          other.type == this.type &&
          other.quantite == this.quantite &&
          other.motif == this.motif &&
          other.date == this.date);
}

class MouvementsStockCompanion extends UpdateCompanion<MouvementStock> {
  final Value<int> id;
  final Value<int> pieceId;
  final Value<String> type;
  final Value<int> quantite;
  final Value<String?> motif;
  final Value<DateTime> date;
  const MouvementsStockCompanion({
    this.id = const Value.absent(),
    this.pieceId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantite = const Value.absent(),
    this.motif = const Value.absent(),
    this.date = const Value.absent(),
  });
  MouvementsStockCompanion.insert({
    this.id = const Value.absent(),
    required int pieceId,
    required String type,
    required int quantite,
    this.motif = const Value.absent(),
    this.date = const Value.absent(),
  })  : pieceId = Value(pieceId),
        type = Value(type),
        quantite = Value(quantite);
  static Insertable<MouvementStock> custom({
    Expression<int>? id,
    Expression<int>? pieceId,
    Expression<String>? type,
    Expression<int>? quantite,
    Expression<String>? motif,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pieceId != null) 'piece_id': pieceId,
      if (type != null) 'type': type,
      if (quantite != null) 'quantite': quantite,
      if (motif != null) 'motif': motif,
      if (date != null) 'date': date,
    });
  }

  MouvementsStockCompanion copyWith(
      {Value<int>? id,
      Value<int>? pieceId,
      Value<String>? type,
      Value<int>? quantite,
      Value<String?>? motif,
      Value<DateTime>? date}) {
    return MouvementsStockCompanion(
      id: id ?? this.id,
      pieceId: pieceId ?? this.pieceId,
      type: type ?? this.type,
      quantite: quantite ?? this.quantite,
      motif: motif ?? this.motif,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pieceId.present) {
      map['piece_id'] = Variable<int>(pieceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<int>(quantite.value);
    }
    if (motif.present) {
      map['motif'] = Variable<String>(motif.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MouvementsStockCompanion(')
          ..write('id: $id, ')
          ..write('pieceId: $pieceId, ')
          ..write('type: $type, ')
          ..write('quantite: $quantite, ')
          ..write('motif: $motif, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $CommandesTable extends Commandes
    with TableInfo<$CommandesTable, Commande> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommandesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fournisseurIdMeta =
      const VerificationMeta('fournisseurId');
  @override
  late final GeneratedColumn<int> fournisseurId = GeneratedColumn<int>(
      'fournisseur_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES fournisseurs (id)'));
  static const VerificationMeta _dateCreationMeta =
      const VerificationMeta('dateCreation');
  @override
  late final GeneratedColumn<DateTime> dateCreation = GeneratedColumn<DateTime>(
      'date_creation', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('brouillon'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, fournisseurId, dateCreation, statut, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commandes';
  @override
  VerificationContext validateIntegrity(Insertable<Commande> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fournisseur_id')) {
      context.handle(
          _fournisseurIdMeta,
          fournisseurId.isAcceptableOrUnknown(
              data['fournisseur_id']!, _fournisseurIdMeta));
    } else if (isInserting) {
      context.missing(_fournisseurIdMeta);
    }
    if (data.containsKey('date_creation')) {
      context.handle(
          _dateCreationMeta,
          dateCreation.isAcceptableOrUnknown(
              data['date_creation']!, _dateCreationMeta));
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Commande map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Commande(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fournisseurId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fournisseur_id'])!,
      dateCreation: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_creation'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $CommandesTable createAlias(String alias) {
    return $CommandesTable(attachedDatabase, alias);
  }
}

class Commande extends DataClass implements Insertable<Commande> {
  final int id;
  final int fournisseurId;
  final DateTime dateCreation;
  final String statut;
  final String? notes;
  const Commande(
      {required this.id,
      required this.fournisseurId,
      required this.dateCreation,
      required this.statut,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fournisseur_id'] = Variable<int>(fournisseurId);
    map['date_creation'] = Variable<DateTime>(dateCreation);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CommandesCompanion toCompanion(bool nullToAbsent) {
    return CommandesCompanion(
      id: Value(id),
      fournisseurId: Value(fournisseurId),
      dateCreation: Value(dateCreation),
      statut: Value(statut),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Commande.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Commande(
      id: serializer.fromJson<int>(json['id']),
      fournisseurId: serializer.fromJson<int>(json['fournisseurId']),
      dateCreation: serializer.fromJson<DateTime>(json['dateCreation']),
      statut: serializer.fromJson<String>(json['statut']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fournisseurId': serializer.toJson<int>(fournisseurId),
      'dateCreation': serializer.toJson<DateTime>(dateCreation),
      'statut': serializer.toJson<String>(statut),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Commande copyWith(
          {int? id,
          int? fournisseurId,
          DateTime? dateCreation,
          String? statut,
          Value<String?> notes = const Value.absent()}) =>
      Commande(
        id: id ?? this.id,
        fournisseurId: fournisseurId ?? this.fournisseurId,
        dateCreation: dateCreation ?? this.dateCreation,
        statut: statut ?? this.statut,
        notes: notes.present ? notes.value : this.notes,
      );
  Commande copyWithCompanion(CommandesCompanion data) {
    return Commande(
      id: data.id.present ? data.id.value : this.id,
      fournisseurId: data.fournisseurId.present
          ? data.fournisseurId.value
          : this.fournisseurId,
      dateCreation: data.dateCreation.present
          ? data.dateCreation.value
          : this.dateCreation,
      statut: data.statut.present ? data.statut.value : this.statut,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Commande(')
          ..write('id: $id, ')
          ..write('fournisseurId: $fournisseurId, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('statut: $statut, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fournisseurId, dateCreation, statut, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Commande &&
          other.id == this.id &&
          other.fournisseurId == this.fournisseurId &&
          other.dateCreation == this.dateCreation &&
          other.statut == this.statut &&
          other.notes == this.notes);
}

class CommandesCompanion extends UpdateCompanion<Commande> {
  final Value<int> id;
  final Value<int> fournisseurId;
  final Value<DateTime> dateCreation;
  final Value<String> statut;
  final Value<String?> notes;
  const CommandesCompanion({
    this.id = const Value.absent(),
    this.fournisseurId = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.statut = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CommandesCompanion.insert({
    this.id = const Value.absent(),
    required int fournisseurId,
    this.dateCreation = const Value.absent(),
    this.statut = const Value.absent(),
    this.notes = const Value.absent(),
  }) : fournisseurId = Value(fournisseurId);
  static Insertable<Commande> custom({
    Expression<int>? id,
    Expression<int>? fournisseurId,
    Expression<DateTime>? dateCreation,
    Expression<String>? statut,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fournisseurId != null) 'fournisseur_id': fournisseurId,
      if (dateCreation != null) 'date_creation': dateCreation,
      if (statut != null) 'statut': statut,
      if (notes != null) 'notes': notes,
    });
  }

  CommandesCompanion copyWith(
      {Value<int>? id,
      Value<int>? fournisseurId,
      Value<DateTime>? dateCreation,
      Value<String>? statut,
      Value<String?>? notes}) {
    return CommandesCompanion(
      id: id ?? this.id,
      fournisseurId: fournisseurId ?? this.fournisseurId,
      dateCreation: dateCreation ?? this.dateCreation,
      statut: statut ?? this.statut,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fournisseurId.present) {
      map['fournisseur_id'] = Variable<int>(fournisseurId.value);
    }
    if (dateCreation.present) {
      map['date_creation'] = Variable<DateTime>(dateCreation.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommandesCompanion(')
          ..write('id: $id, ')
          ..write('fournisseurId: $fournisseurId, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('statut: $statut, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PiecesTable pieces = $PiecesTable(this);
  late final $FournisseursTable fournisseurs = $FournisseursTable(this);
  late final $MouvementsStockTable mouvementsStock =
      $MouvementsStockTable(this);
  late final $CommandesTable commandes = $CommandesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [pieces, fournisseurs, mouvementsStock, commandes];
}

typedef $$PiecesTableCreateCompanionBuilder = PiecesCompanion Function({
  Value<int> id,
  required String reference,
  required String nom,
  Value<String?> description,
  required String categorie,
  Value<String?> compatibilitesMotos,
  Value<int> quantiteEnStock,
  Value<int> quantiteMinimale,
  Value<double> prixAchat,
  Value<double> prixVente,
  Value<String?> imagePath,
  Value<String?> emplacement,
  Value<int> garantieDuree,
  Value<int?> fournisseurId,
  Value<DateTime?> dateLastMaj,
  Value<DateTime> createdAt,
});
typedef $$PiecesTableUpdateCompanionBuilder = PiecesCompanion Function({
  Value<int> id,
  Value<String> reference,
  Value<String> nom,
  Value<String?> description,
  Value<String> categorie,
  Value<String?> compatibilitesMotos,
  Value<int> quantiteEnStock,
  Value<int> quantiteMinimale,
  Value<double> prixAchat,
  Value<double> prixVente,
  Value<String?> imagePath,
  Value<String?> emplacement,
  Value<int> garantieDuree,
  Value<int?> fournisseurId,
  Value<DateTime?> dateLastMaj,
  Value<DateTime> createdAt,
});

final class $$PiecesTableReferences
    extends BaseReferences<_$AppDatabase, $PiecesTable, Piece> {
  $$PiecesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MouvementsStockTable, List<MouvementStock>>
      _mouvementsStockRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.mouvementsStock,
              aliasName: $_aliasNameGenerator(
                  db.pieces.id, db.mouvementsStock.pieceId));

  $$MouvementsStockTableProcessedTableManager get mouvementsStockRefs {
    final manager =
        $$MouvementsStockTableTableManager($_db, $_db.mouvementsStock)
            .filter((f) => f.pieceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_mouvementsStockRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PiecesTableFilterComposer
    extends Composer<_$AppDatabase, $PiecesTable> {
  $$PiecesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categorie => $composableBuilder(
      column: $table.categorie, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get compatibilitesMotos => $composableBuilder(
      column: $table.compatibilitesMotos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantiteEnStock => $composableBuilder(
      column: $table.quantiteEnStock,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantiteMinimale => $composableBuilder(
      column: $table.quantiteMinimale,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get prixAchat => $composableBuilder(
      column: $table.prixAchat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get prixVente => $composableBuilder(
      column: $table.prixVente, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emplacement => $composableBuilder(
      column: $table.emplacement, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get garantieDuree => $composableBuilder(
      column: $table.garantieDuree, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fournisseurId => $composableBuilder(
      column: $table.fournisseurId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateLastMaj => $composableBuilder(
      column: $table.dateLastMaj, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> mouvementsStockRefs(
      Expression<bool> Function($$MouvementsStockTableFilterComposer f) f) {
    final $$MouvementsStockTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mouvementsStock,
        getReferencedColumn: (t) => t.pieceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MouvementsStockTableFilterComposer(
              $db: $db,
              $table: $db.mouvementsStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PiecesTableOrderingComposer
    extends Composer<_$AppDatabase, $PiecesTable> {
  $$PiecesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categorie => $composableBuilder(
      column: $table.categorie, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get compatibilitesMotos => $composableBuilder(
      column: $table.compatibilitesMotos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantiteEnStock => $composableBuilder(
      column: $table.quantiteEnStock,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantiteMinimale => $composableBuilder(
      column: $table.quantiteMinimale,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get prixAchat => $composableBuilder(
      column: $table.prixAchat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get prixVente => $composableBuilder(
      column: $table.prixVente, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emplacement => $composableBuilder(
      column: $table.emplacement, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get garantieDuree => $composableBuilder(
      column: $table.garantieDuree,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fournisseurId => $composableBuilder(
      column: $table.fournisseurId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateLastMaj => $composableBuilder(
      column: $table.dateLastMaj, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PiecesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PiecesTable> {
  $$PiecesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get categorie =>
      $composableBuilder(column: $table.categorie, builder: (column) => column);

  GeneratedColumn<String> get compatibilitesMotos => $composableBuilder(
      column: $table.compatibilitesMotos, builder: (column) => column);

  GeneratedColumn<int> get quantiteEnStock => $composableBuilder(
      column: $table.quantiteEnStock, builder: (column) => column);

  GeneratedColumn<int> get quantiteMinimale => $composableBuilder(
      column: $table.quantiteMinimale, builder: (column) => column);

  GeneratedColumn<double> get prixAchat =>
      $composableBuilder(column: $table.prixAchat, builder: (column) => column);

  GeneratedColumn<double> get prixVente =>
      $composableBuilder(column: $table.prixVente, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get emplacement => $composableBuilder(
      column: $table.emplacement, builder: (column) => column);

  GeneratedColumn<int> get garantieDuree => $composableBuilder(
      column: $table.garantieDuree, builder: (column) => column);

  GeneratedColumn<int> get fournisseurId => $composableBuilder(
      column: $table.fournisseurId, builder: (column) => column);

  GeneratedColumn<DateTime> get dateLastMaj => $composableBuilder(
      column: $table.dateLastMaj, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> mouvementsStockRefs<T extends Object>(
      Expression<T> Function($$MouvementsStockTableAnnotationComposer a) f) {
    final $$MouvementsStockTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mouvementsStock,
        getReferencedColumn: (t) => t.pieceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MouvementsStockTableAnnotationComposer(
              $db: $db,
              $table: $db.mouvementsStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PiecesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PiecesTable,
    Piece,
    $$PiecesTableFilterComposer,
    $$PiecesTableOrderingComposer,
    $$PiecesTableAnnotationComposer,
    $$PiecesTableCreateCompanionBuilder,
    $$PiecesTableUpdateCompanionBuilder,
    (Piece, $$PiecesTableReferences),
    Piece,
    PrefetchHooks Function({bool mouvementsStockRefs})> {
  $$PiecesTableTableManager(_$AppDatabase db, $PiecesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PiecesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PiecesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PiecesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> reference = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> categorie = const Value.absent(),
            Value<String?> compatibilitesMotos = const Value.absent(),
            Value<int> quantiteEnStock = const Value.absent(),
            Value<int> quantiteMinimale = const Value.absent(),
            Value<double> prixAchat = const Value.absent(),
            Value<double> prixVente = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> emplacement = const Value.absent(),
            Value<int> garantieDuree = const Value.absent(),
            Value<int?> fournisseurId = const Value.absent(),
            Value<DateTime?> dateLastMaj = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PiecesCompanion(
            id: id,
            reference: reference,
            nom: nom,
            description: description,
            categorie: categorie,
            compatibilitesMotos: compatibilitesMotos,
            quantiteEnStock: quantiteEnStock,
            quantiteMinimale: quantiteMinimale,
            prixAchat: prixAchat,
            prixVente: prixVente,
            imagePath: imagePath,
            emplacement: emplacement,
            garantieDuree: garantieDuree,
            fournisseurId: fournisseurId,
            dateLastMaj: dateLastMaj,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String reference,
            required String nom,
            Value<String?> description = const Value.absent(),
            required String categorie,
            Value<String?> compatibilitesMotos = const Value.absent(),
            Value<int> quantiteEnStock = const Value.absent(),
            Value<int> quantiteMinimale = const Value.absent(),
            Value<double> prixAchat = const Value.absent(),
            Value<double> prixVente = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> emplacement = const Value.absent(),
            Value<int> garantieDuree = const Value.absent(),
            Value<int?> fournisseurId = const Value.absent(),
            Value<DateTime?> dateLastMaj = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PiecesCompanion.insert(
            id: id,
            reference: reference,
            nom: nom,
            description: description,
            categorie: categorie,
            compatibilitesMotos: compatibilitesMotos,
            quantiteEnStock: quantiteEnStock,
            quantiteMinimale: quantiteMinimale,
            prixAchat: prixAchat,
            prixVente: prixVente,
            imagePath: imagePath,
            emplacement: emplacement,
            garantieDuree: garantieDuree,
            fournisseurId: fournisseurId,
            dateLastMaj: dateLastMaj,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PiecesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({mouvementsStockRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (mouvementsStockRefs) db.mouvementsStock
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mouvementsStockRefs)
                    await $_getPrefetchedData<Piece, $PiecesTable,
                            MouvementStock>(
                        currentTable: table,
                        referencedTable: $$PiecesTableReferences
                            ._mouvementsStockRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PiecesTableReferences(db, table, p0)
                                .mouvementsStockRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.pieceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PiecesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PiecesTable,
    Piece,
    $$PiecesTableFilterComposer,
    $$PiecesTableOrderingComposer,
    $$PiecesTableAnnotationComposer,
    $$PiecesTableCreateCompanionBuilder,
    $$PiecesTableUpdateCompanionBuilder,
    (Piece, $$PiecesTableReferences),
    Piece,
    PrefetchHooks Function({bool mouvementsStockRefs})>;
typedef $$FournisseursTableCreateCompanionBuilder = FournisseursCompanion
    Function({
  Value<int> id,
  required String nom,
  Value<String?> contact,
  Value<String?> telephone,
  Value<String?> email,
  Value<String?> adresse,
  Value<int?> delaiLivraisonMoyen,
  Value<String?> conditionsPaiement,
  Value<DateTime> createdAt,
});
typedef $$FournisseursTableUpdateCompanionBuilder = FournisseursCompanion
    Function({
  Value<int> id,
  Value<String> nom,
  Value<String?> contact,
  Value<String?> telephone,
  Value<String?> email,
  Value<String?> adresse,
  Value<int?> delaiLivraisonMoyen,
  Value<String?> conditionsPaiement,
  Value<DateTime> createdAt,
});

final class $$FournisseursTableReferences
    extends BaseReferences<_$AppDatabase, $FournisseursTable, Fournisseur> {
  $$FournisseursTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CommandesTable, List<Commande>>
      _commandesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.commandes,
              aliasName: $_aliasNameGenerator(
                  db.fournisseurs.id, db.commandes.fournisseurId));

  $$CommandesTableProcessedTableManager get commandesRefs {
    final manager = $$CommandesTableTableManager($_db, $_db.commandes)
        .filter((f) => f.fournisseurId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_commandesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FournisseursTableFilterComposer
    extends Composer<_$AppDatabase, $FournisseursTable> {
  $$FournisseursTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contact => $composableBuilder(
      column: $table.contact, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telephone => $composableBuilder(
      column: $table.telephone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adresse => $composableBuilder(
      column: $table.adresse, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get delaiLivraisonMoyen => $composableBuilder(
      column: $table.delaiLivraisonMoyen,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionsPaiement => $composableBuilder(
      column: $table.conditionsPaiement,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> commandesRefs(
      Expression<bool> Function($$CommandesTableFilterComposer f) f) {
    final $$CommandesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.commandes,
        getReferencedColumn: (t) => t.fournisseurId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CommandesTableFilterComposer(
              $db: $db,
              $table: $db.commandes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FournisseursTableOrderingComposer
    extends Composer<_$AppDatabase, $FournisseursTable> {
  $$FournisseursTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contact => $composableBuilder(
      column: $table.contact, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telephone => $composableBuilder(
      column: $table.telephone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adresse => $composableBuilder(
      column: $table.adresse, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get delaiLivraisonMoyen => $composableBuilder(
      column: $table.delaiLivraisonMoyen,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionsPaiement => $composableBuilder(
      column: $table.conditionsPaiement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FournisseursTableAnnotationComposer
    extends Composer<_$AppDatabase, $FournisseursTable> {
  $$FournisseursTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<String> get telephone =>
      $composableBuilder(column: $table.telephone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get adresse =>
      $composableBuilder(column: $table.adresse, builder: (column) => column);

  GeneratedColumn<int> get delaiLivraisonMoyen => $composableBuilder(
      column: $table.delaiLivraisonMoyen, builder: (column) => column);

  GeneratedColumn<String> get conditionsPaiement => $composableBuilder(
      column: $table.conditionsPaiement, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> commandesRefs<T extends Object>(
      Expression<T> Function($$CommandesTableAnnotationComposer a) f) {
    final $$CommandesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.commandes,
        getReferencedColumn: (t) => t.fournisseurId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CommandesTableAnnotationComposer(
              $db: $db,
              $table: $db.commandes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FournisseursTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FournisseursTable,
    Fournisseur,
    $$FournisseursTableFilterComposer,
    $$FournisseursTableOrderingComposer,
    $$FournisseursTableAnnotationComposer,
    $$FournisseursTableCreateCompanionBuilder,
    $$FournisseursTableUpdateCompanionBuilder,
    (Fournisseur, $$FournisseursTableReferences),
    Fournisseur,
    PrefetchHooks Function({bool commandesRefs})> {
  $$FournisseursTableTableManager(_$AppDatabase db, $FournisseursTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FournisseursTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FournisseursTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FournisseursTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String?> contact = const Value.absent(),
            Value<String?> telephone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> adresse = const Value.absent(),
            Value<int?> delaiLivraisonMoyen = const Value.absent(),
            Value<String?> conditionsPaiement = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FournisseursCompanion(
            id: id,
            nom: nom,
            contact: contact,
            telephone: telephone,
            email: email,
            adresse: adresse,
            delaiLivraisonMoyen: delaiLivraisonMoyen,
            conditionsPaiement: conditionsPaiement,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nom,
            Value<String?> contact = const Value.absent(),
            Value<String?> telephone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> adresse = const Value.absent(),
            Value<int?> delaiLivraisonMoyen = const Value.absent(),
            Value<String?> conditionsPaiement = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FournisseursCompanion.insert(
            id: id,
            nom: nom,
            contact: contact,
            telephone: telephone,
            email: email,
            adresse: adresse,
            delaiLivraisonMoyen: delaiLivraisonMoyen,
            conditionsPaiement: conditionsPaiement,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FournisseursTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({commandesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (commandesRefs) db.commandes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (commandesRefs)
                    await $_getPrefetchedData<Fournisseur, $FournisseursTable,
                            Commande>(
                        currentTable: table,
                        referencedTable: $$FournisseursTableReferences
                            ._commandesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FournisseursTableReferences(db, table, p0)
                                .commandesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.fournisseurId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$FournisseursTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FournisseursTable,
    Fournisseur,
    $$FournisseursTableFilterComposer,
    $$FournisseursTableOrderingComposer,
    $$FournisseursTableAnnotationComposer,
    $$FournisseursTableCreateCompanionBuilder,
    $$FournisseursTableUpdateCompanionBuilder,
    (Fournisseur, $$FournisseursTableReferences),
    Fournisseur,
    PrefetchHooks Function({bool commandesRefs})>;
typedef $$MouvementsStockTableCreateCompanionBuilder = MouvementsStockCompanion
    Function({
  Value<int> id,
  required int pieceId,
  required String type,
  required int quantite,
  Value<String?> motif,
  Value<DateTime> date,
});
typedef $$MouvementsStockTableUpdateCompanionBuilder = MouvementsStockCompanion
    Function({
  Value<int> id,
  Value<int> pieceId,
  Value<String> type,
  Value<int> quantite,
  Value<String?> motif,
  Value<DateTime> date,
});

final class $$MouvementsStockTableReferences extends BaseReferences<
    _$AppDatabase, $MouvementsStockTable, MouvementStock> {
  $$MouvementsStockTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PiecesTable _pieceIdTable(_$AppDatabase db) => db.pieces.createAlias(
      $_aliasNameGenerator(db.mouvementsStock.pieceId, db.pieces.id));

  $$PiecesTableProcessedTableManager get pieceId {
    final $_column = $_itemColumn<int>('piece_id')!;

    final manager = $$PiecesTableTableManager($_db, $_db.pieces)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pieceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MouvementsStockTableFilterComposer
    extends Composer<_$AppDatabase, $MouvementsStockTable> {
  $$MouvementsStockTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motif => $composableBuilder(
      column: $table.motif, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  $$PiecesTableFilterComposer get pieceId {
    final $$PiecesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pieceId,
        referencedTable: $db.pieces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PiecesTableFilterComposer(
              $db: $db,
              $table: $db.pieces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MouvementsStockTableOrderingComposer
    extends Composer<_$AppDatabase, $MouvementsStockTable> {
  $$MouvementsStockTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motif => $composableBuilder(
      column: $table.motif, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  $$PiecesTableOrderingComposer get pieceId {
    final $$PiecesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pieceId,
        referencedTable: $db.pieces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PiecesTableOrderingComposer(
              $db: $db,
              $table: $db.pieces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MouvementsStockTableAnnotationComposer
    extends Composer<_$AppDatabase, $MouvementsStockTable> {
  $$MouvementsStockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<String> get motif =>
      $composableBuilder(column: $table.motif, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$PiecesTableAnnotationComposer get pieceId {
    final $$PiecesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pieceId,
        referencedTable: $db.pieces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PiecesTableAnnotationComposer(
              $db: $db,
              $table: $db.pieces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MouvementsStockTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MouvementsStockTable,
    MouvementStock,
    $$MouvementsStockTableFilterComposer,
    $$MouvementsStockTableOrderingComposer,
    $$MouvementsStockTableAnnotationComposer,
    $$MouvementsStockTableCreateCompanionBuilder,
    $$MouvementsStockTableUpdateCompanionBuilder,
    (MouvementStock, $$MouvementsStockTableReferences),
    MouvementStock,
    PrefetchHooks Function({bool pieceId})> {
  $$MouvementsStockTableTableManager(
      _$AppDatabase db, $MouvementsStockTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MouvementsStockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MouvementsStockTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MouvementsStockTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> pieceId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> quantite = const Value.absent(),
            Value<String?> motif = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              MouvementsStockCompanion(
            id: id,
            pieceId: pieceId,
            type: type,
            quantite: quantite,
            motif: motif,
            date: date,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int pieceId,
            required String type,
            required int quantite,
            Value<String?> motif = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              MouvementsStockCompanion.insert(
            id: id,
            pieceId: pieceId,
            type: type,
            quantite: quantite,
            motif: motif,
            date: date,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MouvementsStockTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({pieceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (pieceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pieceId,
                    referencedTable:
                        $$MouvementsStockTableReferences._pieceIdTable(db),
                    referencedColumn:
                        $$MouvementsStockTableReferences._pieceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MouvementsStockTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MouvementsStockTable,
    MouvementStock,
    $$MouvementsStockTableFilterComposer,
    $$MouvementsStockTableOrderingComposer,
    $$MouvementsStockTableAnnotationComposer,
    $$MouvementsStockTableCreateCompanionBuilder,
    $$MouvementsStockTableUpdateCompanionBuilder,
    (MouvementStock, $$MouvementsStockTableReferences),
    MouvementStock,
    PrefetchHooks Function({bool pieceId})>;
typedef $$CommandesTableCreateCompanionBuilder = CommandesCompanion Function({
  Value<int> id,
  required int fournisseurId,
  Value<DateTime> dateCreation,
  Value<String> statut,
  Value<String?> notes,
});
typedef $$CommandesTableUpdateCompanionBuilder = CommandesCompanion Function({
  Value<int> id,
  Value<int> fournisseurId,
  Value<DateTime> dateCreation,
  Value<String> statut,
  Value<String?> notes,
});

final class $$CommandesTableReferences
    extends BaseReferences<_$AppDatabase, $CommandesTable, Commande> {
  $$CommandesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FournisseursTable _fournisseurIdTable(_$AppDatabase db) =>
      db.fournisseurs.createAlias(
          $_aliasNameGenerator(db.commandes.fournisseurId, db.fournisseurs.id));

  $$FournisseursTableProcessedTableManager get fournisseurId {
    final $_column = $_itemColumn<int>('fournisseur_id')!;

    final manager = $$FournisseursTableTableManager($_db, $_db.fournisseurs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fournisseurIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CommandesTableFilterComposer
    extends Composer<_$AppDatabase, $CommandesTable> {
  $$CommandesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateCreation => $composableBuilder(
      column: $table.dateCreation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$FournisseursTableFilterComposer get fournisseurId {
    final $$FournisseursTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fournisseurId,
        referencedTable: $db.fournisseurs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FournisseursTableFilterComposer(
              $db: $db,
              $table: $db.fournisseurs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CommandesTableOrderingComposer
    extends Composer<_$AppDatabase, $CommandesTable> {
  $$CommandesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateCreation => $composableBuilder(
      column: $table.dateCreation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$FournisseursTableOrderingComposer get fournisseurId {
    final $$FournisseursTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fournisseurId,
        referencedTable: $db.fournisseurs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FournisseursTableOrderingComposer(
              $db: $db,
              $table: $db.fournisseurs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CommandesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommandesTable> {
  $$CommandesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreation => $composableBuilder(
      column: $table.dateCreation, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$FournisseursTableAnnotationComposer get fournisseurId {
    final $$FournisseursTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fournisseurId,
        referencedTable: $db.fournisseurs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FournisseursTableAnnotationComposer(
              $db: $db,
              $table: $db.fournisseurs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CommandesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CommandesTable,
    Commande,
    $$CommandesTableFilterComposer,
    $$CommandesTableOrderingComposer,
    $$CommandesTableAnnotationComposer,
    $$CommandesTableCreateCompanionBuilder,
    $$CommandesTableUpdateCompanionBuilder,
    (Commande, $$CommandesTableReferences),
    Commande,
    PrefetchHooks Function({bool fournisseurId})> {
  $$CommandesTableTableManager(_$AppDatabase db, $CommandesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommandesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommandesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommandesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> fournisseurId = const Value.absent(),
            Value<DateTime> dateCreation = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              CommandesCompanion(
            id: id,
            fournisseurId: fournisseurId,
            dateCreation: dateCreation,
            statut: statut,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int fournisseurId,
            Value<DateTime> dateCreation = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              CommandesCompanion.insert(
            id: id,
            fournisseurId: fournisseurId,
            dateCreation: dateCreation,
            statut: statut,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CommandesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({fournisseurId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (fournisseurId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fournisseurId,
                    referencedTable:
                        $$CommandesTableReferences._fournisseurIdTable(db),
                    referencedColumn:
                        $$CommandesTableReferences._fournisseurIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CommandesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CommandesTable,
    Commande,
    $$CommandesTableFilterComposer,
    $$CommandesTableOrderingComposer,
    $$CommandesTableAnnotationComposer,
    $$CommandesTableCreateCompanionBuilder,
    $$CommandesTableUpdateCompanionBuilder,
    (Commande, $$CommandesTableReferences),
    Commande,
    PrefetchHooks Function({bool fournisseurId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PiecesTableTableManager get pieces =>
      $$PiecesTableTableManager(_db, _db.pieces);
  $$FournisseursTableTableManager get fournisseurs =>
      $$FournisseursTableTableManager(_db, _db.fournisseurs);
  $$MouvementsStockTableTableManager get mouvementsStock =>
      $$MouvementsStockTableTableManager(_db, _db.mouvementsStock);
  $$CommandesTableTableManager get commandes =>
      $$CommandesTableTableManager(_db, _db.commandes);
}
