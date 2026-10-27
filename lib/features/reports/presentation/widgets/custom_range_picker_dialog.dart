import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/features/reports/domain/report_models.dart';

/// Modal dialog allowing selection of date presets or custom date range.
class CustomRangePickerDialog extends StatefulWidget {
  final DateTimeRange initialRange;

  const CustomRangePickerDialog({
    super.key,
    required this.initialRange,
  });

  @override
  State<CustomRangePickerDialog> createState() => _CustomRangePickerDialogState();
}

class _CustomRangePickerDialogState extends State<CustomRangePickerDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialRange.start;
    _endDate = widget.initialRange.end;
  }

  void _applyPreset(DatePeriodFilter preset) {
    final range = preset.toDateRange(DateTime.now());
    setState(() {
      _startDate = range.start;
      _endDate = range.end;
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
        if (_endDate.isBefore(_startDate)) {
          _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59, 999);
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59, 999);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.date_range, color: AppColors.primary, size: 26),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Select Custom Reporting Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Quick Presets
            const Text(
              'Quick Presets:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.history, size: 16),
                  label: const Text('Last 7 Days'),
                  onPressed: () => _applyPreset(DatePeriodFilter.last7Days),
                ),
                ActionChip(
                  avatar: const Icon(Icons.calendar_view_month, size: 16),
                  label: const Text('Last 30 Days'),
                  onPressed: () => _applyPreset(DatePeriodFilter.last30Days),
                ),
                ActionChip(
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('This Year (YTD)'),
                  onPressed: () => _applyPreset(DatePeriodFilter.thisYear),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date Pickers Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickStartDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(_dateFormat.format(_startDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickEndDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(_dateFormat.format(_endDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    final range = DateTimeRange(start: _startDate, end: _endDate);
                    Navigator.of(context).pop(range);
                  },
                  child: const Text('Apply Filter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
