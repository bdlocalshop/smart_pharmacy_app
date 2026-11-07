import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/network/cloud_license_service.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/views/initial_setup_screen.dart';

class _FailingCloudLicenseService implements CloudLicenseService {
  final bool isConnection;
  final String errorMessage;

  _FailingCloudLicenseService({
    required this.isConnection,
    required this.errorMessage,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<CloudRegistrationResult> registerPharmacy({
    required String pharmacyName,
    required String tradeLicenseNumber,
    required String pharmacyAddress,
    required String pharmacyPhone,
    String? mapLocationUrl,
    required String ownerName,
    required String ownerPhone,
    String? ownerEmail,
    String? ownerAddress,
    required String password,
    required String passwordConfirmation,
  }) async {
    return CloudRegistrationResult(
      success: false,
      isConnectionError: isConnection,
      message: errorMessage,
    );
  }
}

void main() {
  group('Initial Setup Registration Internet Requirement Tests', () {
    testWidgets('Popups clean notification when internet or server API is unavailable', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockFailingService = _FailingCloudLicenseService(
        isConnection: true,
        errorMessage: 'Unable to reach the registration server. Please check your internet connection and try again.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cloudLicenseServiceProvider.overrideWithValue(mockFailingService),
          ],
          child: const MaterialApp(
            home: InitialSetupScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify mandatory online registration indicator is rendered
      expect(find.text('Online Registration (Mandatory)'), findsOneWidget);
      expect(find.text('An active internet connection is required to register and bind this device.'), findsOneWidget);

      // Fill in required owner credentials
      final nameFields = find.byType(TextFormField);
      // Field indices:
      // 0: Pharmacy Name, 1: License, 2: Phone, 3: Address, 4: Map Pin, 5: Currency
      // 6: Owner Full Name, 7: Owner Phone, 8: Owner Email, 9: Owner Username, 10: Password, 11: Confirm Password
      await tester.enterText(nameFields.at(6), 'Dr. John Doe');
      await tester.enterText(nameFields.at(7), '+880 1711-000000');
      await tester.enterText(nameFields.at(9), 'owner');
      await tester.enterText(nameFields.at(10), 'password123');
      await tester.enterText(nameFields.at(11), 'password123');

      // Click "Complete Setup & Register"
      final submitButton = find.text('Complete Setup & Register');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify Popup Notification is displayed
      expect(find.text('Internet Connection Required'), findsOneWidget);
      expect(
        find.text('An active internet connection is required to complete pharmacy registration. We could not reach the registration service.'),
        findsOneWidget,
      );
      expect(find.text('Please check your internet connection and try again.'), findsOneWidget);
      expect(find.text('Retry Registration'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Verify no API endpoints or technical URLs are disclosed to the user inside the dialog
      final dialogFinder = find.byType(AlertDialog);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('http://')), findsNothing);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('https://')), findsNothing);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('127.0.0.1')), findsNothing);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('/api/v1')), findsNothing);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('Proceed Offline Only')), findsNothing);
    });
  });
}
