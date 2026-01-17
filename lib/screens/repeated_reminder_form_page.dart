import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../model/repeated_reminder_model.dart';
import '../enums/repeat_type.dart';
import '../enums/reminder_offset.dart';

class RepeatedReminderFormPage extends StatefulWidget {
  final RepeatedReminderModel? reminder;

  const RepeatedReminderFormPage({super.key, this.reminder});

  @override
  State<RepeatedReminderFormPage> createState() =>
      _RepeatedReminderFormPageState();
}

class _RepeatedReminderFormPageState extends State<RepeatedReminderFormPage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime startDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  RepeatType repeatType = RepeatType.Onece;
  ReminderOffset reminderOffset = ReminderOffset.atTime;
  bool isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.reminder != null) {
      final r = widget.reminder!;
      _titleController.text = r.title;
      _noteController.text = r.note ?? '';
      startDate = r.startDate;
      selectedTime = TimeOfDay.fromDateTime(r.time);
      repeatType = r.repeatType;
      reminderOffset = r.reminderOffset;
      isActive = r.isActive;
    }
  }

  void saveReminder() {
    final box = Hive.box<RepeatedReminderModel>('repeatedReminderBox');

    final time = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (widget.reminder == null) {
      box.add(
        RepeatedReminderModel(
          title: _titleController.text,
          note: _noteController.text,
          startDate: startDate,
          time: time,
          repeatType: repeatType,
          reminderOffset: reminderOffset,
          isActive: isActive,
        ),
      );
    } else {
      widget.reminder!
        ..title = _titleController.text
        ..note = _noteController.text
        ..startDate = startDate
        ..time = time
        ..repeatType = repeatType
        ..reminderOffset = reminderOffset
        ..isActive = isActive
        ..save();
    }

    Navigator.pop(context);
  }

  Widget _section(String title, IconData icon, Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.reminder == null
              ? 'New Repeated Reminder'
              : 'Edit Repeated Reminder',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 📝 Details
            _section(
              'Reminder Details',
              Icons.edit_note,
              Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Reminder title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            // 📅 Start Date & Time
            _section(
              'Schedule',
              Icons.schedule,
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Start Date'),
                    subtitle: Text(
                      startDate.toLocal().toString().split(' ')[0],
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => startDate = date);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Time'),
                    subtitle: Text(selectedTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),
                ],
              ),
            ),

            // 🔁 Repeat
            _section(
              'Repeat',
              Icons.repeat,
              DropdownButtonFormField<RepeatType>(
                value: repeatType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: RepeatType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name));
                }).toList(),
                onChanged: (v) => setState(() => repeatType = v!),
              ),
            ),

            // 🔔 Reminder
            _section(
              'Reminder Alert',
              Icons.notifications_active,
              DropdownButtonFormField<ReminderOffset>(
                value: reminderOffset,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: ReminderOffset.values.map((offset) {
                  return DropdownMenuItem(
                    value: offset,
                    child: Text(offset.name),
                  );
                }).toList(),
                onChanged: (v) => setState(() => reminderOffset = v!),
              ),
            ),

            // ✅ Active Toggle
            _section(
              'Status',
              Icons.toggle_on,
              SwitchListTile(
                title: const Text('Reminder Active'),
                value: isActive,
                onChanged: (v) => setState(() => isActive = v),
              ),
            ),
          ],
        ),
      ),

      // 💾 Save Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: saveReminder,
          child: const Text('Save Reminder', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
