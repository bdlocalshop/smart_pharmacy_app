import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/services/secure_storage_service.dart';
import 'package:smart_pharmacy_app/features/auth/data/auth_repository.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_session.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/views/main_app_shell.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/widgets/rbac_guard.dart';
import 'package:smart_pharmacy_app/features/pos/presentation/controllers/pos_controller.dart';

void main() {
  group('RBAC UserRole Matrix Unit Tests', () {
    test('Owner possesses unrestricted access across all system modules', () {
      const role = UserRole.owner;

      expect(role.canManageUsers, isTrue);
      expect(role.canViewProfits, isTrue);
      expect(role.canManageInventory, isTrue);
      expect(role.canManageSuppliers, isTrue);
      expect(role.canViewReports, isTrue);
      expect(role.canManageSettings, isTrue);
      expect(role.canManageBackups, isTrue);
      expect(role.canAccessPos, isTrue);
      expect(role.canLookupStock, isTrue);
    });

    test('Manager has operational access but cannot manage users or backups', () {
      const role = UserRole.manager;

      expect(role.canManageUsers, isFalse); // Owner-only
      expect(role.canManageBackups, isFalse); // Owner-only
      expect(role.canManageSettings, isFalse); // Owner-only

      expect(role.canViewProfits, isTrue);
      expect(role.canManageInventory, isTrue);
      expect(role.canManageSuppliers, isTrue);
      expect(role.canViewReports, isTrue);
      expect(role.canAccessPos, isTrue);
      expect(role.canLookupStock, isTrue);
    });

    test('Salesman is strictly restricted to POS Billing and View-Only lookup', () {
      const role = UserRole.salesman;

      expect(role.canManageUsers, isFalse);
      expect(role.canViewProfits, isFalse); // Hidden profit margins
      expect(role.canManageInventory, isFalse); // View-only
      expect(role.canManageSuppliers, isFalse);
      expect(role.canViewReports, isFalse);
      expect(role.canManageSettings, isFalse);
      expect(role.canManageBackups, isFalse);

      expect(role.canAccessPos, isTrue);
      expect(role.canLookupStock, isTrue);
    });
  });

  group('RbacGuard Widget Tests', () {
    UserSession createTestSession(UserRole role) {
      return UserSession(
        userId: 'user-test-123',
        username: 'testuser',
        fullName: 'Test User',
        role: role,
        pharmacyUid: 'pharmacy-123',
        pharmacyName: 'Test Pharmacy',
        currencySymbol: '\$',
        token: 'token-123',
        loginTimestamp: DateTime.now(),
      );
    }

    testWidgets('RbacGuard.ownerOnly renders child for Owner and restricted banner for Salesman', (tester) async {
      // 1. Test as Salesman -> Expect restricted banner
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.salesman),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RbacGuard.ownerOnly(
                child: Text('Secret Owner Settings'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Secret Owner Settings'), findsNothing);
      expect(find.text('Access Restricted (RBAC Policy)'), findsOneWidget);

      // 2. Test as Owner -> Expect child
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.owner),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RbacGuard.ownerOnly(
                child: Text('Secret Owner Settings'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Secret Owner Settings'), findsOneWidget);
      expect(find.text('Access Restricted (RBAC Policy)'), findsNothing);
    });

    testWidgets('MainAppShell dynamically filters navigation options for Salesman vs Owner', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // As Salesman: Staff Management and Database Backups must NOT be in sidebar
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(createTestSession(UserRole.salesman)),
            posSearchResultsProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(
            home: MainAppShell(),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('POS Billing'), findsWidgets);
      expect(find.text('Medicine Master'), findsWidgets);
      expect(find.text('Expiry Radar & Alerts'), findsWidgets);
      expect(find.text('Staff Management'), findsNothing);
      expect(find.text('Database & Backups'), findsNothing);
      expect(find.text('Financial & Profit Reports'), findsNothing);

      // As Owner: All items must appear
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(createTestSession(UserRole.owner)),
            posSearchResultsProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(
            home: MainAppShell(),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('POS Billing'), findsWidgets);
      expect(find.text('Medicine Master'), findsWidgets);
      expect(find.text('Expiry Radar & Alerts'), findsWidgets);
      expect(find.text('Financial & Profit Reports'), findsWidgets);
      expect(find.text('Staff Management'), findsWidgets);
      expect(find.text('Database & Backups'), findsWidgets);
    });

    testWidgets('Owner can open Staff Management, Add User with Phone, and Edit User', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final storageClient = InMemorySecureStorageClient();
      final secureStorage = SecureStorageService(storageClient);
      final authRepo = AuthRepository(db: db, secureStorage: secureStorage);

      final ownerSession = await authRepo.setupInitialPharmacy(
        pharmacyName: 'Central Care',
        contactPhone: '+880 1717-449639',
        ownerFullName: 'Dr. Jenkins',
        ownerUsername: 'admin',
        ownerPassword: 'adminPassword123',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(ownerSession),
            currentUserRoleProvider.overrideWithValue(UserRole.owner),
            authRepositoryProvider.overrideWithValue(authRepo),
            posSearchResultsProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(
            home: MainAppShell(),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Navigate to Staff Management tab
      final staffTab = find.text('Staff Management');
      expect(staffTab, findsWidgets);
      await tester.tap(staffTab.first);
      await tester.pumpAndSettle();

      // Verify Owner appears in list with Edit button
      expect(find.text('Dr. Jenkins'), findsWidgets);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

      // Open Add Staff User Dialog
      final addUserBtn = find.text('Add Staff User');
      expect(addUserBtn, findsOneWidget);
      await tester.tap(addUserBtn);
      await tester.pumpAndSettle();

      // Verify Dialog fields including Phone Number
      expect(find.text('Add Staff User (Owner Access)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Full Name *'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Phone Number'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password (min 6 chars) *'), findsOneWidget);

      // Fill in user details
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name *'), 'Ali Reza');
      await tester.enterText(find.widgetWithText(TextFormField, 'Username *'), '@reza');
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '+880 1717-449639');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password (min 6 chars) *'), 'secret123');
      await tester.pumpAndSettle();

      // Submit Create User
      final createBtn = find.widgetWithText(ElevatedButton, 'Create User');
      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      // Verify user appears in list with phone number and edit button
      expect(find.text('Ali Reza'), findsOneWidget);
      expect(find.textContaining('+880 1717-449639'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));

      // Open Edit Dialog for newly added user
      final editButtons = find.byIcon(Icons.edit_outlined);
      await tester.tap(editButtons.last);
      await tester.pumpAndSettle();

      expect(find.text('Edit Staff User (@reza)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Reset Password (optional)'), findsOneWidget);

      // Update phone number
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '+880 1818-000111');
      await tester.pumpAndSettle();

      final saveBtn = find.widgetWithText(ElevatedButton, 'Save Changes');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify updated phone number in list
      expect(find.textContaining('+880 1818-000111'), findsOneWidget);

      // Verify new user can log in with credentials
      final loggedInSession = await authRepo.login(username: 'reza', password: 'secret123');
      expect(loggedInSession.fullName, equals('Ali Reza'));
      expect(loggedInSession.role, equals(UserRole.salesman));
    });
  });
}

