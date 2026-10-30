// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SekolahTable extends Sekolah with TableInfo<$SekolahTable, SekolahData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SekolahTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _namaSekolahMeta =
      const VerificationMeta('namaSekolah');
  @override
  late final GeneratedColumn<String> namaSekolah = GeneratedColumn<String>(
      'nama_sekolah', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kodeSekolahMeta =
      const VerificationMeta('kodeSekolah');
  @override
  late final GeneratedColumn<int> kodeSekolah = GeneratedColumn<int>(
      'kode_sekolah', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _jenjangMeta =
      const VerificationMeta('jenjang');
  @override
  late final GeneratedColumn<String> jenjang = GeneratedColumn<String>(
      'jenjang', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, namaSekolah, kodeSekolah, jenjang];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sekolah';
  @override
  VerificationContext validateIntegrity(Insertable<SekolahData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama_sekolah')) {
      context.handle(
          _namaSekolahMeta,
          namaSekolah.isAcceptableOrUnknown(
              data['nama_sekolah']!, _namaSekolahMeta));
    } else if (isInserting) {
      context.missing(_namaSekolahMeta);
    }
    if (data.containsKey('kode_sekolah')) {
      context.handle(
          _kodeSekolahMeta,
          kodeSekolah.isAcceptableOrUnknown(
              data['kode_sekolah']!, _kodeSekolahMeta));
    } else if (isInserting) {
      context.missing(_kodeSekolahMeta);
    }
    if (data.containsKey('jenjang')) {
      context.handle(_jenjangMeta,
          jenjang.isAcceptableOrUnknown(data['jenjang']!, _jenjangMeta));
    } else if (isInserting) {
      context.missing(_jenjangMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SekolahData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SekolahData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      namaSekolah: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama_sekolah'])!,
      kodeSekolah: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kode_sekolah'])!,
      jenjang: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}jenjang'])!,
    );
  }

  @override
  $SekolahTable createAlias(String alias) {
    return $SekolahTable(attachedDatabase, alias);
  }
}

class SekolahData extends DataClass implements Insertable<SekolahData> {
  final int id;
  final String namaSekolah;
  final int kodeSekolah;
  final String jenjang;
  const SekolahData(
      {required this.id,
      required this.namaSekolah,
      required this.kodeSekolah,
      required this.jenjang});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nama_sekolah'] = Variable<String>(namaSekolah);
    map['kode_sekolah'] = Variable<int>(kodeSekolah);
    map['jenjang'] = Variable<String>(jenjang);
    return map;
  }

  SekolahCompanion toCompanion(bool nullToAbsent) {
    return SekolahCompanion(
      id: Value(id),
      namaSekolah: Value(namaSekolah),
      kodeSekolah: Value(kodeSekolah),
      jenjang: Value(jenjang),
    );
  }

  factory SekolahData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SekolahData(
      id: serializer.fromJson<int>(json['id']),
      namaSekolah: serializer.fromJson<String>(json['namaSekolah']),
      kodeSekolah: serializer.fromJson<int>(json['kodeSekolah']),
      jenjang: serializer.fromJson<String>(json['jenjang']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'namaSekolah': serializer.toJson<String>(namaSekolah),
      'kodeSekolah': serializer.toJson<int>(kodeSekolah),
      'jenjang': serializer.toJson<String>(jenjang),
    };
  }

  SekolahData copyWith(
          {int? id, String? namaSekolah, int? kodeSekolah, String? jenjang}) =>
      SekolahData(
        id: id ?? this.id,
        namaSekolah: namaSekolah ?? this.namaSekolah,
        kodeSekolah: kodeSekolah ?? this.kodeSekolah,
        jenjang: jenjang ?? this.jenjang,
      );
  SekolahData copyWithCompanion(SekolahCompanion data) {
    return SekolahData(
      id: data.id.present ? data.id.value : this.id,
      namaSekolah:
          data.namaSekolah.present ? data.namaSekolah.value : this.namaSekolah,
      kodeSekolah:
          data.kodeSekolah.present ? data.kodeSekolah.value : this.kodeSekolah,
      jenjang: data.jenjang.present ? data.jenjang.value : this.jenjang,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SekolahData(')
          ..write('id: $id, ')
          ..write('namaSekolah: $namaSekolah, ')
          ..write('kodeSekolah: $kodeSekolah, ')
          ..write('jenjang: $jenjang')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, namaSekolah, kodeSekolah, jenjang);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SekolahData &&
          other.id == this.id &&
          other.namaSekolah == this.namaSekolah &&
          other.kodeSekolah == this.kodeSekolah &&
          other.jenjang == this.jenjang);
}

