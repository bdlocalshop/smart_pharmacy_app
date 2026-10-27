import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pharmacy_app/core/database/database_provider.dart';
import 'package:smart_pharmacy_app/core/database/backup_manager.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_session.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/pos/presentation/controllers/pos_controller.dart';
import 'package:smart_pharmacy_app/main.dart';

void main() {
  testWidgets('SmartPharmacyApp renders LoginScreen when unauthenticated', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockInitState = AppInitializationState(
      isSeeded: true,
      pharmacyName: 'Smart Pharmacy & Healthcare',
      pharmacyUid: 'test-pharmacy-uid-1234',
      userCount: 3,
      productCount: 5,
      batchCount: 8,
      backupResult: BackupResult(
        success: true,
        backupFile: null,
        prunedFiles: [],
        message: 'Startup rolling backup successfully created',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appInitializationProvider.overrideWith((ref) => Future.value(mockInitState)),
          authControllerProvider.overrideWith(
            () => _MockAuthController(
              const AuthState(
                status: AuthStatus.unauthenticated,
              ),
            ),
          ),
        ],
        child: const SmartPharmacyApp(),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Sign In to Terminal'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Persistent Secure Storage Session'), findsOneWidget);
  });

  testWidgets('SmartPharmacyApp renders MainAppShell when authenticated', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = UserSession(
      userId: 'user-001',
      username: 'admin',
      fullName: 'Dr. Sarah Jenkins',
      role: UserRole.owner,
      pharmacyUid: 'pharmacy-001',
      pharmacyName: 'Smart Pharmacy & Healthcare',
      currencySymbol: '\$',
      token: 'token-123',
      loginTimestamp: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _MockAuthController(
              AuthState(
                status: AuthStatus.authenticated,
                session: session,
              ),
            ),
          ),
          posSearchResultsProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const SmartPharmacyApp(),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('POS Billing'), findsWidgets);
    expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
    expect(find.text('SQLite WAL • Offline Mode'), findsOneWidget);
  });
}

class _MockAuthController extends AuthController {
  final AuthState _initialState;
  _MockAuthController(this._initialState);

  @override
  AuthState build() => _initialState;

  @override
  Future<void> initializeAuth() async {}
}
