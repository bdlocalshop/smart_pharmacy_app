import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';

/// Desktop Batch Procurement & FEFO Ledger Management Dialog.
class BatchManagementDialog extends ConsumerStatefulWidget {
  final Product product;

  const BatchManagementDialog({super.key, required this.product});

  @override
  ConsumerState<BatchManagementDialog> createState() => _BatchManagementDialogState();
}

class _BatchManagementDialogState extends ConsumerState<BatchManagementDialog> {
  final _formKey = GlobalKey<FormState>();

  final _batchNumberCtl = TextEditingController();
  final _supplierNameCtl = TextEditingController(text: 'MediGlobal Supplies');
  final _purchasePriceCtl = TextEditingController();
  final _sellingPriceCtl = TextEditingController();
  final _quantityCtl = TextEditingController();
  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 365));

  bool _isSaving = false;
  String? _clonedFromBatchNumber;

  final List<String> _distributorSuggestions = const [
    'MediGlobal Supplies',
    'Apex Pharma Logistics',
    'City Wholesale Distributors',
    'PharmaCare Direct',
    'National Medical Stores',
  ];

  @override
  void dispose() {
    _batchNumberCtl.dispose();
    _supplierNameCtl.dispose();
    _purchasePriceCtl.dispose();
    _sellingPriceCtl.dispose();
    _quantityCtl.dispose();
    super.dispose();
  }

  void _populateSameBatch(ProductBatch batch) {
    setState(() {
      _clonedFromBatchNumber = batch.batchNumber;
      _batchNumberCtl.text = batch.batchNumber;
      _supplierNameCtl.text = batch.supplierName ?? '';
      _purchasePriceCtl.text = batch.purchasePrice.toStringAsFixed(2);
      _sellingPriceCtl.text = batch.sellingPrice.toStringAsFixed(2);
      _quantityCtl.text = '${batch.initialQuantity}';
      _selectedExpiryDate = batch.expiryDate;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form populated with Batch #${batch.batchNumber} data. Please change the Batch Number.'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _submitNewBatch() async {
    if (!_formKey.currentState!.validate()) return;

    final enteredBatch = _batchNumberCtl.text.trim();

    // Check if the user hasn't changed the batch number from cloned batch
    // or if the batch number already exists for this medicine
    final currentBatches = ref.read(productBatchesProvider(widget.product.id)).asData?.value ?? [];
    final isUnchangedCloned = _clonedFromBatchNumber != null &&
        enteredBatch.toLowerCase() == _clonedFromBatchNumber!.trim().toLowerCase();
    final alreadyExists = isUnchangedCloned ||
        currentBatches.any((b) => b.batchNumber.trim().toLowerCase() == enteredBatch.toLowerCase());

    if (alreadyExists) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.alertUrgent, size: 26),
              SizedBox(width: 10),
              Expanded(
                child: Text('Please Change Batch Number', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Text(
            isUnchangedCloned
                ? 'You are adding a new batch using data from Batch "#$enteredBatch".\n\nPlease change the Batch Number before clicking "Add Batch".'
                : 'A batch with number "#$enteredBatch" already exists for this medicine.\n\nPlease enter a new, unique Batch Number.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final session = ref.read(currentUserSessionProvider);
    if (session == null) return;

    setState(() => _isSaving = true);
    final repo = ref.read(inventoryRepositoryProvider);

    try {
      final purchase = double.parse(_purchasePriceCtl.text);
      final selling = double.parse(_sellingPriceCtl.text);
      final qty = int.parse(_quantityCtl.text);

      await repo.addBatch(
        pharmacyUid: session.pharmacyUid,
        productId: widget.product.id,
        batchNumber: enteredBatch,
        supplierName: _supplierNameCtl.text.isEmpty ? null : _supplierNameCtl.text,
        purchasePrice: purchase,
        sellingPrice: selling,
        initialQuantity: qty,
        expiryDate: _selectedExpiryDate,
      );

      _clonedFromBatchNumber = null;
      _batchNumberCtl.clear();
      _purchasePriceCtl.clear();
      _sellingPriceCtl.clear();
      _quantityCtl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch received successfully!'), backgroundColor: AppColors.accent),
        );
        setState(() => _isSaving = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add batch: $e'), backgroundColor: AppColors.alertCritical),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  double? _calculateMargin() {
    final cost = double.tryParse(_purchasePriceCtl.text);
    final mrp = double.tryParse(_sellingPriceCtl.text);
    if (cost == null || mrp == null || mrp <= 0) return null;
    return ((mrp - cost) / mrp) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserRoleProvider) ?? UserRole.salesman;
    final batchesAsync = ref.watch(productBatchesProvider(widget.product.id));
    final canManage = role.canManageInventory;
    final margin = _calculateMargin();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.product.brandName,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Chip(
                                    label: Text(widget.product.unitType, style: const TextStyle(fontSize: 11)),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Generic: ${widget.product.genericName} • Category: ${widget.product.category}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.shelves, size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Physical Shelf: ${widget.product.shelfLocation}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Expanded Body: Top Form (if permitted) + Bottom Ledger
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Receive Batch Form (Multi-Supplier & Multi-Price)
                      if (canManage) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Procure / Receive New Batch (Multi-Supplier & Multi-Price)',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (margin != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: margin >= 0 ? AppColors.accent.withValues(alpha: 0.15) : AppColors.alertCritical.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Est. Gross Margin: ${margin.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: margin >= 0 ? AppColors.accent : AppColors.alertCritical,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (_clonedFromBatchNumber != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.amber.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Pre-filled with data from Batch #$_clonedFromBatchNumber. Please change the Batch Number before adding.',
                                            style: TextStyle(fontSize: 12, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 16),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () => setState(() => _clonedFromBatchNumber = null),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _batchNumberCtl,
                                        decoration: const InputDecoration(
                                          labelText: 'Batch Number *',
                                          hintText: 'e.g. B-2026-X01',
                                          prefixIcon: Icon(Icons.qr_code, size: 18),
                                        ),
                                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 3,
                                      child: Autocomplete<String>(
                                        initialValue: TextEditingValue(text: _supplierNameCtl.text),
                                        optionsBuilder: (textEditingValue) {
                                          if (textEditingValue.text.isEmpty) return _distributorSuggestions;
                                          return _distributorSuggestions.where((s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                                        },
                                        onSelected: (val) => _supplierNameCtl.text = val,
                                        fieldViewBuilder: (ctx, ctl, focusNode, onEditingComplete) {
                                          _supplierNameCtl.text = ctl.text;
                                          return TextFormField(
                                            controller: ctl,
                                            focusNode: focusNode,
                                            decoration: const InputDecoration(
                                              labelText: 'Supplier / Distributor Store *',
                                              hintText: 'e.g. Apex Pharma, MediGlobal',
                                              prefixIcon: Icon(Icons.local_shipping_outlined, size: 18),
                                            ),
                                            validator: (v) => v == null || v.trim().isEmpty ? 'Supplier required' : null,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _quantityCtl,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Units Received *',
                                          hintText: 'e.g. 100',
                                          prefixIcon: Icon(Icons.numbers, size: 18),
                                        ),
                                        validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid qty' : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _purchasePriceCtl,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (_) => setState(() {}),
                                        decoration: const InputDecoration(
                                          labelText: 'Purchase Cost Price (\$) *',
                                          hintText: 'e.g. 1.25',
                                          prefixIcon: Icon(Icons.money_off, size: 18),
                                        ),
                                        validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid cost' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _sellingPriceCtl,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (_) => setState(() {}),
                                        decoration: const InputDecoration(
                                          labelText: 'Selling Price MRP (\$) *',
                                          hintText: 'e.g. 2.50',
                                          prefixIcon: Icon(Icons.attach_money, size: 18),
                                        ),
                                        validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid price' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: _selectedExpiryDate,
                                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                                          );
                                          if (picked != null) {
                                            setState(() => _selectedExpiryDate = picked);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                            labelText: 'Expiry Date (FEFO) *',
                                            prefixIcon: Icon(Icons.calendar_month, size: 18),
                                          ),
                                          child: Text(
                                            DateFormat('yyyy-MM-dd').format(_selectedExpiryDate),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                      ),
                                      icon: _isSaving
                                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : const Icon(Icons.check, size: 18),
                                      label: const Text('Add Batch'),
                                      onPressed: _isSaving ? null : _submitNewBatch,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Section 2: Existing Batches Ledger
                      const Row(
                        children: [
                          Icon(Icons.format_list_bulleted, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Active & Historical Batches Ledger (FEFO Sorted)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      batchesAsync.when(
                        loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                        error: (err, _) => Text('Error loading batches: $err', style: const TextStyle(color: AppColors.alertCritical)),
                        data: (batches) {
                          if (batches.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text('No batches registered yet. Add a batch above to receive inventory.', style: TextStyle(color: AppColors.textSecondary)),
                              ),
                            );
                          }

                          // Find FEFO priority batch (earliest non-expired batch with stock > 0)
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final activeNonExpiredBatches = batches.where((b) => b.currentStock > 0 && !b.expiryDate.isBefore(today)).toList()
                            ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
                          final fefoPriorityId = activeNonExpiredBatches.isNotEmpty ? activeNonExpiredBatches.first.id : null;

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: batches.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final batch = batches[i];
                                final isExpired = batch.expiryDate.isBefore(today);
                                final isFefoPriority = batch.id == fefoPriorityId;
                                final daysRemaining = batch.expiryDate.difference(today).inDays;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      // Status Indicator
                                      Container(
                                        width: 10,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isExpired
                                              ? AppColors.alertCritical
                                              : (daysRemaining <= 30
                                                  ? AppColors.alertUrgent
                                                  : (daysRemaining <= 60
                                                      ? AppColors.alertWarning
                                                      : (daysRemaining <= 90 ? AppColors.alertCaution : AppColors.alertSafe))),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Batch Details
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                Text(
                                                  'Batch #${batch.batchNumber}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                ),
                                                if (isFefoPriority)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.accent.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.priority_high, size: 12, color: AppColors.accent),
                                                        Text('FEFO Priority #1', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                                      ],
                                                    ),
                                                  ),
                                                if (isExpired)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.alertCritical.withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Text('🔴 EXPIRED (Blocked from POS)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.alertCritical)),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.store, size: 14, color: AppColors.textMuted),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Supplier: ${batch.supplierName ?? 'Direct Purchase'}',
                                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Pricing
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Cost: \$${batch.purchasePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                            Text('Retail MRP: \$${batch.sellingPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                          ],
                                        ),
                                      ),

                                      // Stock Count
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${batch.currentStock} / ${batch.initialQuantity} units',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: batch.currentStock == 0 ? AppColors.textMuted : AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              batch.currentStock == 0 ? 'Out of stock' : 'Available',
                                              style: TextStyle(fontSize: 11, color: batch.currentStock == 0 ? AppColors.alertCritical : AppColors.alertSafe),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Expiry Countdown
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('yyyy-MM-dd').format(batch.expiryDate),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isExpired ? AppColors.alertCritical : AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              isExpired ? 'Expired ${-daysRemaining} days ago' : '$daysRemaining days remaining',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: isExpired || daysRemaining <= 30 ? FontWeight.bold : FontWeight.normal,
                                                color: isExpired
                                                    ? AppColors.alertCritical
                                                    : (daysRemaining <= 30 ? AppColors.alertUrgent : AppColors.textMuted),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Actions (Add Same Batch, Adjust or Delete)
                                      if (canManage)
                                        PopupMenuButton<String>(
                                          key: ValueKey('batch_popup_${batch.id}'),
                                          icon: const Icon(Icons.more_vert, size: 20),
                                          onSelected: (val) async {
                                            if (val == 'same_batch') {
                                              _populateSameBatch(batch);
                                            } else if (val == 'adjust') {
                                              _showAdjustStockDialog(context, batch);
                                            } else if (val == 'delete') {
                                              final repo = ref.read(inventoryRepositoryProvider);
                                              await repo.deleteBatch(widget.product.pharmacyUid, batch.id);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(
                                              value: 'same_batch',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.control_point_duplicate, size: 18, color: AppColors.primary),
                                                  SizedBox(width: 8),
                                                  Text('Add Same Batch'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(value: 'adjust', child: Text('Adjust Stock Count')),
                                            const PopupMenuItem(value: 'delete', child: Text('Delete Batch', style: TextStyle(color: AppColors.alertCritical))),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdjustStockDialog(BuildContext context, ProductBatch batch) {
    final stockCtl = TextEditingController(text: '${batch.currentStock}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Adjust Stock for Batch #${batch.batchNumber}'),
        content: SizedBox(
          width: 320,
          child: TextField(
            controller: stockCtl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'New Remaining Stock Units'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final newStock = int.tryParse(stockCtl.text);
              if (newStock != null && newStock >= 0) {
                final repo = ref.read(inventoryRepositoryProvider);
                await repo.updateBatch(
                  batchId: batch.id,
                  pharmacyUid: batch.pharmacyUid,
                  productId: batch.productId,
                  batchNumber: batch.batchNumber,
                  supplierName: batch.supplierName,
                  purchasePrice: batch.purchasePrice,
                  sellingPrice: batch.sellingPrice,
                  currentStock: newStock,
                  expiryDate: batch.expiryDate,
                );
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save Count'),
          ),
        ],
      ),
    );
  }
}
