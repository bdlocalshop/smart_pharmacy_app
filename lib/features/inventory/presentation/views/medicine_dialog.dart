import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';
import '../../domain/unit_normalizer.dart';
import 'csv_import_dialog.dart';

/// Modal dialog for adding or editing a medicine in the master catalog.
class MedicineDialog extends ConsumerStatefulWidget {
  final Product? existingProduct;

  const MedicineDialog({super.key, this.existingProduct});

  @override
  ConsumerState<MedicineDialog> createState() => _MedicineDialogState();
}

class _MedicineDialogState extends ConsumerState<MedicineDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _brandNameCtl;
  late final TextEditingController _genericNameCtl;
  late final TextEditingController _categoryCtl;
  late final TextEditingController _manufacturerCtl;
  late final TextEditingController _shelfLocationCtl;
  late final TextEditingController _minStockCtl;
  String _selectedUnitType = 'Unknown';
  bool _isSaving = false;
  final Set<String> _customUnits = {};

  static const List<String> _baseUnitTypes = [
    'Unknown',
    'Tablet',
    'Capsule',
    'Strip',
    'Syrup',
    'Suspension',
    'Box',
    'Vial',
    'Ointment',
    'Oral Gel',
    'Suppository',
    'Drop',
    'Injection',
    'Inhaler',
    'Cream',
    'Powder',
    'Sachet',
  ];

  final List<String> _commonCategories = const [
    'Analgesic / Antipyretic',
    'Antibiotic',
    'Antihistamine',
    'Gastrointestinal / PPI',
    'Antidiabetic',
    'Cardiovascular',
    'Respiratory',
    'Vitamins & Supplements',
    'Dermatological',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _brandNameCtl = TextEditingController(text: p?.brandName ?? '');
    _genericNameCtl = TextEditingController(text: p?.genericName ?? '');
    _categoryCtl = TextEditingController(text: p?.category ?? _commonCategories.first);
    _manufacturerCtl = TextEditingController(text: p?.manufacturer ?? '');
    _shelfLocationCtl = TextEditingController(text: p?.shelfLocation ?? 'Rack A-1');
    _minStockCtl = TextEditingController(text: '${p?.minStockAlert ?? 10}');
    if (p != null && p.unitType.trim().isNotEmpty) {
      _selectedUnitType = p.unitType.trim();
    } else {
      _selectedUnitType = 'Unknown';
    }
  }

  @override
  void dispose() {
    _brandNameCtl.dispose();
    _genericNameCtl.dispose();
    _categoryCtl.dispose();
    _manufacturerCtl.dispose();
    _shelfLocationCtl.dispose();
    _minStockCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final session = ref.read(currentUserSessionProvider);
    if (session == null) return;

    setState(() => _isSaving = true);
    final repo = ref.read(inventoryRepositoryProvider);
    final minStock = int.tryParse(_minStockCtl.text) ?? 10;

    try {
      if (widget.existingProduct == null) {
        // Add new
        await repo.addProduct(
          pharmacyUid: session.pharmacyUid,
          brandName: _brandNameCtl.text,
          genericName: _genericNameCtl.text,
          category: _categoryCtl.text,
          manufacturer: _manufacturerCtl.text,
          shelfLocation: _shelfLocationCtl.text,
          unitType: _selectedUnitType,
          minStockAlert: minStock,
        );
      } else {
        // Edit existing
        await repo.updateProduct(
          productId: widget.existingProduct!.id,
          pharmacyUid: session.pharmacyUid,
          brandName: _brandNameCtl.text,
          genericName: _genericNameCtl.text,
          category: _categoryCtl.text,
          manufacturer: _manufacturerCtl.text,
          shelfLocation: _shelfLocationCtl.text,
          unitType: _selectedUnitType,
          minStockAlert: minStock,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save medicine: $e'), backgroundColor: AppColors.alertCritical),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openAddMultipleDialog() async {
    final importedCount = await showDialog<int>(
      context: context,
      builder: (ctx) => const CsvImportDialog(),
    );

    if (importedCount != null && importedCount > 0 && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported $importedCount medicines from CSV!'),
          backgroundColor: AppColors.alertSafe,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _promptAddCustomUnit() async {
    final ctl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final customUnit = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Dispensing Unit Type'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Unit Type Name *',
              hintText: 'e.g. Ampoule, Patch, Nebule, Sachet',
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a unit name' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, ctl.text.trim());
              }
            },
            child: const Text('Add Unit Type'),
          ),
        ],
      ),
    );

    if (customUnit != null && customUnit.isNotEmpty) {
      final normalized = UnitNormalizer.normalize(customUnit);
      setState(() {
        _customUnits.add(normalized);
        _selectedUnitType = normalized;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProduct != null;
    final dbUnits = ref.watch(distinctUnitTypesProvider).value ?? const [];

    // Dynamically assemble unique unit types with 'Unknown' guaranteed as the first item
    final unitOptions = <String>[
      'Unknown',
      ..._baseUnitTypes.skip(1),
      ...dbUnits.where((u) => u.toLowerCase() != 'unknown'),
      ..._customUnits.where((u) => u.toLowerCase() != 'unknown'),
      if (widget.existingProduct != null &&
          widget.existingProduct!.unitType.trim().isNotEmpty &&
          widget.existingProduct!.unitType.toLowerCase() != 'unknown')
        widget.existingProduct!.unitType.trim(),
    ];

    final seen = <String>{};
    final uniqueUnitTypes = <String>[];
    for (final u in unitOptions) {
      final key = u.trim().toLowerCase();
      if (seen.add(key)) {
        uniqueUnitTypes.add(u.trim());
      }
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(isEditing ? Icons.edit_note : Icons.add_circle_outline, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(isEditing ? 'Edit Medicine Details' : 'Add New Medicine to Catalog'),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _brandNameCtl,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Brand / Commercial Name *',
                          hintText: 'e.g. Panadol 500mg, Amoxil',
                          prefixIcon: Icon(Icons.medication, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Brand name is required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _genericNameCtl,
                        decoration: const InputDecoration(
                          labelText: 'Generic Formula *',
                          hintText: 'e.g. Paracetamol, Amoxicillin',
                          prefixIcon: Icon(Icons.science_outlined, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Generic formula is required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Autocomplete<String>(
                        initialValue: TextEditingValue(text: _categoryCtl.text),
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty) return _commonCategories;
                          return _commonCategories.where((c) => c.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (val) => _categoryCtl.text = val,
                        fieldViewBuilder: (ctx, ctl, focusNode, onEditingComplete) {
                          _categoryCtl.text = ctl.text;
                          return TextFormField(
                            controller: ctl,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Therapeutic Category *',
                              prefixIcon: Icon(Icons.category_outlined, size: 20),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Category is required' : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _manufacturerCtl,
                        decoration: const InputDecoration(
                          labelText: 'Manufacturer / Brand Pharma *',
                          hintText: 'e.g. GSK, Pfizer, Square',
                          prefixIcon: Icon(Icons.factory_outlined, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Manufacturer is required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _shelfLocationCtl,
                        decoration: const InputDecoration(
                          labelText: 'Physical Shelf Location *',
                          hintText: 'e.g. Rack A-1, Cold Storage B',
                          prefixIcon: Icon(Icons.shelves, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Shelf location is required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('unit_type_$_selectedUnitType'),
                        isExpanded: true,
                        initialValue: uniqueUnitTypes.contains(_selectedUnitType) ? _selectedUnitType : 'Unknown',
                        decoration: const InputDecoration(
                          labelText: 'Dispensing Unit Type',
                          prefixIcon: Icon(Icons.local_pharmacy_outlined, size: 20),
                        ),
                        items: [
                          ...uniqueUnitTypes.map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(
                                  u,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: u == 'Unknown' ? FontWeight.w600 : FontWeight.normal,
                                    color: u == 'Unknown' ? Colors.orange.shade800 : null,
                                  ),
                                ),
                              )),
                          const DropdownMenuItem(
                            value: '__custom__',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '+ Custom Unit...',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val == '__custom__') {
                            _promptAddCustomUnit();
                          } else if (val != null) {
                            setState(() => _selectedUnitType = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minStockCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minimum Reorder Alert Threshold *',
                          hintText: 'e.g. 10 or 25 units',
                          prefixIcon: Icon(Icons.warning_amber_rounded, size: 20),
                          helperText: 'Triggers low stock warnings when non-expired inventory falls to or below this count.',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Threshold is required';
                          if (int.tryParse(v) == null) return 'Must be a valid integer';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        Row(
          children: [
            if (!isEditing)
              OutlinedButton.icon(
                key: const ValueKey('add_multiple_button'),
                icon: const Icon(Icons.upload_file_outlined, size: 18),
                label: const Text('Add Multiple'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: _isSaving ? null : _openAddMultipleDialog,
              ),
            const Spacer(),
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save, size: 18),
              label: Text(isEditing ? 'Save Changes' : 'Add Medicine'),
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      ],
    );
  }
}
