import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/repeated_reminder_model.dart';
import '../enums/repeat_type.dart';
import 'repeated_reminder_form_page.dart';

class RepeatedReminderListPage extends StatelessWidget {
  const RepeatedReminderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<RepeatedReminderModel>('repeatedReminderBox');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Repeated Reminders'),
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<RepeatedReminderModel> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No repeated reminders yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final reminder = box.getAt(index)!;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.repeat),
                  title: Text(
                    reminder.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${reminder.repeatType.name} • '
                        '${TimeOfDay.fromDateTime(reminder.time).format(context)}',
                      ),
                    ],
                  ),

                  // ✅ Active Toggle
                  trailing: Switch(
                    value: reminder.isActive,
                    onChanged: (v) {
                      reminder.isActive = v;
                      reminder.save();
                    },
                  ),

                  // ✏️ Edit
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RepeatedReminderFormPage(reminder: reminder),
                      ),
                    );
                  },

                  // 🗑 Delete
                  onLongPress: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Reminder'),
                        content: const Text(
                          'Are you sure you want to delete this reminder?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      reminder.delete();
                    }
                  },
                ),
              );
            },
          );
        },
      ),

      // ➕ Add Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RepeatedReminderFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
