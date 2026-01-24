import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/task_model.dart';
import 'task_form_page.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});
  String _formatTaskDateTime(
    DateTime date,
    DateTime time,
    BuildContext context,
  ) {
    // Combine date + time
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Format date
    final formattedDate =
        '${combined.day.toString().padLeft(2, '0')}-'
        '${combined.month.toString().padLeft(2, '0')}-'
        '${combined.year}';

    // Format time
    final formattedTime = TimeOfDay.fromDateTime(combined).format(context);

    return '$formattedDate • $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    final taskBox = Hive.box<TaskModel>('taskBox');

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box<TaskModel> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final task = box.getAt(index)!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      task.isCompleted = value!;
                      task.save();
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    _formatTaskDateTime(task.date, task.time, context),
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                            24,
                            20,
                            24,
                            10,
                          ),

                          title: Column(
                            children: const [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 46,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Delete Task?',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          content: const Text(
                            'This task will be permanently deleted.\nYou cannot recover it later.',
                            textAlign: TextAlign.center,
                            style: TextStyle(height: 1.4),
                          ),

                          actionsPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          actions: [
                            // Cancel Button
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),

                            // Delete Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        task.delete();
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskFormPage(task: task),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
