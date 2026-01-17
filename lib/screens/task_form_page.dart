import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../model/task_model.dart';
import '../enums/reminder_offset.dart';

class TaskFormPage extends StatefulWidget {
  final TaskModel? task;

  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  ReminderOffset reminderOffset = ReminderOffset.atTime;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      final t = widget.task!;
      _titleController.text = t.title;
      _noteController.text = t.note ?? '';
      selectedDate = t.date;
      selectedTime = TimeOfDay.fromDateTime(t.time);
      reminderOffset = t.reminderOffset;
    }
  }

  void saveTask() {
    final box = Hive.box<TaskModel>('taskBox');

    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (widget.task == null) {
      box.add(
        TaskModel(
          title: _titleController.text,
          note: _noteController.text,
          date: selectedDate,
          time: dateTime,
          reminderOffset: reminderOffset,
        ),
      );
    } else {
      widget.task!
        ..title = _titleController.text
        ..note = _noteController.text
        ..date = selectedDate
        ..time = dateTime
        ..reminderOffset = reminderOffset
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
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 📝 Title & Note
            _section(
              'Task Details',
              Icons.edit_note,
              Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Task title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            // 📅 Date & Time
            _section(
              'Schedule',
              Icons.schedule,
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date'),
                    subtitle: Text(
                      selectedDate.toLocal().toString().split(' ')[0],
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
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

            // 🔔 Reminder
            _section(
              'Reminder',
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
          ],
        ),
      ),

      // 💾 Bottom Save Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: saveTask,
          child: const Text('Save Task', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
