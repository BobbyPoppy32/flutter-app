import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/hero_widgets.dart';
import 'package:flutter_app/views/widgets/request_date_format.dart';

class RequestHelpFormPage extends StatefulWidget {
  const RequestHelpFormPage({super.key, this.initialTaskType});

  // Pre-selects a category when arriving from the Home dashboard's
  // quick-access grid, so tapping a tile there is a real shortcut rather
  // than just a decorative icon.
  final RequestTaskType? initialTaskType;

  @override
  State<RequestHelpFormPage> createState() => _RequestHelpFormPageState();
}

class _RequestHelpFormPageState extends State<RequestHelpFormPage> {
  final _formKey = GlobalKey<FormState>();
  RequestTaskType? _taskType;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _dateTime;

  bool _showTaskTypeError = false;
  bool _showDateTimeError = false;

  @override
  void initState() {
    super.initState();
    _taskType = widget.initialTaskType;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HeroWidget(title: "Request Help"),
                const SizedBox(height: 24),

                const Text(
                  "What do you need help with?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    for (final type in RequestTaskType.values) ...[
                      _TaskTypeTile(
                        type: type,
                        selected: _taskType == type,
                        onTap: () => setState(() {
                          _taskType = type;
                          _showTaskTypeError = false;
                        }),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
                if (_showTaskTypeError) ...[
                  const SizedBox(height: 4),
                  const Text(
                    "Please choose what you need help with",
                    style: TextStyle(color: AppColors.emergencyRed, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 16),

                const Text(
                  "Where?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _locationController,
                  hint: "e.g. Sunview Medical Centre, 123 Main St",
                  icon: Icons.location_on_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Enter a location" : null,
                ),
                const SizedBox(height: 16),

                const Text(
                  "When?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 10),
                _DateTimeTile(
                  dateTime: _dateTime,
                  onTap: _pickDateTime,
                ),
                if (_showDateTimeError) ...[
                  const SizedBox(height: 4),
                  const Text(
                    "Please choose a date and time",
                    style: TextStyle(color: AppColors.emergencyRed, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 16),

                const Text(
                  "Notes (optional)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _notesController,
                  hint: "Anything your helper should know",
                  maxLines: 3,
                ),
                const SizedBox(height: 28),

                GradientPillButton(label: "Post Request", onPressed: _submit, height: 56),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _showDateTimeError = false;
    });
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    final taskTypeValid = _taskType != null;
    final dateTimeValid = _dateTime != null;

    setState(() {
      _showTaskTypeError = !taskTypeValid;
      _showDateTimeError = !dateTimeValid;
    });

    if (!formValid || !taskTypeValid || !dateTimeValid) return;

    await appState.addRequest(
      taskType: _taskType!,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      locationText: _locationController.text.trim(),
      requestedDateTime: _dateTime!,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request posted")),
    );
  }
}

class _TaskTypeTile extends StatelessWidget {
  const _TaskTypeTile({required this.type, required this.selected, required this.onTap});
  final RequestTaskType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.tealStart.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.tealStart : Colors.transparent,
            width: 2,
          ),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.tealStart : AppColors.textGrey,
            ),
            const SizedBox(width: 14),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({required this.dateTime, required this.onTap});
  final DateTime? dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.tealStart),
            const SizedBox(width: 14),
            Text(
              dateTime == null ? "Select date & time" : formatRequestDateTime(dateTime!),
              style: const TextStyle(fontSize: 16, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
