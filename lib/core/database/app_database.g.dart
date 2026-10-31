// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PharmacySettingsTableTable extends PharmacySettingsTable
    with TableInfo<$PharmacySettingsTableTable, PharmacySetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PharmacySettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pharmacyUidMeta = const VerificationMeta(
    'pharmacyUid',
  );
  @override
  late final GeneratedColumn<String> pharmacyUid = GeneratedColumn<String>(
    'pharmacy_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pharmacyNameMeta = const VerificationMeta(
    'pharmacyName',
  );
  @override
  late final GeneratedColumn<String> pharmacyName = GeneratedColumn<String>(
    'pharmacy_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseNumberMeta = const VerificationMeta(
    'licenseNumber',
  );
  @override
  late final GeneratedColumn<String> licenseNumber = GeneratedColumn<String>(
    'license_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactPhoneMeta = const VerificationMeta(
    'contactPhone',
  );
  @override
  late final GeneratedColumn<String> contactPhone = GeneratedColumn<String>(
    'contact_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mapPinUrlMeta = const VerificationMeta(
    'mapPinUrl',
  );
  @override
  late final GeneratedColumn<String> mapPinUrl = GeneratedColumn<String>(
    'map_pin_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencySymbolMeta = const VerificationMeta(
    'currencySymbol',
  );
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
    'currency_symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('৳'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $PharmacySettingsTableTable.$convertercreatedAt,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $PharmacySettingsTableTable.$converterupdatedAt,
      );
  @override
  List<GeneratedColumn> get $columns => [
    pharmacyUid,
    pharmacyName,
    licenseNumber,
    contactPhone,
    address,
    mapPinUrl,
    currencySymbol,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pharmacy_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<PharmacySetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pharmacy_uid')) {
      context.handle(
        _pharmacyUidMeta,
        pharmacyUid.isAcceptableOrUnknown(
          data['pharmacy_uid']!,
          _pharmacyUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pharmacyUidMeta);
    }
    if (data.containsKey('pharmacy_name')) {
      context.handle(
        _pharmacyNameMeta,
        pharmacyName.isAcceptableOrUnknown(
          data['pharmacy_name']!,
          _pharmacyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pharmacyNameMeta);
    }
    if (data.containsKey('license_number')) {
      context.handle(
        _licenseNumberMeta,
        licenseNumber.isAcceptableOrUnknown(
          data['license_number']!,
          _licenseNumberMeta,
        ),
      );
    }
    if (data.containsKey('contact_phone')) {
      context.handle(
        _contactPhoneMeta,
        contactPhone.isAcceptableOrUnknown(
          data['contact_phone']!,
          _contactPhoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contactPhoneMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('map_pin_url')) {
      context.handle(
        _mapPinUrlMeta,
        mapPinUrl.isAcceptableOrUnknown(data['map_pin_url']!, _mapPinUrlMeta),
      );
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
        _currencySymbolMeta,
        currencySymbol.isAcceptableOrUnknown(
          data['currency_symbol']!,
          _currencySymbolMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pharmacyUid};
  @override
  PharmacySetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PharmacySetting(
      pharmacyUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pharmacy_uid'],
      )!,
      pharmacyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pharmacy_name'],
      )!,
      licenseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_number'],
      ),
      contactPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_phone'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      mapPinUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}map_pin_url'],
      ),
      currencySymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_symbol'],
      )!,
      createdAt: $PharmacySettingsTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $PharmacySettingsTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $PharmacySettingsTableTable createAlias(String alias) {
    return $PharmacySettingsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const IsoDateTimeConverter();
}

