import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/database/database_provider.dart';
import 'core/localization/language_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/views/initial_setup_screen.dart';
import 'features/auth/presentation/views/login_screen.dart';
import 'features/auth/presentation/views/main_app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SmartPharmacyApp()));
}

class SmartPharmacyApp extends ConsumerWidget {
  const SmartPharmacyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(language.code),
      home: const RootSessionRouter(),
    );
  }
}

/// Root Router inspecting persistent authentication session and onboarding state.
class RootSessionRouter extends ConsumerStatefulWidget {
  const RootSessionRouter({super.key});

  @override
  ConsumerState<RootSessionRouter> createState() => _RootSessionRouterState();
}

class _RootSessionRouterState extends ConsumerState<RootSessionRouter> {
  @override
  void initState() {
    super.initState();
    // Bootstrap database, rolling startup backup, and persistent session
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // 1. Initialize DB & startup backups
        await ref.read(appInitializationProvider.future);
      } catch (_) {
        // Non-fatal: database warning should not block user authentication
      } finally {
        // 2. Guaranteed session restore call - ensures app never hangs on loading screen
        if (mounted) {
          try {
            await ref.read(authControllerProvider.notifier).initializeAuth();
          } catch (_) {
            // Error captured in authState
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return switch (authState.status) {
      AuthStatus.initial || AuthStatus.loading => Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/Smart-Pharmacy-logo.png',
                  height: 64,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.local_pharmacy,
                    color: AppColors.primary,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading Smart Pharmacy Terminal...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      AuthStatus.setupRequired => const InitialSetupScreen(),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => const MainAppShell(),
    };
  }
}
