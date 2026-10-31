import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/cloud_license_service.dart';
import '../controllers/auth_controller.dart';

/// First-time onboarding screen for setting up the local pharmacy tenant and master Owner.
class InitialSetupScreen extends ConsumerStatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  ConsumerState<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends ConsumerState<InitialSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _pharmacyNameController = TextEditingController(text: 'Smart Pharmacy & Healthcare');
  final _licenseController = TextEditingController(text: 'LIC-PHARM-2026-904');
  final _phoneController = TextEditingController(text: '+880 1717-449639');
  final _addressController = TextEditingController(text: '742 Evergreen Terrace, Medical District, Suite 100');
  final _mapPinController = TextEditingController();
  final _currencyController = TextEditingController(text: '৳');

  final _ownerFullNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerUsernameController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _registerWithCloud = true;
  bool _isProcessing = false;

  @override
  void dispose() {
    _pharmacyNameController.dispose();
    _licenseController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _mapPinController.dispose();
    _currencyController.dispose();
    _ownerFullNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    _ownerUsernameController.dispose();
    _ownerPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final notifier = ref.read(authControllerProvider.notifier);
    final localSuccess = await notifier.setupInitialPharmacy(
      pharmacyName: _pharmacyNameController.text,
      contactPhone: _phoneController.text,
      licenseNumber: _licenseController.text.isEmpty ? null : _licenseController.text,
      address: _addressController.text.trim(),
      mapPinUrl: _mapPinController.text.trim().isEmpty ? null : _mapPinController.text.trim(),
      currencySymbol: _currencyController.text.isEmpty ? '৳' : _currencyController.text,
      ownerFullName: _ownerFullNameController.text,
      ownerPhone: _ownerPhoneController.text.trim().isEmpty ? null : _ownerPhoneController.text.trim(),
      ownerUsername: _ownerUsernameController.text,
      ownerPassword: _ownerPasswordController.text,
    );

    if (!localSuccess) {
      if (mounted) setState(() => _isProcessing = false);
      return;
    }

    // Optional Cloud API Hardware Registration
    if (_registerWithCloud) {
      final cloudService = ref.read(cloudLicenseServiceProvider);
      final tradeLicense = _licenseController.text.trim().isNotEmpty
          ? _licenseController.text.trim()
          : 'TL-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 10000}';

      final regResult = await cloudService.registerPharmacy(
        pharmacyName: _pharmacyNameController.text,
        tradeLicenseNumber: tradeLicense,
        pharmacyAddress: _addressController.text.trim(),
        pharmacyPhone: _phoneController.text.trim(),
        mapLocationUrl: _mapPinController.text.trim().isEmpty ? null : _mapPinController.text.trim(),
        ownerName: _ownerFullNameController.text.trim(),
        ownerPhone: _ownerPhoneController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim().isEmpty ? null : _ownerEmailController.text.trim(),
        password: _ownerPasswordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (regResult.success && regResult.licenseKey != null) {
        await cloudService.validateLicense();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.accent,
              content: Text('Cloud License Bound: ${regResult.licenseKey}'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.warning,
              content: Text('Local store active. Cloud Notice: ${regResult.message}'),
            ),
          );
        }
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/Smart-Pharmacy-logo.png',
                            height: 48,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.local_pharmacy,
                              color: AppColors.primary,
                              size: 44,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Initial Pharmacy Onboarding',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Configure your local store installation and master Owner credentials.',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Error message if any
                      if (authState.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.alertCritical.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.alertCritical.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.alertCritical, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(color: AppColors.alertCritical, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Form Grid: Two sections
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Pharmacy Entity
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.storefront, color: AppColors.primary, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Store Identity',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _pharmacyNameController,
                                  label: 'Pharmacy Name *',
                                  icon: Icons.business,
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _licenseController,
                                  label: 'License / Registration Number',
                                  icon: Icons.badge_outlined,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _phoneController,
                                  label: 'Contact Phone *',
                                  icon: Icons.phone_outlined,
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _addressController,
                                  label: 'Physical Address *',
                                  icon: Icons.location_on_outlined,
                                  maxLines: 2,
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _currencyController,
                                  label: 'Currency Symbol *',
                                  icon: Icons.attach_money,
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _mapPinController,
                                  label: 'Map Pin Link (Google Maps)',
                                  icon: Icons.pin_drop_outlined,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 32),

                          // Right Column: Owner Administrator Account
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Master Owner Account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _ownerFullNameController,
                                  label: 'Owner Full Name *',
                                  icon: Icons.person_outline,
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _ownerPhoneController,
                                  label: 'Owner Phone (Personal / Private) *',
                                  icon: Icons.phone_android_outlined,
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _ownerEmailController,
                                  label: 'Owner Email (Cloud Recovery)',
                                  icon: Icons.email_outlined,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _ownerUsernameController,
                                  label: 'Username (Admin Login) *',
                                  icon: Icons.alternate_email,
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _ownerPasswordController,
                                  label: 'Master Password *',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      size: 18,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Password is required';
                                    if (v.length < 8) return 'Must be at least 8 characters';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm Password *',
                                  icon: Icons.lock_clock_outlined,
                                  obscureText: _obscureConfirmPassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                  validator: (v) {
                                    if (v != _ownerPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _submitSetup(),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _registerWithCloud,
                                        activeColor: AppColors.primary,
                                        onChanged: (v) => setState(() => _registerWithCloud = v ?? true),
                                      ),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Register & Bind Device to Cloud API',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                            ),
                                            Text(
                                              'Enforces 1-device license binding with cloud backup capability.',
                                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.info_outline, color: AppColors.primaryDark, size: 20),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'A unique cryptographic pharmacy_uid will be generated for offline tenant isolation.',
                                          style: TextStyle(fontSize: 12, color: AppColors.primaryDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 20),

                      // Submit Button Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: (_isProcessing || authState.isSubmitting)
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              (_isProcessing || authState.isSubmitting)
                                  ? 'Initializing Pharmacy & Cloud...'
                                  : 'Complete Setup & Enter System',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            onPressed: (_isProcessing || authState.isSubmitting) ? null : _submitSetup,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
