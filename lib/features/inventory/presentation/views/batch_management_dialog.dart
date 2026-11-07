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
  final _supplierNameCtl = TextEditingController();
  final _quantityCtl = TextEditingController();
  final _totalCostCtl = TextEditingController();
  final _purchasePriceCtl = TextEditingController();
  final _sellingPriceCtl = TextEditingController();
  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 365));

  bool _isSaving = false;
  bool _isCalculatingCost = false;
  String? _clonedFromBatchNumber;
  ProductBatch? _editingBatch;
  TextEditingController? _autocompleteSupplierCtl;

  List<String> get _distributorSuggestions {
    final mfg = widget.product.manufacturer.trim();
    final suggestions = <String>[];
    if (mfg.isNotEmpty) suggestions.add(mfg);
    suggestions.addAll(const [
      'MediGlobal Supplies',
      'Apex Pharma Logistics',
      'City Wholesale Distributors',
      'PharmaCare Direct',
      'National Medical Stores',
    ]);
    return suggestions;
  }

  @override
  void initState() {
    super.initState();
    final mfg = widget.product.manufacturer.trim();
    _supplierNameCtl.text = mfg.isNotEmpty ? mfg : 'Not Available';
    _batchNumberCtl.text = _generateBatchNumber();
  }

  @override
  void dispose() {
    _batchNumberCtl.dispose();
    _supplierNameCtl.dispose();
    _quantityCtl.dispose();
    _totalCostCtl.dispose();
    _purchasePriceCtl.dispose();
    _sellingPriceCtl.dispose();
    super.dispose();
  }

  void _onTotalCostChanged(String val) {
    if (_isCalculatingCost) return;
    final totalCost = double.tryParse(val.trim());
    final qty = int.tryParse(_quantityCtl.text.trim());

    if (totalCost != null && qty != null && qty > 0) {
      _isCalculatingCost = true;
      final unitCost = totalCost / qty;
      _purchasePriceCtl.text = unitCost.toStringAsFixed(2);
      _isCalculatingCost = false;
    }
    setState(() {});
  }

  void _onPurchasePriceChanged(String val) {
    if (_isCalculatingCost) return;
    final unitCost = double.tryParse(val.trim());
    final qty = int.tryParse(_quantityCtl.text.trim());

    if (unitCost != null && qty != null && qty > 0) {
      _isCalculatingCost = true;
      final total = unitCost * qty;
      _totalCostCtl.text = total.toStringAsFixed(2);
      _isCalculatingCost = false;
    }
    setState(() {});
  }

  void _onQuantityChanged(String val) {
    if (_isCalculatingCost) return;
    final qty = int.tryParse(val.trim());
    if (qty != null && qty > 0) {
      final totalCost = double.tryParse(_totalCostCtl.text.trim());
      final unitCost = double.tryParse(_purchasePriceCtl.text.trim());

      if (totalCost != null && totalCost > 0) {
        _isCalculatingCost = true;
        final calculatedUnitCost = totalCost / qty;
        _purchasePriceCtl.text = calculatedUnitCost.toStringAsFixed(2);
        _isCalculatingCost = false;
      } else if (unitCost != null && unitCost > 0) {
        _isCalculatingCost = true;
        final calculatedTotal = unitCost * qty;
        _totalCostCtl.text = calculatedTotal.toStringAsFixed(2);
        _isCalculatingCost = false;
      }
    }
    setState(() {});
  }

  String _generateBatchNumber({List<ProductBatch>? existingBatches}) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final prefix = 'BA-$dateStr-';

    int maxSeq = 0;
    if (existingBatches != null) {
      for (final b in existingBatches) {
        final num = b.batchNumber.trim();
        if (num.startsWith(prefix)) {
          final remainder = num.substring(prefix.length);
          final parsed = int.tryParse(remainder);
          if (parsed != null && parsed > maxSeq) {
            maxSeq = parsed;
          }
        }
      }
    }
    final nextSeq = (maxSeq + 1).toString().padLeft(2, '0');
    return '$prefix$nextSeq';
  }

  void _cancelEdit({List<ProductBatch>? existingBatches}) {
    setState(() {
      _editingBatch = null;
      _clonedFromBatchNumber = null;
      _batchNumberCtl.text = _generateBatchNumber(existingBatches: existingBatches);
      final mfg = widget.product.manufacturer.trim();
      _supplierNameCtl.text = mfg.isNotEmpty ? mfg : 'Not Available';
      _autocompleteSupplierCtl?.text = _supplierNameCtl.text;
      _quantityCtl.clear();
      _totalCostCtl.clear();
      _purchasePriceCtl.clear();
      _sellingPriceCtl.clear();
      _selectedExpiryDate = DateTime.now().add(const Duration(days: 365));
    });
  }

  void _populateSameBatch(ProductBatch batch) {
    final currentBatches = ref.read(productBatchesProvider(widget.product.id)).asData?.value;
    final newBatchNum = _generateBatchNumber(existingBatches: currentBatches);
    final qty = batch.initialQuantity > 0 ? batch.initialQuantity : batch.currentStock;

    setState(() {
      _editingBatch = null;
      _clonedFromBatchNumber = batch.batchNumber;
      _batchNumberCtl.text = newBatchNum;
      _supplierNameCtl.text = (batch.supplierName != null && batch.supplierName!.trim().isNotEmpty)
          ? batch.supplierName!.trim()
          : (widget.product.manufacturer.trim().isNotEmpty ? widget.product.manufacturer.trim() : 'Not Available');
      _autocompleteSupplierCtl?.text = _supplierNameCtl.text;
      _quantityCtl.text = '$qty';
      _purchasePriceCtl.text = batch.purchasePrice.toStringAsFixed(2);
      _totalCostCtl.text = (batch.purchasePrice * qty).toStringAsFixed(2);
      _sellingPriceCtl.text = batch.sellingPrice.toStringAsFixed(2);
      _selectedExpiryDate = batch.expiryDate;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form populated from Batch #${batch.batchNumber} with new Batch #$newBatchNum'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _startEditingBatch(ProductBatch batch) {
    setState(() {
      _editingBatch = batch;
      _clonedFromBatchNumber = null;
      _batchNumberCtl.text = batch.batchNumber;
      _supplierNameCtl.text = (batch.supplierName != null && batch.supplierName!.trim().isNotEmpty)
          ? batch.supplierName!.trim()
          : (widget.product.manufacturer.trim().isNotEmpty ? widget.product.manufacturer.trim() : 'Not Available');
      _autocompleteSupplierCtl?.text = _supplierNameCtl.text;
      _quantityCtl.text = '${batch.currentStock}';
      _purchasePriceCtl.text = batch.purchasePrice.toStringAsFixed(2);
      _totalCostCtl.text = (batch.purchasePrice * batch.currentStock).toStringAsFixed(2);
      _sellingPriceCtl.text = batch.sellingPrice.toStringAsFixed(2);
      _selectedExpiryDate = batch.expiryDate;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing Batch #${batch.batchNumber}. Click "Edit Batch" when done.'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _showDuplicateBatchDialog(String enteredBatch) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.alertUrgent, size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text('Duplicate Batch Number', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(
          'A batch with number "#$enteredBatch" already exists for this medicine.\n\nPlease enter a new, unique Batch Number.',
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
  }

  Future<void> _submitBatch() async {
    if (!_formKey.currentState!.validate()) return;

    final enteredBatch = _batchNumberCtl.text.trim();
    final currentBatches = ref.read(productBatchesProvider(widget.product.id)).asData?.value ?? [];

    if (_editingBatch != null) {
      // Editing existing batch
      final duplicateExists = currentBatches.any(
        (b) => b.id != _editingBatch!.id && b.batchNumber.trim().toLowerCase() == enteredBatch.toLowerCase(),
      );
      if (duplicateExists) {
        await _showDuplicateBatchDialog(enteredBatch);
        return;
      }

      setState(() => _isSaving = true);
      final repo = ref.read(inventoryRepositoryProvider);

      try {
        final purchase = double.parse(_purchasePriceCtl.text.trim());
        final selling = double.parse(_sellingPriceCtl.text.trim());
        final qty = int.parse(_quantityCtl.text.trim());

        await repo.updateBatch(
          batchId: _editingBatch!.id,
          pharmacyUid: _editingBatch!.pharmacyUid,
          productId: _editingBatch!.productId,
          batchNumber: enteredBatch,
          supplierName: _supplierNameCtl.text.trim(),
          purchasePrice: purchase,
          sellingPrice: selling,
          currentStock: qty,
          expiryDate: _selectedExpiryDate,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Batch #$enteredBatch updated successfully!'),
              backgroundColor: AppColors.accent,
            ),
          );
          _cancelEdit(existingBatches: currentBatches);
          setState(() => _isSaving = false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update batch: $e'), backgroundColor: AppColors.alertCritical),
          );
          setState(() => _isSaving = false);
        }
      }
    } else {
      // Adding new batch
      final alreadyExists = currentBatches.any((b) => b.batchNumber.trim().toLowerCase() == enteredBatch.toLowerCase());
      if (alreadyExists) {
        await _showDuplicateBatchDialog(enteredBatch);
        return;
      }

      final session = ref.read(currentUserSessionProvider);
      if (session == null) return;

      setState(() => _isSaving = true);
      final repo = ref.read(inventoryRepositoryProvider);

      try {
        final purchase = double.parse(_purchasePriceCtl.text.trim());
        final selling = double.parse(_sellingPriceCtl.text.trim());
        final qty = int.parse(_quantityCtl.text.trim());

        await repo.addBatch(
          pharmacyUid: session.pharmacyUid,
          productId: widget.product.id,
          batchNumber: enteredBatch,
          supplierName: _supplierNameCtl.text.trim(),
          purchasePrice: purchase,
          sellingPrice: selling,
          initialQuantity: qty,
          expiryDate: _selectedExpiryDate,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Batch #$enteredBatch added successfully!'),
              backgroundColor: AppColors.accent,
            ),
          );
          _cancelEdit(existingBatches: currentBatches);
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
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            _editingBatch != null ? Icons.edit_note : Icons.add_shopping_cart,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _editingBatch != null
                                                  ? 'Edit Batch Details (Batch #${_editingBatch!.batchNumber})'
                                                  : 'Procure / Receive New Batch (Multi-Supplier & Multi-Price)',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_editingBatch != null)
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.alertCritical,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        icon: const Icon(Icons.close, size: 16),
                                        label: const Text('Cancel Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                                        onPressed: () => _cancelEdit(),
                                      ),
                                    if (margin != null && _editingBatch == null)
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
                                if (_editingBatch != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Editing Batch #${_editingBatch!.batchNumber}. Modify the information below and click "Edit Batch" to save.',
                                            style: const TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (_clonedFromBatchNumber != null) ...[
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
                                            'Pre-filled with data from Batch #$_clonedFromBatchNumber. Batch number has been newly generated.',
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
                                      flex: 5,
                                      child: TextFormField(
                                        controller: _batchNumberCtl,
                                        decoration: InputDecoration(
                                          labelText: 'Batch Number *',
                                          hintText: 'e.g. BA-20261106-01',
                                          prefixIcon: const Icon(Icons.qr_code, size: 18),
                                          suffixIcon: _editingBatch == null
                                              ? IconButton(
                                                  icon: const Icon(Icons.refresh, size: 16),
                                                  tooltip: 'Regenerate Batch Number',
                                                  onPressed: () {
                                                    final batches = ref.read(productBatchesProvider(widget.product.id)).asData?.value;
                                                    setState(() {
                                                      _batchNumberCtl.text = _generateBatchNumber(existingBatches: batches);
                                                    });
                                                  },
                                                )
                                              : null,
                                        ),
                                        validator: (v) => v == null || v.trim().isEmpty ? 'Batch number required' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 6,
                                      child: Autocomplete<String>(
                                        initialValue: TextEditingValue(text: _supplierNameCtl.text),
                                        optionsBuilder: (textEditingValue) {
                                          final suggestions = _distributorSuggestions;
                                          if (textEditingValue.text.isEmpty) return suggestions;
                                          return suggestions.where((s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                                        },
                                        onSelected: (val) {
                                          _supplierNameCtl.text = val;
                                          _autocompleteSupplierCtl?.text = val;
                                        },
                                        fieldViewBuilder: (ctx, ctl, focusNode, onEditingComplete) {
                                          _autocompleteSupplierCtl = ctl;
                                          if (ctl.text != _supplierNameCtl.text && _supplierNameCtl.text.isNotEmpty) {
                                            ctl.text = _supplierNameCtl.text;
                                          }
                                          ctl.addListener(() {
                                            _supplierNameCtl.text = ctl.text;
                                          });
                                          return TextFormField(
                                            controller: ctl,
                                            focusNode: focusNode,
                                            decoration: const InputDecoration(
                                              labelText: 'Supplier / Distributor Store *',
                                              hintText: 'e.g. Acme, Apex Pharma, MediGlobal',
                                              prefixIcon: Icon(Icons.local_shipping_outlined, size: 18),
                                            ),
                                            validator: (v) => v == null || v.trim().isEmpty ? 'Supplier required' : null,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 4,
                                      child: TextFormField(
                                        controller: _quantityCtl,
                                        keyboardType: TextInputType.number,
                                        onChanged: _onQuantityChanged,
                                        decoration: InputDecoration(
                                          labelText: _editingBatch != null ? 'Stock Units *' : 'Units Received *',
                                          hintText: 'e.g. 100',
                                          prefixIcon: const Icon(Icons.numbers, size: 18),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) return 'Quantity required';
                                          final val = int.tryParse(v.trim());
                                          if (val == null || val < 0) return 'Invalid qty';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 5,
                                      child: TextFormField(
                                        controller: _totalCostCtl,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        onChanged: _onTotalCostChanged,
                                        decoration: const InputDecoration(
                                          labelText: 'Total Cost (৳) *',
                                          hintText: 'e.g. 350.00',
                                          prefixIcon: Icon(Icons.calculate_outlined, size: 18),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) return 'Total cost required';
                                          final val = double.tryParse(v.trim());
                                          if (val == null || val < 0) return 'Invalid total';
                                          return null;
                                        },
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
                                        onChanged: _onPurchasePriceChanged,
                                        decoration: const InputDecoration(
                                          labelText: 'Purchase Cost Price (৳) *',
                                          hintText: 'e.g. 1.25',
                                          prefixIcon: Icon(Icons.money_off, size: 18),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) return 'Cost required';
                                          final val = double.tryParse(v.trim());
                                          if (val == null || val < 0) return 'Invalid cost';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _sellingPriceCtl,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (_) => setState(() {}),
                                        decoration: const InputDecoration(
                                          labelText: 'Selling Price MRP (৳) *',
                                          hintText: 'e.g. 2.50',
                                          prefixIcon: Icon(Icons.attach_money, size: 18),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) return 'Price required';
                                          final val = double.tryParse(v.trim());
                                          if (val == null || val <= 0) return 'Invalid price';
                                          return null;
                                        },
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
                                            DateFormat('dd-MM-yyyy').format(_selectedExpiryDate),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _editingBatch != null ? AppColors.primaryDark : AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                      ),
                                      icon: _isSaving
                                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Icon(_editingBatch != null ? Icons.save_outlined : Icons.check, size: 18),
                                      label: Text(_editingBatch != null ? 'Edit Batch' : 'Add Batch'),
                                      onPressed: _isSaving ? null : _submitBatch,
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
                                            Text('Cost: ৳${batch.purchasePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                            Text('Retail MRP: ৳${batch.sellingPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
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
                                              DateFormat('dd-MM-yyyy').format(batch.expiryDate),
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

                                      // Actions (Add Same Batch, Edit Batch or Delete)
                                      if (canManage)
                                        PopupMenuButton<String>(
                                          key: ValueKey('batch_popup_${batch.id}'),
                                          icon: const Icon(Icons.more_vert, size: 20),
                                          onSelected: (val) async {
                                            if (val == 'same_batch') {
                                              _populateSameBatch(batch);
                                            } else if (val == 'edit') {
                                              _startEditingBatch(batch);
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
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryDark),
                                                  SizedBox(width: 8),
                                                  Text('Edit Batch'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete_outline, size: 18, color: AppColors.alertCritical),
                                                  SizedBox(width: 8),
                                                  Text('Delete Batch', style: TextStyle(color: AppColors.alertCritical)),
                                                ],
                                              ),
                                            ),
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
}
