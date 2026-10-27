// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_dao.dart';

// ignore_for_file: type=lint
mixin _$UsersDaoMixin on DatabaseAccessor<AppDatabase> {
  $PharmacySettingsTableTable get pharmacySettingsTable =>
      attachedDatabase.pharmacySettingsTable;
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  UsersDaoManager get managers => UsersDaoManager(this);
}

class UsersDaoManager {
  final _$UsersDaoMixin _db;
  UsersDaoManager(this._db);
  $$PharmacySettingsTableTableTableManager get pharmacySettingsTable =>
      $$PharmacySettingsTableTableTableManager(
        _db.attachedDatabase,
        _db.pharmacySettingsTable,
      );
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
}