class SekolahCompanion extends UpdateCompanion<SekolahData> {
  final Value<int> id;
  final Value<String> namaSekolah;
  final Value<int> kodeSekolah;
  final Value<String> jenjang;
  const SekolahCompanion({
    this.id = const Value.absent(),
    this.namaSekolah = const Value.absent(),
    this.kodeSekolah = const Value.absent(),
    this.jenjang = const Value.absent(),
  });
  SekolahCompanion.insert({
    this.id = const Value.absent(),
    required String namaSekolah,
    required int kodeSekolah,
    required String jenjang,
  })  : namaSekolah = Value(namaSekolah),
        kodeSekolah = Value(kodeSekolah),
        jenjang = Value(jenjang);
  static Insertable<SekolahData> custom({
    Expression<int>? id,
    Expression<String>? namaSekolah,
    Expression<int>? kodeSekolah,
    Expression<String>? jenjang,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (namaSekolah != null) 'nama_sekolah': namaSekolah,
      if (kodeSekolah != null) 'kode_sekolah': kodeSekolah,
      if (jenjang != null) 'jenjang': jenjang,
    });
  }

  SekolahCompanion copyWith(
      {Value<int>? id,
      Value<String>? namaSekolah,
      Value<int>? kodeSekolah,
      Value<String>? jenjang}) {
    return SekolahCompanion(
      id: id ?? this.id,
      namaSekolah: namaSekolah ?? this.namaSekolah,
      kodeSekolah: kodeSekolah ?? this.kodeSekolah,
      jenjang: jenjang ?? this.jenjang,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (namaSekolah.present) {
      map['nama_sekolah'] = Variable<String>(namaSekolah.value);
    }
    if (kodeSekolah.present) {
      map['kode_sekolah'] = Variable<int>(kodeSekolah.value);
    }
    if (jenjang.present) {
      map['jenjang'] = Variable<String>(jenjang.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SekolahCompanion(')
          ..write('id: $id, ')
          ..write('namaSekolah: $namaSekolah, ')
          ..write('kodeSekolah: $kodeSekolah, ')
          ..write('jenjang: $jenjang')
          ..write(')'))
        .toString();
  }
}

class $TahunAjaranTable extends TahunAjaran
    with TableInfo<$TahunAjaranTable, TahunAjaranData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TahunAjaranTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _namaTaMeta = const VerificationMeta('namaTa');
  @override
  late final GeneratedColumn<String> namaTa = GeneratedColumn<String>(
      'nama_ta', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isAktifMeta =
      const VerificationMeta('isAktif');
  @override
  late final GeneratedColumn<int> isAktif = GeneratedColumn<int>(
      'is_aktif', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [id, namaTa, isAktif];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tahun_ajaran';
  @override
  VerificationContext validateIntegrity(Insertable<TahunAjaranData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama_ta')) {
      context.handle(_namaTaMeta,
          namaTa.isAcceptableOrUnknown(data['nama_ta']!, _namaTaMeta));
    } else if (isInserting) {
      context.missing(_namaTaMeta);
    }
    if (data.containsKey('is_aktif')) {
      context.handle(_isAktifMeta,
          isAktif.isAcceptableOrUnknown(data['is_aktif']!, _isAktifMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TahunAjaranData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TahunAjaranData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      namaTa: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama_ta'])!,
      isAktif: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_aktif'])!,
    );
  }

  @override
  $TahunAjaranTable createAlias(String alias) {
    return $TahunAjaranTable(attachedDatabase, alias);
  }
}

class TahunAjaranData extends DataClass implements Insertable<TahunAjaranData> {
  final int id;
  final String namaTa;
  final int isAktif;
  const TahunAjaranData(
      {required this.id, required this.namaTa, required this.isAktif});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nama_ta'] = Variable<String>(namaTa);
    map['is_aktif'] = Variable<int>(isAktif);
    return map;
  }

  TahunAjaranCompanion toCompanion(bool nullToAbsent) {
    return TahunAjaranCompanion(
      id: Value(id),
      namaTa: Value(namaTa),
      isAktif: Value(isAktif),
    );
  }

  factory TahunAjaranData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TahunAjaranData(
      id: serializer.fromJson<int>(json['id']),
      namaTa: serializer.fromJson<String>(json['namaTa']),
      isAktif: serializer.fromJson<int>(json['isAktif']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'namaTa': serializer.toJson<String>(namaTa),
      'isAktif': serializer.toJson<int>(isAktif),
    };
  }

  TahunAjaranData copyWith({int? id, String? namaTa, int? isAktif}) =>
      TahunAjaranData(
        id: id ?? this.id,
        namaTa: namaTa ?? this.namaTa,
        isAktif: isAktif ?? this.isAktif,
      );
  TahunAjaranData copyWithCompanion(TahunAjaranCompanion data) {
    return TahunAjaranData(
      id: data.id.present ? data.id.value : this.id,
      namaTa: data.namaTa.present ? data.namaTa.value : this.namaTa,
      isAktif: data.isAktif.present ? data.isAktif.value : this.isAktif,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TahunAjaranData(')
          ..write('id: $id, ')
          ..write('namaTa: $namaTa, ')
          ..write('isAktif: $isAktif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, namaTa, isAktif);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TahunAjaranData &&
          other.id == this.id &&
          other.namaTa == this.namaTa &&
          other.isAktif == this.isAktif);
}

class TahunAjaranCompanion extends UpdateCompanion<TahunAjaranData> {
  final Value<int> id;
  final Value<String> namaTa;
  final Value<int> isAktif;
  const TahunAjaranCompanion({
    this.id = const Value.absent(),
    this.namaTa = const Value.absent(),
    this.isAktif = const Value.absent(),
  });
  TahunAjaranCompanion.insert({
    this.id = const Value.absent(),
    required String namaTa,
    this.isAktif = const Value.absent(),
  }) : namaTa = Value(namaTa);
  static Insertable<TahunAjaranData> custom({
    Expression<int>? id,
    Expression<String>? namaTa,
    Expression<int>? isAktif,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (namaTa != null) 'nama_ta': namaTa,
      if (isAktif != null) 'is_aktif': isAktif,
    });
  }

  TahunAjaranCompanion copyWith(
      {Value<int>? id, Value<String>? namaTa, Value<int>? isAktif}) {
    return TahunAjaranCompanion(
      id: id ?? this.id,
      namaTa: namaTa ?? this.namaTa,
      isAktif: isAktif ?? this.isAktif,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (namaTa.present) {
      map['nama_ta'] = Variable<String>(namaTa.value);
    }
    if (isAktif.present) {
      map['is_aktif'] = Variable<int>(isAktif.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TahunAjaranCompanion(')
          ..write('id: $id, ')
          ..write('namaTa: $namaTa, ')
          ..write('isAktif: $isAktif')
          ..write(')'))
        .toString();
  }
}

class $KelasTable extends Kelas with TableInfo<$KelasTable, KelasData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KelasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sekolahIdMeta =
      const VerificationMeta('sekolahId');
  @override
  late final GeneratedColumn<int> sekolahId = GeneratedColumn<int>(
      'sekolah_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sekolah (id) ON DELETE CASCADE'));
  static const VerificationMeta _tingkatMeta =
      const VerificationMeta('tingkat');
  @override
  late final GeneratedColumn<int> tingkat = GeneratedColumn<int>(
      'tingkat', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _namaKelasMeta =
      const VerificationMeta('namaKelas');
  @override
  late final GeneratedColumn<String> namaKelas = GeneratedColumn<String>(
      'nama_kelas', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, sekolahId, tingkat, namaKelas];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kelas';
  @override
  VerificationContext validateIntegrity(Insertable<KelasData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sekolah_id')) {
      context.handle(_sekolahIdMeta,
          sekolahId.isAcceptableOrUnknown(data['sekolah_id']!, _sekolahIdMeta));
    } else if (isInserting) {
      context.missing(_sekolahIdMeta);
    }
    if (data.containsKey('tingkat')) {
      context.handle(_tingkatMeta,
          tingkat.isAcceptableOrUnknown(data['tingkat']!, _tingkatMeta));
    } else if (isInserting) {
      context.missing(_tingkatMeta);
    }
    if (data.containsKey('nama_kelas')) {
      context.handle(_namaKelasMeta,
          namaKelas.isAcceptableOrUnknown(data['nama_kelas']!, _namaKelasMeta));
    } else if (isInserting) {
      context.missing(_namaKelasMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KelasData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KelasData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sekolahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sekolah_id'])!,
      tingkat: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tingkat'])!,
      namaKelas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama_kelas'])!,
    );
  }

  @override
  $KelasTable createAlias(String alias) {
    return $KelasTable(attachedDatabase, alias);
  }
}

class KelasData extends DataClass implements Insertable<KelasData> {
  final int id;
  final int sekolahId;
  final int tingkat;
  final String namaKelas;
  const KelasData(
      {required this.id,
      required this.sekolahId,
      required this.tingkat,
      required this.namaKelas});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sekolah_id'] = Variable<int>(sekolahId);
    map['tingkat'] = Variable<int>(tingkat);
    map['nama_kelas'] = Variable<String>(namaKelas);
    return map;
  }

  KelasCompanion toCompanion(bool nullToAbsent) {
    return KelasCompanion(
      id: Value(id),
      sekolahId: Value(sekolahId),
      tingkat: Value(tingkat),
      namaKelas: Value(namaKelas),
    );
  }

  factory KelasData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KelasData(
      id: serializer.fromJson<int>(json['id']),
      sekolahId: serializer.fromJson<int>(json['sekolahId']),
      tingkat: serializer.fromJson<int>(json['tingkat']),
      namaKelas: serializer.fromJson<String>(json['namaKelas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sekolahId': serializer.toJson<int>(sekolahId),
      'tingkat': serializer.toJson<int>(tingkat),
      'namaKelas': serializer.toJson<String>(namaKelas),
    };
  }

  KelasData copyWith(
          {int? id, int? sekolahId, int? tingkat, String? namaKelas}) =>
      KelasData(
        id: id ?? this.id,
        sekolahId: sekolahId ?? this.sekolahId,
        tingkat: tingkat ?? this.tingkat,
        namaKelas: namaKelas ?? this.namaKelas,
      );
  KelasData copyWithCompanion(KelasCompanion data) {
    return KelasData(
      id: data.id.present ? data.id.value : this.id,
      sekolahId: data.sekolahId.present ? data.sekolahId.value : this.sekolahId,
      tingkat: data.tingkat.present ? data.tingkat.value : this.tingkat,
      namaKelas: data.namaKelas.present ? data.namaKelas.value : this.namaKelas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KelasData(')
          ..write('id: $id, ')
          ..write('sekolahId: $sekolahId, ')
          ..write('tingkat: $tingkat, ')
          ..write('namaKelas: $namaKelas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sekolahId, tingkat, namaKelas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KelasData &&
          other.id == this.id &&
          other.sekolahId == this.sekolahId &&
          other.tingkat == this.tingkat &&
          other.namaKelas == this.namaKelas);
}

class KelasCompanion extends UpdateCompanion<KelasData> {
  final Value<int> id;
  final Value<int> sekolahId;
  final Value<int> tingkat;
  final Value<String> namaKelas;
  const KelasCompanion({
    this.id = const Value.absent(),
    this.sekolahId = const Value.absent(),
    this.tingkat = const Value.absent(),
    this.namaKelas = const Value.absent(),
  });
  KelasCompanion.insert({
    this.id = const Value.absent(),
    required int sekolahId,
    required int tingkat,
    required String namaKelas,
  })  : sekolahId = Value(sekolahId),
        tingkat = Value(tingkat),
        namaKelas = Value(namaKelas);
  static Insertable<KelasData> custom({
    Expression<int>? id,
    Expression<int>? sekolahId,
    Expression<int>? tingkat,
    Expression<String>? namaKelas,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sekolahId != null) 'sekolah_id': sekolahId,
      if (tingkat != null) 'tingkat': tingkat,
      if (namaKelas != null) 'nama_kelas': namaKelas,
    });
  }

  KelasCompanion copyWith(
      {Value<int>? id,
      Value<int>? sekolahId,
      Value<int>? tingkat,
      Value<String>? namaKelas}) {
    return KelasCompanion(
      id: id ?? this.id,
      sekolahId: sekolahId ?? this.sekolahId,
      tingkat: tingkat ?? this.tingkat,
      namaKelas: namaKelas ?? this.namaKelas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sekolahId.present) {
      map['sekolah_id'] = Variable<int>(sekolahId.value);
    }
    if (tingkat.present) {
      map['tingkat'] = Variable<int>(tingkat.value);
    }
    if (namaKelas.present) {
      map['nama_kelas'] = Variable<String>(namaKelas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KelasCompanion(')
          ..write('id: $id, ')
          ..write('sekolahId: $sekolahId, ')
          ..write('tingkat: $tingkat, ')
          ..write('namaKelas: $namaKelas')
          ..write(')'))
        .toString();
  }
}

class $KategoriBiayaTable extends KategoriBiaya
    with TableInfo<$KategoriBiayaTable, KategoriBiayaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KategoriBiayaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _namaBiayaMeta =
      const VerificationMeta('namaBiaya');
  @override
  late final GeneratedColumn<String> namaBiaya = GeneratedColumn<String>(
      'nama_biaya', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipeMeta = const VerificationMeta('tipe');
  @override
  late final GeneratedColumn<String> tipe = GeneratedColumn<String>(
      'tipe', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, namaBiaya, tipe];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kategori_biaya';
  @override
  VerificationContext validateIntegrity(Insertable<KategoriBiayaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama_biaya')) {
      context.handle(_namaBiayaMeta,
          namaBiaya.isAcceptableOrUnknown(data['nama_biaya']!, _namaBiayaMeta));
    } else if (isInserting) {
      context.missing(_namaBiayaMeta);
    }
    if (data.containsKey('tipe')) {
      context.handle(
          _tipeMeta, tipe.isAcceptableOrUnknown(data['tipe']!, _tipeMeta));
    } else if (isInserting) {
      context.missing(_tipeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KategoriBiayaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KategoriBiayaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      namaBiaya: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama_biaya'])!,
      tipe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipe'])!,
    );
  }

  @override
  $KategoriBiayaTable createAlias(String alias) {
    return $KategoriBiayaTable(attachedDatabase, alias);
  }
}

class KategoriBiayaData extends DataClass
    implements Insertable<KategoriBiayaData> {
  final int id;
  final String namaBiaya;
  final String tipe;
  const KategoriBiayaData(
      {required this.id, required this.namaBiaya, required this.tipe});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nama_biaya'] = Variable<String>(namaBiaya);
    map['tipe'] = Variable<String>(tipe);
    return map;
  }

  KategoriBiayaCompanion toCompanion(bool nullToAbsent) {
    return KategoriBiayaCompanion(
      id: Value(id),
      namaBiaya: Value(namaBiaya),
      tipe: Value(tipe),
    );
  }

  factory KategoriBiayaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KategoriBiayaData(
      id: serializer.fromJson<int>(json['id']),
      namaBiaya: serializer.fromJson<String>(json['namaBiaya']),
      tipe: serializer.fromJson<String>(json['tipe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'namaBiaya': serializer.toJson<String>(namaBiaya),
      'tipe': serializer.toJson<String>(tipe),
    };
  }

  KategoriBiayaData copyWith({int? id, String? namaBiaya, String? tipe}) =>
      KategoriBiayaData(
        id: id ?? this.id,
        namaBiaya: namaBiaya ?? this.namaBiaya,
        tipe: tipe ?? this.tipe,
      );
  KategoriBiayaData copyWithCompanion(KategoriBiayaCompanion data) {
    return KategoriBiayaData(
      id: data.id.present ? data.id.value : this.id,
      namaBiaya: data.namaBiaya.present ? data.namaBiaya.value : this.namaBiaya,
      tipe: data.tipe.present ? data.tipe.value : this.tipe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KategoriBiayaData(')
          ..write('id: $id, ')
          ..write('namaBiaya: $namaBiaya, ')
          ..write('tipe: $tipe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, namaBiaya, tipe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KategoriBiayaData &&
          other.id == this.id &&
          other.namaBiaya == this.namaBiaya &&
          other.tipe == this.tipe);
}

class KategoriBiayaCompanion extends UpdateCompanion<KategoriBiayaData> {
  final Value<int> id;
  final Value<String> namaBiaya;
  final Value<String> tipe;
  const KategoriBiayaCompanion({
    this.id = const Value.absent(),
    this.namaBiaya = const Value.absent(),
    this.tipe = const Value.absent(),
  });
  KategoriBiayaCompanion.insert({
    this.id = const Value.absent(),
    required String namaBiaya,
    required String tipe,
  })  : namaBiaya = Value(namaBiaya),
        tipe = Value(tipe);
  static Insertable<KategoriBiayaData> custom({
    Expression<int>? id,
    Expression<String>? namaBiaya,
    Expression<String>? tipe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (namaBiaya != null) 'nama_biaya': namaBiaya,
      if (tipe != null) 'tipe': tipe,
    });
  }

  KategoriBiayaCompanion copyWith(
      {Value<int>? id, Value<String>? namaBiaya, Value<String>? tipe}) {
    return KategoriBiayaCompanion(
      id: id ?? this.id,
      namaBiaya: namaBiaya ?? this.namaBiaya,
      tipe: tipe ?? this.tipe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (namaBiaya.present) {
      map['nama_biaya'] = Variable<String>(namaBiaya.value);
    }
    if (tipe.present) {
      map['tipe'] = Variable<String>(tipe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KategoriBiayaCompanion(')
          ..write('id: $id, ')
          ..write('namaBiaya: $namaBiaya, ')
          ..write('tipe: $tipe')
          ..write(')'))
        .toString();
  }
}

class $SiswaTable extends Siswa with TableInfo<$SiswaTable, SiswaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SiswaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sekolahIdMeta =
      const VerificationMeta('sekolahId');
  @override
  late final GeneratedColumn<int> sekolahId = GeneratedColumn<int>(
      'sekolah_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sekolah (id) ON DELETE RESTRICT'));
  static const VerificationMeta _nisMeta = const VerificationMeta('nis');
  @override
  late final GeneratedColumn<String> nis = GeneratedColumn<String>(
      'nis', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nisnMeta = const VerificationMeta('nisn');
  @override
  late final GeneratedColumn<String> nisn = GeneratedColumn<String>(
      'nisn', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _namaLengkapMeta =
      const VerificationMeta('namaLengkap');
  @override
  late final GeneratedColumn<String> namaLengkap = GeneratedColumn<String>(
      'nama_lengkap', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jenisKelaminMeta =
      const VerificationMeta('jenisKelamin');
  @override
  late final GeneratedColumn<String> jenisKelamin = GeneratedColumn<String>(
      'jenis_kelamin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kelasIdMeta =
      const VerificationMeta('kelasId');
  @override
  late final GeneratedColumn<int> kelasId = GeneratedColumn<int>(
      'kelas_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES kelas (id) ON DELETE RESTRICT'));
  static const VerificationMeta _tahunMasukMeta =
      const VerificationMeta('tahunMasuk');
  @override
  late final GeneratedColumn<int> tahunMasuk = GeneratedColumn<int>(
      'tahun_masuk', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _kontakWaliMeta =
      const VerificationMeta('kontakWali');
  @override
  late final GeneratedColumn<String> kontakWali = GeneratedColumn<String>(
      'kontak_wali', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('AKTIF'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sekolahId,
        nis,
        nisn,
        namaLengkap,
        jenisKelamin,
        kelasId,
        tahunMasuk,
        kontakWali,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'siswa';
  @override
  VerificationContext validateIntegrity(Insertable<SiswaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sekolah_id')) {
      context.handle(_sekolahIdMeta,
          sekolahId.isAcceptableOrUnknown(data['sekolah_id']!, _sekolahIdMeta));
    } else if (isInserting) {
      context.missing(_sekolahIdMeta);
    }
    if (data.containsKey('nis')) {
      context.handle(
          _nisMeta, nis.isAcceptableOrUnknown(data['nis']!, _nisMeta));
    } else if (isInserting) {
      context.missing(_nisMeta);
    }
    if (data.containsKey('nisn')) {
      context.handle(
          _nisnMeta, nisn.isAcceptableOrUnknown(data['nisn']!, _nisnMeta));
    }
    if (data.containsKey('nama_lengkap')) {
      context.handle(
          _namaLengkapMeta,
          namaLengkap.isAcceptableOrUnknown(
              data['nama_lengkap']!, _namaLengkapMeta));
    } else if (isInserting) {
      context.missing(_namaLengkapMeta);
    }
    if (data.containsKey('jenis_kelamin')) {
      context.handle(
          _jenisKelaminMeta,
          jenisKelamin.isAcceptableOrUnknown(
              data['jenis_kelamin']!, _jenisKelaminMeta));
    } else if (isInserting) {
      context.missing(_jenisKelaminMeta);
    }
    if (data.containsKey('kelas_id')) {
      context.handle(_kelasIdMeta,
          kelasId.isAcceptableOrUnknown(data['kelas_id']!, _kelasIdMeta));
    } else if (isInserting) {
      context.missing(_kelasIdMeta);
    }
    if (data.containsKey('tahun_masuk')) {
      context.handle(
          _tahunMasukMeta,
          tahunMasuk.isAcceptableOrUnknown(
              data['tahun_masuk']!, _tahunMasukMeta));
    } else if (isInserting) {
      context.missing(_tahunMasukMeta);
    }
    if (data.containsKey('kontak_wali')) {
      context.handle(
          _kontakWaliMeta,
          kontakWali.isAcceptableOrUnknown(
              data['kontak_wali']!, _kontakWaliMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SiswaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SiswaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sekolahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sekolah_id'])!,
      nis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nis'])!,
      nisn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nisn']),
      namaLengkap: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama_lengkap'])!,
      jenisKelamin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}jenis_kelamin'])!,
      kelasId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kelas_id'])!,
      tahunMasuk: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tahun_masuk'])!,
      kontakWali: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kontak_wali']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $SiswaTable createAlias(String alias) {
    return $SiswaTable(attachedDatabase, alias);
  }
}

class SiswaData extends DataClass implements Insertable<SiswaData> {
  final int id;
  final int sekolahId;
  final String nis;
  final String? nisn;
  final String namaLengkap;
  final String jenisKelamin;
  final int kelasId;
  final int tahunMasuk;
  final String? kontakWali;
  final String status;
  const SiswaData(
      {required this.id,
      required this.sekolahId,
      required this.nis,
      this.nisn,
      required this.namaLengkap,
      required this.jenisKelamin,
      required this.kelasId,
      required this.tahunMasuk,
      this.kontakWali,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sekolah_id'] = Variable<int>(sekolahId);
    map['nis'] = Variable<String>(nis);
    if (!nullToAbsent || nisn != null) {
      map['nisn'] = Variable<String>(nisn);
    }
    map['nama_lengkap'] = Variable<String>(namaLengkap);
    map['jenis_kelamin'] = Variable<String>(jenisKelamin);
    map['kelas_id'] = Variable<int>(kelasId);
    map['tahun_masuk'] = Variable<int>(tahunMasuk);
    if (!nullToAbsent || kontakWali != null) {
      map['kontak_wali'] = Variable<String>(kontakWali);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  SiswaCompanion toCompanion(bool nullToAbsent) {
    return SiswaCompanion(
      id: Value(id),
      sekolahId: Value(sekolahId),
      nis: Value(nis),
      nisn: nisn == null && nullToAbsent ? const Value.absent() : Value(nisn),
      namaLengkap: Value(namaLengkap),
      jenisKelamin: Value(jenisKelamin),
      kelasId: Value(kelasId),
      tahunMasuk: Value(tahunMasuk),
      kontakWali: kontakWali == null && nullToAbsent
          ? const Value.absent()
          : Value(kontakWali),
      status: Value(status),
    );
  }

  factory SiswaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SiswaData(
      id: serializer.fromJson<int>(json['id']),
      sekolahId: serializer.fromJson<int>(json['sekolahId']),
      nis: serializer.fromJson<String>(json['nis']),
      nisn: serializer.fromJson<String?>(json['nisn']),
      namaLengkap: serializer.fromJson<String>(json['namaLengkap']),
      jenisKelamin: serializer.fromJson<String>(json['jenisKelamin']),
      kelasId: serializer.fromJson<int>(json['kelasId']),
      tahunMasuk: serializer.fromJson<int>(json['tahunMasuk']),
      kontakWali: serializer.fromJson<String?>(json['kontakWali']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sekolahId': serializer.toJson<int>(sekolahId),
      'nis': serializer.toJson<String>(nis),
      'nisn': serializer.toJson<String?>(nisn),
      'namaLengkap': serializer.toJson<String>(namaLengkap),
      'jenisKelamin': serializer.toJson<String>(jenisKelamin),
      'kelasId': serializer.toJson<int>(kelasId),
      'tahunMasuk': serializer.toJson<int>(tahunMasuk),
      'kontakWali': serializer.toJson<String?>(kontakWali),
      'status': serializer.toJson<String>(status),
    };
  }

  SiswaData copyWith(
          {int? id,
          int? sekolahId,
          String? nis,
          Value<String?> nisn = const Value.absent(),
          String? namaLengkap,
          String? jenisKelamin,
          int? kelasId,
          int? tahunMasuk,
          Value<String?> kontakWali = const Value.absent(),
          String? status}) =>
      SiswaData(
        id: id ?? this.id,
        sekolahId: sekolahId ?? this.sekolahId,
        nis: nis ?? this.nis,
        nisn: nisn.present ? nisn.value : this.nisn,
        namaLengkap: namaLengkap ?? this.namaLengkap,
        jenisKelamin: jenisKelamin ?? this.jenisKelamin,
        kelasId: kelasId ?? this.kelasId,
        tahunMasuk: tahunMasuk ?? this.tahunMasuk,
        kontakWali: kontakWali.present ? kontakWali.value : this.kontakWali,
        status: status ?? this.status,
      );
  SiswaData copyWithCompanion(SiswaCompanion data) {
    return SiswaData(
      id: data.id.present ? data.id.value : this.id,
      sekolahId: data.sekolahId.present ? data.sekolahId.value : this.sekolahId,
      nis: data.nis.present ? data.nis.value : this.nis,
      nisn: data.nisn.present ? data.nisn.value : this.nisn,
      namaLengkap:
          data.namaLengkap.present ? data.namaLengkap.value : this.namaLengkap,
      jenisKelamin: data.jenisKelamin.present
          ? data.jenisKelamin.value
          : this.jenisKelamin,
      kelasId: data.kelasId.present ? data.kelasId.value : this.kelasId,
      tahunMasuk:
          data.tahunMasuk.present ? data.tahunMasuk.value : this.tahunMasuk,
      kontakWali:
          data.kontakWali.present ? data.kontakWali.value : this.kontakWali,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SiswaData(')
          ..write('id: $id, ')
          ..write('sekolahId: $sekolahId, ')
          ..write('nis: $nis, ')
          ..write('nisn: $nisn, ')
          ..write('namaLengkap: $namaLengkap, ')
          ..write('jenisKelamin: $jenisKelamin, ')
          ..write('kelasId: $kelasId, ')
          ..write('tahunMasuk: $tahunMasuk, ')
          ..write('kontakWali: $kontakWali, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sekolahId, nis, nisn, namaLengkap,
      jenisKelamin, kelasId, tahunMasuk, kontakWali, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SiswaData &&
          other.id == this.id &&
          other.sekolahId == this.sekolahId &&
          other.nis == this.nis &&
          other.nisn == this.nisn &&
          other.namaLengkap == this.namaLengkap &&
          other.jenisKelamin == this.jenisKelamin &&
          other.kelasId == this.kelasId &&
          other.tahunMasuk == this.tahunMasuk &&
          other.kontakWali == this.kontakWali &&
          other.status == this.status);
}

class SiswaCompanion extends UpdateCompanion<SiswaData> {
  final Value<int> id;
  final Value<int> sekolahId;
  final Value<String> nis;
  final Value<String?> nisn;
  final Value<String> namaLengkap;
  final Value<String> jenisKelamin;
  final Value<int> kelasId;
  final Value<int> tahunMasuk;
  final Value<String?> kontakWali;
  final Value<String> status;
  const SiswaCompanion({
    this.id = const Value.absent(),
    this.sekolahId = const Value.absent(),
    this.nis = const Value.absent(),
    this.nisn = const Value.absent(),
    this.namaLengkap = const Value.absent(),
    this.jenisKelamin = const Value.absent(),
    this.kelasId = const Value.absent(),
    this.tahunMasuk = const Value.absent(),
    this.kontakWali = const Value.absent(),
    this.status = const Value.absent(),
  });
  SiswaCompanion.insert({
    this.id = const Value.absent(),
    required int sekolahId,
    required String nis,
    this.nisn = const Value.absent(),
    required String namaLengkap,
    required String jenisKelamin,
    required int kelasId,
    required int tahunMasuk,
    this.kontakWali = const Value.absent(),
    this.status = const Value.absent(),
  })  : sekolahId = Value(sekolahId),
        nis = Value(nis),
        namaLengkap = Value(namaLengkap),
        jenisKelamin = Value(jenisKelamin),
        kelasId = Value(kelasId),
        tahunMasuk = Value(tahunMasuk);
  static Insertable<SiswaData> custom({
    Expression<int>? id,
    Expression<int>? sekolahId,
    Expression<String>? nis,
    Expression<String>? nisn,
    Expression<String>? namaLengkap,
    Expression<String>? jenisKelamin,
    Expression<int>? kelasId,
    Expression<int>? tahunMasuk,
    Expression<String>? kontakWali,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sekolahId != null) 'sekolah_id': sekolahId,
      if (nis != null) 'nis': nis,
      if (nisn != null) 'nisn': nisn,
      if (namaLengkap != null) 'nama_lengkap': namaLengkap,
      if (jenisKelamin != null) 'jenis_kelamin': jenisKelamin,
      if (kelasId != null) 'kelas_id': kelasId,
      if (tahunMasuk != null) 'tahun_masuk': tahunMasuk,
      if (kontakWali != null) 'kontak_wali': kontakWali,
      if (status != null) 'status': status,
    });
  }

  SiswaCompanion copyWith(
      {Value<int>? id,
      Value<int>? sekolahId,
      Value<String>? nis,
      Value<String?>? nisn,
      Value<String>? namaLengkap,
      Value<String>? jenisKelamin,
      Value<int>? kelasId,
      Value<int>? tahunMasuk,
      Value<String?>? kontakWali,
      Value<String>? status}) {
    return SiswaCompanion(
      id: id ?? this.id,
      sekolahId: sekolahId ?? this.sekolahId,
      nis: nis ?? this.nis,
      nisn: nisn ?? this.nisn,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      kelasId: kelasId ?? this.kelasId,
      tahunMasuk: tahunMasuk ?? this.tahunMasuk,
      kontakWali: kontakWali ?? this.kontakWali,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sekolahId.present) {
      map['sekolah_id'] = Variable<int>(sekolahId.value);
    }
    if (nis.present) {
      map['nis'] = Variable<String>(nis.value);
    }
    if (nisn.present) {
      map['nisn'] = Variable<String>(nisn.value);
    }
    if (namaLengkap.present) {
      map['nama_lengkap'] = Variable<String>(namaLengkap.value);
    }
    if (jenisKelamin.present) {
      map['jenis_kelamin'] = Variable<String>(jenisKelamin.value);
    }
    if (kelasId.present) {
      map['kelas_id'] = Variable<int>(kelasId.value);
    }
    if (tahunMasuk.present) {
      map['tahun_masuk'] = Variable<int>(tahunMasuk.value);
    }
    if (kontakWali.present) {
      map['kontak_wali'] = Variable<String>(kontakWali.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SiswaCompanion(')
          ..write('id: $id, ')
          ..write('sekolahId: $sekolahId, ')
          ..write('nis: $nis, ')
          ..write('nisn: $nisn, ')
          ..write('namaLengkap: $namaLengkap, ')
          ..write('jenisKelamin: $jenisKelamin, ')
          ..write('kelasId: $kelasId, ')
          ..write('tahunMasuk: $tahunMasuk, ')
          ..write('kontakWali: $kontakWali, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $TarifMasterTable extends TarifMaster
    with TableInfo<$TarifMasterTable, TarifMasterData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TarifMasterTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _kategoriBiayaIdMeta =
      const VerificationMeta('kategoriBiayaId');
  @override
  late final GeneratedColumn<int> kategoriBiayaId = GeneratedColumn<int>(
      'kategori_biaya_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES kategori_biaya (id) ON DELETE RESTRICT'));
  static const VerificationMeta _tingkatMeta =
      const VerificationMeta('tingkat');
  @override
  late final GeneratedColumn<int> tingkat = GeneratedColumn<int>(
      'tingkat', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nominalMeta =
      const VerificationMeta('nominal');
  @override
  late final GeneratedColumn<int> nominal = GeneratedColumn<int>(
      'nominal', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, kategoriBiayaId, tingkat, nominal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tarif_master';
  @override
  VerificationContext validateIntegrity(Insertable<TarifMasterData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kategori_biaya_id')) {
      context.handle(
          _kategoriBiayaIdMeta,
          kategoriBiayaId.isAcceptableOrUnknown(
              data['kategori_biaya_id']!, _kategoriBiayaIdMeta));
    } else if (isInserting) {
      context.missing(_kategoriBiayaIdMeta);
    }
    if (data.containsKey('tingkat')) {
      context.handle(_tingkatMeta,
          tingkat.isAcceptableOrUnknown(data['tingkat']!, _tingkatMeta));
    } else if (isInserting) {
      context.missing(_tingkatMeta);
    }
    if (data.containsKey('nominal')) {
      context.handle(_nominalMeta,
          nominal.isAcceptableOrUnknown(data['nominal']!, _nominalMeta));
    } else if (isInserting) {
      context.missing(_nominalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TarifMasterData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TarifMasterData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kategoriBiayaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kategori_biaya_id'])!,
      tingkat: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tingkat'])!,
      nominal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nominal'])!,
    );
  }

  @override
  $TarifMasterTable createAlias(String alias) {
    return $TarifMasterTable(attachedDatabase, alias);
  }
}

class TarifMasterData extends DataClass implements Insertable<TarifMasterData> {
  final int id;
  final int kategoriBiayaId;
  final int tingkat;
  final int nominal;
  const TarifMasterData(
      {required this.id,
      required this.kategoriBiayaId,
      required this.tingkat,
      required this.nominal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kategori_biaya_id'] = Variable<int>(kategoriBiayaId);
    map['tingkat'] = Variable<int>(tingkat);
    map['nominal'] = Variable<int>(nominal);
    return map;
  }

  TarifMasterCompanion toCompanion(bool nullToAbsent) {
    return TarifMasterCompanion(
      id: Value(id),
      kategoriBiayaId: Value(kategoriBiayaId),
      tingkat: Value(tingkat),
      nominal: Value(nominal),
    );
  }

  factory TarifMasterData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TarifMasterData(
      id: serializer.fromJson<int>(json['id']),
      kategoriBiayaId: serializer.fromJson<int>(json['kategoriBiayaId']),
      tingkat: serializer.fromJson<int>(json['tingkat']),
      nominal: serializer.fromJson<int>(json['nominal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kategoriBiayaId': serializer.toJson<int>(kategoriBiayaId),
      'tingkat': serializer.toJson<int>(tingkat),
      'nominal': serializer.toJson<int>(nominal),
    };
  }

  TarifMasterData copyWith(
          {int? id, int? kategoriBiayaId, int? tingkat, int? nominal}) =>
      TarifMasterData(
        id: id ?? this.id,
        kategoriBiayaId: kategoriBiayaId ?? this.kategoriBiayaId,
        tingkat: tingkat ?? this.tingkat,
        nominal: nominal ?? this.nominal,
      );
  TarifMasterData copyWithCompanion(TarifMasterCompanion data) {
    return TarifMasterData(
      id: data.id.present ? data.id.value : this.id,
      kategoriBiayaId: data.kategoriBiayaId.present
          ? data.kategoriBiayaId.value
          : this.kategoriBiayaId,
      tingkat: data.tingkat.present ? data.tingkat.value : this.tingkat,
      nominal: data.nominal.present ? data.nominal.value : this.nominal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TarifMasterData(')
          ..write('id: $id, ')
          ..write('kategoriBiayaId: $kategoriBiayaId, ')
          ..write('tingkat: $tingkat, ')
          ..write('nominal: $nominal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kategoriBiayaId, tingkat, nominal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TarifMasterData &&
          other.id == this.id &&
          other.kategoriBiayaId == this.kategoriBiayaId &&
          other.tingkat == this.tingkat &&
          other.nominal == this.nominal);
}

class TarifMasterCompanion extends UpdateCompanion<TarifMasterData> {
  final Value<int> id;
  final Value<int> kategoriBiayaId;
  final Value<int> tingkat;
  final Value<int> nominal;
  const TarifMasterCompanion({
    this.id = const Value.absent(),
    this.kategoriBiayaId = const Value.absent(),
    this.tingkat = const Value.absent(),
    this.nominal = const Value.absent(),
  });
  TarifMasterCompanion.insert({
    this.id = const Value.absent(),
    required int kategoriBiayaId,
    required int tingkat,
    required int nominal,
  })  : kategoriBiayaId = Value(kategoriBiayaId),
        tingkat = Value(tingkat),
        nominal = Value(nominal);
  static Insertable<TarifMasterData> custom({
    Expression<int>? id,
    Expression<int>? kategoriBiayaId,
    Expression<int>? tingkat,
    Expression<int>? nominal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kategoriBiayaId != null) 'kategori_biaya_id': kategoriBiayaId,
      if (tingkat != null) 'tingkat': tingkat,
      if (nominal != null) 'nominal': nominal,
    });
  }

  TarifMasterCompanion copyWith(
      {Value<int>? id,
      Value<int>? kategoriBiayaId,
      Value<int>? tingkat,
      Value<int>? nominal}) {
    return TarifMasterCompanion(
      id: id ?? this.id,
      kategoriBiayaId: kategoriBiayaId ?? this.kategoriBiayaId,
      tingkat: tingkat ?? this.tingkat,
      nominal: nominal ?? this.nominal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kategoriBiayaId.present) {
      map['kategori_biaya_id'] = Variable<int>(kategoriBiayaId.value);
    }
    if (tingkat.present) {
      map['tingkat'] = Variable<int>(tingkat.value);
    }
    if (nominal.present) {
      map['nominal'] = Variable<int>(nominal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TarifMasterCompanion(')
          ..write('id: $id, ')
          ..write('kategoriBiayaId: $kategoriBiayaId, ')
          ..write('tingkat: $tingkat, ')
          ..write('nominal: $nominal')
          ..write(')'))
        .toString();
  }
}

class $SkemaPembayaranSiswaTable extends SkemaPembayaranSiswa
    with TableInfo<$SkemaPembayaranSiswaTable, SkemaPembayaranSiswaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkemaPembayaranSiswaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _siswaIdMeta =
      const VerificationMeta('siswaId');
  @override
  late final GeneratedColumn<int> siswaId = GeneratedColumn<int>(
      'siswa_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES siswa (id) ON DELETE CASCADE'));
  static const VerificationMeta _kategoriBiayaIdMeta =
      const VerificationMeta('kategoriBiayaId');
  @override
  late final GeneratedColumn<int> kategoriBiayaId = GeneratedColumn<int>(
      'kategori_biaya_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES kategori_biaya (id) ON DELETE RESTRICT'));
  static const VerificationMeta _nominalKustomMeta =
      const VerificationMeta('nominalKustom');
  @override
  late final GeneratedColumn<int> nominalKustom = GeneratedColumn<int>(
      'nominal_kustom', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _catatanMeta =
      const VerificationMeta('catatan');
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
      'catatan', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, siswaId, kategoriBiayaId, nominalKustom, catatan];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skema_pembayaran_siswa';
  @override
  VerificationContext validateIntegrity(
      Insertable<SkemaPembayaranSiswaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('siswa_id')) {
      context.handle(_siswaIdMeta,
          siswaId.isAcceptableOrUnknown(data['siswa_id']!, _siswaIdMeta));
    } else if (isInserting) {
      context.missing(_siswaIdMeta);
    }
    if (data.containsKey('kategori_biaya_id')) {
      context.handle(
          _kategoriBiayaIdMeta,
          kategoriBiayaId.isAcceptableOrUnknown(
              data['kategori_biaya_id']!, _kategoriBiayaIdMeta));
    } else if (isInserting) {
      context.missing(_kategoriBiayaIdMeta);
    }
    if (data.containsKey('nominal_kustom')) {
      context.handle(
          _nominalKustomMeta,
          nominalKustom.isAcceptableOrUnknown(
              data['nominal_kustom']!, _nominalKustomMeta));
    } else if (isInserting) {
      context.missing(_nominalKustomMeta);
    }
    if (data.containsKey('catatan')) {
      context.handle(_catatanMeta,
          catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SkemaPembayaranSiswaData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkemaPembayaranSiswaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      siswaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}siswa_id'])!,
      kategoriBiayaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kategori_biaya_id'])!,
      nominalKustom: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nominal_kustom'])!,
      catatan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catatan']),
    );
  }

  @override
  $SkemaPembayaranSiswaTable createAlias(String alias) {
    return $SkemaPembayaranSiswaTable(attachedDatabase, alias);
  }
}

class SkemaPembayaranSiswaData extends DataClass
    implements Insertable<SkemaPembayaranSiswaData> {
  final int id;
  final int siswaId;
  final int kategoriBiayaId;
  final int nominalKustom;
  final String? catatan;
  const SkemaPembayaranSiswaData(
      {required this.id,
      required this.siswaId,
      required this.kategoriBiayaId,
      required this.nominalKustom,
      this.catatan});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['siswa_id'] = Variable<int>(siswaId);
    map['kategori_biaya_id'] = Variable<int>(kategoriBiayaId);
    map['nominal_kustom'] = Variable<int>(nominalKustom);
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    return map;
  }

  SkemaPembayaranSiswaCompanion toCompanion(bool nullToAbsent) {
    return SkemaPembayaranSiswaCompanion(
      id: Value(id),
      siswaId: Value(siswaId),
      kategoriBiayaId: Value(kategoriBiayaId),
      nominalKustom: Value(nominalKustom),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
    );
  }

  factory SkemaPembayaranSiswaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkemaPembayaranSiswaData(
      id: serializer.fromJson<int>(json['id']),
      siswaId: serializer.fromJson<int>(json['siswaId']),
      kategoriBiayaId: serializer.fromJson<int>(json['kategoriBiayaId']),
      nominalKustom: serializer.fromJson<int>(json['nominalKustom']),
      catatan: serializer.fromJson<String?>(json['catatan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siswaId': serializer.toJson<int>(siswaId),
      'kategoriBiayaId': serializer.toJson<int>(kategoriBiayaId),
      'nominalKustom': serializer.toJson<int>(nominalKustom),
      'catatan': serializer.toJson<String?>(catatan),
    };
  }

  SkemaPembayaranSiswaData copyWith(
          {int? id,
          int? siswaId,
          int? kategoriBiayaId,
          int? nominalKustom,
          Value<String?> catatan = const Value.absent()}) =>
      SkemaPembayaranSiswaData(
        id: id ?? this.id,
        siswaId: siswaId ?? this.siswaId,
        kategoriBiayaId: kategoriBiayaId ?? this.kategoriBiayaId,
        nominalKustom: nominalKustom ?? this.nominalKustom,
        catatan: catatan.present ? catatan.value : this.catatan,
      );
  SkemaPembayaranSiswaData copyWithCompanion(
      SkemaPembayaranSiswaCompanion data) {
    return SkemaPembayaranSiswaData(
      id: data.id.present ? data.id.value : this.id,
      siswaId: data.siswaId.present ? data.siswaId.value : this.siswaId,
      kategoriBiayaId: data.kategoriBiayaId.present
          ? data.kategoriBiayaId.value
          : this.kategoriBiayaId,
      nominalKustom: data.nominalKustom.present
          ? data.nominalKustom.value
          : this.nominalKustom,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkemaPembayaranSiswaData(')
          ..write('id: $id, ')
          ..write('siswaId: $siswaId, ')
          ..write('kategoriBiayaId: $kategoriBiayaId, ')
          ..write('nominalKustom: $nominalKustom, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, siswaId, kategoriBiayaId, nominalKustom, catatan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkemaPembayaranSiswaData &&
          other.id == this.id &&
          other.siswaId == this.siswaId &&
          other.kategoriBiayaId == this.kategoriBiayaId &&
          other.nominalKustom == this.nominalKustom &&
          other.catatan == this.catatan);
}

class SkemaPembayaranSiswaCompanion
    extends UpdateCompanion<SkemaPembayaranSiswaData> {
  final Value<int> id;
  final Value<int> siswaId;
  final Value<int> kategoriBiayaId;
  final Value<int> nominalKustom;
  final Value<String?> catatan;
  const SkemaPembayaranSiswaCompanion({
    this.id = const Value.absent(),
    this.siswaId = const Value.absent(),
    this.kategoriBiayaId = const Value.absent(),
    this.nominalKustom = const Value.absent(),
    this.catatan = const Value.absent(),
  });
  SkemaPembayaranSiswaCompanion.insert({
    this.id = const Value.absent(),
    required int siswaId,
    required int kategoriBiayaId,
    required int nominalKustom,
    this.catatan = const Value.absent(),
  })  : siswaId = Value(siswaId),
        kategoriBiayaId = Value(kategoriBiayaId),
        nominalKustom = Value(nominalKustom);
  static Insertable<SkemaPembayaranSiswaData> custom({
    Expression<int>? id,
    Expression<int>? siswaId,
    Expression<int>? kategoriBiayaId,
    Expression<int>? nominalKustom,
    Expression<String>? catatan,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siswaId != null) 'siswa_id': siswaId,
      if (kategoriBiayaId != null) 'kategori_biaya_id': kategoriBiayaId,
      if (nominalKustom != null) 'nominal_kustom': nominalKustom,
      if (catatan != null) 'catatan': catatan,
    });
  }

  SkemaPembayaranSiswaCompanion copyWith(
      {Value<int>? id,
      Value<int>? siswaId,
      Value<int>? kategoriBiayaId,
      Value<int>? nominalKustom,
      Value<String?>? catatan}) {
    return SkemaPembayaranSiswaCompanion(
      id: id ?? this.id,
      siswaId: siswaId ?? this.siswaId,
      kategoriBiayaId: kategoriBiayaId ?? this.kategoriBiayaId,
      nominalKustom: nominalKustom ?? this.nominalKustom,
      catatan: catatan ?? this.catatan,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (siswaId.present) {
      map['siswa_id'] = Variable<int>(siswaId.value);
    }
    if (kategoriBiayaId.present) {
      map['kategori_biaya_id'] = Variable<int>(kategoriBiayaId.value);
    }
    if (nominalKustom.present) {
      map['nominal_kustom'] = Variable<int>(nominalKustom.value);
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkemaPembayaranSiswaCompanion(')
          ..write('id: $id, ')
          ..write('siswaId: $siswaId, ')
          ..write('kategoriBiayaId: $kategoriBiayaId, ')
          ..write('nominalKustom: $nominalKustom, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }
}

class $TagihanSiswaTable extends TagihanSiswa
    with TableInfo<$TagihanSiswaTable, TagihanSiswaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagihanSiswaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _siswaIdMeta =
      const VerificationMeta('siswaId');
  @override
  late final GeneratedColumn<int> siswaId = GeneratedColumn<int>(
      'siswa_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES siswa (id) ON DELETE RESTRICT'));
  static const VerificationMeta _periodeMeta =
      const VerificationMeta('periode');
  @override
  late final GeneratedColumn<String> periode = GeneratedColumn<String>(
      'periode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isLunasMeta =
      const VerificationMeta('isLunas');
  @override
  late final GeneratedColumn<int> isLunas = GeneratedColumn<int>(
      'is_lunas', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, siswaId, periode, isLunas];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tagihan_siswa';
  @override
  VerificationContext validateIntegrity(Insertable<TagihanSiswaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('siswa_id')) {
      context.handle(_siswaIdMeta,
          siswaId.isAcceptableOrUnknown(data['siswa_id']!, _siswaIdMeta));
    } else if (isInserting) {
      context.missing(_siswaIdMeta);
    }
    if (data.containsKey('periode')) {
      context.handle(_periodeMeta,
          periode.isAcceptableOrUnknown(data['periode']!, _periodeMeta));
    } else if (isInserting) {
      context.missing(_periodeMeta);
    }
    if (data.containsKey('is_lunas')) {
      context.handle(_isLunasMeta,
          isLunas.isAcceptableOrUnknown(data['is_lunas']!, _isLunasMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagihanSiswaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagihanSiswaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      siswaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}siswa_id'])!,
      periode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}periode'])!,
      isLunas: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_lunas'])!,
    );
  }

  @override
  $TagihanSiswaTable createAlias(String alias) {
    return $TagihanSiswaTable(attachedDatabase, alias);
  }
}

class TagihanSiswaData extends DataClass
    implements Insertable<TagihanSiswaData> {
  final int id;
  final int siswaId;
  final String periode;
  final int isLunas;
  const TagihanSiswaData(
      {required this.id,
      required this.siswaId,
      required this.periode,
      required this.isLunas});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['siswa_id'] = Variable<int>(siswaId);
    map['periode'] = Variable<String>(periode);
    map['is_lunas'] = Variable<int>(isLunas);
    return map;
  }

  TagihanSiswaCompanion toCompanion(bool nullToAbsent) {
    return TagihanSiswaCompanion(
      id: Value(id),
      siswaId: Value(siswaId),
      periode: Value(periode),
      isLunas: Value(isLunas),
    );
  }

  factory TagihanSiswaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagihanSiswaData(
      id: serializer.fromJson<int>(json['id']),
      siswaId: serializer.fromJson<int>(json['siswaId']),
      periode: serializer.fromJson<String>(json['periode']),
      isLunas: serializer.fromJson<int>(json['isLunas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siswaId': serializer.toJson<int>(siswaId),
      'periode': serializer.toJson<String>(periode),
      'isLunas': serializer.toJson<int>(isLunas),
    };
  }

  TagihanSiswaData copyWith(
          {int? id, int? siswaId, String? periode, int? isLunas}) =>
      TagihanSiswaData(
        id: id ?? this.id,
        siswaId: siswaId ?? this.siswaId,
        periode: periode ?? this.periode,
        isLunas: isLunas ?? this.isLunas,
      );
  TagihanSiswaData copyWithCompanion(TagihanSiswaCompanion data) {
    return TagihanSiswaData(
      id: data.id.present ? data.id.value : this.id,
      siswaId: data.siswaId.present ? data.siswaId.value : this.siswaId,
      periode: data.periode.present ? data.periode.value : this.periode,
      isLunas: data.isLunas.present ? data.isLunas.value : this.isLunas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagihanSiswaData(')
          ..write('id: $id, ')
          ..write('siswaId: $siswaId, ')
          ..write('periode: $periode, ')
          ..write('isLunas: $isLunas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, siswaId, periode, isLunas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagihanSiswaData &&
          other.id == this.id &&
          other.siswaId == this.siswaId &&
          other.periode == this.periode &&
          other.isLunas == this.isLunas);
}

class TagihanSiswaCompanion extends UpdateCompanion<TagihanSiswaData> {
  final Value<int> id;
  final Value<int> siswaId;
  final Value<String> periode;
  final Value<int> isLunas;
  const TagihanSiswaCompanion({
    this.id = const Value.absent(),
    this.siswaId = const Value.absent(),
    this.periode = const Value.absent(),
    this.isLunas = const Value.absent(),
  });
  TagihanSiswaCompanion.insert({
    this.id = const Value.absent(),
    required int siswaId,
    required String periode,
    this.isLunas = const Value.absent(),
  })  : siswaId = Value(siswaId),
        periode = Value(periode);
  static Insertable<TagihanSiswaData> custom({
    Expression<int>? id,
    Expression<int>? siswaId,
    Expression<String>? periode,
    Expression<int>? isLunas,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siswaId != null) 'siswa_id': siswaId,
      if (periode != null) 'periode': periode,
      if (isLunas != null) 'is_lunas': isLunas,
    });
  }

  TagihanSiswaCompanion copyWith(
      {Value<int>? id,
      Value<int>? siswaId,
      Value<String>? periode,
      Value<int>? isLunas}) {
    return TagihanSiswaCompanion(
      id: id ?? this.id,
      siswaId: siswaId ?? this.siswaId,
      periode: periode ?? this.periode,
      isLunas: isLunas ?? this.isLunas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (siswaId.present) {
      map['siswa_id'] = Variable<int>(siswaId.value);
    }
    if (periode.present) {
      map['periode'] = Variable<String>(periode.value);
    }
    if (isLunas.present) {
      map['is_lunas'] = Variable<int>(isLunas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagihanSiswaCompanion(')
          ..write('id: $id, ')
          ..write('siswaId: $siswaId, ')
          ..write('periode: $periode, ')
          ..write('isLunas: $isLunas')
          ..write(')'))
        .toString();
  }
}

class $TagihanItemTable extends TagihanItem
    with TableInfo<$TagihanItemTable, TagihanItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagihanItemTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tagihanIdMeta =
      const VerificationMeta('tagihanId');
  @override
  late final GeneratedColumn<int> tagihanId = GeneratedColumn<int>(
      'tagihan_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tagihan_siswa (id) ON DELETE CASCADE'));
  static const VerificationMeta _kategoriBiayaIdMeta =
      const VerificationMeta('kategoriBiayaId');
  @override
  late final GeneratedColumn<int> kategoriBiayaId = GeneratedColumn<int>(
      'kategori_biaya_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES kategori_biaya (id) ON DELETE RESTRICT'));
  static const VerificationMeta _namaItemMeta =
      const VerificationMeta('namaItem');
  @override
  late final GeneratedColumn<String> namaItem = GeneratedColumn<String>(
      'nama_item', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nominalAwalMeta =
      const VerificationMeta('nominalAwal');
  @override
  late final GeneratedColumn<int> nominalAwal = GeneratedColumn<int>(
      'nominal_awal', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nominalDiskonMeta =
      const VerificationMeta('nominalDiskon');
  @override
  late final GeneratedColumn<int> nominalDiskon = GeneratedColumn<int>(
      'nominal_diskon', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nominalAkhirMeta =
      const VerificationMeta('nominalAkhir');
  @override
  late final GeneratedColumn<int> nominalAkhir = GeneratedColumn<int>(
      'nominal_akhir', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _terbayarMeta =
      const VerificationMeta('terbayar');
  @override
  late final GeneratedColumn<int> terbayar = GeneratedColumn<int>(
      'terbayar', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isLunasMeta =
      const VerificationMeta('isLunas');
  @override
  late final GeneratedColumn<int> isLunas = GeneratedColumn<int>(
      'is_lunas', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tagihanId,
        kategoriBiayaId,
        namaItem,
        nominalAwal,
        nominalDiskon,
        nominalAkhir,
        terbayar,
        isLunas
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tagihan_item';
  @override
  VerificationContext validateIntegrity(Insertable<TagihanItemData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tagihan_id')) {
      context.handle(_tagihanIdMeta,
          tagihanId.isAcceptableOrUnknown(data['tagihan_id']!, _tagihanIdMeta));
    } else if (isInserting) {
      context.missing(_tagihanIdMeta);
    }
    if (data.containsKey('kategori_biaya_id')) {
      context.handle(
          _kategoriBiayaIdMeta,
          kategoriBiayaId.isAcceptableOrUnknown(
              data['kategori_biaya_id']!, _kategoriBiayaIdMeta));
    } else if (isInserting) {
      context.missing(_kategoriBiayaIdMeta);
    }
    if (data.containsKey('nama_item')) {
      context.handle(_namaItemMeta,
          namaItem.isAcceptableOrUnknown(data['nama_item']!, _namaItemMeta));
    } else if (isInserting) {
      context.missing(_namaItemMeta);
    }
    if (data.containsKey('nominal_awal')) {
      context.handle(
          _nominalAwalMeta,
          nominalAwal.isAcceptableOrUnknown(
              data['nominal_awal']!, _nominalAwalMeta));
    } else if (isInserting) {
      context.missing(_nominalAwalMeta);
    }
    if (data.containsKey('nominal_diskon')) {
      context.handle(
          _nominalDiskonMeta,
          nominalDiskon.isAcceptableOrUnknown(
              data['nominal_diskon']!, _nominalDiskonMeta));
    }
    if (data.containsKey('nominal_akhir')) {
      context.handle(
          _nominalAkhirMeta,
          nominalAkhir.isAcceptableOrUnknown(
              data['nominal_akhir']!, _nominalAkhirMeta));
    } else if (isInserting) {
      context.missing(_nominalAkhirMeta);
    }
    if (data.containsKey('terbayar')) {
      context.handle(_terbayarMeta,
          terbayar.isAcceptableOrUnknown(data['terbayar']!, _terbayarMeta));
    }
    if (data.containsKey('is_lunas')) {
      context.handle(_isLunasMeta,
          isLunas.isAcceptableOrUnknown(data['is_lunas']!, _isLunasMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagihanItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagihanItemData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tagihanId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tagihan_id'])!,
      kategoriBiayaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kategori_biaya_id'])!,
      namaItem: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama_item'])!,
      nominalAwal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nominal_awal'])!,
      nominalDiskon: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nominal_diskon'])!,
      nominalAkhir: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nominal_akhir'])!,
      terbayar: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}terbayar'])!,
      isLunas: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_lunas'])!,
    );
  }

  @override
  $TagihanItemTable createAlias(String alias) {
    return $TagihanItemTable(attachedDatabase, alias);
  }
}

class TagihanItemData extends DataClass implements Insertable<TagihanItemData> {
  final int id;
  final int tagihanId;
  final int kategoriBiayaId;
  final String namaItem;
  final int nominalAwal;
  final int nominalDiskon;
  final int nominalAkhir;
  final int terbayar;
  final int isLunas;
  const TagihanItemData(
      {required this.id,
      required this.tagihanId,
      required this.kategoriBiayaId,
      required this.namaItem,
      required this.nominalAwal,
      required this.nominalDiskon,
      required this.nominalAkhir,
      required this.terbayar,
      required this.isLunas});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tagihan_id'] = Variable<int>(tagihanId);
    map['kategori_biaya_id'] = Variable<int>(kategoriBiayaId);
    map['nama_item'] = Variable<String>(namaItem);
    map['nominal_awal'] = Variable<int>(nominalAwal);
    map['nominal_diskon'] = Variable<int>(nominalDiskon);
    map['nominal_akhir'] = Variable<int>(nominalAkhir);
    map['terbayar'] = Variable<int>(terbayar);
    map['is_lunas'] = Variable<int>(isLunas);
    return map;
  }

  TagihanItemCompanion toCompanion(bool nullToAbsent) {
    return TagihanItemCompanion(
      id: Value(id),
      tagihanId: Value(tagihanId),
      kategoriBiayaId: Value(kategoriBiayaId),
      namaItem: Value(namaItem),
      nominalAwal: Value(nominalAwal),
      nominalDiskon: Value(nominalDiskon),
      nominalAkhir: Value(nominalAkhir),
      terbayar: Value(terbayar),
      isLunas: Value(isLunas),
    );
  }

  factory TagihanItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagihanItemData(
      id: serializer.fromJson<int>(json['id']),
      tagihanId: serializer.fromJson<int>(json['tagihanId']),
      kategoriBiayaId: serializer.fromJson<int>(json['kategoriBiayaId']),
      namaItem: serializer.fromJson<String>(json['namaItem']),
      nominalAwal: serializer.fromJson<int>(json['nominalAwal']),
      nominalDiskon: serializer.fromJson<int>(json['nominalDiskon']),
      nominalAkhir: serializer.fromJson<int>(json['nominalAkhir']),
      terbayar: serializer.fromJson<int>(json['terbayar']),
      isLunas: serializer.fromJson<int>(json['isLunas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tagihanId': serializer.toJson<int>(tagihanId),
      'kategoriBiayaId': serializer.toJson<int>(kategoriBiayaId),
      'namaItem': serializer.toJson<String>(namaItem),
      'nominalAwal': serializer.toJson<int>(nominalAwal),
      'nominalDiskon': serializer.toJson<int>(nominalDiskon),
      'nominalAkhir': serializer.toJson<int>(nominalAkhir),
      'terbayar': serializer.toJson<int>(terbayar),
      'isLunas': serializer.toJson<int>(isLunas),
    };
  }

  TagihanItemData copyWith(
          {int? id,
          int? tagihanId,
          int? kategoriBiayaId,
          String? namaItem,
          int? nominalAwal,
          int? nominalDiskon,
          int? nominalAkhir,
          int? terbayar,
          int? isLunas}) =>
      TagihanItemData(
        id: id ?? this.id,
        tagihanId: tagihanId ?? this.tagihanId,
        kategoriBiayaId: kategoriBiayaId ?? this.kategoriBiayaId,
        namaItem: namaItem ?? this.namaItem,
        nominalAwal: nominalAwal ?? this.nominalAwal,
        nominalDiskon: nominalDiskon ?? this.nominalDiskon,
        nominalAkhir: nominalAkhir ?? this.nominalAkhir,
        terbayar: terbayar ?? this.terbayar,
        isLunas: isLunas ?? this.isLunas,
      );
  TagihanItemData copyWithCompanion(TagihanItemCompanion data) {
    return TagihanItemData(
      id: data.id.present ? data.id.value : this.id,
      tagihanId: data.tagihanId.present ? data.tagihanId.value : this.tagihanId,
      kategoriBiayaId: data.kategoriBiayaId.present
          ? data.kategoriBiayaId.value
          : this.kategoriBiayaId,
      namaItem: data.namaItem.present ? data.namaItem.value : this.namaItem,
      nominalAwal:
          data.nominalAwal.present ? data.nominalAwal.value : this.nominalAwal,
      nominalDiskon: data.nominalDiskon.present
          ? data.nominalDiskon.value
          : this.nominalDiskon,
      nominalAkhir: data.nominalAkhir.present
          ? data.nominalAkhir.value
          : this.nominalAkhir,
      terbayar: data.terbayar.present ? data.terbayar.value : this.terbayar,
      isLunas: data.isLunas.present ? data.isLunas.value : this.isLunas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagihanItemData(')
          ..write('id: $id, ')
          ..write('tagihanId: $tagihanId, ')
          ..write('kategoriBiayaId: $kategoriBiayaId, ')
          ..write('namaItem: $namaItem, ')
          ..write('nominalAwal: $nominalAwal, ')
          ..write('nominalDiskon: $nominalDiskon, ')
          ..write('nominalAkhir: $nominalAkhir, ')
          ..write('terbayar: $terbayar, ')
          ..write('isLunas: $isLunas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tagihanId, kategoriBiayaId, namaItem,
      nominalAwal, nominalDiskon, nominalAkhir, terbayar, isLunas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagihanItemData &&
          other.id == this.id &&
          other.tagihanId == this.tagihanId &&
          other.kategoriBiayaId == this.kategoriBiayaId &&
          other.namaItem == this.namaItem &&
          other.nominalAwal == this.nominalAwal &&
          other.nominalDiskon == this.nominalDiskon &&
          other.nominalAkhir == this.nominalAkhir &&
          other.terbayar == this.terbayar &&
          other.isLunas == this.isLunas);
}

class TagihanItemCompanion extends UpdateCompanion<TagihanItemData> {
  final Value<int> id;
  final Value<int> tagihanId;
  final Value<int> kategoriBiayaId;
  final Value<String> namaItem;
  final Value<int> nominalAwal;
  final Value<int> nominalDiskon;
  final Value<int> nominalAkhir;
  final Value<int> terbayar;
  final Value<int> isLunas;
  const TagihanItemCompanion({
    this.id = const Value.absent(),
    this.tagihanId = const Value.absent(),
    this.kategoriBiayaId = const Value.absent(),
    this.namaItem = const Value.absent(),
    this.nominalAwal = const Value.absent(),
    this.nominalDiskon = const Value.absent(),
    this.nominalAkhir = const Value.absent(),
    this.terbayar = const Value.absent(),
    this.isLunas = const Value.absent(),
  });
  TagihanItemCompanion.insert({
    this.id = const Value.absent(),
    required int tagihanId,
    required int kategoriBiayaId,
    required String namaItem,
    required int nominalAwal,
    this.nominalDiskon = const Value.absent(),
    required int nominalAkhir,
    this.terbayar = const Value.absent(),
    this.isLunas = const Value.absent(),
  })  : tagihanId = Value(tagihanId),
        kategoriBiayaId = Value(kategoriBiayaId),
        namaItem = Value(namaItem),
        nominalAwal = Value(nominalAwal),
        nominalAkhir = Value(nominalAkhir);
  static Insertable<TagihanItemData> custom({
    Expression<int>? id,
    Expression<int>? tagihanId,
    Expression<int>? kategoriBiayaId,
    Expression<String>? namaItem,
    Expression<int>? nominalAwal,
    Expression<int>? nominalDiskon,
    Expression<int>? nominalAkhir,
    Expression<int>? terbayar,
    Expression<int>? isLunas,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tagihanId != null) 'tagihan_id': tagihanId,
      if (kategoriBiayaId != null) 'kategori_biaya_id': kategoriBiayaId,
      if (namaItem != null) 'nama_item': namaItem,
      if (nominalAwal != null) 'nominal_awal': nominalAwal,
      if (nominalDiskon != null) 'nominal_diskon': nominalDiskon,
      if (nominalAkhir != null) 'nominal_akhir': nominalAkhir,
      if (terbayar != null) 'terbayar': terbayar,
      if (isLunas != null) 'is_lunas': isLunas,
    });
  }

  TagihanItemCompanion copyWith(
      {Value<int>? id,
      Value<int>? tagihanId,
      Value<int>? kategoriBiayaId,
      Value<String>? namaItem,
      Value<int>? nominalAwal,
      Value<int>? nominalDiskon,
      Value<int>? nominalAkhir,
      Value<int>? terbayar,
      Value<int>? isLunas}) {
    return TagihanItemCompanion(
      id: id ?? this.id,
      tagihanId: tagihanId ?? this.tagihanId,
      kategoriBiayaId: kategoriBiayaId ?? this.kategoriBiayaId,
      namaItem: namaItem ?? this.namaItem,
      nominalAwal: nominalAwal ?? this.nominalAwal,
      nominalDiskon: nominalDiskon ?? this.nominalDiskon,
      nominalAkhir: nominalAkhir ?? this.nominalAkhir,
      terbayar: terbayar ?? this.terbayar,
      isLunas: isLunas ?? this.isLunas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tagihanId.present) {
      map['tagihan_id'] = Variable<int>(tagihanId.value);
    }
    if (kategoriBiayaId.present) {
      map['kategori_biaya_id'] = Variable<int>(kategoriBiayaId.value);
    }
    if (namaItem.present) {
      map['nama_item'] = Variable<String>(namaItem.value);
    }
    if (nominalAwal.present) {
      map['nominal_awal'] = Variable<int>(nominalAwal.value);
    }
    if (nominalDiskon.present) {
      map['nominal_diskon'] = Variable<int>(nominalDiskon.value);
    }
    if (nominalAkhir.present) {
      map['nominal_akhir'] = Variable<int>(nominalAkhir.value);
    }
    if (terbayar.present) {
      map['terbayar'] = Variable<int>(terbayar.value);
    }
    if (isLunas.present) {
      map['is_lunas'] = Variable<int>(isLunas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagihanItemCompanion(')
          ..write('id: $id, ')
          ..write('tagihanId: $tagihanId, ')
          ..write('kategoriBiayaId: $kategoriBiayaId, ')
          ..write('namaItem: $namaItem, ')
          ..write('nominalAwal: $nominalAwal, ')
          ..write('nominalDiskon: $nominalDiskon, ')
          ..write('nominalAkhir: $nominalAkhir, ')
          ..write('terbayar: $terbayar, ')
          ..write('isLunas: $isLunas')
          ..write(')'))
        .toString();
  }
}

class $PembayaranTransaksiTable extends PembayaranTransaksi
    with TableInfo<$PembayaranTransaksiTable, PembayaranTransaksiData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PembayaranTransaksiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomorKuitansiMeta =
      const VerificationMeta('nomorKuitansi');
  @override
  late final GeneratedColumn<String> nomorKuitansi = GeneratedColumn<String>(
      'nomor_kuitansi', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _siswaIdMeta =
      const VerificationMeta('siswaId');
  @override
  late final GeneratedColumn<int> siswaId = GeneratedColumn<int>(
      'siswa_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES siswa (id) ON DELETE RESTRICT'));
  static const VerificationMeta _tanggalBayarMeta =
      const VerificationMeta('tanggalBayar');
  @override
  late final GeneratedColumn<String> tanggalBayar = GeneratedColumn<String>(
      'tanggal_bayar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalBayarMeta =
      const VerificationMeta('totalBayar');
  @override
  late final GeneratedColumn<int> totalBayar = GeneratedColumn<int>(
      'total_bayar', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _metodeBayarMeta =
      const VerificationMeta('metodeBayar');
  @override
  late final GeneratedColumn<String> metodeBayar = GeneratedColumn<String>(
      'metode_bayar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('VALID'));
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nomorKuitansi,
        siswaId,
        tanggalBayar,
        totalBayar,
        metodeBayar,
        status,
        createdBy
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pembayaran_transaksi';
  @override
  VerificationContext validateIntegrity(
      Insertable<PembayaranTransaksiData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nomor_kuitansi')) {
      context.handle(
          _nomorKuitansiMeta,
          nomorKuitansi.isAcceptableOrUnknown(
              data['nomor_kuitansi']!, _nomorKuitansiMeta));
    } else if (isInserting) {
      context.missing(_nomorKuitansiMeta);
    }
    if (data.containsKey('siswa_id')) {
      context.handle(_siswaIdMeta,
          siswaId.isAcceptableOrUnknown(data['siswa_id']!, _siswaIdMeta));
    } else if (isInserting) {
      context.missing(_siswaIdMeta);
    }
    if (data.containsKey('tanggal_bayar')) {
      context.handle(
          _tanggalBayarMeta,
          tanggalBayar.isAcceptableOrUnknown(
              data['tanggal_bayar']!, _tanggalBayarMeta));
    } else if (isInserting) {
      context.missing(_tanggalBayarMeta);
    }
    if (data.containsKey('total_bayar')) {
      context.handle(
          _totalBayarMeta,
          totalBayar.isAcceptableOrUnknown(
              data['total_bayar']!, _totalBayarMeta));
    } else if (isInserting) {
      context.missing(_totalBayarMeta);
    }
    if (data.containsKey('metode_bayar')) {
      context.handle(
          _metodeBayarMeta,
          metodeBayar.isAcceptableOrUnknown(
              data['metode_bayar']!, _metodeBayarMeta));
    } else if (isInserting) {
      context.missing(_metodeBayarMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PembayaranTransaksiData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PembayaranTransaksiData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nomorKuitansi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nomor_kuitansi'])!,
      siswaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}siswa_id'])!,
      tanggalBayar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tanggal_bayar'])!,
      totalBayar: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_bayar'])!,
      metodeBayar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metode_bayar'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
    );
  }

  @override
  $PembayaranTransaksiTable createAlias(String alias) {
    return $PembayaranTransaksiTable(attachedDatabase, alias);
  }
}

class PembayaranTransaksiData extends DataClass
    implements Insertable<PembayaranTransaksiData> {
  final int id;
  final String nomorKuitansi;
  final int siswaId;
  final String tanggalBayar;
  final int totalBayar;
  final String metodeBayar;
  final String status;
  final String createdBy;
  const PembayaranTransaksiData(
      {required this.id,
      required this.nomorKuitansi,
      required this.siswaId,
      required this.tanggalBayar,
      required this.totalBayar,
      required this.metodeBayar,
      required this.status,
      required this.createdBy});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nomor_kuitansi'] = Variable<String>(nomorKuitansi);
    map['siswa_id'] = Variable<int>(siswaId);
    map['tanggal_bayar'] = Variable<String>(tanggalBayar);
    map['total_bayar'] = Variable<int>(totalBayar);
    map['metode_bayar'] = Variable<String>(metodeBayar);
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<String>(createdBy);
    return map;
  }

  PembayaranTransaksiCompanion toCompanion(bool nullToAbsent) {
    return PembayaranTransaksiCompanion(
      id: Value(id),
      nomorKuitansi: Value(nomorKuitansi),
      siswaId: Value(siswaId),
      tanggalBayar: Value(tanggalBayar),
      totalBayar: Value(totalBayar),
      metodeBayar: Value(metodeBayar),
      status: Value(status),
      createdBy: Value(createdBy),
    );
  }

  factory PembayaranTransaksiData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PembayaranTransaksiData(
      id: serializer.fromJson<int>(json['id']),
      nomorKuitansi: serializer.fromJson<String>(json['nomorKuitansi']),
      siswaId: serializer.fromJson<int>(json['siswaId']),
      tanggalBayar: serializer.fromJson<String>(json['tanggalBayar']),
      totalBayar: serializer.fromJson<int>(json['totalBayar']),
      metodeBayar: serializer.fromJson<String>(json['metodeBayar']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nomorKuitansi': serializer.toJson<String>(nomorKuitansi),
      'siswaId': serializer.toJson<int>(siswaId),
      'tanggalBayar': serializer.toJson<String>(tanggalBayar),
      'totalBayar': serializer.toJson<int>(totalBayar),
      'metodeBayar': serializer.toJson<String>(metodeBayar),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<String>(createdBy),
    };
  }

  PembayaranTransaksiData copyWith(
          {int? id,
          String? nomorKuitansi,
          int? siswaId,
          String? tanggalBayar,
          int? totalBayar,
          String? metodeBayar,
          String? status,
          String? createdBy}) =>
      PembayaranTransaksiData(
        id: id ?? this.id,
        nomorKuitansi: nomorKuitansi ?? this.nomorKuitansi,
        siswaId: siswaId ?? this.siswaId,
        tanggalBayar: tanggalBayar ?? this.tanggalBayar,
        totalBayar: totalBayar ?? this.totalBayar,
        metodeBayar: metodeBayar ?? this.metodeBayar,
        status: status ?? this.status,
        createdBy: createdBy ?? this.createdBy,
      );
  PembayaranTransaksiData copyWithCompanion(PembayaranTransaksiCompanion data) {
    return PembayaranTransaksiData(
      id: data.id.present ? data.id.value : this.id,
      nomorKuitansi: data.nomorKuitansi.present
          ? data.nomorKuitansi.value
          : this.nomorKuitansi,
      siswaId: data.siswaId.present ? data.siswaId.value : this.siswaId,
      tanggalBayar: data.tanggalBayar.present
          ? data.tanggalBayar.value
          : this.tanggalBayar,
      totalBayar:
          data.totalBayar.present ? data.totalBayar.value : this.totalBayar,
      metodeBayar:
          data.metodeBayar.present ? data.metodeBayar.value : this.metodeBayar,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PembayaranTransaksiData(')
          ..write('id: $id, ')
          ..write('nomorKuitansi: $nomorKuitansi, ')
          ..write('siswaId: $siswaId, ')
          ..write('tanggalBayar: $tanggalBayar, ')
          ..write('totalBayar: $totalBayar, ')
          ..write('metodeBayar: $metodeBayar, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nomorKuitansi, siswaId, tanggalBayar,
      totalBayar, metodeBayar, status, createdBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PembayaranTransaksiData &&
          other.id == this.id &&
          other.nomorKuitansi == this.nomorKuitansi &&
          other.siswaId == this.siswaId &&
          other.tanggalBayar == this.tanggalBayar &&
          other.totalBayar == this.totalBayar &&
          other.metodeBayar == this.metodeBayar &&
          other.status == this.status &&
          other.createdBy == this.createdBy);
}

class PembayaranTransaksiCompanion
    extends UpdateCompanion<PembayaranTransaksiData> {
  final Value<int> id;
  final Value<String> nomorKuitansi;
  final Value<int> siswaId;
  final Value<String> tanggalBayar;
  final Value<int> totalBayar;
  final Value<String> metodeBayar;
  final Value<String> status;
  final Value<String> createdBy;
  const PembayaranTransaksiCompanion({
    this.id = const Value.absent(),
    this.nomorKuitansi = const Value.absent(),
    this.siswaId = const Value.absent(),
    this.tanggalBayar = const Value.absent(),
    this.totalBayar = const Value.absent(),
    this.metodeBayar = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
  });
  PembayaranTransaksiCompanion.insert({
    this.id = const Value.absent(),
    required String nomorKuitansi,
    required int siswaId,
    required String tanggalBayar,
    required int totalBayar,
    required String metodeBayar,
    this.status = const Value.absent(),
    required String createdBy,
  })  : nomorKuitansi = Value(nomorKuitansi),
        siswaId = Value(siswaId),
        tanggalBayar = Value(tanggalBayar),
        totalBayar = Value(totalBayar),
        metodeBayar = Value(metodeBayar),
        createdBy = Value(createdBy);
  static Insertable<PembayaranTransaksiData> custom({
    Expression<int>? id,
    Expression<String>? nomorKuitansi,
    Expression<int>? siswaId,
    Expression<String>? tanggalBayar,
    Expression<int>? totalBayar,
    Expression<String>? metodeBayar,
    Expression<String>? status,
    Expression<String>? createdBy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nomorKuitansi != null) 'nomor_kuitansi': nomorKuitansi,
      if (siswaId != null) 'siswa_id': siswaId,
      if (tanggalBayar != null) 'tanggal_bayar': tanggalBayar,
      if (totalBayar != null) 'total_bayar': totalBayar,
      if (metodeBayar != null) 'metode_bayar': metodeBayar,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
    });
  }

  PembayaranTransaksiCompanion copyWith(
      {Value<int>? id,
      Value<String>? nomorKuitansi,
      Value<int>? siswaId,
      Value<String>? tanggalBayar,
      Value<int>? totalBayar,
      Value<String>? metodeBayar,
      Value<String>? status,
      Value<String>? createdBy}) {
    return PembayaranTransaksiCompanion(
      id: id ?? this.id,
      nomorKuitansi: nomorKuitansi ?? this.nomorKuitansi,
      siswaId: siswaId ?? this.siswaId,
      tanggalBayar: tanggalBayar ?? this.tanggalBayar,
      totalBayar: totalBayar ?? this.totalBayar,
      metodeBayar: metodeBayar ?? this.metodeBayar,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nomorKuitansi.present) {
      map['nomor_kuitansi'] = Variable<String>(nomorKuitansi.value);
    }
    if (siswaId.present) {
      map['siswa_id'] = Variable<int>(siswaId.value);
    }
    if (tanggalBayar.present) {
      map['tanggal_bayar'] = Variable<String>(tanggalBayar.value);
    }
    if (totalBayar.present) {
      map['total_bayar'] = Variable<int>(totalBayar.value);
    }
    if (metodeBayar.present) {
      map['metode_bayar'] = Variable<String>(metodeBayar.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PembayaranTransaksiCompanion(')
          ..write('id: $id, ')
          ..write('nomorKuitansi: $nomorKuitansi, ')
          ..write('siswaId: $siswaId, ')
          ..write('tanggalBayar: $tanggalBayar, ')
          ..write('totalBayar: $totalBayar, ')
          ..write('metodeBayar: $metodeBayar, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }
}

class $AlokasiPembayaranTable extends AlokasiPembayaran
    with TableInfo<$AlokasiPembayaranTable, AlokasiPembayaranData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlokasiPembayaranTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transaksiIdMeta =
      const VerificationMeta('transaksiId');
  @override
  late final GeneratedColumn<int> transaksiId = GeneratedColumn<int>(
      'transaksi_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES pembayaran_transaksi (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagihanItemIdMeta =
      const VerificationMeta('tagihanItemId');
  @override
  late final GeneratedColumn<int> tagihanItemId = GeneratedColumn<int>(
      'tagihan_item_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tagihan_item (id) ON DELETE RESTRICT'));
  static const VerificationMeta _nominalDialokasikanMeta =
      const VerificationMeta('nominalDialokasikan');
  @override
  late final GeneratedColumn<int> nominalDialokasikan = GeneratedColumn<int>(
      'nominal_dialokasikan', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, transaksiId, tagihanItemId, nominalDialokasikan];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alokasi_pembayaran';
  @override
  VerificationContext validateIntegrity(
      Insertable<AlokasiPembayaranData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaksi_id')) {
      context.handle(
          _transaksiIdMeta,
          transaksiId.isAcceptableOrUnknown(
              data['transaksi_id']!, _transaksiIdMeta));
    } else if (isInserting) {
      context.missing(_transaksiIdMeta);
    }
    if (data.containsKey('tagihan_item_id')) {
      context.handle(
          _tagihanItemIdMeta,
          tagihanItemId.isAcceptableOrUnknown(
              data['tagihan_item_id']!, _tagihanItemIdMeta));
    } else if (isInserting) {
      context.missing(_tagihanItemIdMeta);
    }
    if (data.containsKey('nominal_dialokasikan')) {
      context.handle(
          _nominalDialokasikanMeta,
          nominalDialokasikan.isAcceptableOrUnknown(
              data['nominal_dialokasikan']!, _nominalDialokasikanMeta));
    } else if (isInserting) {
      context.missing(_nominalDialokasikanMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlokasiPembayaranData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlokasiPembayaranData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transaksiId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaksi_id'])!,
      tagihanItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tagihan_item_id'])!,
      nominalDialokasikan: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}nominal_dialokasikan'])!,
    );
  }

  @override
  $AlokasiPembayaranTable createAlias(String alias) {
    return $AlokasiPembayaranTable(attachedDatabase, alias);
  }
}

class AlokasiPembayaranData extends DataClass
    implements Insertable<AlokasiPembayaranData> {
  final int id;
  final int transaksiId;
  final int tagihanItemId;
  final int nominalDialokasikan;
  const AlokasiPembayaranData(
      {required this.id,
      required this.transaksiId,
      required this.tagihanItemId,
      required this.nominalDialokasikan});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaksi_id'] = Variable<int>(transaksiId);
    map['tagihan_item_id'] = Variable<int>(tagihanItemId);
    map['nominal_dialokasikan'] = Variable<int>(nominalDialokasikan);
    return map;
  }

  AlokasiPembayaranCompanion toCompanion(bool nullToAbsent) {
    return AlokasiPembayaranCompanion(
      id: Value(id),
      transaksiId: Value(transaksiId),
      tagihanItemId: Value(tagihanItemId),
      nominalDialokasikan: Value(nominalDialokasikan),
    );
  }

  factory AlokasiPembayaranData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlokasiPembayaranData(
      id: serializer.fromJson<int>(json['id']),
      transaksiId: serializer.fromJson<int>(json['transaksiId']),
      tagihanItemId: serializer.fromJson<int>(json['tagihanItemId']),
      nominalDialokasikan:
          serializer.fromJson<int>(json['nominalDialokasikan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transaksiId': serializer.toJson<int>(transaksiId),
      'tagihanItemId': serializer.toJson<int>(tagihanItemId),
      'nominalDialokasikan': serializer.toJson<int>(nominalDialokasikan),
    };
  }

  AlokasiPembayaranData copyWith(
          {int? id,
          int? transaksiId,
          int? tagihanItemId,
          int? nominalDialokasikan}) =>
      AlokasiPembayaranData(
        id: id ?? this.id,
        transaksiId: transaksiId ?? this.transaksiId,
        tagihanItemId: tagihanItemId ?? this.tagihanItemId,
        nominalDialokasikan: nominalDialokasikan ?? this.nominalDialokasikan,
      );
  AlokasiPembayaranData copyWithCompanion(AlokasiPembayaranCompanion data) {
    return AlokasiPembayaranData(
      id: data.id.present ? data.id.value : this.id,
      transaksiId:
          data.transaksiId.present ? data.transaksiId.value : this.transaksiId,
      tagihanItemId: data.tagihanItemId.present
          ? data.tagihanItemId.value
          : this.tagihanItemId,
      nominalDialokasikan: data.nominalDialokasikan.present
          ? data.nominalDialokasikan.value
          : this.nominalDialokasikan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlokasiPembayaranData(')
          ..write('id: $id, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('tagihanItemId: $tagihanItemId, ')
          ..write('nominalDialokasikan: $nominalDialokasikan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, transaksiId, tagihanItemId, nominalDialokasikan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlokasiPembayaranData &&
          other.id == this.id &&
          other.transaksiId == this.transaksiId &&
          other.tagihanItemId == this.tagihanItemId &&
          other.nominalDialokasikan == this.nominalDialokasikan);
}

class AlokasiPembayaranCompanion
    extends UpdateCompanion<AlokasiPembayaranData> {
  final Value<int> id;
  final Value<int> transaksiId;
  final Value<int> tagihanItemId;
  final Value<int> nominalDialokasikan;
  const AlokasiPembayaranCompanion({
    this.id = const Value.absent(),
    this.transaksiId = const Value.absent(),
    this.tagihanItemId = const Value.absent(),
    this.nominalDialokasikan = const Value.absent(),
  });
  AlokasiPembayaranCompanion.insert({
    this.id = const Value.absent(),
    required int transaksiId,
    required int tagihanItemId,
    required int nominalDialokasikan,
  })  : transaksiId = Value(transaksiId),
        tagihanItemId = Value(tagihanItemId),
        nominalDialokasikan = Value(nominalDialokasikan);
  static Insertable<AlokasiPembayaranData> custom({
    Expression<int>? id,
    Expression<int>? transaksiId,
    Expression<int>? tagihanItemId,
    Expression<int>? nominalDialokasikan,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transaksiId != null) 'transaksi_id': transaksiId,
      if (tagihanItemId != null) 'tagihan_item_id': tagihanItemId,
      if (nominalDialokasikan != null)
        'nominal_dialokasikan': nominalDialokasikan,
    });
  }

  AlokasiPembayaranCompanion copyWith(
      {Value<int>? id,
      Value<int>? transaksiId,
      Value<int>? tagihanItemId,
      Value<int>? nominalDialokasikan}) {
    return AlokasiPembayaranCompanion(
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      tagihanItemId: tagihanItemId ?? this.tagihanItemId,
      nominalDialokasikan: nominalDialokasikan ?? this.nominalDialokasikan,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transaksiId.present) {
      map['transaksi_id'] = Variable<int>(transaksiId.value);
    }
    if (tagihanItemId.present) {
      map['tagihan_item_id'] = Variable<int>(tagihanItemId.value);
    }
    if (nominalDialokasikan.present) {
      map['nominal_dialokasikan'] = Variable<int>(nominalDialokasikan.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlokasiPembayaranCompanion(')
          ..write('id: $id, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('tagihanItemId: $tagihanItemId, ')
          ..write('nominalDialokasikan: $nominalDialokasikan')
          ..write(')'))
        .toString();
  }
}

class $AuditLogTable extends AuditLog
    with TableInfo<$AuditLogTable, AuditLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userRoleMeta =
      const VerificationMeta('userRole');
  @override
  late final GeneratedColumn<String> userRole = GeneratedColumn<String>(
      'user_role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityAffectedMeta =
      const VerificationMeta('entityAffected');
  @override
  late final GeneratedColumn<String> entityAffected = GeneratedColumn<String>(
      'entity_affected', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _timestampIsoMeta =
      const VerificationMeta('timestampIso');
  @override
  late final GeneratedColumn<String> timestampIso = GeneratedColumn<String>(
      'timestamp_iso', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userRole,
        actionType,
        entityAffected,
        entityId,
        timestampIso,
        details
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_role')) {
      context.handle(_userRoleMeta,
          userRole.isAcceptableOrUnknown(data['user_role']!, _userRoleMeta));
    } else if (isInserting) {
      context.missing(_userRoleMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('entity_affected')) {
      context.handle(
          _entityAffectedMeta,
          entityAffected.isAcceptableOrUnknown(
              data['entity_affected']!, _entityAffectedMeta));
    } else if (isInserting) {
      context.missing(_entityAffectedMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('timestamp_iso')) {
      context.handle(
          _timestampIsoMeta,
          timestampIso.isAcceptableOrUnknown(
              data['timestamp_iso']!, _timestampIsoMeta));
    } else if (isInserting) {
      context.missing(_timestampIsoMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userRole: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_role'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      entityAffected: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}entity_affected'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}entity_id']),
      timestampIso: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp_iso'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details']),
    );
  }

  @override
  $AuditLogTable createAlias(String alias) {
    return $AuditLogTable(attachedDatabase, alias);
  }
}

class AuditLogData extends DataClass implements Insertable<AuditLogData> {
  final int id;
  final String userRole;
  final String actionType;
  final String entityAffected;
  final int? entityId;
  final String timestampIso;
  final String? details;
  const AuditLogData(
      {required this.id,
      required this.userRole,
      required this.actionType,
      required this.entityAffected,
      this.entityId,
      required this.timestampIso,
      this.details});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_role'] = Variable<String>(userRole);
    map['action_type'] = Variable<String>(actionType);
    map['entity_affected'] = Variable<String>(entityAffected);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    map['timestamp_iso'] = Variable<String>(timestampIso);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      userRole: Value(userRole),
      actionType: Value(actionType),
      entityAffected: Value(entityAffected),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      timestampIso: Value(timestampIso),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
    );
  }

  factory AuditLogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogData(
      id: serializer.fromJson<int>(json['id']),
      userRole: serializer.fromJson<String>(json['userRole']),
      actionType: serializer.fromJson<String>(json['actionType']),
      entityAffected: serializer.fromJson<String>(json['entityAffected']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      timestampIso: serializer.fromJson<String>(json['timestampIso']),
      details: serializer.fromJson<String?>(json['details']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userRole': serializer.toJson<String>(userRole),
      'actionType': serializer.toJson<String>(actionType),
      'entityAffected': serializer.toJson<String>(entityAffected),
      'entityId': serializer.toJson<int?>(entityId),
      'timestampIso': serializer.toJson<String>(timestampIso),
      'details': serializer.toJson<String?>(details),
    };
  }

  AuditLogData copyWith(
          {int? id,
          String? userRole,
          String? actionType,
          String? entityAffected,
          Value<int?> entityId = const Value.absent(),
          String? timestampIso,
          Value<String?> details = const Value.absent()}) =>
      AuditLogData(
        id: id ?? this.id,
        userRole: userRole ?? this.userRole,
        actionType: actionType ?? this.actionType,
        entityAffected: entityAffected ?? this.entityAffected,
        entityId: entityId.present ? entityId.value : this.entityId,
        timestampIso: timestampIso ?? this.timestampIso,
        details: details.present ? details.value : this.details,
      );
  AuditLogData copyWithCompanion(AuditLogCompanion data) {
    return AuditLogData(
      id: data.id.present ? data.id.value : this.id,
      userRole: data.userRole.present ? data.userRole.value : this.userRole,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      entityAffected: data.entityAffected.present
          ? data.entityAffected.value
          : this.entityAffected,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      timestampIso: data.timestampIso.present
          ? data.timestampIso.value
          : this.timestampIso,
      details: data.details.present ? data.details.value : this.details,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogData(')
          ..write('id: $id, ')
          ..write('userRole: $userRole, ')
          ..write('actionType: $actionType, ')
          ..write('entityAffected: $entityAffected, ')
          ..write('entityId: $entityId, ')
          ..write('timestampIso: $timestampIso, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userRole, actionType, entityAffected,
      entityId, timestampIso, details);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogData &&
          other.id == this.id &&
          other.userRole == this.userRole &&
          other.actionType == this.actionType &&
          other.entityAffected == this.entityAffected &&
          other.entityId == this.entityId &&
          other.timestampIso == this.timestampIso &&
          other.details == this.details);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogData> {
  final Value<int> id;
  final Value<String> userRole;
  final Value<String> actionType;
  final Value<String> entityAffected;
  final Value<int?> entityId;
  final Value<String> timestampIso;
  final Value<String?> details;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.userRole = const Value.absent(),
    this.actionType = const Value.absent(),
    this.entityAffected = const Value.absent(),
    this.entityId = const Value.absent(),
    this.timestampIso = const Value.absent(),
    this.details = const Value.absent(),
  });
  AuditLogCompanion.insert({
    this.id = const Value.absent(),
    required String userRole,
    required String actionType,
    required String entityAffected,
    this.entityId = const Value.absent(),
    required String timestampIso,
    this.details = const Value.absent(),
  })  : userRole = Value(userRole),
        actionType = Value(actionType),
        entityAffected = Value(entityAffected),
        timestampIso = Value(timestampIso);
  static Insertable<AuditLogData> custom({
    Expression<int>? id,
    Expression<String>? userRole,
    Expression<String>? actionType,
    Expression<String>? entityAffected,
    Expression<int>? entityId,
    Expression<String>? timestampIso,
    Expression<String>? details,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userRole != null) 'user_role': userRole,
      if (actionType != null) 'action_type': actionType,
      if (entityAffected != null) 'entity_affected': entityAffected,
      if (entityId != null) 'entity_id': entityId,
      if (timestampIso != null) 'timestamp_iso': timestampIso,
      if (details != null) 'details': details,
    });
  }

  AuditLogCompanion copyWith(
      {Value<int>? id,
      Value<String>? userRole,
      Value<String>? actionType,
      Value<String>? entityAffected,
      Value<int?>? entityId,
      Value<String>? timestampIso,
      Value<String?>? details}) {
    return AuditLogCompanion(
      id: id ?? this.id,
      userRole: userRole ?? this.userRole,
      actionType: actionType ?? this.actionType,
      entityAffected: entityAffected ?? this.entityAffected,
      entityId: entityId ?? this.entityId,
      timestampIso: timestampIso ?? this.timestampIso,
      details: details ?? this.details,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userRole.present) {
      map['user_role'] = Variable<String>(userRole.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (entityAffected.present) {
      map['entity_affected'] = Variable<String>(entityAffected.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (timestampIso.present) {
      map['timestamp_iso'] = Variable<String>(timestampIso.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('userRole: $userRole, ')
          ..write('actionType: $actionType, ')
          ..write('entityAffected: $entityAffected, ')
          ..write('entityId: $entityId, ')
          ..write('timestampIso: $timestampIso, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SekolahTable sekolah = $SekolahTable(this);
  late final $TahunAjaranTable tahunAjaran = $TahunAjaranTable(this);
  late final $KelasTable kelas = $KelasTable(this);
  late final $KategoriBiayaTable kategoriBiaya = $KategoriBiayaTable(this);
  late final $SiswaTable siswa = $SiswaTable(this);
  late final $TarifMasterTable tarifMaster = $TarifMasterTable(this);
  late final $SkemaPembayaranSiswaTable skemaPembayaranSiswa =
      $SkemaPembayaranSiswaTable(this);
  late final $TagihanSiswaTable tagihanSiswa = $TagihanSiswaTable(this);
  late final $TagihanItemTable tagihanItem = $TagihanItemTable(this);
  late final $PembayaranTransaksiTable pembayaranTransaksi =
      $PembayaranTransaksiTable(this);
  late final $AlokasiPembayaranTable alokasiPembayaran =
      $AlokasiPembayaranTable(this);
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final SiswaDao siswaDao = SiswaDao(this as AppDatabase);
  late final TagihanDao tagihanDao = TagihanDao(this as AppDatabase);
  late final PembayaranDao pembayaranDao = PembayaranDao(this as AppDatabase);
  late final TarifDao tarifDao = TarifDao(this as AppDatabase);
  late final AuditDao auditDao = AuditDao(this as AppDatabase);
  late final SekolahDao sekolahDao = SekolahDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        sekolah,
        tahunAjaran,
        kelas,
        kategoriBiaya,
        siswa,
        tarifMaster,
        skemaPembayaranSiswa,
        tagihanSiswa,
        tagihanItem,
        pembayaranTransaksi,
        alokasiPembayaran,
        auditLog
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('sekolah',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('kelas', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('siswa',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('skema_pembayaran_siswa', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tagihan_siswa',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tagihan_item', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('pembayaran_transaksi',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('alokasi_pembayaran', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SekolahTableCreateCompanionBuilder = SekolahCompanion Function({
  Value<int> id,
  required String namaSekolah,
  required int kodeSekolah,
  required String jenjang,
});
typedef $$SekolahTableUpdateCompanionBuilder = SekolahCompanion Function({
  Value<int> id,
  Value<String> namaSekolah,
  Value<int> kodeSekolah,
  Value<String> jenjang,
});

final class $$SekolahTableReferences
    extends BaseReferences<_$AppDatabase, $SekolahTable, SekolahData> {
  $$SekolahTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$KelasTable, List<KelasData>> _kelasRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.kelas,
          aliasName: $_aliasNameGenerator(db.sekolah.id, db.kelas.sekolahId));

  $$KelasTableProcessedTableManager get kelasRefs {
    final manager = $$KelasTableTableManager($_db, $_db.kelas)
        .filter((f) => f.sekolahId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_kelasRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SiswaTable, List<SiswaData>> _siswaRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.siswa,
          aliasName: $_aliasNameGenerator(db.sekolah.id, db.siswa.sekolahId));

  $$SiswaTableProcessedTableManager get siswaRefs {
    final manager = $$SiswaTableTableManager($_db, $_db.siswa)
        .filter((f) => f.sekolahId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_siswaRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SekolahTableFilterComposer
    extends Composer<_$AppDatabase, $SekolahTable> {
  $$SekolahTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get namaSekolah => $composableBuilder(
      column: $table.namaSekolah, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kodeSekolah => $composableBuilder(
      column: $table.kodeSekolah, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jenjang => $composableBuilder(
      column: $table.jenjang, builder: (column) => ColumnFilters(column));

  Expression<bool> kelasRefs(
      Expression<bool> Function($$KelasTableFilterComposer f) f) {
    final $$KelasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.kelas,
        getReferencedColumn: (t) => t.sekolahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KelasTableFilterComposer(
              $db: $db,
              $table: $db.kelas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> siswaRefs(
      Expression<bool> Function($$SiswaTableFilterComposer f) f) {
    final $$SiswaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.sekolahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableFilterComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SekolahTableOrderingComposer
    extends Composer<_$AppDatabase, $SekolahTable> {
  $$SekolahTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get namaSekolah => $composableBuilder(
      column: $table.namaSekolah, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kodeSekolah => $composableBuilder(
      column: $table.kodeSekolah, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jenjang => $composableBuilder(
      column: $table.jenjang, builder: (column) => ColumnOrderings(column));
}

class $$SekolahTableAnnotationComposer
    extends Composer<_$AppDatabase, $SekolahTable> {
  $$SekolahTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get namaSekolah => $composableBuilder(
      column: $table.namaSekolah, builder: (column) => column);

  GeneratedColumn<int> get kodeSekolah => $composableBuilder(
      column: $table.kodeSekolah, builder: (column) => column);

  GeneratedColumn<String> get jenjang =>
      $composableBuilder(column: $table.jenjang, builder: (column) => column);

  Expression<T> kelasRefs<T extends Object>(
      Expression<T> Function($$KelasTableAnnotationComposer a) f) {
    final $$KelasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.kelas,
        getReferencedColumn: (t) => t.sekolahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KelasTableAnnotationComposer(
              $db: $db,
              $table: $db.kelas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> siswaRefs<T extends Object>(
      Expression<T> Function($$SiswaTableAnnotationComposer a) f) {
    final $$SiswaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.sekolahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableAnnotationComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SekolahTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SekolahTable,
    SekolahData,
    $$SekolahTableFilterComposer,
    $$SekolahTableOrderingComposer,
    $$SekolahTableAnnotationComposer,
    $$SekolahTableCreateCompanionBuilder,
    $$SekolahTableUpdateCompanionBuilder,
    (SekolahData, $$SekolahTableReferences),
    SekolahData,
    PrefetchHooks Function({bool kelasRefs, bool siswaRefs})> {
  $$SekolahTableTableManager(_$AppDatabase db, $SekolahTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SekolahTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SekolahTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SekolahTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> namaSekolah = const Value.absent(),
            Value<int> kodeSekolah = const Value.absent(),
            Value<String> jenjang = const Value.absent(),
          }) =>
              SekolahCompanion(
            id: id,
            namaSekolah: namaSekolah,
            kodeSekolah: kodeSekolah,
            jenjang: jenjang,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String namaSekolah,
            required int kodeSekolah,
            required String jenjang,
          }) =>
              SekolahCompanion.insert(
            id: id,
            namaSekolah: namaSekolah,
            kodeSekolah: kodeSekolah,
            jenjang: jenjang,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SekolahTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({kelasRefs = false, siswaRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (kelasRefs) db.kelas,
                if (siswaRefs) db.siswa
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (kelasRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SekolahTableReferences._kelasRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SekolahTableReferences(db, table, p0).kelasRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sekolahId == item.id),
                        typedResults: items),
                  if (siswaRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SekolahTableReferences._siswaRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SekolahTableReferences(db, table, p0).siswaRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sekolahId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SekolahTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SekolahTable,
    SekolahData,
    $$SekolahTableFilterComposer,
    $$SekolahTableOrderingComposer,
    $$SekolahTableAnnotationComposer,
    $$SekolahTableCreateCompanionBuilder,
    $$SekolahTableUpdateCompanionBuilder,
    (SekolahData, $$SekolahTableReferences),
    SekolahData,
    PrefetchHooks Function({bool kelasRefs, bool siswaRefs})>;
typedef $$TahunAjaranTableCreateCompanionBuilder = TahunAjaranCompanion
    Function({
  Value<int> id,
  required String namaTa,
  Value<int> isAktif,
});
typedef $$TahunAjaranTableUpdateCompanionBuilder = TahunAjaranCompanion
    Function({
  Value<int> id,
  Value<String> namaTa,
  Value<int> isAktif,
});

class $$TahunAjaranTableFilterComposer
    extends Composer<_$AppDatabase, $TahunAjaranTable> {
  $$TahunAjaranTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get namaTa => $composableBuilder(
      column: $table.namaTa, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isAktif => $composableBuilder(
      column: $table.isAktif, builder: (column) => ColumnFilters(column));
}

class $$TahunAjaranTableOrderingComposer
    extends Composer<_$AppDatabase, $TahunAjaranTable> {
  $$TahunAjaranTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get namaTa => $composableBuilder(
      column: $table.namaTa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isAktif => $composableBuilder(
      column: $table.isAktif, builder: (column) => ColumnOrderings(column));
}

class $$TahunAjaranTableAnnotationComposer
    extends Composer<_$AppDatabase, $TahunAjaranTable> {
  $$TahunAjaranTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get namaTa =>
      $composableBuilder(column: $table.namaTa, builder: (column) => column);

  GeneratedColumn<int> get isAktif =>
      $composableBuilder(column: $table.isAktif, builder: (column) => column);
}

class $$TahunAjaranTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TahunAjaranTable,
    TahunAjaranData,
    $$TahunAjaranTableFilterComposer,
    $$TahunAjaranTableOrderingComposer,
    $$TahunAjaranTableAnnotationComposer,
    $$TahunAjaranTableCreateCompanionBuilder,
    $$TahunAjaranTableUpdateCompanionBuilder,
    (
      TahunAjaranData,
      BaseReferences<_$AppDatabase, $TahunAjaranTable, TahunAjaranData>
    ),
    TahunAjaranData,
    PrefetchHooks Function()> {
  $$TahunAjaranTableTableManager(_$AppDatabase db, $TahunAjaranTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TahunAjaranTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TahunAjaranTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TahunAjaranTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> namaTa = const Value.absent(),
            Value<int> isAktif = const Value.absent(),
          }) =>
              TahunAjaranCompanion(
            id: id,
            namaTa: namaTa,
            isAktif: isAktif,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String namaTa,
            Value<int> isAktif = const Value.absent(),
          }) =>
              TahunAjaranCompanion.insert(
            id: id,
            namaTa: namaTa,
            isAktif: isAktif,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TahunAjaranTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TahunAjaranTable,
    TahunAjaranData,
    $$TahunAjaranTableFilterComposer,
    $$TahunAjaranTableOrderingComposer,
    $$TahunAjaranTableAnnotationComposer,
    $$TahunAjaranTableCreateCompanionBuilder,
    $$TahunAjaranTableUpdateCompanionBuilder,
    (
      TahunAjaranData,
      BaseReferences<_$AppDatabase, $TahunAjaranTable, TahunAjaranData>
    ),
    TahunAjaranData,
    PrefetchHooks Function()>;
typedef $$KelasTableCreateCompanionBuilder = KelasCompanion Function({
  Value<int> id,
  required int sekolahId,
  required int tingkat,
  required String namaKelas,
});
typedef $$KelasTableUpdateCompanionBuilder = KelasCompanion Function({
  Value<int> id,
  Value<int> sekolahId,
  Value<int> tingkat,
  Value<String> namaKelas,
});

final class $$KelasTableReferences
    extends BaseReferences<_$AppDatabase, $KelasTable, KelasData> {
  $$KelasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SekolahTable _sekolahIdTable(_$AppDatabase db) => db.sekolah
      .createAlias($_aliasNameGenerator(db.kelas.sekolahId, db.sekolah.id));

  $$SekolahTableProcessedTableManager? get sekolahId {
    if ($_item.sekolahId == null) return null;
    final manager = $$SekolahTableTableManager($_db, $_db.sekolah)
        .filter((f) => f.id($_item.sekolahId!));
    final item = $_typedResult.readTableOrNull(_sekolahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SiswaTable, List<SiswaData>> _siswaRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.siswa,
          aliasName: $_aliasNameGenerator(db.kelas.id, db.siswa.kelasId));

  $$SiswaTableProcessedTableManager get siswaRefs {
    final manager = $$SiswaTableTableManager($_db, $_db.siswa)
        .filter((f) => f.kelasId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_siswaRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$KelasTableFilterComposer extends Composer<_$AppDatabase, $KelasTable> {
  $$KelasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tingkat => $composableBuilder(
      column: $table.tingkat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get namaKelas => $composableBuilder(
      column: $table.namaKelas, builder: (column) => ColumnFilters(column));

  $$SekolahTableFilterComposer get sekolahId {
    final $$SekolahTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sekolahId,
        referencedTable: $db.sekolah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SekolahTableFilterComposer(
              $db: $db,
              $table: $db.sekolah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> siswaRefs(
      Expression<bool> Function($$SiswaTableFilterComposer f) f) {
    final $$SiswaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.kelasId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableFilterComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$KelasTableOrderingComposer
    extends Composer<_$AppDatabase, $KelasTable> {
  $$KelasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tingkat => $composableBuilder(
      column: $table.tingkat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get namaKelas => $composableBuilder(
      column: $table.namaKelas, builder: (column) => ColumnOrderings(column));

  $$SekolahTableOrderingComposer get sekolahId {
    final $$SekolahTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sekolahId,
        referencedTable: $db.sekolah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SekolahTableOrderingComposer(
              $db: $db,
              $table: $db.sekolah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$KelasTableAnnotationComposer
    extends Composer<_$AppDatabase, $KelasTable> {
  $$KelasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tingkat =>
      $composableBuilder(column: $table.tingkat, builder: (column) => column);

  GeneratedColumn<String> get namaKelas =>
      $composableBuilder(column: $table.namaKelas, builder: (column) => column);

  $$SekolahTableAnnotationComposer get sekolahId {
    final $$SekolahTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sekolahId,
        referencedTable: $db.sekolah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SekolahTableAnnotationComposer(
              $db: $db,
              $table: $db.sekolah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> siswaRefs<T extends Object>(
      Expression<T> Function($$SiswaTableAnnotationComposer a) f) {
    final $$SiswaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.kelasId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableAnnotationComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$KelasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $KelasTable,
    KelasData,
    $$KelasTableFilterComposer,
    $$KelasTableOrderingComposer,
    $$KelasTableAnnotationComposer,
    $$KelasTableCreateCompanionBuilder,
    $$KelasTableUpdateCompanionBuilder,
    (KelasData, $$KelasTableReferences),
    KelasData,
    PrefetchHooks Function({bool sekolahId, bool siswaRefs})> {
  $$KelasTableTableManager(_$AppDatabase db, $KelasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KelasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KelasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KelasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sekolahId = const Value.absent(),
            Value<int> tingkat = const Value.absent(),
            Value<String> namaKelas = const Value.absent(),
          }) =>
              KelasCompanion(
            id: id,
            sekolahId: sekolahId,
            tingkat: tingkat,
            namaKelas: namaKelas,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sekolahId,
            required int tingkat,
            required String namaKelas,
          }) =>
              KelasCompanion.insert(
            id: id,
            sekolahId: sekolahId,
            tingkat: tingkat,
            namaKelas: namaKelas,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$KelasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sekolahId = false, siswaRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (siswaRefs) db.siswa],
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
                if (sekolahId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sekolahId,
                    referencedTable: $$KelasTableReferences._sekolahIdTable(db),
                    referencedColumn:
                        $$KelasTableReferences._sekolahIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (siswaRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$KelasTableReferences._siswaRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$KelasTableReferences(db, table, p0).siswaRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.kelasId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$KelasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $KelasTable,
    KelasData,
    $$KelasTableFilterComposer,
    $$KelasTableOrderingComposer,
    $$KelasTableAnnotationComposer,
    $$KelasTableCreateCompanionBuilder,
    $$KelasTableUpdateCompanionBuilder,
    (KelasData, $$KelasTableReferences),
    KelasData,
    PrefetchHooks Function({bool sekolahId, bool siswaRefs})>;
typedef $$KategoriBiayaTableCreateCompanionBuilder = KategoriBiayaCompanion
    Function({
  Value<int> id,
  required String namaBiaya,
  required String tipe,
});
typedef $$KategoriBiayaTableUpdateCompanionBuilder = KategoriBiayaCompanion
    Function({
  Value<int> id,
  Value<String> namaBiaya,
  Value<String> tipe,
});

final class $$KategoriBiayaTableReferences extends BaseReferences<_$AppDatabase,
    $KategoriBiayaTable, KategoriBiayaData> {
  $$KategoriBiayaTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TarifMasterTable, List<TarifMasterData>>
      _tarifMasterRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tarifMaster,
              aliasName: $_aliasNameGenerator(
                  db.kategoriBiaya.id, db.tarifMaster.kategoriBiayaId));

  $$TarifMasterTableProcessedTableManager get tarifMasterRefs {
    final manager = $$TarifMasterTableTableManager($_db, $_db.tarifMaster)
        .filter((f) => f.kategoriBiayaId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tarifMasterRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SkemaPembayaranSiswaTable,
      List<SkemaPembayaranSiswaData>> _skemaPembayaranSiswaRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.skemaPembayaranSiswa,
          aliasName: $_aliasNameGenerator(
              db.kategoriBiaya.id, db.skemaPembayaranSiswa.kategoriBiayaId));

  $$SkemaPembayaranSiswaTableProcessedTableManager
      get skemaPembayaranSiswaRefs {
    final manager =
        $$SkemaPembayaranSiswaTableTableManager($_db, $_db.skemaPembayaranSiswa)
            .filter((f) => f.kategoriBiayaId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_skemaPembayaranSiswaRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TagihanItemTable, List<TagihanItemData>>
      _tagihanItemRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tagihanItem,
              aliasName: $_aliasNameGenerator(
                  db.kategoriBiaya.id, db.tagihanItem.kategoriBiayaId));

  $$TagihanItemTableProcessedTableManager get tagihanItemRefs {
    final manager = $$TagihanItemTableTableManager($_db, $_db.tagihanItem)
        .filter((f) => f.kategoriBiayaId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tagihanItemRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$KategoriBiayaTableFilterComposer
    extends Composer<_$AppDatabase, $KategoriBiayaTable> {
  $$KategoriBiayaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get namaBiaya => $composableBuilder(
      column: $table.namaBiaya, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipe => $composableBuilder(
      column: $table.tipe, builder: (column) => ColumnFilters(column));

  Expression<bool> tarifMasterRefs(
      Expression<bool> Function($$TarifMasterTableFilterComposer f) f) {
    final $$TarifMasterTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tarifMaster,
        getReferencedColumn: (t) => t.kategoriBiayaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TarifMasterTableFilterComposer(
              $db: $db,
              $table: $db.tarifMaster,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> skemaPembayaranSiswaRefs(
      Expression<bool> Function($$SkemaPembayaranSiswaTableFilterComposer f)
          f) {
    final $$SkemaPembayaranSiswaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.skemaPembayaranSiswa,
        getReferencedColumn: (t) => t.kategoriBiayaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkemaPembayaranSiswaTableFilterComposer(
              $db: $db,
              $table: $db.skemaPembayaranSiswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tagihanItemRefs(
      Expression<bool> Function($$TagihanItemTableFilterComposer f) f) {
    final $$TagihanItemTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tagihanItem,
        getReferencedColumn: (t) => t.kategoriBiayaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanItemTableFilterComposer(
              $db: $db,
              $table: $db.tagihanItem,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$KategoriBiayaTableOrderingComposer
    extends Composer<_$AppDatabase, $KategoriBiayaTable> {
  $$KategoriBiayaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get namaBiaya => $composableBuilder(
      column: $table.namaBiaya, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipe => $composableBuilder(
      column: $table.tipe, builder: (column) => ColumnOrderings(column));
}

class $$KategoriBiayaTableAnnotationComposer
    extends Composer<_$AppDatabase, $KategoriBiayaTable> {
  $$KategoriBiayaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get namaBiaya =>
      $composableBuilder(column: $table.namaBiaya, builder: (column) => column);

  GeneratedColumn<String> get tipe =>
      $composableBuilder(column: $table.tipe, builder: (column) => column);

  Expression<T> tarifMasterRefs<T extends Object>(
      Expression<T> Function($$TarifMasterTableAnnotationComposer a) f) {
    final $$TarifMasterTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tarifMaster,
        getReferencedColumn: (t) => t.kategoriBiayaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TarifMasterTableAnnotationComposer(
              $db: $db,
              $table: $db.tarifMaster,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> skemaPembayaranSiswaRefs<T extends Object>(
      Expression<T> Function($$SkemaPembayaranSiswaTableAnnotationComposer a)
          f) {
    final $$SkemaPembayaranSiswaTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.skemaPembayaranSiswa,
            getReferencedColumn: (t) => t.kategoriBiayaId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SkemaPembayaranSiswaTableAnnotationComposer(
                  $db: $db,
                  $table: $db.skemaPembayaranSiswa,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> tagihanItemRefs<T extends Object>(
      Expression<T> Function($$TagihanItemTableAnnotationComposer a) f) {
    final $$TagihanItemTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tagihanItem,
        getReferencedColumn: (t) => t.kategoriBiayaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanItemTableAnnotationComposer(
              $db: $db,
              $table: $db.tagihanItem,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$KategoriBiayaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $KategoriBiayaTable,
    KategoriBiayaData,
    $$KategoriBiayaTableFilterComposer,
    $$KategoriBiayaTableOrderingComposer,
    $$KategoriBiayaTableAnnotationComposer,
    $$KategoriBiayaTableCreateCompanionBuilder,
    $$KategoriBiayaTableUpdateCompanionBuilder,
    (KategoriBiayaData, $$KategoriBiayaTableReferences),
    KategoriBiayaData,
    PrefetchHooks Function(
        {bool tarifMasterRefs,
        bool skemaPembayaranSiswaRefs,
        bool tagihanItemRefs})> {
  $$KategoriBiayaTableTableManager(_$AppDatabase db, $KategoriBiayaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KategoriBiayaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KategoriBiayaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KategoriBiayaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> namaBiaya = const Value.absent(),
            Value<String> tipe = const Value.absent(),
          }) =>
              KategoriBiayaCompanion(
            id: id,
            namaBiaya: namaBiaya,
            tipe: tipe,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String namaBiaya,
            required String tipe,
          }) =>
              KategoriBiayaCompanion.insert(
            id: id,
            namaBiaya: namaBiaya,
            tipe: tipe,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$KategoriBiayaTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {tarifMasterRefs = false,
              skemaPembayaranSiswaRefs = false,
              tagihanItemRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tarifMasterRefs) db.tarifMaster,
                if (skemaPembayaranSiswaRefs) db.skemaPembayaranSiswa,
                if (tagihanItemRefs) db.tagihanItem
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tarifMasterRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$KategoriBiayaTableReferences
                            ._tarifMasterRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$KategoriBiayaTableReferences(db, table, p0)
                                .tarifMasterRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.kategoriBiayaId == item.id),
                        typedResults: items),
                  if (skemaPembayaranSiswaRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$KategoriBiayaTableReferences
                            ._skemaPembayaranSiswaRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$KategoriBiayaTableReferences(db, table, p0)
                                .skemaPembayaranSiswaRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.kategoriBiayaId == item.id),
                        typedResults: items),
                  if (tagihanItemRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$KategoriBiayaTableReferences
                            ._tagihanItemRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$KategoriBiayaTableReferences(db, table, p0)
                                .tagihanItemRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.kategoriBiayaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$KategoriBiayaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $KategoriBiayaTable,
    KategoriBiayaData,
    $$KategoriBiayaTableFilterComposer,
    $$KategoriBiayaTableOrderingComposer,
    $$KategoriBiayaTableAnnotationComposer,
    $$KategoriBiayaTableCreateCompanionBuilder,
    $$KategoriBiayaTableUpdateCompanionBuilder,
    (KategoriBiayaData, $$KategoriBiayaTableReferences),
    KategoriBiayaData,
    PrefetchHooks Function(
        {bool tarifMasterRefs,
        bool skemaPembayaranSiswaRefs,
        bool tagihanItemRefs})>;
typedef $$SiswaTableCreateCompanionBuilder = SiswaCompanion Function({
  Value<int> id,
  required int sekolahId,
  required String nis,
  Value<String?> nisn,
  required String namaLengkap,
  required String jenisKelamin,
  required int kelasId,
  required int tahunMasuk,
  Value<String?> kontakWali,
  Value<String> status,
});
typedef $$SiswaTableUpdateCompanionBuilder = SiswaCompanion Function({
  Value<int> id,
  Value<int> sekolahId,
  Value<String> nis,
  Value<String?> nisn,
  Value<String> namaLengkap,
  Value<String> jenisKelamin,
  Value<int> kelasId,
  Value<int> tahunMasuk,
  Value<String?> kontakWali,
  Value<String> status,
});

final class $$SiswaTableReferences
    extends BaseReferences<_$AppDatabase, $SiswaTable, SiswaData> {
  $$SiswaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SekolahTable _sekolahIdTable(_$AppDatabase db) => db.sekolah
      .createAlias($_aliasNameGenerator(db.siswa.sekolahId, db.sekolah.id));

  $$SekolahTableProcessedTableManager? get sekolahId {
    if ($_item.sekolahId == null) return null;
    final manager = $$SekolahTableTableManager($_db, $_db.sekolah)
        .filter((f) => f.id($_item.sekolahId!));
    final item = $_typedResult.readTableOrNull(_sekolahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $KelasTable _kelasIdTable(_$AppDatabase db) =>
      db.kelas.createAlias($_aliasNameGenerator(db.siswa.kelasId, db.kelas.id));

  $$KelasTableProcessedTableManager? get kelasId {
    if ($_item.kelasId == null) return null;
    final manager = $$KelasTableTableManager($_db, $_db.kelas)
        .filter((f) => f.id($_item.kelasId!));
    final item = $_typedResult.readTableOrNull(_kelasIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SkemaPembayaranSiswaTable,
      List<SkemaPembayaranSiswaData>> _skemaPembayaranSiswaRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.skemaPembayaranSiswa,
          aliasName: $_aliasNameGenerator(
              db.siswa.id, db.skemaPembayaranSiswa.siswaId));

  $$SkemaPembayaranSiswaTableProcessedTableManager
      get skemaPembayaranSiswaRefs {
    final manager =
        $$SkemaPembayaranSiswaTableTableManager($_db, $_db.skemaPembayaranSiswa)
            .filter((f) => f.siswaId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_skemaPembayaranSiswaRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TagihanSiswaTable, List<TagihanSiswaData>>
      _tagihanSiswaRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tagihanSiswa,
              aliasName:
                  $_aliasNameGenerator(db.siswa.id, db.tagihanSiswa.siswaId));

  $$TagihanSiswaTableProcessedTableManager get tagihanSiswaRefs {
    final manager = $$TagihanSiswaTableTableManager($_db, $_db.tagihanSiswa)
        .filter((f) => f.siswaId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tagihanSiswaRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PembayaranTransaksiTable,
      List<PembayaranTransaksiData>> _pembayaranTransaksiRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pembayaranTransaksi,
          aliasName: $_aliasNameGenerator(
              db.siswa.id, db.pembayaranTransaksi.siswaId));

  $$PembayaranTransaksiTableProcessedTableManager get pembayaranTransaksiRefs {
    final manager =
        $$PembayaranTransaksiTableTableManager($_db, $_db.pembayaranTransaksi)
            .filter((f) => f.siswaId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_pembayaranTransaksiRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SiswaTableFilterComposer extends Composer<_$AppDatabase, $SiswaTable> {
  $$SiswaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nis => $composableBuilder(
      column: $table.nis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nisn => $composableBuilder(
      column: $table.nisn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get namaLengkap => $composableBuilder(
      column: $table.namaLengkap, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jenisKelamin => $composableBuilder(
      column: $table.jenisKelamin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tahunMasuk => $composableBuilder(
      column: $table.tahunMasuk, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kontakWali => $composableBuilder(
      column: $table.kontakWali, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  $$SekolahTableFilterComposer get sekolahId {
    final $$SekolahTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sekolahId,
        referencedTable: $db.sekolah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SekolahTableFilterComposer(
              $db: $db,
              $table: $db.sekolah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$KelasTableFilterComposer get kelasId {
    final $$KelasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kelasId,
        referencedTable: $db.kelas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KelasTableFilterComposer(
              $db: $db,
              $table: $db.kelas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> skemaPembayaranSiswaRefs(
      Expression<bool> Function($$SkemaPembayaranSiswaTableFilterComposer f)
          f) {
    final $$SkemaPembayaranSiswaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.skemaPembayaranSiswa,
        getReferencedColumn: (t) => t.siswaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SkemaPembayaranSiswaTableFilterComposer(
              $db: $db,
              $table: $db.skemaPembayaranSiswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tagihanSiswaRefs(
      Expression<bool> Function($$TagihanSiswaTableFilterComposer f) f) {
    final $$TagihanSiswaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tagihanSiswa,
        getReferencedColumn: (t) => t.siswaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanSiswaTableFilterComposer(
              $db: $db,
              $table: $db.tagihanSiswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pembayaranTransaksiRefs(
      Expression<bool> Function($$PembayaranTransaksiTableFilterComposer f) f) {
    final $$PembayaranTransaksiTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pembayaranTransaksi,
        getReferencedColumn: (t) => t.siswaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PembayaranTransaksiTableFilterComposer(
              $db: $db,
              $table: $db.pembayaranTransaksi,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SiswaTableOrderingComposer
    extends Composer<_$AppDatabase, $SiswaTable> {
  $$SiswaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nis => $composableBuilder(
      column: $table.nis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nisn => $composableBuilder(
      column: $table.nisn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get namaLengkap => $composableBuilder(
      column: $table.namaLengkap, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jenisKelamin => $composableBuilder(
      column: $table.jenisKelamin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tahunMasuk => $composableBuilder(
      column: $table.tahunMasuk, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kontakWali => $composableBuilder(
      column: $table.kontakWali, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  $$SekolahTableOrderingComposer get sekolahId {
    final $$SekolahTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sekolahId,
        referencedTable: $db.sekolah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SekolahTableOrderingComposer(
              $db: $db,
              $table: $db.sekolah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$KelasTableOrderingComposer get kelasId {
    final $$KelasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kelasId,
        referencedTable: $db.kelas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KelasTableOrderingComposer(
              $db: $db,
              $table: $db.kelas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SiswaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SiswaTable> {
  $$SiswaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nis =>
      $composableBuilder(column: $table.nis, builder: (column) => column);

  GeneratedColumn<String> get nisn =>
      $composableBuilder(column: $table.nisn, builder: (column) => column);

  GeneratedColumn<String> get namaLengkap => $composableBuilder(
      column: $table.namaLengkap, builder: (column) => column);

  GeneratedColumn<String> get jenisKelamin => $composableBuilder(
      column: $table.jenisKelamin, builder: (column) => column);

  GeneratedColumn<int> get tahunMasuk => $composableBuilder(
      column: $table.tahunMasuk, builder: (column) => column);

  GeneratedColumn<String> get kontakWali => $composableBuilder(
      column: $table.kontakWali, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$SekolahTableAnnotationComposer get sekolahId {
    final $$SekolahTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sekolahId,
        referencedTable: $db.sekolah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SekolahTableAnnotationComposer(
              $db: $db,
              $table: $db.sekolah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$KelasTableAnnotationComposer get kelasId {
    final $$KelasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kelasId,
        referencedTable: $db.kelas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KelasTableAnnotationComposer(
              $db: $db,
              $table: $db.kelas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> skemaPembayaranSiswaRefs<T extends Object>(
      Expression<T> Function($$SkemaPembayaranSiswaTableAnnotationComposer a)
          f) {
    final $$SkemaPembayaranSiswaTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.skemaPembayaranSiswa,
            getReferencedColumn: (t) => t.siswaId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SkemaPembayaranSiswaTableAnnotationComposer(
                  $db: $db,
                  $table: $db.skemaPembayaranSiswa,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> tagihanSiswaRefs<T extends Object>(
      Expression<T> Function($$TagihanSiswaTableAnnotationComposer a) f) {
    final $$TagihanSiswaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tagihanSiswa,
        getReferencedColumn: (t) => t.siswaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanSiswaTableAnnotationComposer(
              $db: $db,
              $table: $db.tagihanSiswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pembayaranTransaksiRefs<T extends Object>(
      Expression<T> Function($$PembayaranTransaksiTableAnnotationComposer a)
          f) {
    final $$PembayaranTransaksiTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pembayaranTransaksi,
            getReferencedColumn: (t) => t.siswaId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PembayaranTransaksiTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pembayaranTransaksi,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SiswaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SiswaTable,
    SiswaData,
    $$SiswaTableFilterComposer,
    $$SiswaTableOrderingComposer,
    $$SiswaTableAnnotationComposer,
    $$SiswaTableCreateCompanionBuilder,
    $$SiswaTableUpdateCompanionBuilder,
    (SiswaData, $$SiswaTableReferences),
    SiswaData,
    PrefetchHooks Function(
        {bool sekolahId,
        bool kelasId,
        bool skemaPembayaranSiswaRefs,
        bool tagihanSiswaRefs,
        bool pembayaranTransaksiRefs})> {
  $$SiswaTableTableManager(_$AppDatabase db, $SiswaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SiswaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SiswaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SiswaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sekolahId = const Value.absent(),
            Value<String> nis = const Value.absent(),
            Value<String?> nisn = const Value.absent(),
            Value<String> namaLengkap = const Value.absent(),
            Value<String> jenisKelamin = const Value.absent(),
            Value<int> kelasId = const Value.absent(),
            Value<int> tahunMasuk = const Value.absent(),
            Value<String?> kontakWali = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              SiswaCompanion(
            id: id,
            sekolahId: sekolahId,
            nis: nis,
            nisn: nisn,
            namaLengkap: namaLengkap,
            jenisKelamin: jenisKelamin,
            kelasId: kelasId,
            tahunMasuk: tahunMasuk,
            kontakWali: kontakWali,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sekolahId,
            required String nis,
            Value<String?> nisn = const Value.absent(),
            required String namaLengkap,
            required String jenisKelamin,
            required int kelasId,
            required int tahunMasuk,
            Value<String?> kontakWali = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              SiswaCompanion.insert(
            id: id,
            sekolahId: sekolahId,
            nis: nis,
            nisn: nisn,
            namaLengkap: namaLengkap,
            jenisKelamin: jenisKelamin,
            kelasId: kelasId,
            tahunMasuk: tahunMasuk,
            kontakWali: kontakWali,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SiswaTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {sekolahId = false,
              kelasId = false,
              skemaPembayaranSiswaRefs = false,
              tagihanSiswaRefs = false,
              pembayaranTransaksiRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (skemaPembayaranSiswaRefs) db.skemaPembayaranSiswa,
                if (tagihanSiswaRefs) db.tagihanSiswa,
                if (pembayaranTransaksiRefs) db.pembayaranTransaksi
              ],
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
                if (sekolahId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sekolahId,
                    referencedTable: $$SiswaTableReferences._sekolahIdTable(db),
                    referencedColumn:
                        $$SiswaTableReferences._sekolahIdTable(db).id,
                  ) as T;
                }
                if (kelasId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.kelasId,
                    referencedTable: $$SiswaTableReferences._kelasIdTable(db),
                    referencedColumn:
                        $$SiswaTableReferences._kelasIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (skemaPembayaranSiswaRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$SiswaTableReferences
                            ._skemaPembayaranSiswaRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SiswaTableReferences(db, table, p0)
                                .skemaPembayaranSiswaRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.siswaId == item.id),
                        typedResults: items),
                  if (tagihanSiswaRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SiswaTableReferences._tagihanSiswaRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SiswaTableReferences(db, table, p0)
                                .tagihanSiswaRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.siswaId == item.id),
                        typedResults: items),
                  if (pembayaranTransaksiRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$SiswaTableReferences
                            ._pembayaranTransaksiRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SiswaTableReferences(db, table, p0)
                                .pembayaranTransaksiRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.siswaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SiswaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SiswaTable,
    SiswaData,
    $$SiswaTableFilterComposer,
    $$SiswaTableOrderingComposer,
    $$SiswaTableAnnotationComposer,
    $$SiswaTableCreateCompanionBuilder,
    $$SiswaTableUpdateCompanionBuilder,
    (SiswaData, $$SiswaTableReferences),
    SiswaData,
    PrefetchHooks Function(
        {bool sekolahId,
        bool kelasId,
        bool skemaPembayaranSiswaRefs,
        bool tagihanSiswaRefs,
        bool pembayaranTransaksiRefs})>;
typedef $$TarifMasterTableCreateCompanionBuilder = TarifMasterCompanion
    Function({
  Value<int> id,
  required int kategoriBiayaId,
  required int tingkat,
  required int nominal,
});
typedef $$TarifMasterTableUpdateCompanionBuilder = TarifMasterCompanion
    Function({
  Value<int> id,
  Value<int> kategoriBiayaId,
  Value<int> tingkat,
  Value<int> nominal,
});

final class $$TarifMasterTableReferences
    extends BaseReferences<_$AppDatabase, $TarifMasterTable, TarifMasterData> {
  $$TarifMasterTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KategoriBiayaTable _kategoriBiayaIdTable(_$AppDatabase db) =>
      db.kategoriBiaya.createAlias($_aliasNameGenerator(
          db.tarifMaster.kategoriBiayaId, db.kategoriBiaya.id));

  $$KategoriBiayaTableProcessedTableManager? get kategoriBiayaId {
    if ($_item.kategoriBiayaId == null) return null;
    final manager = $$KategoriBiayaTableTableManager($_db, $_db.kategoriBiaya)
        .filter((f) => f.id($_item.kategoriBiayaId!));
    final item = $_typedResult.readTableOrNull(_kategoriBiayaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TarifMasterTableFilterComposer
    extends Composer<_$AppDatabase, $TarifMasterTable> {
  $$TarifMasterTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tingkat => $composableBuilder(
      column: $table.tingkat, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nominal => $composableBuilder(
      column: $table.nominal, builder: (column) => ColumnFilters(column));

  $$KategoriBiayaTableFilterComposer get kategoriBiayaId {
    final $$KategoriBiayaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kategoriBiayaId,
        referencedTable: $db.kategoriBiaya,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KategoriBiayaTableFilterComposer(
              $db: $db,
              $table: $db.kategoriBiaya,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TarifMasterTableOrderingComposer
    extends Composer<_$AppDatabase, $TarifMasterTable> {
  $$TarifMasterTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tingkat => $composableBuilder(
      column: $table.tingkat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nominal => $composableBuilder(
      column: $table.nominal, builder: (column) => ColumnOrderings(column));

  $$KategoriBiayaTableOrderingComposer get kategoriBiayaId {
    final $$KategoriBiayaTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kategoriBiayaId,
        referencedTable: $db.kategoriBiaya,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KategoriBiayaTableOrderingComposer(
              $db: $db,
              $table: $db.kategoriBiaya,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TarifMasterTableAnnotationComposer
    extends Composer<_$AppDatabase, $TarifMasterTable> {
  $$TarifMasterTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tingkat =>
      $composableBuilder(column: $table.tingkat, builder: (column) => column);

  GeneratedColumn<int> get nominal =>
      $composableBuilder(column: $table.nominal, builder: (column) => column);

  $$KategoriBiayaTableAnnotationComposer get kategoriBiayaId {
    final $$KategoriBiayaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kategoriBiayaId,
        referencedTable: $db.kategoriBiaya,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KategoriBiayaTableAnnotationComposer(
              $db: $db,
              $table: $db.kategoriBiaya,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TarifMasterTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TarifMasterTable,
    TarifMasterData,
    $$TarifMasterTableFilterComposer,
    $$TarifMasterTableOrderingComposer,
    $$TarifMasterTableAnnotationComposer,
    $$TarifMasterTableCreateCompanionBuilder,
    $$TarifMasterTableUpdateCompanionBuilder,
    (TarifMasterData, $$TarifMasterTableReferences),
    TarifMasterData,
    PrefetchHooks Function({bool kategoriBiayaId})> {
  $$TarifMasterTableTableManager(_$AppDatabase db, $TarifMasterTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TarifMasterTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TarifMasterTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TarifMasterTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> kategoriBiayaId = const Value.absent(),
            Value<int> tingkat = const Value.absent(),
            Value<int> nominal = const Value.absent(),
          }) =>
              TarifMasterCompanion(
            id: id,
            kategoriBiayaId: kategoriBiayaId,
            tingkat: tingkat,
            nominal: nominal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int kategoriBiayaId,
            required int tingkat,
            required int nominal,
          }) =>
              TarifMasterCompanion.insert(
            id: id,
            kategoriBiayaId: kategoriBiayaId,
            tingkat: tingkat,
            nominal: nominal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TarifMasterTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({kategoriBiayaId = false}) {
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
                if (kategoriBiayaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.kategoriBiayaId,
                    referencedTable:
                        $$TarifMasterTableReferences._kategoriBiayaIdTable(db),
                    referencedColumn: $$TarifMasterTableReferences
                        ._kategoriBiayaIdTable(db)
                        .id,
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

typedef $$TarifMasterTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TarifMasterTable,
    TarifMasterData,
    $$TarifMasterTableFilterComposer,
    $$TarifMasterTableOrderingComposer,
    $$TarifMasterTableAnnotationComposer,
    $$TarifMasterTableCreateCompanionBuilder,
    $$TarifMasterTableUpdateCompanionBuilder,
    (TarifMasterData, $$TarifMasterTableReferences),
    TarifMasterData,
    PrefetchHooks Function({bool kategoriBiayaId})>;
typedef $$SkemaPembayaranSiswaTableCreateCompanionBuilder
    = SkemaPembayaranSiswaCompanion Function({
  Value<int> id,
  required int siswaId,
  required int kategoriBiayaId,
  required int nominalKustom,
  Value<String?> catatan,
});
typedef $$SkemaPembayaranSiswaTableUpdateCompanionBuilder
    = SkemaPembayaranSiswaCompanion Function({
  Value<int> id,
  Value<int> siswaId,
  Value<int> kategoriBiayaId,
  Value<int> nominalKustom,
  Value<String?> catatan,
});

final class $$SkemaPembayaranSiswaTableReferences extends BaseReferences<
    _$AppDatabase, $SkemaPembayaranSiswaTable, SkemaPembayaranSiswaData> {
  $$SkemaPembayaranSiswaTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SiswaTable _siswaIdTable(_$AppDatabase db) => db.siswa.createAlias(
      $_aliasNameGenerator(db.skemaPembayaranSiswa.siswaId, db.siswa.id));

  $$SiswaTableProcessedTableManager? get siswaId {
    if ($_item.siswaId == null) return null;
    final manager = $$SiswaTableTableManager($_db, $_db.siswa)
        .filter((f) => f.id($_item.siswaId!));
    final item = $_typedResult.readTableOrNull(_siswaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $KategoriBiayaTable _kategoriBiayaIdTable(_$AppDatabase db) =>
      db.kategoriBiaya.createAlias($_aliasNameGenerator(
          db.skemaPembayaranSiswa.kategoriBiayaId, db.kategoriBiaya.id));

  $$KategoriBiayaTableProcessedTableManager? get kategoriBiayaId {
    if ($_item.kategoriBiayaId == null) return null;
    final manager = $$KategoriBiayaTableTableManager($_db, $_db.kategoriBiaya)
        .filter((f) => f.id($_item.kategoriBiayaId!));
    final item = $_typedResult.readTableOrNull(_kategoriBiayaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SkemaPembayaranSiswaTableFilterComposer
    extends Composer<_$AppDatabase, $SkemaPembayaranSiswaTable> {
  $$SkemaPembayaranSiswaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nominalKustom => $composableBuilder(
      column: $table.nominalKustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catatan => $composableBuilder(
      column: $table.catatan, builder: (column) => ColumnFilters(column));

  $$SiswaTableFilterComposer get siswaId {
    final $$SiswaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siswaId,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableFilterComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$KategoriBiayaTableFilterComposer get kategoriBiayaId {
    final $$KategoriBiayaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kategoriBiayaId,
        referencedTable: $db.kategoriBiaya,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KategoriBiayaTableFilterComposer(
              $db: $db,
              $table: $db.kategoriBiaya,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SkemaPembayaranSiswaTableOrderingComposer
    extends Composer<_$AppDatabase, $SkemaPembayaranSiswaTable> {
  $$SkemaPembayaranSiswaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nominalKustom => $composableBuilder(
      column: $table.nominalKustom,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catatan => $composableBuilder(
      column: $table.catatan, builder: (column) => ColumnOrderings(column));

  $$SiswaTableOrderingComposer get siswaId {
    final $$SiswaTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siswaId,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableOrderingComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$KategoriBiayaTableOrderingComposer get kategoriBiayaId {
    final $$KategoriBiayaTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kategoriBiayaId,
        referencedTable: $db.kategoriBiaya,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KategoriBiayaTableOrderingComposer(
              $db: $db,
              $table: $db.kategoriBiaya,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SkemaPembayaranSiswaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkemaPembayaranSiswaTable> {
  $$SkemaPembayaranSiswaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get nominalKustom => $composableBuilder(
      column: $table.nominalKustom, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  $$SiswaTableAnnotationComposer get siswaId {
    final $$SiswaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siswaId,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableAnnotationComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$KategoriBiayaTableAnnotationComposer get kategoriBiayaId {
    final $$KategoriBiayaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kategoriBiayaId,
        referencedTable: $db.kategoriBiaya,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KategoriBiayaTableAnnotationComposer(
              $db: $db,
              $table: $db.kategoriBiaya,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SkemaPembayaranSiswaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SkemaPembayaranSiswaTable,
    SkemaPembayaranSiswaData,
    $$SkemaPembayaranSiswaTableFilterComposer,
    $$SkemaPembayaranSiswaTableOrderingComposer,
    $$SkemaPembayaranSiswaTableAnnotationComposer,
    $$SkemaPembayaranSiswaTableCreateCompanionBuilder,
    $$SkemaPembayaranSiswaTableUpdateCompanionBuilder,
    (SkemaPembayaranSiswaData, $$SkemaPembayaranSiswaTableReferences),
    SkemaPembayaranSiswaData,
    PrefetchHooks Function({bool siswaId, bool kategoriBiayaId})> {
  $$SkemaPembayaranSiswaTableTableManager(
      _$AppDatabase db, $SkemaPembayaranSiswaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkemaPembayaranSiswaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkemaPembayaranSiswaTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkemaPembayaranSiswaTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> siswaId = const Value.absent(),
            Value<int> kategoriBiayaId = const Value.absent(),
            Value<int> nominalKustom = const Value.absent(),
            Value<String?> catatan = const Value.absent(),
          }) =>
              SkemaPembayaranSiswaCompanion(
            id: id,
            siswaId: siswaId,
            kategoriBiayaId: kategoriBiayaId,
            nominalKustom: nominalKustom,
            catatan: catatan,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int siswaId,
            required int kategoriBiayaId,
            required int nominalKustom,
            Value<String?> catatan = const Value.absent(),
          }) =>
              SkemaPembayaranSiswaCompanion.insert(
            id: id,
            siswaId: siswaId,
            kategoriBiayaId: kategoriBiayaId,
            nominalKustom: nominalKustom,
            catatan: catatan,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SkemaPembayaranSiswaTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({siswaId = false, kategoriBiayaId = false}) {
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
                if (siswaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.siswaId,
                    referencedTable:
                        $$SkemaPembayaranSiswaTableReferences._siswaIdTable(db),
                    referencedColumn: $$SkemaPembayaranSiswaTableReferences
                        ._siswaIdTable(db)
                        .id,
                  ) as T;
                }
                if (kategoriBiayaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.kategoriBiayaId,
                    referencedTable: $$SkemaPembayaranSiswaTableReferences
                        ._kategoriBiayaIdTable(db),
                    referencedColumn: $$SkemaPembayaranSiswaTableReferences
                        ._kategoriBiayaIdTable(db)
                        .id,
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

typedef $$SkemaPembayaranSiswaTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SkemaPembayaranSiswaTable,
        SkemaPembayaranSiswaData,
        $$SkemaPembayaranSiswaTableFilterComposer,
        $$SkemaPembayaranSiswaTableOrderingComposer,
        $$SkemaPembayaranSiswaTableAnnotationComposer,
        $$SkemaPembayaranSiswaTableCreateCompanionBuilder,
        $$SkemaPembayaranSiswaTableUpdateCompanionBuilder,
        (SkemaPembayaranSiswaData, $$SkemaPembayaranSiswaTableReferences),
        SkemaPembayaranSiswaData,
        PrefetchHooks Function({bool siswaId, bool kategoriBiayaId})>;
typedef $$TagihanSiswaTableCreateCompanionBuilder = TagihanSiswaCompanion
    Function({
  Value<int> id,
  required int siswaId,
  required String periode,
  Value<int> isLunas,
});
typedef $$TagihanSiswaTableUpdateCompanionBuilder = TagihanSiswaCompanion
    Function({
  Value<int> id,
  Value<int> siswaId,
  Value<String> periode,
  Value<int> isLunas,
});

final class $$TagihanSiswaTableReferences extends BaseReferences<_$AppDatabase,
    $TagihanSiswaTable, TagihanSiswaData> {
  $$TagihanSiswaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SiswaTable _siswaIdTable(_$AppDatabase db) => db.siswa
      .createAlias($_aliasNameGenerator(db.tagihanSiswa.siswaId, db.siswa.id));

  $$SiswaTableProcessedTableManager? get siswaId {
    if ($_item.siswaId == null) return null;
    final manager = $$SiswaTableTableManager($_db, $_db.siswa)
        .filter((f) => f.id($_item.siswaId!));
    final item = $_typedResult.readTableOrNull(_siswaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TagihanItemTable, List<TagihanItemData>>
      _tagihanItemRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tagihanItem,
              aliasName: $_aliasNameGenerator(
                  db.tagihanSiswa.id, db.tagihanItem.tagihanId));

  $$TagihanItemTableProcessedTableManager get tagihanItemRefs {
    final manager = $$TagihanItemTableTableManager($_db, $_db.tagihanItem)
        .filter((f) => f.tagihanId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tagihanItemRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagihanSiswaTableFilterComposer
    extends Composer<_$AppDatabase, $TagihanSiswaTable> {
  $$TagihanSiswaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get periode => $composableBuilder(
      column: $table.periode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isLunas => $composableBuilder(
      column: $table.isLunas, builder: (column) => ColumnFilters(column));

  $$SiswaTableFilterComposer get siswaId {
    final $$SiswaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siswaId,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableFilterComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> tagihanItemRefs(
      Expression<bool> Function($$TagihanItemTableFilterComposer f) f) {
    final $$TagihanItemTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tagihanItem,
        getReferencedColumn: (t) => t.tagihanId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanItemTableFilterComposer(
              $db: $db,
              $table: $db.tagihanItem,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagihanSiswaTableOrderingComposer
    extends Composer<_$AppDatabase, $TagihanSiswaTable> {
  $$TagihanSiswaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get periode => $composableBuilder(
      column: $table.periode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isLunas => $composableBuilder(
      column: $table.isLunas, builder: (column) => ColumnOrderings(column));

  $$SiswaTableOrderingComposer get siswaId {
    final $$SiswaTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siswaId,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableOrderingComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TagihanSiswaTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagihanSiswaTable> {
  $$TagihanSiswaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get periode =>
      $composableBuilder(column: $table.periode, builder: (column) => column);

  GeneratedColumn<int> get isLunas =>
      $composableBuilder(column: $table.isLunas, builder: (column) => column);

  $$SiswaTableAnnotationComposer get siswaId {
    final $$SiswaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siswaId,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableAnnotationComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> tagihanItemRefs<T extends Object>(
      Expression<T> Function($$TagihanItemTableAnnotationComposer a) f) {
    final $$TagihanItemTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tagihanItem,
        getReferencedColumn: (t) => t.tagihanId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanItemTableAnnotationComposer(
              $db: $db,
              $table: $db.tagihanItem,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagihanSiswaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagihanSiswaTable,
    TagihanSiswaData,
    $$TagihanSiswaTableFilterComposer,
    $$TagihanSiswaTableOrderingComposer,
    $$TagihanSiswaTableAnnotationComposer,
    $$TagihanSiswaTableCreateCompanionBuilder,
    $$TagihanSiswaTableUpdateCompanionBuilder,
    (TagihanSiswaData, $$TagihanSiswaTableReferences),
    TagihanSiswaData,
    PrefetchHooks Function({bool siswaId, bool tagihanItemRefs})> {
  $$TagihanSiswaTableTableManager(_$AppDatabase db, $TagihanSiswaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagihanSiswaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagihanSiswaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagihanSiswaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> siswaId = const Value.absent(),
            Value<String> periode = const Value.absent(),
            Value<int> isLunas = const Value.absent(),
          }) =>
              TagihanSiswaCompanion(
            id: id,
            siswaId: siswaId,
            periode: periode,
            isLunas: isLunas,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int siswaId,
            required String periode,
            Value<int> isLunas = const Value.absent(),
          }) =>
              TagihanSiswaCompanion.insert(
            id: id,
            siswaId: siswaId,
            periode: periode,
            isLunas: isLunas,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TagihanSiswaTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({siswaId = false, tagihanItemRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tagihanItemRefs) db.tagihanItem],
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
                if (siswaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.siswaId,
                    referencedTable:
                        $$TagihanSiswaTableReferences._siswaIdTable(db),
                    referencedColumn:
                        $$TagihanSiswaTableReferences._siswaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tagihanItemRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$TagihanSiswaTableReferences
                            ._tagihanItemRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagihanSiswaTableReferences(db, table, p0)
                                .tagihanItemRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.tagihanId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagihanSiswaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagihanSiswaTable,
    TagihanSiswaData,
    $$TagihanSiswaTableFilterComposer,
    $$TagihanSiswaTableOrderingComposer,
    $$TagihanSiswaTableAnnotationComposer,
    $$TagihanSiswaTableCreateCompanionBuilder,
    $$TagihanSiswaTableUpdateCompanionBuilder,
    (TagihanSiswaData, $$TagihanSiswaTableReferences),
    TagihanSiswaData,
    PrefetchHooks Function({bool siswaId, bool tagihanItemRefs})>;
typedef $$TagihanItemTableCreateCompanionBuilder = TagihanItemCompanion
    Function({
  Value<int> id,
  required int tagihanId,
  required int kategoriBiayaId,
  required String namaItem,
  required int nominalAwal,
  Value<int> nominalDiskon,
  required int nominalAkhir,
  Value<int> terbayar,
  Value<int> isLunas,
});
typedef $$TagihanItemTableUpdateCompanionBuilder = TagihanItemCompanion
    Function({
  Value<int> id,
  Value<int> tagihanId,
  Value<int> kategoriBiayaId,
  Value<String> namaItem,
  Value<int> nominalAwal,
  Value<int> nominalDiskon,
  Value<int> nominalAkhir,
  Value<int> terbayar,
  Value<int> isLunas,
});

final class $$TagihanItemTableReferences
    extends BaseReferences<_$AppDatabase, $TagihanItemTable, TagihanItemData> {
  $$TagihanItemTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TagihanSiswaTable _tagihanIdTable(_$AppDatabase db) =>
      db.tagihanSiswa.createAlias(
          $_aliasNameGenerator(db.tagihanItem.tagihanId, db.tagihanSiswa.id));

  $$TagihanSiswaTableProcessedTableManager? get tagihanId {
    if ($_item.tagihanId == null) return null;
    final manager = $$TagihanSiswaTableTableManager($_db, $_db.tagihanSiswa)
        .filter((f) => f.id($_item.tagihanId!));
    final item = $_typedResult.readTableOrNull(_tagihanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $KategoriBiayaTable _kategoriBiayaIdTable(_$AppDatabase db) =>
      db.kategoriBiaya.createAlias($_aliasNameGenerator(
          db.tagihanItem.kategoriBiayaId, db.kategoriBiaya.id));

  $$KategoriBiayaTableProcessedTableManager? get kategoriBiayaId {
    if ($_item.kategoriBiayaId == null) return null;
    final manager = $$KategoriBiayaTableTableManager($_db, $_db.kategoriBiaya)
        .filter((f) => f.id($_item.kategoriBiayaId!));
    final item = $_typedResult.readTableOrNull(_kategoriBiayaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$AlokasiPembayaranTable,
      List<AlokasiPembayaranData>> _alokasiPembayaranRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.alokasiPembayaran,
          aliasName: $_aliasNameGenerator(
              db.tagihanItem.id, db.alokasiPembayaran.tagihanItemId));

  $$AlokasiPembayaranTableProcessedTableManager get alokasiPembayaranRefs {
    final manager =
        $$AlokasiPembayaranTableTableManager($_db, $_db.alokasiPembayaran)
            .filter((f) => f.tagihanItemId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_alokasiPembayaranRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagihanItemTableFilterComposer
    extends Composer<_$AppDatabase, $TagihanItemTable> {
  $$TagihanItemTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get namaItem => $composableBuilder(
      column: $table.namaItem, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nominalAwal => $composableBuilder(
      column: $table.nominalAwal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nominalDiskon => $composableBuilder(
      column: $table.nominalDiskon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nominalAkhir => $composableBuilder(
      column: $table.nominalAkhir, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get terbayar => $composableBuilder(
      column: $table.terbayar, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isLunas => $composableBuilder(
      column: $table.isLunas, builder: (column) => ColumnFilters(column));

  $$TagihanSiswaTableFilterComposer get tagihanId {
    final $$TagihanSiswaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagihanId,
        referencedTable: $db.tagihanSiswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanSiswaTableFilterComposer(
              $db: $db,
              $table: $db.tagihanSiswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$KategoriBiayaTableFilterComposer get kategoriBiayaId {
    final $$KategoriBiayaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kategoriBiayaId,
        referencedTable: $db.kategoriBiaya,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KategoriBiayaTableFilterComposer(
              $db: $db,
              $table: $db.kategoriBiaya,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> alokasiPembayaranRefs(
      Expression<bool> Function($$AlokasiPembayaranTableFilterComposer f) f) {
    final $$AlokasiPembayaranTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.alokasiPembayaran,
        getReferencedColumn: (t) => t.tagihanItemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlokasiPembayaranTableFilterComposer(
              $db: $db,
              $table: $db.alokasiPembayaran,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagihanItemTableOrderingComposer
    extends Composer<_$AppDatabase, $TagihanItemTable> {
  $$TagihanItemTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get namaItem => $composableBuilder(
      column: $table.namaItem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nominalAwal => $composableBuilder(
      column: $table.nominalAwal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nominalDiskon => $composableBuilder(
      column: $table.nominalDiskon,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nominalAkhir => $composableBuilder(
      column: $table.nominalAkhir,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get terbayar => $composableBuilder(
      column: $table.terbayar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isLunas => $composableBuilder(
      column: $table.isLunas, builder: (column) => ColumnOrderings(column));

  $$TagihanSiswaTableOrderingComposer get tagihanId {
    final $$TagihanSiswaTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagihanId,
        referencedTable: $db.tagihanSiswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanSiswaTableOrderingComposer(
              $db: $db,
              $table: $db.tagihanSiswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$KategoriBiayaTableOrderingComposer get kategoriBiayaId {
    final $$KategoriBiayaTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kategoriBiayaId,
        referencedTable: $db.kategoriBiaya,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KategoriBiayaTableOrderingComposer(
              $db: $db,
              $table: $db.kategoriBiaya,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TagihanItemTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagihanItemTable> {
  $$TagihanItemTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get namaItem =>
      $composableBuilder(column: $table.namaItem, builder: (column) => column);

  GeneratedColumn<int> get nominalAwal => $composableBuilder(
      column: $table.nominalAwal, builder: (column) => column);

  GeneratedColumn<int> get nominalDiskon => $composableBuilder(
      column: $table.nominalDiskon, builder: (column) => column);

  GeneratedColumn<int> get nominalAkhir => $composableBuilder(
      column: $table.nominalAkhir, builder: (column) => column);

  GeneratedColumn<int> get terbayar =>
      $composableBuilder(column: $table.terbayar, builder: (column) => column);

  GeneratedColumn<int> get isLunas =>
      $composableBuilder(column: $table.isLunas, builder: (column) => column);

  $$TagihanSiswaTableAnnotationComposer get tagihanId {
    final $$TagihanSiswaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagihanId,
        referencedTable: $db.tagihanSiswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanSiswaTableAnnotationComposer(
              $db: $db,
              $table: $db.tagihanSiswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$KategoriBiayaTableAnnotationComposer get kategoriBiayaId {
    final $$KategoriBiayaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.kategoriBiayaId,
        referencedTable: $db.kategoriBiaya,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KategoriBiayaTableAnnotationComposer(
              $db: $db,
              $table: $db.kategoriBiaya,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> alokasiPembayaranRefs<T extends Object>(
      Expression<T> Function($$AlokasiPembayaranTableAnnotationComposer a) f) {
    final $$AlokasiPembayaranTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.alokasiPembayaran,
            getReferencedColumn: (t) => t.tagihanItemId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AlokasiPembayaranTableAnnotationComposer(
                  $db: $db,
                  $table: $db.alokasiPembayaran,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TagihanItemTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagihanItemTable,
    TagihanItemData,
    $$TagihanItemTableFilterComposer,
    $$TagihanItemTableOrderingComposer,
    $$TagihanItemTableAnnotationComposer,
    $$TagihanItemTableCreateCompanionBuilder,
    $$TagihanItemTableUpdateCompanionBuilder,
    (TagihanItemData, $$TagihanItemTableReferences),
    TagihanItemData,
    PrefetchHooks Function(
        {bool tagihanId, bool kategoriBiayaId, bool alokasiPembayaranRefs})> {
  $$TagihanItemTableTableManager(_$AppDatabase db, $TagihanItemTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagihanItemTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagihanItemTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagihanItemTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> tagihanId = const Value.absent(),
            Value<int> kategoriBiayaId = const Value.absent(),
            Value<String> namaItem = const Value.absent(),
            Value<int> nominalAwal = const Value.absent(),
            Value<int> nominalDiskon = const Value.absent(),
            Value<int> nominalAkhir = const Value.absent(),
            Value<int> terbayar = const Value.absent(),
            Value<int> isLunas = const Value.absent(),
          }) =>
              TagihanItemCompanion(
            id: id,
            tagihanId: tagihanId,
            kategoriBiayaId: kategoriBiayaId,
            namaItem: namaItem,
            nominalAwal: nominalAwal,
            nominalDiskon: nominalDiskon,
            nominalAkhir: nominalAkhir,
            terbayar: terbayar,
            isLunas: isLunas,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int tagihanId,
            required int kategoriBiayaId,
            required String namaItem,
            required int nominalAwal,
            Value<int> nominalDiskon = const Value.absent(),
            required int nominalAkhir,
            Value<int> terbayar = const Value.absent(),
            Value<int> isLunas = const Value.absent(),
          }) =>
              TagihanItemCompanion.insert(
            id: id,
            tagihanId: tagihanId,
            kategoriBiayaId: kategoriBiayaId,
            namaItem: namaItem,
            nominalAwal: nominalAwal,
            nominalDiskon: nominalDiskon,
            nominalAkhir: nominalAkhir,
            terbayar: terbayar,
            isLunas: isLunas,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TagihanItemTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {tagihanId = false,
              kategoriBiayaId = false,
              alokasiPembayaranRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (alokasiPembayaranRefs) db.alokasiPembayaran
              ],
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
                if (tagihanId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagihanId,
                    referencedTable:
                        $$TagihanItemTableReferences._tagihanIdTable(db),
                    referencedColumn:
                        $$TagihanItemTableReferences._tagihanIdTable(db).id,
                  ) as T;
                }
                if (kategoriBiayaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.kategoriBiayaId,
                    referencedTable:
                        $$TagihanItemTableReferences._kategoriBiayaIdTable(db),
                    referencedColumn: $$TagihanItemTableReferences
                        ._kategoriBiayaIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (alokasiPembayaranRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$TagihanItemTableReferences
                            ._alokasiPembayaranRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagihanItemTableReferences(db, table, p0)
                                .alokasiPembayaranRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.tagihanItemId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagihanItemTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagihanItemTable,
    TagihanItemData,
    $$TagihanItemTableFilterComposer,
    $$TagihanItemTableOrderingComposer,
    $$TagihanItemTableAnnotationComposer,
    $$TagihanItemTableCreateCompanionBuilder,
    $$TagihanItemTableUpdateCompanionBuilder,
    (TagihanItemData, $$TagihanItemTableReferences),
    TagihanItemData,
    PrefetchHooks Function(
        {bool tagihanId, bool kategoriBiayaId, bool alokasiPembayaranRefs})>;
typedef $$PembayaranTransaksiTableCreateCompanionBuilder
    = PembayaranTransaksiCompanion Function({
  Value<int> id,
  required String nomorKuitansi,
  required int siswaId,
  required String tanggalBayar,
  required int totalBayar,
  required String metodeBayar,
  Value<String> status,
  required String createdBy,
});
typedef $$PembayaranTransaksiTableUpdateCompanionBuilder
    = PembayaranTransaksiCompanion Function({
  Value<int> id,
  Value<String> nomorKuitansi,
  Value<int> siswaId,
  Value<String> tanggalBayar,
  Value<int> totalBayar,
  Value<String> metodeBayar,
  Value<String> status,
  Value<String> createdBy,
});

final class $$PembayaranTransaksiTableReferences extends BaseReferences<
    _$AppDatabase, $PembayaranTransaksiTable, PembayaranTransaksiData> {
  $$PembayaranTransaksiTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SiswaTable _siswaIdTable(_$AppDatabase db) => db.siswa.createAlias(
      $_aliasNameGenerator(db.pembayaranTransaksi.siswaId, db.siswa.id));

  $$SiswaTableProcessedTableManager? get siswaId {
    if ($_item.siswaId == null) return null;
    final manager = $$SiswaTableTableManager($_db, $_db.siswa)
        .filter((f) => f.id($_item.siswaId!));
    final item = $_typedResult.readTableOrNull(_siswaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$AlokasiPembayaranTable,
      List<AlokasiPembayaranData>> _alokasiPembayaranRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.alokasiPembayaran,
          aliasName: $_aliasNameGenerator(
              db.pembayaranTransaksi.id, db.alokasiPembayaran.transaksiId));

  $$AlokasiPembayaranTableProcessedTableManager get alokasiPembayaranRefs {
    final manager =
        $$AlokasiPembayaranTableTableManager($_db, $_db.alokasiPembayaran)
            .filter((f) => f.transaksiId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_alokasiPembayaranRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PembayaranTransaksiTableFilterComposer
    extends Composer<_$AppDatabase, $PembayaranTransaksiTable> {
  $$PembayaranTransaksiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nomorKuitansi => $composableBuilder(
      column: $table.nomorKuitansi, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tanggalBayar => $composableBuilder(
      column: $table.tanggalBayar, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalBayar => $composableBuilder(
      column: $table.totalBayar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metodeBayar => $composableBuilder(
      column: $table.metodeBayar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  $$SiswaTableFilterComposer get siswaId {
    final $$SiswaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siswaId,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableFilterComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> alokasiPembayaranRefs(
      Expression<bool> Function($$AlokasiPembayaranTableFilterComposer f) f) {
    final $$AlokasiPembayaranTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.alokasiPembayaran,
        getReferencedColumn: (t) => t.transaksiId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlokasiPembayaranTableFilterComposer(
              $db: $db,
              $table: $db.alokasiPembayaran,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PembayaranTransaksiTableOrderingComposer
    extends Composer<_$AppDatabase, $PembayaranTransaksiTable> {
  $$PembayaranTransaksiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nomorKuitansi => $composableBuilder(
      column: $table.nomorKuitansi,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tanggalBayar => $composableBuilder(
      column: $table.tanggalBayar,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalBayar => $composableBuilder(
      column: $table.totalBayar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metodeBayar => $composableBuilder(
      column: $table.metodeBayar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  $$SiswaTableOrderingComposer get siswaId {
    final $$SiswaTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siswaId,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableOrderingComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PembayaranTransaksiTableAnnotationComposer
    extends Composer<_$AppDatabase, $PembayaranTransaksiTable> {
  $$PembayaranTransaksiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nomorKuitansi => $composableBuilder(
      column: $table.nomorKuitansi, builder: (column) => column);

  GeneratedColumn<String> get tanggalBayar => $composableBuilder(
      column: $table.tanggalBayar, builder: (column) => column);

  GeneratedColumn<int> get totalBayar => $composableBuilder(
      column: $table.totalBayar, builder: (column) => column);

  GeneratedColumn<String> get metodeBayar => $composableBuilder(
      column: $table.metodeBayar, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  $$SiswaTableAnnotationComposer get siswaId {
    final $$SiswaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siswaId,
        referencedTable: $db.siswa,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SiswaTableAnnotationComposer(
              $db: $db,
              $table: $db.siswa,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> alokasiPembayaranRefs<T extends Object>(
      Expression<T> Function($$AlokasiPembayaranTableAnnotationComposer a) f) {
    final $$AlokasiPembayaranTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.alokasiPembayaran,
            getReferencedColumn: (t) => t.transaksiId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AlokasiPembayaranTableAnnotationComposer(
                  $db: $db,
                  $table: $db.alokasiPembayaran,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PembayaranTransaksiTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PembayaranTransaksiTable,
    PembayaranTransaksiData,
    $$PembayaranTransaksiTableFilterComposer,
    $$PembayaranTransaksiTableOrderingComposer,
    $$PembayaranTransaksiTableAnnotationComposer,
    $$PembayaranTransaksiTableCreateCompanionBuilder,
    $$PembayaranTransaksiTableUpdateCompanionBuilder,
    (PembayaranTransaksiData, $$PembayaranTransaksiTableReferences),
    PembayaranTransaksiData,
    PrefetchHooks Function({bool siswaId, bool alokasiPembayaranRefs})> {
  $$PembayaranTransaksiTableTableManager(
      _$AppDatabase db, $PembayaranTransaksiTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PembayaranTransaksiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PembayaranTransaksiTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PembayaranTransaksiTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nomorKuitansi = const Value.absent(),
            Value<int> siswaId = const Value.absent(),
            Value<String> tanggalBayar = const Value.absent(),
            Value<int> totalBayar = const Value.absent(),
            Value<String> metodeBayar = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
          }) =>
              PembayaranTransaksiCompanion(
            id: id,
            nomorKuitansi: nomorKuitansi,
            siswaId: siswaId,
            tanggalBayar: tanggalBayar,
            totalBayar: totalBayar,
            metodeBayar: metodeBayar,
            status: status,
            createdBy: createdBy,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nomorKuitansi,
            required int siswaId,
            required String tanggalBayar,
            required int totalBayar,
            required String metodeBayar,
            Value<String> status = const Value.absent(),
            required String createdBy,
          }) =>
              PembayaranTransaksiCompanion.insert(
            id: id,
            nomorKuitansi: nomorKuitansi,
            siswaId: siswaId,
            tanggalBayar: tanggalBayar,
            totalBayar: totalBayar,
            metodeBayar: metodeBayar,
            status: status,
            createdBy: createdBy,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PembayaranTransaksiTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {siswaId = false, alokasiPembayaranRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (alokasiPembayaranRefs) db.alokasiPembayaran
              ],
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
                if (siswaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.siswaId,
                    referencedTable:
                        $$PembayaranTransaksiTableReferences._siswaIdTable(db),
                    referencedColumn: $$PembayaranTransaksiTableReferences
                        ._siswaIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (alokasiPembayaranRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$PembayaranTransaksiTableReferences
                            ._alokasiPembayaranRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PembayaranTransaksiTableReferences(db, table, p0)
                                .alokasiPembayaranRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transaksiId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PembayaranTransaksiTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PembayaranTransaksiTable,
    PembayaranTransaksiData,
    $$PembayaranTransaksiTableFilterComposer,
    $$PembayaranTransaksiTableOrderingComposer,
    $$PembayaranTransaksiTableAnnotationComposer,
    $$PembayaranTransaksiTableCreateCompanionBuilder,
    $$PembayaranTransaksiTableUpdateCompanionBuilder,
    (PembayaranTransaksiData, $$PembayaranTransaksiTableReferences),
    PembayaranTransaksiData,
    PrefetchHooks Function({bool siswaId, bool alokasiPembayaranRefs})>;
typedef $$AlokasiPembayaranTableCreateCompanionBuilder
    = AlokasiPembayaranCompanion Function({
  Value<int> id,
  required int transaksiId,
  required int tagihanItemId,
  required int nominalDialokasikan,
});
typedef $$AlokasiPembayaranTableUpdateCompanionBuilder
    = AlokasiPembayaranCompanion Function({
  Value<int> id,
  Value<int> transaksiId,
  Value<int> tagihanItemId,
  Value<int> nominalDialokasikan,
});

final class $$AlokasiPembayaranTableReferences extends BaseReferences<
    _$AppDatabase, $AlokasiPembayaranTable, AlokasiPembayaranData> {
  $$AlokasiPembayaranTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PembayaranTransaksiTable _transaksiIdTable(_$AppDatabase db) =>
      db.pembayaranTransaksi.createAlias($_aliasNameGenerator(
          db.alokasiPembayaran.transaksiId, db.pembayaranTransaksi.id));

  $$PembayaranTransaksiTableProcessedTableManager? get transaksiId {
    if ($_item.transaksiId == null) return null;
    final manager =
        $$PembayaranTransaksiTableTableManager($_db, $_db.pembayaranTransaksi)
            .filter((f) => f.id($_item.transaksiId!));
    final item = $_typedResult.readTableOrNull(_transaksiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagihanItemTable _tagihanItemIdTable(_$AppDatabase db) =>
      db.tagihanItem.createAlias($_aliasNameGenerator(
          db.alokasiPembayaran.tagihanItemId, db.tagihanItem.id));

  $$TagihanItemTableProcessedTableManager? get tagihanItemId {
    if ($_item.tagihanItemId == null) return null;
    final manager = $$TagihanItemTableTableManager($_db, $_db.tagihanItem)
        .filter((f) => f.id($_item.tagihanItemId!));
    final item = $_typedResult.readTableOrNull(_tagihanItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AlokasiPembayaranTableFilterComposer
    extends Composer<_$AppDatabase, $AlokasiPembayaranTable> {
  $$AlokasiPembayaranTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nominalDialokasikan => $composableBuilder(
      column: $table.nominalDialokasikan,
      builder: (column) => ColumnFilters(column));

  $$PembayaranTransaksiTableFilterComposer get transaksiId {
    final $$PembayaranTransaksiTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transaksiId,
        referencedTable: $db.pembayaranTransaksi,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PembayaranTransaksiTableFilterComposer(
              $db: $db,
              $table: $db.pembayaranTransaksi,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagihanItemTableFilterComposer get tagihanItemId {
    final $$TagihanItemTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagihanItemId,
        referencedTable: $db.tagihanItem,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanItemTableFilterComposer(
              $db: $db,
              $table: $db.tagihanItem,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlokasiPembayaranTableOrderingComposer
    extends Composer<_$AppDatabase, $AlokasiPembayaranTable> {
  $$AlokasiPembayaranTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nominalDialokasikan => $composableBuilder(
      column: $table.nominalDialokasikan,
      builder: (column) => ColumnOrderings(column));

  $$PembayaranTransaksiTableOrderingComposer get transaksiId {
    final $$PembayaranTransaksiTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transaksiId,
            referencedTable: $db.pembayaranTransaksi,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PembayaranTransaksiTableOrderingComposer(
                  $db: $db,
                  $table: $db.pembayaranTransaksi,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TagihanItemTableOrderingComposer get tagihanItemId {
    final $$TagihanItemTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagihanItemId,
        referencedTable: $db.tagihanItem,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanItemTableOrderingComposer(
              $db: $db,
              $table: $db.tagihanItem,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlokasiPembayaranTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlokasiPembayaranTable> {
  $$AlokasiPembayaranTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get nominalDialokasikan => $composableBuilder(
      column: $table.nominalDialokasikan, builder: (column) => column);

  $$PembayaranTransaksiTableAnnotationComposer get transaksiId {
    final $$PembayaranTransaksiTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transaksiId,
            referencedTable: $db.pembayaranTransaksi,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PembayaranTransaksiTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pembayaranTransaksi,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TagihanItemTableAnnotationComposer get tagihanItemId {
    final $$TagihanItemTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagihanItemId,
        referencedTable: $db.tagihanItem,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagihanItemTableAnnotationComposer(
              $db: $db,
              $table: $db.tagihanItem,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlokasiPembayaranTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlokasiPembayaranTable,
    AlokasiPembayaranData,
    $$AlokasiPembayaranTableFilterComposer,
    $$AlokasiPembayaranTableOrderingComposer,
    $$AlokasiPembayaranTableAnnotationComposer,
    $$AlokasiPembayaranTableCreateCompanionBuilder,
    $$AlokasiPembayaranTableUpdateCompanionBuilder,
    (AlokasiPembayaranData, $$AlokasiPembayaranTableReferences),
    AlokasiPembayaranData,
    PrefetchHooks Function({bool transaksiId, bool tagihanItemId})> {
  $$AlokasiPembayaranTableTableManager(
      _$AppDatabase db, $AlokasiPembayaranTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlokasiPembayaranTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlokasiPembayaranTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlokasiPembayaranTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transaksiId = const Value.absent(),
            Value<int> tagihanItemId = const Value.absent(),
            Value<int> nominalDialokasikan = const Value.absent(),
          }) =>
              AlokasiPembayaranCompanion(
            id: id,
            transaksiId: transaksiId,
            tagihanItemId: tagihanItemId,
            nominalDialokasikan: nominalDialokasikan,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transaksiId,
            required int tagihanItemId,
            required int nominalDialokasikan,
          }) =>
              AlokasiPembayaranCompanion.insert(
            id: id,
            transaksiId: transaksiId,
            tagihanItemId: tagihanItemId,
            nominalDialokasikan: nominalDialokasikan,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AlokasiPembayaranTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {transaksiId = false, tagihanItemId = false}) {
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
                if (transaksiId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transaksiId,
                    referencedTable: $$AlokasiPembayaranTableReferences
                        ._transaksiIdTable(db),
                    referencedColumn: $$AlokasiPembayaranTableReferences
                        ._transaksiIdTable(db)
                        .id,
                  ) as T;
                }
                if (tagihanItemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagihanItemId,
                    referencedTable: $$AlokasiPembayaranTableReferences
                        ._tagihanItemIdTable(db),
                    referencedColumn: $$AlokasiPembayaranTableReferences
                        ._tagihanItemIdTable(db)
                        .id,
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

typedef $$AlokasiPembayaranTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AlokasiPembayaranTable,
    AlokasiPembayaranData,
    $$AlokasiPembayaranTableFilterComposer,
    $$AlokasiPembayaranTableOrderingComposer,
    $$AlokasiPembayaranTableAnnotationComposer,
    $$AlokasiPembayaranTableCreateCompanionBuilder,
    $$AlokasiPembayaranTableUpdateCompanionBuilder,
    (AlokasiPembayaranData, $$AlokasiPembayaranTableReferences),
    AlokasiPembayaranData,
    PrefetchHooks Function({bool transaksiId, bool tagihanItemId})>;
typedef $$AuditLogTableCreateCompanionBuilder = AuditLogCompanion Function({
  Value<int> id,
  required String userRole,
  required String actionType,
  required String entityAffected,
  Value<int?> entityId,
  required String timestampIso,
  Value<String?> details,
});
typedef $$AuditLogTableUpdateCompanionBuilder = AuditLogCompanion Function({
  Value<int> id,
  Value<String> userRole,
  Value<String> actionType,
  Value<String> entityAffected,
  Value<int?> entityId,
  Value<String> timestampIso,
  Value<String?> details,
});

class $$AuditLogTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userRole => $composableBuilder(
      column: $table.userRole, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityAffected => $composableBuilder(
      column: $table.entityAffected,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timestampIso => $composableBuilder(
      column: $table.timestampIso, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnFilters(column));
}

class $$AuditLogTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userRole => $composableBuilder(
      column: $table.userRole, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityAffected => $composableBuilder(
      column: $table.entityAffected,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timestampIso => $composableBuilder(
      column: $table.timestampIso,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnOrderings(column));
}

class $$AuditLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userRole =>
      $composableBuilder(column: $table.userRole, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get entityAffected => $composableBuilder(
      column: $table.entityAffected, builder: (column) => column);

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get timestampIso => $composableBuilder(
      column: $table.timestampIso, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);
}

class $$AuditLogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogTable,
    AuditLogData,
    $$AuditLogTableFilterComposer,
    $$AuditLogTableOrderingComposer,
    $$AuditLogTableAnnotationComposer,
    $$AuditLogTableCreateCompanionBuilder,
    $$AuditLogTableUpdateCompanionBuilder,
    (AuditLogData, BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>),
    AuditLogData,
    PrefetchHooks Function()> {
  $$AuditLogTableTableManager(_$AppDatabase db, $AuditLogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> userRole = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String> entityAffected = const Value.absent(),
            Value<int?> entityId = const Value.absent(),
            Value<String> timestampIso = const Value.absent(),
            Value<String?> details = const Value.absent(),
          }) =>
              AuditLogCompanion(
            id: id,
            userRole: userRole,
            actionType: actionType,
            entityAffected: entityAffected,
            entityId: entityId,
            timestampIso: timestampIso,
            details: details,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String userRole,
            required String actionType,
            required String entityAffected,
            Value<int?> entityId = const Value.absent(),
            required String timestampIso,
            Value<String?> details = const Value.absent(),
          }) =>
              AuditLogCompanion.insert(
            id: id,
            userRole: userRole,
            actionType: actionType,
            entityAffected: entityAffected,
            entityId: entityId,
            timestampIso: timestampIso,
            details: details,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AuditLogTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditLogTable,
    AuditLogData,
    $$AuditLogTableFilterComposer,
    $$AuditLogTableOrderingComposer,
    $$AuditLogTableAnnotationComposer,
    $$AuditLogTableCreateCompanionBuilder,
    $$AuditLogTableUpdateCompanionBuilder,
    (AuditLogData, BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>),
    AuditLogData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SekolahTableTableManager get sekolah =>
      $$SekolahTableTableManager(_db, _db.sekolah);
  $$TahunAjaranTableTableManager get tahunAjaran =>
      $$TahunAjaranTableTableManager(_db, _db.tahunAjaran);
  $$KelasTableTableManager get kelas =>
      $$KelasTableTableManager(_db, _db.kelas);
  $$KategoriBiayaTableTableManager get kategoriBiaya =>
      $$KategoriBiayaTableTableManager(_db, _db.kategoriBiaya);
  $$SiswaTableTableManager get siswa =>
      $$SiswaTableTableManager(_db, _db.siswa);
  $$TarifMasterTableTableManager get tarifMaster =>
      $$TarifMasterTableTableManager(_db, _db.tarifMaster);
  $$SkemaPembayaranSiswaTableTableManager get skemaPembayaranSiswa =>
      $$SkemaPembayaranSiswaTableTableManager(_db, _db.skemaPembayaranSiswa);
  $$TagihanSiswaTableTableManager get tagihanSiswa =>
      $$TagihanSiswaTableTableManager(_db, _db.tagihanSiswa);
  $$TagihanItemTableTableManager get tagihanItem =>
      $$TagihanItemTableTableManager(_db, _db.tagihanItem);
  $$PembayaranTransaksiTableTableManager get pembayaranTransaksi =>
      $$PembayaranTransaksiTableTableManager(_db, _db.pembayaranTransaksi);
  $$AlokasiPembayaranTableTableManager get alokasiPembayaran =>
      $$AlokasiPembayaranTableTableManager(_db, _db.alokasiPembayaran);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db, _db.auditLog);
}
