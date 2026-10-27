import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';
import '../../utils/password_hasher.dart';

part 'users_dao.g.dart';

/// User authentication and RBAC management DAO.
@DriftAccessor(tables: [UsersTable])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<User?> getUserByUsername(String username) {
    return (select(usersTable)
          ..where((tbl) => tbl.username.equals(username) & tbl.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<User?> authenticate(String username, String plainPassword) async {
    final user = await getUserByUsername(username);
    if (user == null || !user.isActive) return null;

    final isCorrect = PasswordHasher.verifyPassword(plainPassword, user.passwordHash);
    return isCorrect ? user : null;
  }

  Selectable<User> getActiveUsers(String pharmacyUid) {
    return select(usersTable)
      ..where((tbl) =>
          tbl.pharmacyUid.equals(pharmacyUid) &
          tbl.isActive.equals(true) &
          tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.fullName, mode: OrderingMode.asc)]);
  }
}