class PharmacySetting extends DataClass implements Insertable<PharmacySetting> {
  final String pharmacyUid;
  final String pharmacyName;
  final String? licenseNumber;
  final String contactPhone;
  final String? address;
  final String? mapPinUrl;
  final String currencySymbol;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PharmacySetting({
    required this.pharmacyUid,
    required this.pharmacyName,
    this.licenseNumber,
    required this.contactPhone,
    this.address,
    this.mapPinUrl,
    required this.currencySymbol,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pharmacy_uid'] = Variable<String>(pharmacyUid);
    map['pharmacy_name'] = Variable<String>(pharmacyName);
    if (!nullToAbsent || licenseNumber != null) {
      map['license_number'] = Variable<String>(licenseNumber);
    }
    map['contact_phone'] = Variable<String>(contactPhone);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || mapPinUrl != null) {
      map['map_pin_url'] = Variable<String>(mapPinUrl);
    }
    map['currency_symbol'] = Variable<String>(currencySymbol);
    {
      map['created_at'] = Variable<String>(
        $PharmacySettingsTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $PharmacySettingsTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  PharmacySettingsTableCompanion toCompanion(bool nullToAbsent) {
    return PharmacySettingsTableCompanion(
      pharmacyUid: Value(pharmacyUid),
      pharmacyName: Value(pharmacyName),
      licenseNumber: licenseNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseNumber),
      contactPhone: Value(contactPhone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      mapPinUrl: mapPinUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mapPinUrl),
      currencySymbol: Value(currencySymbol),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PharmacySetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PharmacySetting(
      pharmacyUid: serializer.fromJson<String>(json['pharmacyUid']),
      pharmacyName: serializer.fromJson<String>(json['pharmacyName']),
      licenseNumber: serializer.fromJson<String?>(json['licenseNumber']),
      contactPhone: serializer.fromJson<String>(json['contactPhone']),
      address: serializer.fromJson<String?>(json['address']),
      mapPinUrl: serializer.fromJson<String?>(json['mapPinUrl']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pharmacyUid': serializer.toJson<String>(pharmacyUid),
      'pharmacyName': serializer.toJson<String>(pharmacyName),
      'licenseNumber': serializer.toJson<String?>(licenseNumber),
      'contactPhone': serializer.toJson<String>(contactPhone),
      'address': serializer.toJson<String?>(address),
      'mapPinUrl': serializer.toJson<String?>(mapPinUrl),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PharmacySetting copyWith({
    String? pharmacyUid,
    String? pharmacyName,
    Value<String?> licenseNumber = const Value.absent(),
    String? contactPhone,
    Value<String?> address = const Value.absent(),
    Value<String?> mapPinUrl = const Value.absent(),
    String? currencySymbol,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PharmacySetting(
    pharmacyUid: pharmacyUid ?? this.pharmacyUid,
    pharmacyName: pharmacyName ?? this.pharmacyName,
    licenseNumber: licenseNumber.present
        ? licenseNumber.value
        : this.licenseNumber,
    contactPhone: contactPhone ?? this.contactPhone,
    address: address.present ? address.value : this.address,
    mapPinUrl: mapPinUrl.present ? mapPinUrl.value : this.mapPinUrl,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PharmacySetting copyWithCompanion(PharmacySettingsTableCompanion data) {
    return PharmacySetting(
      pharmacyUid: data.pharmacyUid.present
          ? data.pharmacyUid.value
          : this.pharmacyUid,
      pharmacyName: data.pharmacyName.present
          ? data.pharmacyName.value
          : this.pharmacyName,
      licenseNumber: data.licenseNumber.present
          ? data.licenseNumber.value
          : this.licenseNumber,
      contactPhone: data.contactPhone.present
          ? data.contactPhone.value
          : this.contactPhone,
      address: data.address.present ? data.address.value : this.address,
      mapPinUrl: data.mapPinUrl.present ? data.mapPinUrl.value : this.mapPinUrl,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PharmacySetting(')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('pharmacyName: $pharmacyName, ')
          ..write('licenseNumber: $licenseNumber, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('address: $address, ')
          ..write('mapPinUrl: $mapPinUrl, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pharmacyUid,
    pharmacyName,
    licenseNumber,
    contactPhone,
    address,
    mapPinUrl,
    currencySymbol,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PharmacySetting &&
          other.pharmacyUid == this.pharmacyUid &&
          other.pharmacyName == this.pharmacyName &&
          other.licenseNumber == this.licenseNumber &&
          other.contactPhone == this.contactPhone &&
          other.address == this.address &&
          other.mapPinUrl == this.mapPinUrl &&
          other.currencySymbol == this.currencySymbol &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PharmacySettingsTableCompanion extends UpdateCompanion<PharmacySetting> {
  final Value<String> pharmacyUid;
  final Value<String> pharmacyName;
  final Value<String?> licenseNumber;
  final Value<String> contactPhone;
  final Value<String?> address;
  final Value<String?> mapPinUrl;
  final Value<String> currencySymbol;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PharmacySettingsTableCompanion({
    this.pharmacyUid = const Value.absent(),
    this.pharmacyName = const Value.absent(),
    this.licenseNumber = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.address = const Value.absent(),
    this.mapPinUrl = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PharmacySettingsTableCompanion.insert({
    required String pharmacyUid,
    required String pharmacyName,
    this.licenseNumber = const Value.absent(),
    required String contactPhone,
    this.address = const Value.absent(),
    this.mapPinUrl = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : pharmacyUid = Value(pharmacyUid),
       pharmacyName = Value(pharmacyName),
       contactPhone = Value(contactPhone),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PharmacySetting> custom({
    Expression<String>? pharmacyUid,
    Expression<String>? pharmacyName,
    Expression<String>? licenseNumber,
    Expression<String>? contactPhone,
    Expression<String>? address,
    Expression<String>? mapPinUrl,
    Expression<String>? currencySymbol,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pharmacyUid != null) 'pharmacy_uid': pharmacyUid,
      if (pharmacyName != null) 'pharmacy_name': pharmacyName,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (address != null) 'address': address,
      if (mapPinUrl != null) 'map_pin_url': mapPinUrl,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PharmacySettingsTableCompanion copyWith({
    Value<String>? pharmacyUid,
    Value<String>? pharmacyName,
    Value<String?>? licenseNumber,
    Value<String>? contactPhone,
    Value<String?>? address,
    Value<String?>? mapPinUrl,
    Value<String>? currencySymbol,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PharmacySettingsTableCompanion(
      pharmacyUid: pharmacyUid ?? this.pharmacyUid,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      mapPinUrl: mapPinUrl ?? this.mapPinUrl,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pharmacyUid.present) {
      map['pharmacy_uid'] = Variable<String>(pharmacyUid.value);
    }
    if (pharmacyName.present) {
      map['pharmacy_name'] = Variable<String>(pharmacyName.value);
    }
    if (licenseNumber.present) {
      map['license_number'] = Variable<String>(licenseNumber.value);
    }
    if (contactPhone.present) {
      map['contact_phone'] = Variable<String>(contactPhone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (mapPinUrl.present) {
      map['map_pin_url'] = Variable<String>(mapPinUrl.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $PharmacySettingsTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $PharmacySettingsTableTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PharmacySettingsTableCompanion(')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('pharmacyName: $pharmacyName, ')
          ..write('licenseNumber: $licenseNumber, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('address: $address, ')
          ..write('mapPinUrl: $mapPinUrl, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pharmacyUidMeta = const VerificationMeta(
    'pharmacyUid',
  );
  @override
  late final GeneratedColumn<String> pharmacyUid = GeneratedColumn<String>(
    'pharmacy_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pharmacy_settings (pharmacy_uid)',
    ),
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($UsersTableTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($UsersTableTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UsersTableTable.$converterdeletedAtn);
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pharmacyUid,
    fullName,
    username,
    passwordHash,
    role,
    phone,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pharmacy_uid')) {
      context.handle(
        _pharmacyUidMeta,
        pharmacyUid.isAcceptableOrUnknown(
          data['pharmacy_uid']!,
          _pharmacyUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pharmacyUidMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pharmacyUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pharmacy_uid'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: $UsersTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $UsersTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $UsersTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String pharmacyUid;
  final String fullName;
  final String username;
  final String passwordHash;
  final String role;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  const User({
    required this.id,
    required this.pharmacyUid,
    required this.fullName,
    required this.username,
    required this.passwordHash,
    required this.role,
    this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pharmacy_uid'] = Variable<String>(pharmacyUid);
    map['full_name'] = Variable<String>(fullName);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<String>(passwordHash);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['is_active'] = Variable<bool>(isActive);
    {
      map['created_at'] = Variable<String>(
        $UsersTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $UsersTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $UsersTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      pharmacyUid: Value(pharmacyUid),
      fullName: Value(fullName),
      username: Value(username),
      passwordHash: Value(passwordHash),
      role: Value(role),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      pharmacyUid: serializer.fromJson<String>(json['pharmacyUid']),
      fullName: serializer.fromJson<String>(json['fullName']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      role: serializer.fromJson<String>(json['role']),
      phone: serializer.fromJson<String?>(json['phone']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pharmacyUid': serializer.toJson<String>(pharmacyUid),
      'fullName': serializer.toJson<String>(fullName),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'role': serializer.toJson<String>(role),
      'phone': serializer.toJson<String?>(phone),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  User copyWith({
    String? id,
    String? pharmacyUid,
    String? fullName,
    String? username,
    String? passwordHash,
    String? role,
    Value<String?> phone = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => User(
    id: id ?? this.id,
    pharmacyUid: pharmacyUid ?? this.pharmacyUid,
    fullName: fullName ?? this.fullName,
    username: username ?? this.username,
    passwordHash: passwordHash ?? this.passwordHash,
    role: role ?? this.role,
    phone: phone.present ? phone.value : this.phone,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  User copyWithCompanion(UsersTableCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      pharmacyUid: data.pharmacyUid.present
          ? data.pharmacyUid.value
          : this.pharmacyUid,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      role: data.role.present ? data.role.value : this.role,
      phone: data.phone.present ? data.phone.value : this.phone,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('fullName: $fullName, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('role: $role, ')
          ..write('phone: $phone, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pharmacyUid,
    fullName,
    username,
    passwordHash,
    role,
    phone,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.pharmacyUid == this.pharmacyUid &&
          other.fullName == this.fullName &&
          other.username == this.username &&
          other.passwordHash == this.passwordHash &&
          other.role == this.role &&
          other.phone == this.phone &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class UsersTableCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> pharmacyUid;
  final Value<String> fullName;
  final Value<String> username;
  final Value<String> passwordHash;
  final Value<String> role;
  final Value<String?> phone;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.pharmacyUid = const Value.absent(),
    this.fullName = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.role = const Value.absent(),
    this.phone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersTableCompanion.insert({
    required String id,
    required String pharmacyUid,
    required String fullName,
    required String username,
    required String passwordHash,
    required String role,
    this.phone = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pharmacyUid = Value(pharmacyUid),
       fullName = Value(fullName),
       username = Value(username),
       passwordHash = Value(passwordHash),
       role = Value(role),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? pharmacyUid,
    Expression<String>? fullName,
    Expression<String>? username,
    Expression<String>? passwordHash,
    Expression<String>? role,
    Expression<String>? phone,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pharmacyUid != null) 'pharmacy_uid': pharmacyUid,
      if (fullName != null) 'full_name': fullName,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (role != null) 'role': role,
      if (phone != null) 'phone': phone,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? pharmacyUid,
    Value<String>? fullName,
    Value<String>? username,
    Value<String>? passwordHash,
    Value<String>? role,
    Value<String?>? phone,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return UsersTableCompanion(
      id: id ?? this.id,
      pharmacyUid: pharmacyUid ?? this.pharmacyUid,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pharmacyUid.present) {
      map['pharmacy_uid'] = Variable<String>(pharmacyUid.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $UsersTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $UsersTableTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $UsersTableTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('fullName: $fullName, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('role: $role, ')
          ..write('phone: $phone, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTableTable extends ProductsTable
    with TableInfo<$ProductsTableTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pharmacyUidMeta = const VerificationMeta(
    'pharmacyUid',
  );
  @override
  late final GeneratedColumn<String> pharmacyUid = GeneratedColumn<String>(
    'pharmacy_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pharmacy_settings (pharmacy_uid)',
    ),
  );
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genericNameMeta = const VerificationMeta(
    'genericName',
  );
  @override
  late final GeneratedColumn<String> genericName = GeneratedColumn<String>(
    'generic_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shelfLocationMeta = const VerificationMeta(
    'shelfLocation',
  );
  @override
  late final GeneratedColumn<String> shelfLocation = GeneratedColumn<String>(
    'shelf_location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Tablet'),
  );
  static const VerificationMeta _minStockAlertMeta = const VerificationMeta(
    'minStockAlert',
  );
  @override
  late final GeneratedColumn<int> minStockAlert = GeneratedColumn<int>(
    'min_stock_alert',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ProductsTableTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ProductsTableTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ProductsTableTable.$converterdeletedAtn);
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pharmacyUid,
    brandName,
    genericName,
    category,
    manufacturer,
    shelfLocation,
    unitType,
    minStockAlert,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pharmacy_uid')) {
      context.handle(
        _pharmacyUidMeta,
        pharmacyUid.isAcceptableOrUnknown(
          data['pharmacy_uid']!,
          _pharmacyUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pharmacyUidMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    } else if (isInserting) {
      context.missing(_brandNameMeta);
    }
    if (data.containsKey('generic_name')) {
      context.handle(
        _genericNameMeta,
        genericName.isAcceptableOrUnknown(
          data['generic_name']!,
          _genericNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_genericNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manufacturerMeta);
    }
    if (data.containsKey('shelf_location')) {
      context.handle(
        _shelfLocationMeta,
        shelfLocation.isAcceptableOrUnknown(
          data['shelf_location']!,
          _shelfLocationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shelfLocationMeta);
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    }
    if (data.containsKey('min_stock_alert')) {
      context.handle(
        _minStockAlertMeta,
        minStockAlert.isAcceptableOrUnknown(
          data['min_stock_alert']!,
          _minStockAlertMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pharmacyUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pharmacy_uid'],
      )!,
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      )!,
      genericName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generic_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      )!,
      shelfLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf_location'],
      )!,
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      minStockAlert: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_stock_alert'],
      )!,
      createdAt: $ProductsTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ProductsTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $ProductsTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ProductsTableTable createAlias(String alias) {
    return $ProductsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String pharmacyUid;
  final String brandName;
  final String genericName;
  final String category;
  final String manufacturer;
  final String shelfLocation;
  final String unitType;
  final int minStockAlert;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  const Product({
    required this.id,
    required this.pharmacyUid,
    required this.brandName,
    required this.genericName,
    required this.category,
    required this.manufacturer,
    required this.shelfLocation,
    required this.unitType,
    required this.minStockAlert,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pharmacy_uid'] = Variable<String>(pharmacyUid);
    map['brand_name'] = Variable<String>(brandName);
    map['generic_name'] = Variable<String>(genericName);
    map['category'] = Variable<String>(category);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['shelf_location'] = Variable<String>(shelfLocation);
    map['unit_type'] = Variable<String>(unitType);
    map['min_stock_alert'] = Variable<int>(minStockAlert);
    {
      map['created_at'] = Variable<String>(
        $ProductsTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $ProductsTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $ProductsTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ProductsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductsTableCompanion(
      id: Value(id),
      pharmacyUid: Value(pharmacyUid),
      brandName: Value(brandName),
      genericName: Value(genericName),
      category: Value(category),
      manufacturer: Value(manufacturer),
      shelfLocation: Value(shelfLocation),
      unitType: Value(unitType),
      minStockAlert: Value(minStockAlert),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      pharmacyUid: serializer.fromJson<String>(json['pharmacyUid']),
      brandName: serializer.fromJson<String>(json['brandName']),
      genericName: serializer.fromJson<String>(json['genericName']),
      category: serializer.fromJson<String>(json['category']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      shelfLocation: serializer.fromJson<String>(json['shelfLocation']),
      unitType: serializer.fromJson<String>(json['unitType']),
      minStockAlert: serializer.fromJson<int>(json['minStockAlert']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pharmacyUid': serializer.toJson<String>(pharmacyUid),
      'brandName': serializer.toJson<String>(brandName),
      'genericName': serializer.toJson<String>(genericName),
      'category': serializer.toJson<String>(category),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'shelfLocation': serializer.toJson<String>(shelfLocation),
      'unitType': serializer.toJson<String>(unitType),
      'minStockAlert': serializer.toJson<int>(minStockAlert),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Product copyWith({
    String? id,
    String? pharmacyUid,
    String? brandName,
    String? genericName,
    String? category,
    String? manufacturer,
    String? shelfLocation,
    String? unitType,
    int? minStockAlert,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => Product(
    id: id ?? this.id,
    pharmacyUid: pharmacyUid ?? this.pharmacyUid,
    brandName: brandName ?? this.brandName,
    genericName: genericName ?? this.genericName,
    category: category ?? this.category,
    manufacturer: manufacturer ?? this.manufacturer,
    shelfLocation: shelfLocation ?? this.shelfLocation,
    unitType: unitType ?? this.unitType,
    minStockAlert: minStockAlert ?? this.minStockAlert,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Product copyWithCompanion(ProductsTableCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      pharmacyUid: data.pharmacyUid.present
          ? data.pharmacyUid.value
          : this.pharmacyUid,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      genericName: data.genericName.present
          ? data.genericName.value
          : this.genericName,
      category: data.category.present ? data.category.value : this.category,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      shelfLocation: data.shelfLocation.present
          ? data.shelfLocation.value
          : this.shelfLocation,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      minStockAlert: data.minStockAlert.present
          ? data.minStockAlert.value
          : this.minStockAlert,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('brandName: $brandName, ')
          ..write('genericName: $genericName, ')
          ..write('category: $category, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('shelfLocation: $shelfLocation, ')
          ..write('unitType: $unitType, ')
          ..write('minStockAlert: $minStockAlert, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pharmacyUid,
    brandName,
    genericName,
    category,
    manufacturer,
    shelfLocation,
    unitType,
    minStockAlert,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.pharmacyUid == this.pharmacyUid &&
          other.brandName == this.brandName &&
          other.genericName == this.genericName &&
          other.category == this.category &&
          other.manufacturer == this.manufacturer &&
          other.shelfLocation == this.shelfLocation &&
          other.unitType == this.unitType &&
          other.minStockAlert == this.minStockAlert &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class ProductsTableCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> pharmacyUid;
  final Value<String> brandName;
  final Value<String> genericName;
  final Value<String> category;
  final Value<String> manufacturer;
  final Value<String> shelfLocation;
  final Value<String> unitType;
  final Value<int> minStockAlert;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ProductsTableCompanion({
    this.id = const Value.absent(),
    this.pharmacyUid = const Value.absent(),
    this.brandName = const Value.absent(),
    this.genericName = const Value.absent(),
    this.category = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.shelfLocation = const Value.absent(),
    this.unitType = const Value.absent(),
    this.minStockAlert = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsTableCompanion.insert({
    required String id,
    required String pharmacyUid,
    required String brandName,
    required String genericName,
    required String category,
    required String manufacturer,
    required String shelfLocation,
    this.unitType = const Value.absent(),
    this.minStockAlert = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pharmacyUid = Value(pharmacyUid),
       brandName = Value(brandName),
       genericName = Value(genericName),
       category = Value(category),
       manufacturer = Value(manufacturer),
       shelfLocation = Value(shelfLocation),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? pharmacyUid,
    Expression<String>? brandName,
    Expression<String>? genericName,
    Expression<String>? category,
    Expression<String>? manufacturer,
    Expression<String>? shelfLocation,
    Expression<String>? unitType,
    Expression<int>? minStockAlert,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pharmacyUid != null) 'pharmacy_uid': pharmacyUid,
      if (brandName != null) 'brand_name': brandName,
      if (genericName != null) 'generic_name': genericName,
      if (category != null) 'category': category,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (shelfLocation != null) 'shelf_location': shelfLocation,
      if (unitType != null) 'unit_type': unitType,
      if (minStockAlert != null) 'min_stock_alert': minStockAlert,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? pharmacyUid,
    Value<String>? brandName,
    Value<String>? genericName,
    Value<String>? category,
    Value<String>? manufacturer,
    Value<String>? shelfLocation,
    Value<String>? unitType,
    Value<int>? minStockAlert,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ProductsTableCompanion(
      id: id ?? this.id,
      pharmacyUid: pharmacyUid ?? this.pharmacyUid,
      brandName: brandName ?? this.brandName,
      genericName: genericName ?? this.genericName,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      unitType: unitType ?? this.unitType,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pharmacyUid.present) {
      map['pharmacy_uid'] = Variable<String>(pharmacyUid.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (genericName.present) {
      map['generic_name'] = Variable<String>(genericName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (shelfLocation.present) {
      map['shelf_location'] = Variable<String>(shelfLocation.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (minStockAlert.present) {
      map['min_stock_alert'] = Variable<int>(minStockAlert.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $ProductsTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $ProductsTableTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $ProductsTableTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableCompanion(')
          ..write('id: $id, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('brandName: $brandName, ')
          ..write('genericName: $genericName, ')
          ..write('category: $category, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('shelfLocation: $shelfLocation, ')
          ..write('unitType: $unitType, ')
          ..write('minStockAlert: $minStockAlert, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductBatchesTableTable extends ProductBatchesTable
    with TableInfo<$ProductBatchesTableTable, ProductBatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductBatchesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pharmacyUidMeta = const VerificationMeta(
    'pharmacyUid',
  );
  @override
  late final GeneratedColumn<String> pharmacyUid = GeneratedColumn<String>(
    'pharmacy_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pharmacy_settings (pharmacy_uid)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierNameMeta = const VerificationMeta(
    'supplierName',
  );
  @override
  late final GeneratedColumn<String> supplierName = GeneratedColumn<String>(
    'supplier_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellingPriceMeta = const VerificationMeta(
    'sellingPrice',
  );
  @override
  late final GeneratedColumn<double> sellingPrice = GeneratedColumn<double>(
    'selling_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialQuantityMeta = const VerificationMeta(
    'initialQuantity',
  );
  @override
  late final GeneratedColumn<int> initialQuantity = GeneratedColumn<int>(
    'initial_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentStockMeta = const VerificationMeta(
    'currentStock',
  );
  @override
  late final GeneratedColumn<int> currentStock = GeneratedColumn<int>(
    'current_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> expiryDate =
      GeneratedColumn<String>(
        'expiry_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ProductBatchesTableTable.$converterexpiryDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ProductBatchesTableTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ProductBatchesTableTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $ProductBatchesTableTable.$converterdeletedAtn,
      );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pharmacyUid,
    productId,
    batchNumber,
    supplierName,
    purchasePrice,
    sellingPrice,
    initialQuantity,
    currentStock,
    expiryDate,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductBatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pharmacy_uid')) {
      context.handle(
        _pharmacyUidMeta,
        pharmacyUid.isAcceptableOrUnknown(
          data['pharmacy_uid']!,
          _pharmacyUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pharmacyUidMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batchNumberMeta);
    }
    if (data.containsKey('supplier_name')) {
      context.handle(
        _supplierNameMeta,
        supplierName.isAcceptableOrUnknown(
          data['supplier_name']!,
          _supplierNameMeta,
        ),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('selling_price')) {
      context.handle(
        _sellingPriceMeta,
        sellingPrice.isAcceptableOrUnknown(
          data['selling_price']!,
          _sellingPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingPriceMeta);
    }
    if (data.containsKey('initial_quantity')) {
      context.handle(
        _initialQuantityMeta,
        initialQuantity.isAcceptableOrUnknown(
          data['initial_quantity']!,
          _initialQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialQuantityMeta);
    }
    if (data.containsKey('current_stock')) {
      context.handle(
        _currentStockMeta,
        currentStock.isAcceptableOrUnknown(
          data['current_stock']!,
          _currentStockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentStockMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductBatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductBatch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pharmacyUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pharmacy_uid'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      )!,
      supplierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_name'],
      ),
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      sellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_price'],
      )!,
      initialQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_quantity'],
      )!,
      currentStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_stock'],
      )!,
      expiryDate: $ProductBatchesTableTable.$converterexpiryDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expiry_date'],
        )!,
      ),
      createdAt: $ProductBatchesTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ProductBatchesTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $ProductBatchesTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ProductBatchesTableTable createAlias(String alias) {
    return $ProductBatchesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterexpiryDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class ProductBatch extends DataClass implements Insertable<ProductBatch> {
  final String id;
  final String pharmacyUid;
  final String productId;
  final String batchNumber;
  final String? supplierName;
  final double purchasePrice;
  final double sellingPrice;
  final int initialQuantity;
  final int currentStock;
  final DateTime expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  const ProductBatch({
    required this.id,
    required this.pharmacyUid,
    required this.productId,
    required this.batchNumber,
    this.supplierName,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.initialQuantity,
    required this.currentStock,
    required this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pharmacy_uid'] = Variable<String>(pharmacyUid);
    map['product_id'] = Variable<String>(productId);
    map['batch_number'] = Variable<String>(batchNumber);
    if (!nullToAbsent || supplierName != null) {
      map['supplier_name'] = Variable<String>(supplierName);
    }
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['selling_price'] = Variable<double>(sellingPrice);
    map['initial_quantity'] = Variable<int>(initialQuantity);
    map['current_stock'] = Variable<int>(currentStock);
    {
      map['expiry_date'] = Variable<String>(
        $ProductBatchesTableTable.$converterexpiryDate.toSql(expiryDate),
      );
    }
    {
      map['created_at'] = Variable<String>(
        $ProductBatchesTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $ProductBatchesTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $ProductBatchesTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ProductBatchesTableCompanion toCompanion(bool nullToAbsent) {
    return ProductBatchesTableCompanion(
      id: Value(id),
      pharmacyUid: Value(pharmacyUid),
      productId: Value(productId),
      batchNumber: Value(batchNumber),
      supplierName: supplierName == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierName),
      purchasePrice: Value(purchasePrice),
      sellingPrice: Value(sellingPrice),
      initialQuantity: Value(initialQuantity),
      currentStock: Value(currentStock),
      expiryDate: Value(expiryDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ProductBatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductBatch(
      id: serializer.fromJson<String>(json['id']),
      pharmacyUid: serializer.fromJson<String>(json['pharmacyUid']),
      productId: serializer.fromJson<String>(json['productId']),
      batchNumber: serializer.fromJson<String>(json['batchNumber']),
      supplierName: serializer.fromJson<String?>(json['supplierName']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      sellingPrice: serializer.fromJson<double>(json['sellingPrice']),
      initialQuantity: serializer.fromJson<int>(json['initialQuantity']),
      currentStock: serializer.fromJson<int>(json['currentStock']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pharmacyUid': serializer.toJson<String>(pharmacyUid),
      'productId': serializer.toJson<String>(productId),
      'batchNumber': serializer.toJson<String>(batchNumber),
      'supplierName': serializer.toJson<String?>(supplierName),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'sellingPrice': serializer.toJson<double>(sellingPrice),
      'initialQuantity': serializer.toJson<int>(initialQuantity),
      'currentStock': serializer.toJson<int>(currentStock),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ProductBatch copyWith({
    String? id,
    String? pharmacyUid,
    String? productId,
    String? batchNumber,
    Value<String?> supplierName = const Value.absent(),
    double? purchasePrice,
    double? sellingPrice,
    int? initialQuantity,
    int? currentStock,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => ProductBatch(
    id: id ?? this.id,
    pharmacyUid: pharmacyUid ?? this.pharmacyUid,
    productId: productId ?? this.productId,
    batchNumber: batchNumber ?? this.batchNumber,
    supplierName: supplierName.present ? supplierName.value : this.supplierName,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    sellingPrice: sellingPrice ?? this.sellingPrice,
    initialQuantity: initialQuantity ?? this.initialQuantity,
    currentStock: currentStock ?? this.currentStock,
    expiryDate: expiryDate ?? this.expiryDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ProductBatch copyWithCompanion(ProductBatchesTableCompanion data) {
    return ProductBatch(
      id: data.id.present ? data.id.value : this.id,
      pharmacyUid: data.pharmacyUid.present
          ? data.pharmacyUid.value
          : this.pharmacyUid,
      productId: data.productId.present ? data.productId.value : this.productId,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      supplierName: data.supplierName.present
          ? data.supplierName.value
          : this.supplierName,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
      initialQuantity: data.initialQuantity.present
          ? data.initialQuantity.value
          : this.initialQuantity,
      currentStock: data.currentStock.present
          ? data.currentStock.value
          : this.currentStock,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductBatch(')
          ..write('id: $id, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('productId: $productId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('supplierName: $supplierName, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('currentStock: $currentStock, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pharmacyUid,
    productId,
    batchNumber,
    supplierName,
    purchasePrice,
    sellingPrice,
    initialQuantity,
    currentStock,
    expiryDate,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductBatch &&
          other.id == this.id &&
          other.pharmacyUid == this.pharmacyUid &&
          other.productId == this.productId &&
          other.batchNumber == this.batchNumber &&
          other.supplierName == this.supplierName &&
          other.purchasePrice == this.purchasePrice &&
          other.sellingPrice == this.sellingPrice &&
          other.initialQuantity == this.initialQuantity &&
          other.currentStock == this.currentStock &&
          other.expiryDate == this.expiryDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class ProductBatchesTableCompanion extends UpdateCompanion<ProductBatch> {
  final Value<String> id;
  final Value<String> pharmacyUid;
  final Value<String> productId;
  final Value<String> batchNumber;
  final Value<String?> supplierName;
  final Value<double> purchasePrice;
  final Value<double> sellingPrice;
  final Value<int> initialQuantity;
  final Value<int> currentStock;
  final Value<DateTime> expiryDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ProductBatchesTableCompanion({
    this.id = const Value.absent(),
    this.pharmacyUid = const Value.absent(),
    this.productId = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.initialQuantity = const Value.absent(),
    this.currentStock = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductBatchesTableCompanion.insert({
    required String id,
    required String pharmacyUid,
    required String productId,
    required String batchNumber,
    this.supplierName = const Value.absent(),
    required double purchasePrice,
    required double sellingPrice,
    required int initialQuantity,
    required int currentStock,
    required DateTime expiryDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pharmacyUid = Value(pharmacyUid),
       productId = Value(productId),
       batchNumber = Value(batchNumber),
       purchasePrice = Value(purchasePrice),
       sellingPrice = Value(sellingPrice),
       initialQuantity = Value(initialQuantity),
       currentStock = Value(currentStock),
       expiryDate = Value(expiryDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProductBatch> custom({
    Expression<String>? id,
    Expression<String>? pharmacyUid,
    Expression<String>? productId,
    Expression<String>? batchNumber,
    Expression<String>? supplierName,
    Expression<double>? purchasePrice,
    Expression<double>? sellingPrice,
    Expression<int>? initialQuantity,
    Expression<int>? currentStock,
    Expression<String>? expiryDate,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pharmacyUid != null) 'pharmacy_uid': pharmacyUid,
      if (productId != null) 'product_id': productId,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (supplierName != null) 'supplier_name': supplierName,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (initialQuantity != null) 'initial_quantity': initialQuantity,
      if (currentStock != null) 'current_stock': currentStock,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductBatchesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? pharmacyUid,
    Value<String>? productId,
    Value<String>? batchNumber,
    Value<String?>? supplierName,
    Value<double>? purchasePrice,
    Value<double>? sellingPrice,
    Value<int>? initialQuantity,
    Value<int>? currentStock,
    Value<DateTime>? expiryDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ProductBatchesTableCompanion(
      id: id ?? this.id,
      pharmacyUid: pharmacyUid ?? this.pharmacyUid,
      productId: productId ?? this.productId,
      batchNumber: batchNumber ?? this.batchNumber,
      supplierName: supplierName ?? this.supplierName,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      currentStock: currentStock ?? this.currentStock,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pharmacyUid.present) {
      map['pharmacy_uid'] = Variable<String>(pharmacyUid.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (supplierName.present) {
      map['supplier_name'] = Variable<String>(supplierName.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<double>(sellingPrice.value);
    }
    if (initialQuantity.present) {
      map['initial_quantity'] = Variable<int>(initialQuantity.value);
    }
    if (currentStock.present) {
      map['current_stock'] = Variable<int>(currentStock.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<String>(
        $ProductBatchesTableTable.$converterexpiryDate.toSql(expiryDate.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $ProductBatchesTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $ProductBatchesTableTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $ProductBatchesTableTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductBatchesTableCompanion(')
          ..write('id: $id, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('productId: $productId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('supplierName: $supplierName, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('currentStock: $currentStock, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTableTable extends SalesTable
    with TableInfo<$SalesTableTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pharmacyUidMeta = const VerificationMeta(
    'pharmacyUid',
  );
  @override
  late final GeneratedColumn<String> pharmacyUid = GeneratedColumn<String>(
    'pharmacy_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pharmacy_settings (pharmacy_uid)',
    ),
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _cashierUserIdMeta = const VerificationMeta(
    'cashierUserId',
  );
  @override
  late final GeneratedColumn<String> cashierUserId = GeneratedColumn<String>(
    'cashier_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Walk-in Customer'),
  );
  static const VerificationMeta _customerPhoneMeta = const VerificationMeta(
    'customerPhone',
  );
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
    'customer_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalPayableMeta = const VerificationMeta(
    'totalPayable',
  );
  @override
  late final GeneratedColumn<double> totalPayable = GeneratedColumn<double>(
    'total_payable',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountTenderedMeta = const VerificationMeta(
    'amountTendered',
  );
  @override
  late final GeneratedColumn<double> amountTendered = GeneratedColumn<double>(
    'amount_tendered',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeReturnedMeta = const VerificationMeta(
    'changeReturned',
  );
  @override
  late final GeneratedColumn<double> changeReturned = GeneratedColumn<double>(
    'change_returned',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCostPriceMeta = const VerificationMeta(
    'totalCostPrice',
  );
  @override
  late final GeneratedColumn<double> totalCostPrice = GeneratedColumn<double>(
    'total_cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossProfitMeta = const VerificationMeta(
    'grossProfit',
  );
  @override
  late final GeneratedColumn<double> grossProfit = GeneratedColumn<double>(
    'gross_profit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SalesTableTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SalesTableTable.$converterdeletedAtn);
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pharmacyUid,
    invoiceNumber,
    cashierUserId,
    customerName,
    customerPhone,
    subtotal,
    discountAmount,
    taxAmount,
    totalPayable,
    amountTendered,
    changeReturned,
    paymentMethod,
    totalCostPrice,
    grossProfit,
    createdAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pharmacy_uid')) {
      context.handle(
        _pharmacyUidMeta,
        pharmacyUid.isAcceptableOrUnknown(
          data['pharmacy_uid']!,
          _pharmacyUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pharmacyUidMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('cashier_user_id')) {
      context.handle(
        _cashierUserIdMeta,
        cashierUserId.isAcceptableOrUnknown(
          data['cashier_user_id']!,
          _cashierUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashierUserIdMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
        _customerPhoneMeta,
        customerPhone.isAcceptableOrUnknown(
          data['customer_phone']!,
          _customerPhoneMeta,
        ),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    }
    if (data.containsKey('total_payable')) {
      context.handle(
        _totalPayableMeta,
        totalPayable.isAcceptableOrUnknown(
          data['total_payable']!,
          _totalPayableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPayableMeta);
    }
    if (data.containsKey('amount_tendered')) {
      context.handle(
        _amountTenderedMeta,
        amountTendered.isAcceptableOrUnknown(
          data['amount_tendered']!,
          _amountTenderedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountTenderedMeta);
    }
    if (data.containsKey('change_returned')) {
      context.handle(
        _changeReturnedMeta,
        changeReturned.isAcceptableOrUnknown(
          data['change_returned']!,
          _changeReturnedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changeReturnedMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('total_cost_price')) {
      context.handle(
        _totalCostPriceMeta,
        totalCostPrice.isAcceptableOrUnknown(
          data['total_cost_price']!,
          _totalCostPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalCostPriceMeta);
    }
    if (data.containsKey('gross_profit')) {
      context.handle(
        _grossProfitMeta,
        grossProfit.isAcceptableOrUnknown(
          data['gross_profit']!,
          _grossProfitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossProfitMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pharmacyUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pharmacy_uid'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      )!,
      cashierUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_user_id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      customerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_phone'],
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
      totalPayable: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_payable'],
      )!,
      amountTendered: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_tendered'],
      )!,
      changeReturned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}change_returned'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      totalCostPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cost_price'],
      )!,
      grossProfit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gross_profit'],
      )!,
      createdAt: $SalesTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      deletedAt: $SalesTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $SalesTableTable createAlias(String alias) {
    return $SalesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class Sale extends DataClass implements Insertable<Sale> {
  final String id;
  final String pharmacyUid;
  final String invoiceNumber;
  final String cashierUserId;
  final String customerName;
  final String? customerPhone;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalPayable;
  final double amountTendered;
  final double changeReturned;
  final String paymentMethod;
  final double totalCostPrice;
  final double grossProfit;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String syncStatus;
  const Sale({
    required this.id,
    required this.pharmacyUid,
    required this.invoiceNumber,
    required this.cashierUserId,
    required this.customerName,
    this.customerPhone,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalPayable,
    required this.amountTendered,
    required this.changeReturned,
    required this.paymentMethod,
    required this.totalCostPrice,
    required this.grossProfit,
    required this.createdAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pharmacy_uid'] = Variable<String>(pharmacyUid);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['cashier_user_id'] = Variable<String>(cashierUserId);
    map['customer_name'] = Variable<String>(customerName);
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['total_payable'] = Variable<double>(totalPayable);
    map['amount_tendered'] = Variable<double>(amountTendered);
    map['change_returned'] = Variable<double>(changeReturned);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['total_cost_price'] = Variable<double>(totalCostPrice);
    map['gross_profit'] = Variable<double>(grossProfit);
    {
      map['created_at'] = Variable<String>(
        $SalesTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $SalesTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SalesTableCompanion toCompanion(bool nullToAbsent) {
    return SalesTableCompanion(
      id: Value(id),
      pharmacyUid: Value(pharmacyUid),
      invoiceNumber: Value(invoiceNumber),
      cashierUserId: Value(cashierUserId),
      customerName: Value(customerName),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      subtotal: Value(subtotal),
      discountAmount: Value(discountAmount),
      taxAmount: Value(taxAmount),
      totalPayable: Value(totalPayable),
      amountTendered: Value(amountTendered),
      changeReturned: Value(changeReturned),
      paymentMethod: Value(paymentMethod),
      totalCostPrice: Value(totalCostPrice),
      grossProfit: Value(grossProfit),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<String>(json['id']),
      pharmacyUid: serializer.fromJson<String>(json['pharmacyUid']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      cashierUserId: serializer.fromJson<String>(json['cashierUserId']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      totalPayable: serializer.fromJson<double>(json['totalPayable']),
      amountTendered: serializer.fromJson<double>(json['amountTendered']),
      changeReturned: serializer.fromJson<double>(json['changeReturned']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      totalCostPrice: serializer.fromJson<double>(json['totalCostPrice']),
      grossProfit: serializer.fromJson<double>(json['grossProfit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pharmacyUid': serializer.toJson<String>(pharmacyUid),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'cashierUserId': serializer.toJson<String>(cashierUserId),
      'customerName': serializer.toJson<String>(customerName),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'subtotal': serializer.toJson<double>(subtotal),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'totalPayable': serializer.toJson<double>(totalPayable),
      'amountTendered': serializer.toJson<double>(amountTendered),
      'changeReturned': serializer.toJson<double>(changeReturned),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'totalCostPrice': serializer.toJson<double>(totalCostPrice),
      'grossProfit': serializer.toJson<double>(grossProfit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Sale copyWith({
    String? id,
    String? pharmacyUid,
    String? invoiceNumber,
    String? cashierUserId,
    String? customerName,
    Value<String?> customerPhone = const Value.absent(),
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? totalPayable,
    double? amountTendered,
    double? changeReturned,
    String? paymentMethod,
    double? totalCostPrice,
    double? grossProfit,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => Sale(
    id: id ?? this.id,
    pharmacyUid: pharmacyUid ?? this.pharmacyUid,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    cashierUserId: cashierUserId ?? this.cashierUserId,
    customerName: customerName ?? this.customerName,
    customerPhone: customerPhone.present
        ? customerPhone.value
        : this.customerPhone,
    subtotal: subtotal ?? this.subtotal,
    discountAmount: discountAmount ?? this.discountAmount,
    taxAmount: taxAmount ?? this.taxAmount,
    totalPayable: totalPayable ?? this.totalPayable,
    amountTendered: amountTendered ?? this.amountTendered,
    changeReturned: changeReturned ?? this.changeReturned,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    totalCostPrice: totalCostPrice ?? this.totalCostPrice,
    grossProfit: grossProfit ?? this.grossProfit,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Sale copyWithCompanion(SalesTableCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      pharmacyUid: data.pharmacyUid.present
          ? data.pharmacyUid.value
          : this.pharmacyUid,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      cashierUserId: data.cashierUserId.present
          ? data.cashierUserId.value
          : this.cashierUserId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      totalPayable: data.totalPayable.present
          ? data.totalPayable.value
          : this.totalPayable,
      amountTendered: data.amountTendered.present
          ? data.amountTendered.value
          : this.amountTendered,
      changeReturned: data.changeReturned.present
          ? data.changeReturned.value
          : this.changeReturned,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      totalCostPrice: data.totalCostPrice.present
          ? data.totalCostPrice.value
          : this.totalCostPrice,
      grossProfit: data.grossProfit.present
          ? data.grossProfit.value
          : this.grossProfit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('cashierUserId: $cashierUserId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('totalPayable: $totalPayable, ')
          ..write('amountTendered: $amountTendered, ')
          ..write('changeReturned: $changeReturned, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('totalCostPrice: $totalCostPrice, ')
          ..write('grossProfit: $grossProfit, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pharmacyUid,
    invoiceNumber,
    cashierUserId,
    customerName,
    customerPhone,
    subtotal,
    discountAmount,
    taxAmount,
    totalPayable,
    amountTendered,
    changeReturned,
    paymentMethod,
    totalCostPrice,
    grossProfit,
    createdAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.pharmacyUid == this.pharmacyUid &&
          other.invoiceNumber == this.invoiceNumber &&
          other.cashierUserId == this.cashierUserId &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.subtotal == this.subtotal &&
          other.discountAmount == this.discountAmount &&
          other.taxAmount == this.taxAmount &&
          other.totalPayable == this.totalPayable &&
          other.amountTendered == this.amountTendered &&
          other.changeReturned == this.changeReturned &&
          other.paymentMethod == this.paymentMethod &&
          other.totalCostPrice == this.totalCostPrice &&
          other.grossProfit == this.grossProfit &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class SalesTableCompanion extends UpdateCompanion<Sale> {
  final Value<String> id;
  final Value<String> pharmacyUid;
  final Value<String> invoiceNumber;
  final Value<String> cashierUserId;
  final Value<String> customerName;
  final Value<String?> customerPhone;
  final Value<double> subtotal;
  final Value<double> discountAmount;
  final Value<double> taxAmount;
  final Value<double> totalPayable;
  final Value<double> amountTendered;
  final Value<double> changeReturned;
  final Value<String> paymentMethod;
  final Value<double> totalCostPrice;
  final Value<double> grossProfit;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const SalesTableCompanion({
    this.id = const Value.absent(),
    this.pharmacyUid = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.cashierUserId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.totalPayable = const Value.absent(),
    this.amountTendered = const Value.absent(),
    this.changeReturned = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.totalCostPrice = const Value.absent(),
    this.grossProfit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesTableCompanion.insert({
    required String id,
    required String pharmacyUid,
    required String invoiceNumber,
    required String cashierUserId,
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    required double subtotal,
    this.discountAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    required double totalPayable,
    required double amountTendered,
    required double changeReturned,
    required String paymentMethod,
    required double totalCostPrice,
    required double grossProfit,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pharmacyUid = Value(pharmacyUid),
       invoiceNumber = Value(invoiceNumber),
       cashierUserId = Value(cashierUserId),
       subtotal = Value(subtotal),
       totalPayable = Value(totalPayable),
       amountTendered = Value(amountTendered),
       changeReturned = Value(changeReturned),
       paymentMethod = Value(paymentMethod),
       totalCostPrice = Value(totalCostPrice),
       grossProfit = Value(grossProfit),
       createdAt = Value(createdAt);
  static Insertable<Sale> custom({
    Expression<String>? id,
    Expression<String>? pharmacyUid,
    Expression<String>? invoiceNumber,
    Expression<String>? cashierUserId,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<double>? subtotal,
    Expression<double>? discountAmount,
    Expression<double>? taxAmount,
    Expression<double>? totalPayable,
    Expression<double>? amountTendered,
    Expression<double>? changeReturned,
    Expression<String>? paymentMethod,
    Expression<double>? totalCostPrice,
    Expression<double>? grossProfit,
    Expression<String>? createdAt,
    Expression<String>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pharmacyUid != null) 'pharmacy_uid': pharmacyUid,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (cashierUserId != null) 'cashier_user_id': cashierUserId,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (subtotal != null) 'subtotal': subtotal,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (totalPayable != null) 'total_payable': totalPayable,
      if (amountTendered != null) 'amount_tendered': amountTendered,
      if (changeReturned != null) 'change_returned': changeReturned,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (totalCostPrice != null) 'total_cost_price': totalCostPrice,
      if (grossProfit != null) 'gross_profit': grossProfit,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? pharmacyUid,
    Value<String>? invoiceNumber,
    Value<String>? cashierUserId,
    Value<String>? customerName,
    Value<String?>? customerPhone,
    Value<double>? subtotal,
    Value<double>? discountAmount,
    Value<double>? taxAmount,
    Value<double>? totalPayable,
    Value<double>? amountTendered,
    Value<double>? changeReturned,
    Value<String>? paymentMethod,
    Value<double>? totalCostPrice,
    Value<double>? grossProfit,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return SalesTableCompanion(
      id: id ?? this.id,
      pharmacyUid: pharmacyUid ?? this.pharmacyUid,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      cashierUserId: cashierUserId ?? this.cashierUserId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalPayable: totalPayable ?? this.totalPayable,
      amountTendered: amountTendered ?? this.amountTendered,
      changeReturned: changeReturned ?? this.changeReturned,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalCostPrice: totalCostPrice ?? this.totalCostPrice,
      grossProfit: grossProfit ?? this.grossProfit,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pharmacyUid.present) {
      map['pharmacy_uid'] = Variable<String>(pharmacyUid.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (cashierUserId.present) {
      map['cashier_user_id'] = Variable<String>(cashierUserId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (totalPayable.present) {
      map['total_payable'] = Variable<double>(totalPayable.value);
    }
    if (amountTendered.present) {
      map['amount_tendered'] = Variable<double>(amountTendered.value);
    }
    if (changeReturned.present) {
      map['change_returned'] = Variable<double>(changeReturned.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (totalCostPrice.present) {
      map['total_cost_price'] = Variable<double>(totalCostPrice.value);
    }
    if (grossProfit.present) {
      map['gross_profit'] = Variable<double>(grossProfit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $SalesTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $SalesTableTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesTableCompanion(')
          ..write('id: $id, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('cashierUserId: $cashierUserId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('totalPayable: $totalPayable, ')
          ..write('amountTendered: $amountTendered, ')
          ..write('changeReturned: $changeReturned, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('totalCostPrice: $totalCostPrice, ')
          ..write('grossProfit: $grossProfit, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTableTable extends SaleItemsTable
    with TableInfo<$SaleItemsTableTable, SaleItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pharmacyUidMeta = const VerificationMeta(
    'pharmacyUid',
  );
  @override
  late final GeneratedColumn<String> pharmacyUid = GeneratedColumn<String>(
    'pharmacy_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pharmacy_settings (pharmacy_uid)',
    ),
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES product_batches (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostPriceMeta = const VerificationMeta(
    'unitCostPrice',
  );
  @override
  late final GeneratedColumn<double> unitCostPrice = GeneratedColumn<double>(
    'unit_cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitSellingPriceMeta = const VerificationMeta(
    'unitSellingPrice',
  );
  @override
  late final GeneratedColumn<double> unitSellingPrice = GeneratedColumn<double>(
    'unit_selling_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTotalMeta = const VerificationMeta(
    'lineTotal',
  );
  @override
  late final GeneratedColumn<double> lineTotal = GeneratedColumn<double>(
    'line_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SaleItemsTableTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SaleItemsTableTable.$converterdeletedAtn);
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pharmacyUid,
    saleId,
    productId,
    batchId,
    quantity,
    unitCostPrice,
    unitSellingPrice,
    lineTotal,
    createdAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pharmacy_uid')) {
      context.handle(
        _pharmacyUidMeta,
        pharmacyUid.isAcceptableOrUnknown(
          data['pharmacy_uid']!,
          _pharmacyUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pharmacyUidMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_cost_price')) {
      context.handle(
        _unitCostPriceMeta,
        unitCostPrice.isAcceptableOrUnknown(
          data['unit_cost_price']!,
          _unitCostPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostPriceMeta);
    }
    if (data.containsKey('unit_selling_price')) {
      context.handle(
        _unitSellingPriceMeta,
        unitSellingPrice.isAcceptableOrUnknown(
          data['unit_selling_price']!,
          _unitSellingPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitSellingPriceMeta);
    }
    if (data.containsKey('line_total')) {
      context.handle(
        _lineTotalMeta,
        lineTotal.isAcceptableOrUnknown(data['line_total']!, _lineTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_lineTotalMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pharmacyUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pharmacy_uid'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitCostPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_cost_price'],
      )!,
      unitSellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_selling_price'],
      )!,
      lineTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}line_total'],
      )!,
      createdAt: $SaleItemsTableTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      deletedAt: $SaleItemsTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $SaleItemsTableTable createAlias(String alias) {
    return $SaleItemsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class SaleItem extends DataClass implements Insertable<SaleItem> {
  final String id;
  final String pharmacyUid;
  final String saleId;
  final String productId;
  final String batchId;
  final int quantity;
  final double unitCostPrice;
  final double unitSellingPrice;
  final double lineTotal;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String syncStatus;
  const SaleItem({
    required this.id,
    required this.pharmacyUid,
    required this.saleId,
    required this.productId,
    required this.batchId,
    required this.quantity,
    required this.unitCostPrice,
    required this.unitSellingPrice,
    required this.lineTotal,
    required this.createdAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pharmacy_uid'] = Variable<String>(pharmacyUid);
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['batch_id'] = Variable<String>(batchId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_cost_price'] = Variable<double>(unitCostPrice);
    map['unit_selling_price'] = Variable<double>(unitSellingPrice);
    map['line_total'] = Variable<double>(lineTotal);
    {
      map['created_at'] = Variable<String>(
        $SaleItemsTableTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $SaleItemsTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SaleItemsTableCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsTableCompanion(
      id: Value(id),
      pharmacyUid: Value(pharmacyUid),
      saleId: Value(saleId),
      productId: Value(productId),
      batchId: Value(batchId),
      quantity: Value(quantity),
      unitCostPrice: Value(unitCostPrice),
      unitSellingPrice: Value(unitSellingPrice),
      lineTotal: Value(lineTotal),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory SaleItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItem(
      id: serializer.fromJson<String>(json['id']),
      pharmacyUid: serializer.fromJson<String>(json['pharmacyUid']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitCostPrice: serializer.fromJson<double>(json['unitCostPrice']),
      unitSellingPrice: serializer.fromJson<double>(json['unitSellingPrice']),
      lineTotal: serializer.fromJson<double>(json['lineTotal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pharmacyUid': serializer.toJson<String>(pharmacyUid),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'batchId': serializer.toJson<String>(batchId),
      'quantity': serializer.toJson<int>(quantity),
      'unitCostPrice': serializer.toJson<double>(unitCostPrice),
      'unitSellingPrice': serializer.toJson<double>(unitSellingPrice),
      'lineTotal': serializer.toJson<double>(lineTotal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  SaleItem copyWith({
    String? id,
    String? pharmacyUid,
    String? saleId,
    String? productId,
    String? batchId,
    int? quantity,
    double? unitCostPrice,
    double? unitSellingPrice,
    double? lineTotal,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => SaleItem(
    id: id ?? this.id,
    pharmacyUid: pharmacyUid ?? this.pharmacyUid,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    batchId: batchId ?? this.batchId,
    quantity: quantity ?? this.quantity,
    unitCostPrice: unitCostPrice ?? this.unitCostPrice,
    unitSellingPrice: unitSellingPrice ?? this.unitSellingPrice,
    lineTotal: lineTotal ?? this.lineTotal,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  SaleItem copyWithCompanion(SaleItemsTableCompanion data) {
    return SaleItem(
      id: data.id.present ? data.id.value : this.id,
      pharmacyUid: data.pharmacyUid.present
          ? data.pharmacyUid.value
          : this.pharmacyUid,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCostPrice: data.unitCostPrice.present
          ? data.unitCostPrice.value
          : this.unitCostPrice,
      unitSellingPrice: data.unitSellingPrice.present
          ? data.unitSellingPrice.value
          : this.unitSellingPrice,
      lineTotal: data.lineTotal.present ? data.lineTotal.value : this.lineTotal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItem(')
          ..write('id: $id, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('batchId: $batchId, ')
          ..write('quantity: $quantity, ')
          ..write('unitCostPrice: $unitCostPrice, ')
          ..write('unitSellingPrice: $unitSellingPrice, ')
          ..write('lineTotal: $lineTotal, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pharmacyUid,
    saleId,
    productId,
    batchId,
    quantity,
    unitCostPrice,
    unitSellingPrice,
    lineTotal,
    createdAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItem &&
          other.id == this.id &&
          other.pharmacyUid == this.pharmacyUid &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.batchId == this.batchId &&
          other.quantity == this.quantity &&
          other.unitCostPrice == this.unitCostPrice &&
          other.unitSellingPrice == this.unitSellingPrice &&
          other.lineTotal == this.lineTotal &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class SaleItemsTableCompanion extends UpdateCompanion<SaleItem> {
  final Value<String> id;
  final Value<String> pharmacyUid;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<String> batchId;
  final Value<int> quantity;
  final Value<double> unitCostPrice;
  final Value<double> unitSellingPrice;
  final Value<double> lineTotal;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const SaleItemsTableCompanion({
    this.id = const Value.absent(),
    this.pharmacyUid = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCostPrice = const Value.absent(),
    this.unitSellingPrice = const Value.absent(),
    this.lineTotal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleItemsTableCompanion.insert({
    required String id,
    required String pharmacyUid,
    required String saleId,
    required String productId,
    required String batchId,
    required int quantity,
    required double unitCostPrice,
    required double unitSellingPrice,
    required double lineTotal,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pharmacyUid = Value(pharmacyUid),
       saleId = Value(saleId),
       productId = Value(productId),
       batchId = Value(batchId),
       quantity = Value(quantity),
       unitCostPrice = Value(unitCostPrice),
       unitSellingPrice = Value(unitSellingPrice),
       lineTotal = Value(lineTotal),
       createdAt = Value(createdAt);
  static Insertable<SaleItem> custom({
    Expression<String>? id,
    Expression<String>? pharmacyUid,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<String>? batchId,
    Expression<int>? quantity,
    Expression<double>? unitCostPrice,
    Expression<double>? unitSellingPrice,
    Expression<double>? lineTotal,
    Expression<String>? createdAt,
    Expression<String>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pharmacyUid != null) 'pharmacy_uid': pharmacyUid,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (batchId != null) 'batch_id': batchId,
      if (quantity != null) 'quantity': quantity,
      if (unitCostPrice != null) 'unit_cost_price': unitCostPrice,
      if (unitSellingPrice != null) 'unit_selling_price': unitSellingPrice,
      if (lineTotal != null) 'line_total': lineTotal,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? pharmacyUid,
    Value<String>? saleId,
    Value<String>? productId,
    Value<String>? batchId,
    Value<int>? quantity,
    Value<double>? unitCostPrice,
    Value<double>? unitSellingPrice,
    Value<double>? lineTotal,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return SaleItemsTableCompanion(
      id: id ?? this.id,
      pharmacyUid: pharmacyUid ?? this.pharmacyUid,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      batchId: batchId ?? this.batchId,
      quantity: quantity ?? this.quantity,
      unitCostPrice: unitCostPrice ?? this.unitCostPrice,
      unitSellingPrice: unitSellingPrice ?? this.unitSellingPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pharmacyUid.present) {
      map['pharmacy_uid'] = Variable<String>(pharmacyUid.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitCostPrice.present) {
      map['unit_cost_price'] = Variable<double>(unitCostPrice.value);
    }
    if (unitSellingPrice.present) {
      map['unit_selling_price'] = Variable<double>(unitSellingPrice.value);
    }
    if (lineTotal.present) {
      map['line_total'] = Variable<double>(lineTotal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $SaleItemsTableTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $SaleItemsTableTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('batchId: $batchId, ')
          ..write('quantity: $quantity, ')
          ..write('unitCostPrice: $unitCostPrice, ')
          ..write('unitSellingPrice: $unitSellingPrice, ')
          ..write('lineTotal: $lineTotal, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncChangeLogsTableTable extends SyncChangeLogsTable
    with TableInfo<$SyncChangeLogsTableTable, SyncChangeLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncChangeLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  @override
  late final GeneratedColumn<String> logId = GeneratedColumn<String>(
    'log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pharmacyUidMeta = const VerificationMeta(
    'pharmacyUid',
  );
  @override
  late final GeneratedColumn<String> pharmacyUid = GeneratedColumn<String>(
    'pharmacy_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pharmacy_settings (pharmacy_uid)',
    ),
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> changedAt =
      GeneratedColumn<String>(
        'changed_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SyncChangeLogsTableTable.$converterchangedAt);
  static const VerificationMeta _isPushedMeta = const VerificationMeta(
    'isPushed',
  );
  @override
  late final GeneratedColumn<bool> isPushed = GeneratedColumn<bool>(
    'is_pushed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pushed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    logId,
    pharmacyUid,
    targetTable,
    recordId,
    operation,
    changedAt,
    isPushed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_change_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncChangeLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    } else if (isInserting) {
      context.missing(_logIdMeta);
    }
    if (data.containsKey('pharmacy_uid')) {
      context.handle(
        _pharmacyUidMeta,
        pharmacyUid.isAcceptableOrUnknown(
          data['pharmacy_uid']!,
          _pharmacyUidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pharmacyUidMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('is_pushed')) {
      context.handle(
        _isPushedMeta,
        isPushed.isAcceptableOrUnknown(data['is_pushed']!, _isPushedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {logId};
  @override
  SyncChangeLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncChangeLog(
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_id'],
      )!,
      pharmacyUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pharmacy_uid'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      changedAt: $SyncChangeLogsTableTable.$converterchangedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}changed_at'],
        )!,
      ),
      isPushed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pushed'],
      )!,
    );
  }

  @override
  $SyncChangeLogsTableTable createAlias(String alias) {
    return $SyncChangeLogsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterchangedAt =
      const IsoDateTimeConverter();
}

class SyncChangeLog extends DataClass implements Insertable<SyncChangeLog> {
  final String logId;
  final String pharmacyUid;
  final String targetTable;
  final String recordId;
  final String operation;
  final DateTime changedAt;
  final bool isPushed;
  const SyncChangeLog({
    required this.logId,
    required this.pharmacyUid,
    required this.targetTable,
    required this.recordId,
    required this.operation,
    required this.changedAt,
    required this.isPushed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['log_id'] = Variable<String>(logId);
    map['pharmacy_uid'] = Variable<String>(pharmacyUid);
    map['target_table'] = Variable<String>(targetTable);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    {
      map['changed_at'] = Variable<String>(
        $SyncChangeLogsTableTable.$converterchangedAt.toSql(changedAt),
      );
    }
    map['is_pushed'] = Variable<bool>(isPushed);
    return map;
  }

  SyncChangeLogsTableCompanion toCompanion(bool nullToAbsent) {
    return SyncChangeLogsTableCompanion(
      logId: Value(logId),
      pharmacyUid: Value(pharmacyUid),
      targetTable: Value(targetTable),
      recordId: Value(recordId),
      operation: Value(operation),
      changedAt: Value(changedAt),
      isPushed: Value(isPushed),
    );
  }

  factory SyncChangeLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncChangeLog(
      logId: serializer.fromJson<String>(json['logId']),
      pharmacyUid: serializer.fromJson<String>(json['pharmacyUid']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
      isPushed: serializer.fromJson<bool>(json['isPushed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'logId': serializer.toJson<String>(logId),
      'pharmacyUid': serializer.toJson<String>(pharmacyUid),
      'targetTable': serializer.toJson<String>(targetTable),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'changedAt': serializer.toJson<DateTime>(changedAt),
      'isPushed': serializer.toJson<bool>(isPushed),
    };
  }

  SyncChangeLog copyWith({
    String? logId,
    String? pharmacyUid,
    String? targetTable,
    String? recordId,
    String? operation,
    DateTime? changedAt,
    bool? isPushed,
  }) => SyncChangeLog(
    logId: logId ?? this.logId,
    pharmacyUid: pharmacyUid ?? this.pharmacyUid,
    targetTable: targetTable ?? this.targetTable,
    recordId: recordId ?? this.recordId,
    operation: operation ?? this.operation,
    changedAt: changedAt ?? this.changedAt,
    isPushed: isPushed ?? this.isPushed,
  );
  SyncChangeLog copyWithCompanion(SyncChangeLogsTableCompanion data) {
    return SyncChangeLog(
      logId: data.logId.present ? data.logId.value : this.logId,
      pharmacyUid: data.pharmacyUid.present
          ? data.pharmacyUid.value
          : this.pharmacyUid,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
      isPushed: data.isPushed.present ? data.isPushed.value : this.isPushed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncChangeLog(')
          ..write('logId: $logId, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('changedAt: $changedAt, ')
          ..write('isPushed: $isPushed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    logId,
    pharmacyUid,
    targetTable,
    recordId,
    operation,
    changedAt,
    isPushed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncChangeLog &&
          other.logId == this.logId &&
          other.pharmacyUid == this.pharmacyUid &&
          other.targetTable == this.targetTable &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.changedAt == this.changedAt &&
          other.isPushed == this.isPushed);
}

class SyncChangeLogsTableCompanion extends UpdateCompanion<SyncChangeLog> {
  final Value<String> logId;
  final Value<String> pharmacyUid;
  final Value<String> targetTable;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<DateTime> changedAt;
  final Value<bool> isPushed;
  final Value<int> rowid;
  const SyncChangeLogsTableCompanion({
    this.logId = const Value.absent(),
    this.pharmacyUid = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.isPushed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncChangeLogsTableCompanion.insert({
    required String logId,
    required String pharmacyUid,
    required String targetTable,
    required String recordId,
    required String operation,
    required DateTime changedAt,
    this.isPushed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : logId = Value(logId),
       pharmacyUid = Value(pharmacyUid),
       targetTable = Value(targetTable),
       recordId = Value(recordId),
       operation = Value(operation),
       changedAt = Value(changedAt);
  static Insertable<SyncChangeLog> custom({
    Expression<String>? logId,
    Expression<String>? pharmacyUid,
    Expression<String>? targetTable,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? changedAt,
    Expression<bool>? isPushed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (logId != null) 'log_id': logId,
      if (pharmacyUid != null) 'pharmacy_uid': pharmacyUid,
      if (targetTable != null) 'target_table': targetTable,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (changedAt != null) 'changed_at': changedAt,
      if (isPushed != null) 'is_pushed': isPushed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncChangeLogsTableCompanion copyWith({
    Value<String>? logId,
    Value<String>? pharmacyUid,
    Value<String>? targetTable,
    Value<String>? recordId,
    Value<String>? operation,
    Value<DateTime>? changedAt,
    Value<bool>? isPushed,
    Value<int>? rowid,
  }) {
    return SyncChangeLogsTableCompanion(
      logId: logId ?? this.logId,
      pharmacyUid: pharmacyUid ?? this.pharmacyUid,
      targetTable: targetTable ?? this.targetTable,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      changedAt: changedAt ?? this.changedAt,
      isPushed: isPushed ?? this.isPushed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (logId.present) {
      map['log_id'] = Variable<String>(logId.value);
    }
    if (pharmacyUid.present) {
      map['pharmacy_uid'] = Variable<String>(pharmacyUid.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<String>(
        $SyncChangeLogsTableTable.$converterchangedAt.toSql(changedAt.value),
      );
    }
    if (isPushed.present) {
      map['is_pushed'] = Variable<bool>(isPushed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncChangeLogsTableCompanion(')
          ..write('logId: $logId, ')
          ..write('pharmacyUid: $pharmacyUid, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('changedAt: $changedAt, ')
          ..write('isPushed: $isPushed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PharmacySettingsTableTable pharmacySettingsTable =
      $PharmacySettingsTableTable(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $ProductsTableTable productsTable = $ProductsTableTable(this);
  late final $ProductBatchesTableTable productBatchesTable =
      $ProductBatchesTableTable(this);
  late final $SalesTableTable salesTable = $SalesTableTable(this);
  late final $SaleItemsTableTable saleItemsTable = $SaleItemsTableTable(this);
  late final $SyncChangeLogsTableTable syncChangeLogsTable =
      $SyncChangeLogsTableTable(this);
  late final ProductsDao productsDao = ProductsDao(this as AppDatabase);
  late final SalesDao salesDao = SalesDao(this as AppDatabase);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pharmacySettingsTable,
    usersTable,
    productsTable,
    productBatchesTable,
    salesTable,
    saleItemsTable,
    syncChangeLogsTable,
  ];
}

typedef $$PharmacySettingsTableTableCreateCompanionBuilder =
    PharmacySettingsTableCompanion Function({
      required String pharmacyUid,
      required String pharmacyName,
      Value<String?> licenseNumber,
      required String contactPhone,
      Value<String?> address,
      Value<String?> mapPinUrl,
      Value<String> currencySymbol,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PharmacySettingsTableTableUpdateCompanionBuilder =
    PharmacySettingsTableCompanion Function({
      Value<String> pharmacyUid,
      Value<String> pharmacyName,
      Value<String?> licenseNumber,
      Value<String> contactPhone,
      Value<String?> address,
      Value<String?> mapPinUrl,
      Value<String> currencySymbol,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PharmacySettingsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PharmacySettingsTableTable,
          PharmacySetting
        > {
  $$PharmacySettingsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$UsersTableTable, List<User>> _usersTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.usersTable,
    aliasName: 'pharmacy_settings__pharmacy_uid__users__pharmacy_uid',
  );

  $$UsersTableTableProcessedTableManager get usersTableRefs {
    final manager = $$UsersTableTableTableManager($_db, $_db.usersTable).filter(
      (f) => f.pharmacyUid.pharmacyUid.sqlEquals(
        $_itemColumn<String>('pharmacy_uid')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_usersTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProductsTableTable, List<Product>>
  _productsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productsTable,
    aliasName: 'pharmacy_settings__pharmacy_uid__products__pharmacy_uid',
  );

  $$ProductsTableTableProcessedTableManager get productsTableRefs {
    final manager = $$ProductsTableTableTableManager($_db, $_db.productsTable)
        .filter(
          (f) => f.pharmacyUid.pharmacyUid.sqlEquals(
            $_itemColumn<String>('pharmacy_uid')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_productsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProductBatchesTableTable, List<ProductBatch>>
  _productBatchesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productBatchesTable,
        aliasName:
            'pharmacy_settings__pharmacy_uid__product_batches__pharmacy_uid',
      );

  $$ProductBatchesTableTableProcessedTableManager get productBatchesTableRefs {
    final manager =
        $$ProductBatchesTableTableTableManager(
          $_db,
          $_db.productBatchesTable,
        ).filter(
          (f) => f.pharmacyUid.pharmacyUid.sqlEquals(
            $_itemColumn<String>('pharmacy_uid')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _productBatchesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SalesTableTable, List<Sale>> _salesTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.salesTable,
    aliasName: 'pharmacy_settings__pharmacy_uid__sales__pharmacy_uid',
  );

  $$SalesTableTableProcessedTableManager get salesTableRefs {
    final manager = $$SalesTableTableTableManager($_db, $_db.salesTable).filter(
      (f) => f.pharmacyUid.pharmacyUid.sqlEquals(
        $_itemColumn<String>('pharmacy_uid')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_salesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleItemsTableTable, List<SaleItem>>
  _saleItemsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItemsTable,
    aliasName: 'pharmacy_settings__pharmacy_uid__sale_items__pharmacy_uid',
  );

  $$SaleItemsTableTableProcessedTableManager get saleItemsTableRefs {
    final manager = $$SaleItemsTableTableTableManager($_db, $_db.saleItemsTable)
        .filter(
          (f) => f.pharmacyUid.pharmacyUid.sqlEquals(
            $_itemColumn<String>('pharmacy_uid')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_saleItemsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncChangeLogsTableTable, List<SyncChangeLog>>
  _syncChangeLogsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.syncChangeLogsTable,
        aliasName:
            'pharmacy_settings__pharmacy_uid__sync_change_log__pharmacy_uid',
      );

  $$SyncChangeLogsTableTableProcessedTableManager get syncChangeLogsTableRefs {
    final manager =
        $$SyncChangeLogsTableTableTableManager(
          $_db,
          $_db.syncChangeLogsTable,
        ).filter(
          (f) => f.pharmacyUid.pharmacyUid.sqlEquals(
            $_itemColumn<String>('pharmacy_uid')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _syncChangeLogsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PharmacySettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PharmacySettingsTableTable> {
  $$PharmacySettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pharmacyUid => $composableBuilder(
    column: $table.pharmacyUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pharmacyName => $composableBuilder(
    column: $table.pharmacyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseNumber => $composableBuilder(
    column: $table.licenseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mapPinUrl => $composableBuilder(
    column: $table.mapPinUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> usersTableRefs(
    Expression<bool> Function($$UsersTableTableFilterComposer f) f,
  ) {
    final $$UsersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pharmacyUid,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.pharmacyUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableFilterComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> productsTableRefs(
    Expression<bool> Function($$ProductsTableTableFilterComposer f) f,
  ) {
    final $$ProductsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pharmacyUid,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.pharmacyUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableFilterComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> productBatchesTableRefs(
    Expression<bool> Function($$ProductBatchesTableTableFilterComposer f) f,
  ) {
    final $$ProductBatchesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pharmacyUid,
      referencedTable: $db.productBatchesTable,
      getReferencedColumn: (t) => t.pharmacyUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductBatchesTableTableFilterComposer(
            $db: $db,
            $table: $db.productBatchesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> salesTableRefs(
    Expression<bool> Function($$SalesTableTableFilterComposer f) f,
  ) {
    final $$SalesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pharmacyUid,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.pharmacyUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableFilterComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleItemsTableRefs(
    Expression<bool> Function($$SaleItemsTableTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pharmacyUid,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.pharmacyUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncChangeLogsTableRefs(
    Expression<bool> Function($$SyncChangeLogsTableTableFilterComposer f) f,
  ) {
    final $$SyncChangeLogsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pharmacyUid,
      referencedTable: $db.syncChangeLogsTable,
      getReferencedColumn: (t) => t.pharmacyUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncChangeLogsTableTableFilterComposer(
            $db: $db,
            $table: $db.syncChangeLogsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PharmacySettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PharmacySettingsTableTable> {
  $$PharmacySettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pharmacyUid => $composableBuilder(
    column: $table.pharmacyUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pharmacyName => $composableBuilder(
    column: $table.pharmacyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseNumber => $composableBuilder(
    column: $table.licenseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mapPinUrl => $composableBuilder(
    column: $table.mapPinUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PharmacySettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PharmacySettingsTableTable> {
  $$PharmacySettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pharmacyUid => $composableBuilder(
    column: $table.pharmacyUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pharmacyName => $composableBuilder(
    column: $table.pharmacyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get licenseNumber => $composableBuilder(
    column: $table.licenseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get mapPinUrl =>
      $composableBuilder(column: $table.mapPinUrl, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> usersTableRefs<T extends Object>(
    Expression<T> Function($$UsersTableTableAnnotationComposer a) f,
  ) {
    final $$UsersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pharmacyUid,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.pharmacyUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> productsTableRefs<T extends Object>(
    Expression<T> Function($$ProductsTableTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pharmacyUid,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.pharmacyUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> productBatchesTableRefs<T extends Object>(
    Expression<T> Function($$ProductBatchesTableTableAnnotationComposer a) f,
  ) {
    final $$ProductBatchesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.productBatchesTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductBatchesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.productBatchesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> salesTableRefs<T extends Object>(
    Expression<T> Function($$SalesTableTableAnnotationComposer a) f,
  ) {
    final $$SalesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pharmacyUid,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.pharmacyUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saleItemsTableRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pharmacyUid,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.pharmacyUid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncChangeLogsTableRefs<T extends Object>(
    Expression<T> Function($$SyncChangeLogsTableTableAnnotationComposer a) f,
  ) {
    final $$SyncChangeLogsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.syncChangeLogsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SyncChangeLogsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.syncChangeLogsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PharmacySettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PharmacySettingsTableTable,
          PharmacySetting,
          $$PharmacySettingsTableTableFilterComposer,
          $$PharmacySettingsTableTableOrderingComposer,
          $$PharmacySettingsTableTableAnnotationComposer,
          $$PharmacySettingsTableTableCreateCompanionBuilder,
          $$PharmacySettingsTableTableUpdateCompanionBuilder,
          (PharmacySetting, $$PharmacySettingsTableTableReferences),
          PharmacySetting,
          PrefetchHooks Function({
            bool usersTableRefs,
            bool productsTableRefs,
            bool productBatchesTableRefs,
            bool salesTableRefs,
            bool saleItemsTableRefs,
            bool syncChangeLogsTableRefs,
          })
        > {
  $$PharmacySettingsTableTableTableManager(
    _$AppDatabase db,
    $PharmacySettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PharmacySettingsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PharmacySettingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PharmacySettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> pharmacyUid = const Value.absent(),
                Value<String> pharmacyName = const Value.absent(),
                Value<String?> licenseNumber = const Value.absent(),
                Value<String> contactPhone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> mapPinUrl = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PharmacySettingsTableCompanion(
                pharmacyUid: pharmacyUid,
                pharmacyName: pharmacyName,
                licenseNumber: licenseNumber,
                contactPhone: contactPhone,
                address: address,
                mapPinUrl: mapPinUrl,
                currencySymbol: currencySymbol,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pharmacyUid,
                required String pharmacyName,
                Value<String?> licenseNumber = const Value.absent(),
                required String contactPhone,
                Value<String?> address = const Value.absent(),
                Value<String?> mapPinUrl = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PharmacySettingsTableCompanion.insert(
                pharmacyUid: pharmacyUid,
                pharmacyName: pharmacyName,
                licenseNumber: licenseNumber,
                contactPhone: contactPhone,
                address: address,
                mapPinUrl: mapPinUrl,
                currencySymbol: currencySymbol,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PharmacySettingsTableTable, PharmacySetting>(
                    table,
                  ),
                  $$PharmacySettingsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                usersTableRefs = false,
                productsTableRefs = false,
                productBatchesTableRefs = false,
                salesTableRefs = false,
                saleItemsTableRefs = false,
                syncChangeLogsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (usersTableRefs) db.usersTable,
                    if (productsTableRefs) db.productsTable,
                    if (productBatchesTableRefs) db.productBatchesTable,
                    if (salesTableRefs) db.salesTable,
                    if (saleItemsTableRefs) db.saleItemsTable,
                    if (syncChangeLogsTableRefs) db.syncChangeLogsTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (usersTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PharmacySetting,
                          $PharmacySettingsTableTable,
                          User,
                          $UsersTableTable
                        >(
                          currentTable: table,
                          referencedTable:
                              $$PharmacySettingsTableTableReferences
                                  ._usersTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PharmacySettingsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).usersTableRefs,
                          currentColumn: 'pharmacy_uid',
                          referencedColumn: 'pharmacy_uid',
                          typedResults: items,
                        ),
                      if (productsTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PharmacySetting,
                          $PharmacySettingsTableTable,
                          Product,
                          $ProductsTableTable
                        >(
                          currentTable: table,
                          referencedTable:
                              $$PharmacySettingsTableTableReferences
                                  ._productsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PharmacySettingsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).productsTableRefs,
                          currentColumn: 'pharmacy_uid',
                          referencedColumn: 'pharmacy_uid',
                          typedResults: items,
                        ),
                      if (productBatchesTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PharmacySetting,
                          $PharmacySettingsTableTable,
                          ProductBatch,
                          $ProductBatchesTableTable
                        >(
                          currentTable: table,
                          referencedTable:
                              $$PharmacySettingsTableTableReferences
                                  ._productBatchesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PharmacySettingsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).productBatchesTableRefs,
                          currentColumn: 'pharmacy_uid',
                          referencedColumn: 'pharmacy_uid',
                          typedResults: items,
                        ),
                      if (salesTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PharmacySetting,
                          $PharmacySettingsTableTable,
                          Sale,
                          $SalesTableTable
                        >(
                          currentTable: table,
                          referencedTable:
                              $$PharmacySettingsTableTableReferences
                                  ._salesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PharmacySettingsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).salesTableRefs,
                          currentColumn: 'pharmacy_uid',
                          referencedColumn: 'pharmacy_uid',
                          typedResults: items,
                        ),
                      if (saleItemsTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PharmacySetting,
                          $PharmacySettingsTableTable,
                          SaleItem,
                          $SaleItemsTableTable
                        >(
                          currentTable: table,
                          referencedTable:
                              $$PharmacySettingsTableTableReferences
                                  ._saleItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PharmacySettingsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemsTableRefs,
                          currentColumn: 'pharmacy_uid',
                          referencedColumn: 'pharmacy_uid',
                          typedResults: items,
                        ),
                      if (syncChangeLogsTableRefs)
                        await $_getPrefetchedDataByColumns<
                          PharmacySetting,
                          $PharmacySettingsTableTable,
                          SyncChangeLog,
                          $SyncChangeLogsTableTable
                        >(
                          currentTable: table,
                          referencedTable:
                              $$PharmacySettingsTableTableReferences
                                  ._syncChangeLogsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PharmacySettingsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).syncChangeLogsTableRefs,
                          currentColumn: 'pharmacy_uid',
                          referencedColumn: 'pharmacy_uid',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PharmacySettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PharmacySettingsTableTable,
      PharmacySetting,
      $$PharmacySettingsTableTableFilterComposer,
      $$PharmacySettingsTableTableOrderingComposer,
      $$PharmacySettingsTableTableAnnotationComposer,
      $$PharmacySettingsTableTableCreateCompanionBuilder,
      $$PharmacySettingsTableTableUpdateCompanionBuilder,
      (PharmacySetting, $$PharmacySettingsTableTableReferences),
      PharmacySetting,
      PrefetchHooks Function({
        bool usersTableRefs,
        bool productsTableRefs,
        bool productBatchesTableRefs,
        bool salesTableRefs,
        bool saleItemsTableRefs,
        bool syncChangeLogsTableRefs,
      })
    >;
typedef $$UsersTableTableCreateCompanionBuilder = UsersTableCompanion Function({
  required String id,
  required String pharmacyUid,
  required String fullName,
  required String username,
  required String passwordHash,
  required String role,
  Value<String?> phone,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$UsersTableTableUpdateCompanionBuilder = UsersTableCompanion Function({
  Value<String> id,
  Value<String> pharmacyUid,
  Value<String> fullName,
  Value<String> username,
  Value<String> passwordHash,
  Value<String> role,
  Value<String?> phone,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$UsersTableTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTableTable, User> {
  $$UsersTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PharmacySettingsTableTable _pharmacyUidTable(_$AppDatabase db) => db
      .pharmacySettingsTable
      .createAlias('users__pharmacy_uid__pharmacy_settings__pharmacy_uid');

  $$PharmacySettingsTableTableProcessedTableManager get pharmacyUid {
    final $_column = $_itemColumn<String>('pharmacy_uid')!;

    final manager = $$PharmacySettingsTableTableTableManager(
      $_db,
      $_db.pharmacySettingsTable,
    ).filter((f) => f.pharmacyUid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pharmacyUidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SalesTableTable, List<Sale>> _salesTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.salesTable,
    aliasName: 'users__id__sales__cashier_user_id',
  );

  $$SalesTableTableProcessedTableManager get salesTableRefs {
    final manager = $$SalesTableTableTableManager(
      $_db,
      $_db.salesTable,
    ).filter((f) => f.cashierUserId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$PharmacySettingsTableTableFilterComposer get pharmacyUid {
    final $$PharmacySettingsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableFilterComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> salesTableRefs(
    Expression<bool> Function($$SalesTableTableFilterComposer f) f,
  ) {
    final $$SalesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.cashierUserId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableFilterComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$PharmacySettingsTableTableOrderingComposer get pharmacyUid {
    final $$PharmacySettingsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableOrderingComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$PharmacySettingsTableTableAnnotationComposer get pharmacyUid {
    final $$PharmacySettingsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> salesTableRefs<T extends Object>(
    Expression<T> Function($$SalesTableTableAnnotationComposer a) f,
  ) {
    final $$SalesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.cashierUserId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTableTable,
          User,
          $$UsersTableTableFilterComposer,
          $$UsersTableTableOrderingComposer,
          $$UsersTableTableAnnotationComposer,
          $$UsersTableTableCreateCompanionBuilder,
          $$UsersTableTableUpdateCompanionBuilder,
          (User, $$UsersTableTableReferences),
          User,
          PrefetchHooks Function({bool pharmacyUid, bool salesTableRefs})
        > {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pharmacyUid = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion(
                id: id,
                pharmacyUid: pharmacyUid,
                fullName: fullName,
                username: username,
                passwordHash: passwordHash,
                role: role,
                phone: phone,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pharmacyUid,
                required String fullName,
                required String username,
                required String passwordHash,
                required String role,
                Value<String?> phone = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion.insert(
                id: id,
                pharmacyUid: pharmacyUid,
                fullName: fullName,
                username: username,
                passwordHash: passwordHash,
                role: role,
                phone: phone,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTableTable, User>(table),
                  $$UsersTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({pharmacyUid = false, salesTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (salesTableRefs) db.salesTable],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (pharmacyUid) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.pharmacyUid,
                            referencedTable: $$UsersTableTableReferences
                                ._pharmacyUidTable(db),
                            referencedColumn: $$UsersTableTableReferences
                                ._pharmacyUidTable(db)
                                .pharmacyUid,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (salesTableRefs)
                        await $_getPrefetchedDataByColumns<
                          User,
                          $UsersTableTable,
                          Sale,
                          $SalesTableTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableTableReferences
                              ._salesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableTableReferences(
                                db,
                                table,
                                p0,
                              ).salesTableRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cashier_user_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTableTable,
      User,
      $$UsersTableTableFilterComposer,
      $$UsersTableTableOrderingComposer,
      $$UsersTableTableAnnotationComposer,
      $$UsersTableTableCreateCompanionBuilder,
      $$UsersTableTableUpdateCompanionBuilder,
      (User, $$UsersTableTableReferences),
      User,
      PrefetchHooks Function({bool pharmacyUid, bool salesTableRefs})
    >;
typedef $$ProductsTableTableCreateCompanionBuilder =
    ProductsTableCompanion Function({
      required String id,
      required String pharmacyUid,
      required String brandName,
      required String genericName,
      required String category,
      required String manufacturer,
      required String shelfLocation,
      Value<String> unitType,
      Value<int> minStockAlert,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ProductsTableTableUpdateCompanionBuilder =
    ProductsTableCompanion Function({
      Value<String> id,
      Value<String> pharmacyUid,
      Value<String> brandName,
      Value<String> genericName,
      Value<String> category,
      Value<String> manufacturer,
      Value<String> shelfLocation,
      Value<String> unitType,
      Value<int> minStockAlert,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$ProductsTableTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTableTable, Product> {
  $$ProductsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PharmacySettingsTableTable _pharmacyUidTable(_$AppDatabase db) => db
      .pharmacySettingsTable
      .createAlias('products__pharmacy_uid__pharmacy_settings__pharmacy_uid');

  $$PharmacySettingsTableTableProcessedTableManager get pharmacyUid {
    final $_column = $_itemColumn<String>('pharmacy_uid')!;

    final manager = $$PharmacySettingsTableTableTableManager(
      $_db,
      $_db.pharmacySettingsTable,
    ).filter((f) => f.pharmacyUid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pharmacyUidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ProductBatchesTableTable, List<ProductBatch>>
  _productBatchesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productBatchesTable,
        aliasName: 'products__id__product_batches__product_id',
      );

  $$ProductBatchesTableTableProcessedTableManager get productBatchesTableRefs {
    final manager = $$ProductBatchesTableTableTableManager(
      $_db,
      $_db.productBatchesTable,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _productBatchesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleItemsTableTable, List<SaleItem>>
  _saleItemsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItemsTable,
    aliasName: 'products__id__sale_items__product_id',
  );

  $$SaleItemsTableTableProcessedTableManager get saleItemsTableRefs {
    final manager = $$SaleItemsTableTableTableManager(
      $_db,
      $_db.saleItemsTable,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genericName => $composableBuilder(
    column: $table.genericName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minStockAlert => $composableBuilder(
    column: $table.minStockAlert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$PharmacySettingsTableTableFilterComposer get pharmacyUid {
    final $$PharmacySettingsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableFilterComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> productBatchesTableRefs(
    Expression<bool> Function($$ProductBatchesTableTableFilterComposer f) f,
  ) {
    final $$ProductBatchesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productBatchesTable,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductBatchesTableTableFilterComposer(
            $db: $db,
            $table: $db.productBatchesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleItemsTableRefs(
    Expression<bool> Function($$SaleItemsTableTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genericName => $composableBuilder(
    column: $table.genericName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minStockAlert => $composableBuilder(
    column: $table.minStockAlert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$PharmacySettingsTableTableOrderingComposer get pharmacyUid {
    final $$PharmacySettingsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableOrderingComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ProductsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<String> get genericName => $composableBuilder(
    column: $table.genericName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<int> get minStockAlert => $composableBuilder(
    column: $table.minStockAlert,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$PharmacySettingsTableTableAnnotationComposer get pharmacyUid {
    final $$PharmacySettingsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> productBatchesTableRefs<T extends Object>(
    Expression<T> Function($$ProductBatchesTableTableAnnotationComposer a) f,
  ) {
    final $$ProductBatchesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productBatchesTable,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductBatchesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.productBatchesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> saleItemsTableRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTableTable,
          Product,
          $$ProductsTableTableFilterComposer,
          $$ProductsTableTableOrderingComposer,
          $$ProductsTableTableAnnotationComposer,
          $$ProductsTableTableCreateCompanionBuilder,
          $$ProductsTableTableUpdateCompanionBuilder,
          (Product, $$ProductsTableTableReferences),
          Product,
          PrefetchHooks Function({
            bool pharmacyUid,
            bool productBatchesTableRefs,
            bool saleItemsTableRefs,
          })
        > {
  $$ProductsTableTableTableManager(_$AppDatabase db, $ProductsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pharmacyUid = const Value.absent(),
                Value<String> brandName = const Value.absent(),
                Value<String> genericName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> manufacturer = const Value.absent(),
                Value<String> shelfLocation = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<int> minStockAlert = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsTableCompanion(
                id: id,
                pharmacyUid: pharmacyUid,
                brandName: brandName,
                genericName: genericName,
                category: category,
                manufacturer: manufacturer,
                shelfLocation: shelfLocation,
                unitType: unitType,
                minStockAlert: minStockAlert,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pharmacyUid,
                required String brandName,
                required String genericName,
                required String category,
                required String manufacturer,
                required String shelfLocation,
                Value<String> unitType = const Value.absent(),
                Value<int> minStockAlert = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsTableCompanion.insert(
                id: id,
                pharmacyUid: pharmacyUid,
                brandName: brandName,
                genericName: genericName,
                category: category,
                manufacturer: manufacturer,
                shelfLocation: shelfLocation,
                unitType: unitType,
                minStockAlert: minStockAlert,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTableTable, Product>(table),
                  $$ProductsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pharmacyUid = false,
                productBatchesTableRefs = false,
                saleItemsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (productBatchesTableRefs) db.productBatchesTable,
                    if (saleItemsTableRefs) db.saleItemsTable,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (pharmacyUid) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.pharmacyUid,
                            referencedTable: $$ProductsTableTableReferences
                                ._pharmacyUidTable(db),
                            referencedColumn: $$ProductsTableTableReferences
                                ._pharmacyUidTable(db)
                                .pharmacyUid,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (productBatchesTableRefs)
                        await $_getPrefetchedDataByColumns<
                          Product,
                          $ProductsTableTable,
                          ProductBatch,
                          $ProductBatchesTableTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableTableReferences
                              ._productBatchesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).productBatchesTableRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                      if (saleItemsTableRefs)
                        await $_getPrefetchedDataByColumns<
                          Product,
                          $ProductsTableTable,
                          SaleItem,
                          $SaleItemsTableTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableTableReferences
                              ._saleItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemsTableRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTableTable,
      Product,
      $$ProductsTableTableFilterComposer,
      $$ProductsTableTableOrderingComposer,
      $$ProductsTableTableAnnotationComposer,
      $$ProductsTableTableCreateCompanionBuilder,
      $$ProductsTableTableUpdateCompanionBuilder,
      (Product, $$ProductsTableTableReferences),
      Product,
      PrefetchHooks Function({
        bool pharmacyUid,
        bool productBatchesTableRefs,
        bool saleItemsTableRefs,
      })
    >;
typedef $$ProductBatchesTableTableCreateCompanionBuilder =
    ProductBatchesTableCompanion Function({
      required String id,
      required String pharmacyUid,
      required String productId,
      required String batchNumber,
      Value<String?> supplierName,
      required double purchasePrice,
      required double sellingPrice,
      required int initialQuantity,
      required int currentStock,
      required DateTime expiryDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ProductBatchesTableTableUpdateCompanionBuilder =
    ProductBatchesTableCompanion Function({
      Value<String> id,
      Value<String> pharmacyUid,
      Value<String> productId,
      Value<String> batchNumber,
      Value<String?> supplierName,
      Value<double> purchasePrice,
      Value<double> sellingPrice,
      Value<int> initialQuantity,
      Value<int> currentStock,
      Value<DateTime> expiryDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$ProductBatchesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProductBatchesTableTable, ProductBatch> {
  $$ProductBatchesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PharmacySettingsTableTable _pharmacyUidTable(_$AppDatabase db) =>
      db.pharmacySettingsTable.createAlias(
        'product_batches__pharmacy_uid__pharmacy_settings__pharmacy_uid',
      );

  $$PharmacySettingsTableTableProcessedTableManager get pharmacyUid {
    final $_column = $_itemColumn<String>('pharmacy_uid')!;

    final manager = $$PharmacySettingsTableTableTableManager(
      $_db,
      $_db.pharmacySettingsTable,
    ).filter((f) => f.pharmacyUid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pharmacyUidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTableTable _productIdTable(_$AppDatabase db) =>
      db.productsTable.createAlias('product_batches__product_id__products__id');

  $$ProductsTableTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableTableManager(
      $_db,
      $_db.productsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaleItemsTableTable, List<SaleItem>>
  _saleItemsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItemsTable,
    aliasName: 'product_batches__id__sale_items__batch_id',
  );

  $$SaleItemsTableTableProcessedTableManager get saleItemsTableRefs {
    final manager = $$SaleItemsTableTableTableManager(
      $_db,
      $_db.saleItemsTable,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductBatchesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductBatchesTableTable> {
  $$ProductBatchesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStock => $composableBuilder(
    column: $table.currentStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get expiryDate =>
      $composableBuilder(
        column: $table.expiryDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$PharmacySettingsTableTableFilterComposer get pharmacyUid {
    final $$PharmacySettingsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableFilterComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProductsTableTableFilterComposer get productId {
    final $$ProductsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableFilterComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saleItemsTableRefs(
    Expression<bool> Function($$SaleItemsTableTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductBatchesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductBatchesTableTable> {
  $$ProductBatchesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStock => $composableBuilder(
    column: $table.currentStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$PharmacySettingsTableTableOrderingComposer get pharmacyUid {
    final $$PharmacySettingsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableOrderingComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProductsTableTableOrderingComposer get productId {
    final $$ProductsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableOrderingComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductBatchesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductBatchesTableTable> {
  $$ProductBatchesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStock => $composableBuilder(
    column: $table.currentStock,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get expiryDate =>
      $composableBuilder(
        column: $table.expiryDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$PharmacySettingsTableTableAnnotationComposer get pharmacyUid {
    final $$PharmacySettingsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProductsTableTableAnnotationComposer get productId {
    final $$ProductsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saleItemsTableRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductBatchesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductBatchesTableTable,
          ProductBatch,
          $$ProductBatchesTableTableFilterComposer,
          $$ProductBatchesTableTableOrderingComposer,
          $$ProductBatchesTableTableAnnotationComposer,
          $$ProductBatchesTableTableCreateCompanionBuilder,
          $$ProductBatchesTableTableUpdateCompanionBuilder,
          (ProductBatch, $$ProductBatchesTableTableReferences),
          ProductBatch,
          PrefetchHooks Function({
            bool pharmacyUid,
            bool productId,
            bool saleItemsTableRefs,
          })
        > {
  $$ProductBatchesTableTableTableManager(
    _$AppDatabase db,
    $ProductBatchesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductBatchesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductBatchesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductBatchesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pharmacyUid = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> batchNumber = const Value.absent(),
                Value<String?> supplierName = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> sellingPrice = const Value.absent(),
                Value<int> initialQuantity = const Value.absent(),
                Value<int> currentStock = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductBatchesTableCompanion(
                id: id,
                pharmacyUid: pharmacyUid,
                productId: productId,
                batchNumber: batchNumber,
                supplierName: supplierName,
                purchasePrice: purchasePrice,
                sellingPrice: sellingPrice,
                initialQuantity: initialQuantity,
                currentStock: currentStock,
                expiryDate: expiryDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pharmacyUid,
                required String productId,
                required String batchNumber,
                Value<String?> supplierName = const Value.absent(),
                required double purchasePrice,
                required double sellingPrice,
                required int initialQuantity,
                required int currentStock,
                required DateTime expiryDate,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductBatchesTableCompanion.insert(
                id: id,
                pharmacyUid: pharmacyUid,
                productId: productId,
                batchNumber: batchNumber,
                supplierName: supplierName,
                purchasePrice: purchasePrice,
                sellingPrice: sellingPrice,
                initialQuantity: initialQuantity,
                currentStock: currentStock,
                expiryDate: expiryDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductBatchesTableTable, ProductBatch>(table),
                  $$ProductBatchesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pharmacyUid = false,
                productId = false,
                saleItemsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleItemsTableRefs) db.saleItemsTable,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (pharmacyUid) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.pharmacyUid,
                            referencedTable:
                                $$ProductBatchesTableTableReferences
                                    ._pharmacyUidTable(db),
                            referencedColumn:
                                $$ProductBatchesTableTableReferences
                                    ._pharmacyUidTable(db)
                                    .pharmacyUid,
                          ) as T;
                        }
                        if (productId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.productId,
                            referencedTable:
                                $$ProductBatchesTableTableReferences
                                    ._productIdTable(db),
                            referencedColumn:
                                $$ProductBatchesTableTableReferences
                                    ._productIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleItemsTableRefs)
                        await $_getPrefetchedDataByColumns<
                          ProductBatch,
                          $ProductBatchesTableTable,
                          SaleItem,
                          $SaleItemsTableTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductBatchesTableTableReferences
                              ._saleItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductBatchesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemsTableRefs,
                          currentColumn: 'id',
                          referencedColumn: 'batch_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductBatchesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductBatchesTableTable,
      ProductBatch,
      $$ProductBatchesTableTableFilterComposer,
      $$ProductBatchesTableTableOrderingComposer,
      $$ProductBatchesTableTableAnnotationComposer,
      $$ProductBatchesTableTableCreateCompanionBuilder,
      $$ProductBatchesTableTableUpdateCompanionBuilder,
      (ProductBatch, $$ProductBatchesTableTableReferences),
      ProductBatch,
      PrefetchHooks Function({
        bool pharmacyUid,
        bool productId,
        bool saleItemsTableRefs,
      })
    >;
typedef $$SalesTableTableCreateCompanionBuilder = SalesTableCompanion Function({
  required String id,
  required String pharmacyUid,
  required String invoiceNumber,
  required String cashierUserId,
  Value<String> customerName,
  Value<String?> customerPhone,
  required double subtotal,
  Value<double> discountAmount,
  Value<double> taxAmount,
  required double totalPayable,
  required double amountTendered,
  required double changeReturned,
  required String paymentMethod,
  required double totalCostPrice,
  required double grossProfit,
  required DateTime createdAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$SalesTableTableUpdateCompanionBuilder = SalesTableCompanion Function({
  Value<String> id,
  Value<String> pharmacyUid,
  Value<String> invoiceNumber,
  Value<String> cashierUserId,
  Value<String> customerName,
  Value<String?> customerPhone,
  Value<double> subtotal,
  Value<double> discountAmount,
  Value<double> taxAmount,
  Value<double> totalPayable,
  Value<double> amountTendered,
  Value<double> changeReturned,
  Value<String> paymentMethod,
  Value<double> totalCostPrice,
  Value<double> grossProfit,
  Value<DateTime> createdAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$SalesTableTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTableTable, Sale> {
  $$SalesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PharmacySettingsTableTable _pharmacyUidTable(_$AppDatabase db) => db
      .pharmacySettingsTable
      .createAlias('sales__pharmacy_uid__pharmacy_settings__pharmacy_uid');

  $$PharmacySettingsTableTableProcessedTableManager get pharmacyUid {
    final $_column = $_itemColumn<String>('pharmacy_uid')!;

    final manager = $$PharmacySettingsTableTableTableManager(
      $_db,
      $_db.pharmacySettingsTable,
    ).filter((f) => f.pharmacyUid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pharmacyUidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTableTable _cashierUserIdTable(_$AppDatabase db) =>
      db.usersTable.createAlias('sales__cashier_user_id__users__id');

  $$UsersTableTableProcessedTableManager get cashierUserId {
    final $_column = $_itemColumn<String>('cashier_user_id')!;

    final manager = $$UsersTableTableTableManager(
      $_db,
      $_db.usersTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cashierUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaleItemsTableTable, List<SaleItem>>
  _saleItemsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItemsTable,
    aliasName: 'sales__id__sale_items__sale_id',
  );

  $$SaleItemsTableTableProcessedTableManager get saleItemsTableRefs {
    final manager = $$SaleItemsTableTableTableManager(
      $_db,
      $_db.saleItemsTable,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPayable => $composableBuilder(
    column: $table.totalPayable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountTendered => $composableBuilder(
    column: $table.amountTendered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get changeReturned => $composableBuilder(
    column: $table.changeReturned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCostPrice => $composableBuilder(
    column: $table.totalCostPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grossProfit => $composableBuilder(
    column: $table.grossProfit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$PharmacySettingsTableTableFilterComposer get pharmacyUid {
    final $$PharmacySettingsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableFilterComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$UsersTableTableFilterComposer get cashierUserId {
    final $$UsersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cashierUserId,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableFilterComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saleItemsTableRefs(
    Expression<bool> Function($$SaleItemsTableTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPayable => $composableBuilder(
    column: $table.totalPayable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountTendered => $composableBuilder(
    column: $table.amountTendered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get changeReturned => $composableBuilder(
    column: $table.changeReturned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCostPrice => $composableBuilder(
    column: $table.totalCostPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grossProfit => $composableBuilder(
    column: $table.grossProfit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$PharmacySettingsTableTableOrderingComposer get pharmacyUid {
    final $$PharmacySettingsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableOrderingComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$UsersTableTableOrderingComposer get cashierUserId {
    final $$UsersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cashierUserId,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableOrderingComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get totalPayable => $composableBuilder(
    column: $table.totalPayable,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountTendered => $composableBuilder(
    column: $table.amountTendered,
    builder: (column) => column,
  );

  GeneratedColumn<double> get changeReturned => $composableBuilder(
    column: $table.changeReturned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalCostPrice => $composableBuilder(
    column: $table.totalCostPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grossProfit => $composableBuilder(
    column: $table.grossProfit,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$PharmacySettingsTableTableAnnotationComposer get pharmacyUid {
    final $$PharmacySettingsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$UsersTableTableAnnotationComposer get cashierUserId {
    final $$UsersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cashierUserId,
      referencedTable: $db.usersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.usersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saleItemsTableRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTableTable,
          Sale,
          $$SalesTableTableFilterComposer,
          $$SalesTableTableOrderingComposer,
          $$SalesTableTableAnnotationComposer,
          $$SalesTableTableCreateCompanionBuilder,
          $$SalesTableTableUpdateCompanionBuilder,
          (Sale, $$SalesTableTableReferences),
          Sale,
          PrefetchHooks Function({
            bool pharmacyUid,
            bool cashierUserId,
            bool saleItemsTableRefs,
          })
        > {
  $$SalesTableTableTableManager(_$AppDatabase db, $SalesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pharmacyUid = const Value.absent(),
                Value<String> invoiceNumber = const Value.absent(),
                Value<String> cashierUserId = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> totalPayable = const Value.absent(),
                Value<double> amountTendered = const Value.absent(),
                Value<double> changeReturned = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<double> totalCostPrice = const Value.absent(),
                Value<double> grossProfit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesTableCompanion(
                id: id,
                pharmacyUid: pharmacyUid,
                invoiceNumber: invoiceNumber,
                cashierUserId: cashierUserId,
                customerName: customerName,
                customerPhone: customerPhone,
                subtotal: subtotal,
                discountAmount: discountAmount,
                taxAmount: taxAmount,
                totalPayable: totalPayable,
                amountTendered: amountTendered,
                changeReturned: changeReturned,
                paymentMethod: paymentMethod,
                totalCostPrice: totalCostPrice,
                grossProfit: grossProfit,
                createdAt: createdAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pharmacyUid,
                required String invoiceNumber,
                required String cashierUserId,
                Value<String> customerName = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                required double subtotal,
                Value<double> discountAmount = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                required double totalPayable,
                required double amountTendered,
                required double changeReturned,
                required String paymentMethod,
                required double totalCostPrice,
                required double grossProfit,
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesTableCompanion.insert(
                id: id,
                pharmacyUid: pharmacyUid,
                invoiceNumber: invoiceNumber,
                cashierUserId: cashierUserId,
                customerName: customerName,
                customerPhone: customerPhone,
                subtotal: subtotal,
                discountAmount: discountAmount,
                taxAmount: taxAmount,
                totalPayable: totalPayable,
                amountTendered: amountTendered,
                changeReturned: changeReturned,
                paymentMethod: paymentMethod,
                totalCostPrice: totalCostPrice,
                grossProfit: grossProfit,
                createdAt: createdAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SalesTableTable, Sale>(table),
                  $$SalesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pharmacyUid = false,
                cashierUserId = false,
                saleItemsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleItemsTableRefs) db.saleItemsTable,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (pharmacyUid) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.pharmacyUid,
                            referencedTable: $$SalesTableTableReferences
                                ._pharmacyUidTable(db),
                            referencedColumn: $$SalesTableTableReferences
                                ._pharmacyUidTable(db)
                                .pharmacyUid,
                          ) as T;
                        }
                        if (cashierUserId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cashierUserId,
                            referencedTable: $$SalesTableTableReferences
                                ._cashierUserIdTable(db),
                            referencedColumn: $$SalesTableTableReferences
                                ._cashierUserIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleItemsTableRefs)
                        await $_getPrefetchedDataByColumns<
                          Sale,
                          $SalesTableTable,
                          SaleItem,
                          $SaleItemsTableTable
                        >(
                          currentTable: table,
                          referencedTable: $$SalesTableTableReferences
                              ._saleItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemsTableRefs,
                          currentColumn: 'id',
                          referencedColumn: 'sale_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SalesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTableTable,
      Sale,
      $$SalesTableTableFilterComposer,
      $$SalesTableTableOrderingComposer,
      $$SalesTableTableAnnotationComposer,
      $$SalesTableTableCreateCompanionBuilder,
      $$SalesTableTableUpdateCompanionBuilder,
      (Sale, $$SalesTableTableReferences),
      Sale,
      PrefetchHooks Function({
        bool pharmacyUid,
        bool cashierUserId,
        bool saleItemsTableRefs,
      })
    >;
typedef $$SaleItemsTableTableCreateCompanionBuilder =
    SaleItemsTableCompanion Function({
      required String id,
      required String pharmacyUid,
      required String saleId,
      required String productId,
      required String batchId,
      required int quantity,
      required double unitCostPrice,
      required double unitSellingPrice,
      required double lineTotal,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$SaleItemsTableTableUpdateCompanionBuilder =
    SaleItemsTableCompanion Function({
      Value<String> id,
      Value<String> pharmacyUid,
      Value<String> saleId,
      Value<String> productId,
      Value<String> batchId,
      Value<int> quantity,
      Value<double> unitCostPrice,
      Value<double> unitSellingPrice,
      Value<double> lineTotal,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$SaleItemsTableTableReferences
    extends BaseReferences<_$AppDatabase, $SaleItemsTableTable, SaleItem> {
  $$SaleItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PharmacySettingsTableTable _pharmacyUidTable(_$AppDatabase db) => db
      .pharmacySettingsTable
      .createAlias('sale_items__pharmacy_uid__pharmacy_settings__pharmacy_uid');

  $$PharmacySettingsTableTableProcessedTableManager get pharmacyUid {
    final $_column = $_itemColumn<String>('pharmacy_uid')!;

    final manager = $$PharmacySettingsTableTableTableManager(
      $_db,
      $_db.pharmacySettingsTable,
    ).filter((f) => f.pharmacyUid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pharmacyUidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SalesTableTable _saleIdTable(_$AppDatabase db) =>
      db.salesTable.createAlias('sale_items__sale_id__sales__id');

  $$SalesTableTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<String>('sale_id')!;

    final manager = $$SalesTableTableTableManager(
      $_db,
      $_db.salesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTableTable _productIdTable(_$AppDatabase db) =>
      db.productsTable.createAlias('sale_items__product_id__products__id');

  $$ProductsTableTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableTableManager(
      $_db,
      $_db.productsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductBatchesTableTable _batchIdTable(_$AppDatabase db) => db
      .productBatchesTable
      .createAlias('sale_items__batch_id__product_batches__id');

  $$ProductBatchesTableTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<String>('batch_id')!;

    final manager = $$ProductBatchesTableTableTableManager(
      $_db,
      $_db.productBatchesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTableTable> {
  $$SaleItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitCostPrice => $composableBuilder(
    column: $table.unitCostPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitSellingPrice => $composableBuilder(
    column: $table.unitSellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lineTotal => $composableBuilder(
    column: $table.lineTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$PharmacySettingsTableTableFilterComposer get pharmacyUid {
    final $$PharmacySettingsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableFilterComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$SalesTableTableFilterComposer get saleId {
    final $$SalesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableFilterComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableTableFilterComposer get productId {
    final $$ProductsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableFilterComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductBatchesTableTableFilterComposer get batchId {
    final $$ProductBatchesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.productBatchesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductBatchesTableTableFilterComposer(
            $db: $db,
            $table: $db.productBatchesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTableTable> {
  $$SaleItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitCostPrice => $composableBuilder(
    column: $table.unitCostPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitSellingPrice => $composableBuilder(
    column: $table.unitSellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lineTotal => $composableBuilder(
    column: $table.lineTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$PharmacySettingsTableTableOrderingComposer get pharmacyUid {
    final $$PharmacySettingsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableOrderingComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$SalesTableTableOrderingComposer get saleId {
    final $$SalesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableOrderingComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableTableOrderingComposer get productId {
    final $$ProductsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableOrderingComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductBatchesTableTableOrderingComposer get batchId {
    final $$ProductBatchesTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.batchId,
          referencedTable: $db.productBatchesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductBatchesTableTableOrderingComposer(
                $db: $db,
                $table: $db.productBatchesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SaleItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTableTable> {
  $$SaleItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitCostPrice => $composableBuilder(
    column: $table.unitCostPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get unitSellingPrice => $composableBuilder(
    column: $table.unitSellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lineTotal =>
      $composableBuilder(column: $table.lineTotal, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$PharmacySettingsTableTableAnnotationComposer get pharmacyUid {
    final $$PharmacySettingsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$SalesTableTableAnnotationComposer get saleId {
    final $$SalesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableTableAnnotationComposer get productId {
    final $$ProductsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductBatchesTableTableAnnotationComposer get batchId {
    final $$ProductBatchesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.batchId,
          referencedTable: $db.productBatchesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductBatchesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.productBatchesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SaleItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleItemsTableTable,
          SaleItem,
          $$SaleItemsTableTableFilterComposer,
          $$SaleItemsTableTableOrderingComposer,
          $$SaleItemsTableTableAnnotationComposer,
          $$SaleItemsTableTableCreateCompanionBuilder,
          $$SaleItemsTableTableUpdateCompanionBuilder,
          (SaleItem, $$SaleItemsTableTableReferences),
          SaleItem,
          PrefetchHooks Function({
            bool pharmacyUid,
            bool saleId,
            bool productId,
            bool batchId,
          })
        > {
  $$SaleItemsTableTableTableManager(
    _$AppDatabase db,
    $SaleItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pharmacyUid = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> unitCostPrice = const Value.absent(),
                Value<double> unitSellingPrice = const Value.absent(),
                Value<double> lineTotal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleItemsTableCompanion(
                id: id,
                pharmacyUid: pharmacyUid,
                saleId: saleId,
                productId: productId,
                batchId: batchId,
                quantity: quantity,
                unitCostPrice: unitCostPrice,
                unitSellingPrice: unitSellingPrice,
                lineTotal: lineTotal,
                createdAt: createdAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pharmacyUid,
                required String saleId,
                required String productId,
                required String batchId,
                required int quantity,
                required double unitCostPrice,
                required double unitSellingPrice,
                required double lineTotal,
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleItemsTableCompanion.insert(
                id: id,
                pharmacyUid: pharmacyUid,
                saleId: saleId,
                productId: productId,
                batchId: batchId,
                quantity: quantity,
                unitCostPrice: unitCostPrice,
                unitSellingPrice: unitSellingPrice,
                lineTotal: lineTotal,
                createdAt: createdAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleItemsTableTable, SaleItem>(table),
                  $$SaleItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pharmacyUid = false,
                saleId = false,
                productId = false,
                batchId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (pharmacyUid) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.pharmacyUid,
                            referencedTable: $$SaleItemsTableTableReferences
                                ._pharmacyUidTable(db),
                            referencedColumn: $$SaleItemsTableTableReferences
                                ._pharmacyUidTable(db)
                                .pharmacyUid,
                          ) as T;
                        }
                        if (saleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.saleId,
                            referencedTable: $$SaleItemsTableTableReferences
                                ._saleIdTable(db),
                            referencedColumn: $$SaleItemsTableTableReferences
                                ._saleIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (productId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.productId,
                            referencedTable: $$SaleItemsTableTableReferences
                                ._productIdTable(db),
                            referencedColumn: $$SaleItemsTableTableReferences
                                ._productIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (batchId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.batchId,
                            referencedTable: $$SaleItemsTableTableReferences
                                ._batchIdTable(db),
                            referencedColumn: $$SaleItemsTableTableReferences
                                ._batchIdTable(db)
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
        ),
      );
}

typedef $$SaleItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleItemsTableTable,
      SaleItem,
      $$SaleItemsTableTableFilterComposer,
      $$SaleItemsTableTableOrderingComposer,
      $$SaleItemsTableTableAnnotationComposer,
      $$SaleItemsTableTableCreateCompanionBuilder,
      $$SaleItemsTableTableUpdateCompanionBuilder,
      (SaleItem, $$SaleItemsTableTableReferences),
      SaleItem,
      PrefetchHooks Function({
        bool pharmacyUid,
        bool saleId,
        bool productId,
        bool batchId,
      })
    >;
typedef $$SyncChangeLogsTableTableCreateCompanionBuilder =
    SyncChangeLogsTableCompanion Function({
      required String logId,
      required String pharmacyUid,
      required String targetTable,
      required String recordId,
      required String operation,
      required DateTime changedAt,
      Value<bool> isPushed,
      Value<int> rowid,
    });
typedef $$SyncChangeLogsTableTableUpdateCompanionBuilder =
    SyncChangeLogsTableCompanion Function({
      Value<String> logId,
      Value<String> pharmacyUid,
      Value<String> targetTable,
      Value<String> recordId,
      Value<String> operation,
      Value<DateTime> changedAt,
      Value<bool> isPushed,
      Value<int> rowid,
    });

final class $$SyncChangeLogsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SyncChangeLogsTableTable,
          SyncChangeLog
        > {
  $$SyncChangeLogsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PharmacySettingsTableTable _pharmacyUidTable(_$AppDatabase db) =>
      db.pharmacySettingsTable.createAlias(
        'sync_change_log__pharmacy_uid__pharmacy_settings__pharmacy_uid',
      );

  $$PharmacySettingsTableTableProcessedTableManager get pharmacyUid {
    final $_column = $_itemColumn<String>('pharmacy_uid')!;

    final manager = $$PharmacySettingsTableTableTableManager(
      $_db,
      $_db.pharmacySettingsTable,
    ).filter((f) => f.pharmacyUid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pharmacyUidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncChangeLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncChangeLogsTableTable> {
  $$SyncChangeLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get changedAt =>
      $composableBuilder(
        column: $table.changedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isPushed => $composableBuilder(
    column: $table.isPushed,
    builder: (column) => ColumnFilters(column),
  );

  $$PharmacySettingsTableTableFilterComposer get pharmacyUid {
    final $$PharmacySettingsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableFilterComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SyncChangeLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncChangeLogsTableTable> {
  $$SyncChangeLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPushed => $composableBuilder(
    column: $table.isPushed,
    builder: (column) => ColumnOrderings(column),
  );

  $$PharmacySettingsTableTableOrderingComposer get pharmacyUid {
    final $$PharmacySettingsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableOrderingComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SyncChangeLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncChangeLogsTableTable> {
  $$SyncChangeLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get logId =>
      $composableBuilder(column: $table.logId, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  GeneratedColumn<bool> get isPushed =>
      $composableBuilder(column: $table.isPushed, builder: (column) => column);

  $$PharmacySettingsTableTableAnnotationComposer get pharmacyUid {
    final $$PharmacySettingsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.pharmacyUid,
          referencedTable: $db.pharmacySettingsTable,
          getReferencedColumn: (t) => t.pharmacyUid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PharmacySettingsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pharmacySettingsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SyncChangeLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncChangeLogsTableTable,
          SyncChangeLog,
          $$SyncChangeLogsTableTableFilterComposer,
          $$SyncChangeLogsTableTableOrderingComposer,
          $$SyncChangeLogsTableTableAnnotationComposer,
          $$SyncChangeLogsTableTableCreateCompanionBuilder,
          $$SyncChangeLogsTableTableUpdateCompanionBuilder,
          (SyncChangeLog, $$SyncChangeLogsTableTableReferences),
          SyncChangeLog,
          PrefetchHooks Function({bool pharmacyUid})
        > {
  $$SyncChangeLogsTableTableTableManager(
    _$AppDatabase db,
    $SyncChangeLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncChangeLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncChangeLogsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SyncChangeLogsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> logId = const Value.absent(),
                Value<String> pharmacyUid = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<bool> isPushed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncChangeLogsTableCompanion(
                logId: logId,
                pharmacyUid: pharmacyUid,
                targetTable: targetTable,
                recordId: recordId,
                operation: operation,
                changedAt: changedAt,
                isPushed: isPushed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String logId,
                required String pharmacyUid,
                required String targetTable,
                required String recordId,
                required String operation,
                required DateTime changedAt,
                Value<bool> isPushed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncChangeLogsTableCompanion.insert(
                logId: logId,
                pharmacyUid: pharmacyUid,
                targetTable: targetTable,
                recordId: recordId,
                operation: operation,
                changedAt: changedAt,
                isPushed: isPushed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncChangeLogsTableTable, SyncChangeLog>(table),
                  $$SyncChangeLogsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pharmacyUid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (pharmacyUid) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pharmacyUid,
                        referencedTable: $$SyncChangeLogsTableTableReferences
                            ._pharmacyUidTable(db),
                        referencedColumn: $$SyncChangeLogsTableTableReferences
                            ._pharmacyUidTable(db)
                            .pharmacyUid,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncChangeLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncChangeLogsTableTable,
      SyncChangeLog,
      $$SyncChangeLogsTableTableFilterComposer,
      $$SyncChangeLogsTableTableOrderingComposer,
      $$SyncChangeLogsTableTableAnnotationComposer,
      $$SyncChangeLogsTableTableCreateCompanionBuilder,
      $$SyncChangeLogsTableTableUpdateCompanionBuilder,
      (SyncChangeLog, $$SyncChangeLogsTableTableReferences),
      SyncChangeLog,
      PrefetchHooks Function({bool pharmacyUid})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PharmacySettingsTableTableTableManager get pharmacySettingsTable =>
      $$PharmacySettingsTableTableTableManager(_db, _db.pharmacySettingsTable);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db, _db.productsTable);
  $$ProductBatchesTableTableTableManager get productBatchesTable =>
      $$ProductBatchesTableTableTableManager(_db, _db.productBatchesTable);
  $$SalesTableTableTableManager get salesTable =>
      $$SalesTableTableTableManager(_db, _db.salesTable);
  $$SaleItemsTableTableTableManager get saleItemsTable =>
      $$SaleItemsTableTableTableManager(_db, _db.saleItemsTable);
  $$SyncChangeLogsTableTableTableManager get syncChangeLogsTable =>
      $$SyncChangeLogsTableTableTableManager(_db, _db.syncChangeLogsTable);
}
