import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/task_model.dart';
import 'task_form_page.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  // Format Date + Time
  String _formatTaskDateTime(
    DateTime date,
    DateTime time,
    BuildContext context,
  ) {
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final formattedDate =
        '${combined.day.toString().padLeft(2, '0')}-'
        '${combined.month.toString().padLeft(2, '0')}-'
        '${combined.year}';

    final formattedTime = TimeOfDay.fromDateTime(combined).format(context);

    return '$formattedDate • $formattedTime';
  }

  // Check if same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  //check is missed
  bool _isMissed(TaskModel task) {
    if (task.isCompleted) return false;

    final now = DateTime.now();

    final taskDateTime = DateTime(
      task.date.year,
      task.date.month,
      task.date.day,
      task.time.hour,
      task.time.minute,
    );

    return taskDateTime.isBefore(now);
  }

  // Build Task Tile
  Widget _buildTaskTile(BuildContext context, TaskModel task) {
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
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),

        subtitle: Text(_formatTaskDateTime(task.date, task.time, context)),

        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),

          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,

              builder: (_) => AlertDialog(
                title: const Text('Delete Task?'),

                content: const Text('Are you sure?'),

                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),

                  TextButton(
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
            MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
          );
        },
      ),
    );
  }
  Widget _buildMissedTaskTile(BuildContext context, TaskModel task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),

        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),

        subtitle: Text(
          _formatTaskDateTime(task.date, task.time, context),
          style: const TextStyle(color: Colors.redAccent),
        ),

          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),

            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,

                builder: (_) => AlertDialog(
                  title: const Text('Delete Task?'),

                  content: const Text('Are you sure?'),

                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),

                    TextButton(
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
            MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskBox = Hive.box<TaskModel>('taskBox');

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormPage()),
          );
        },
      ),

      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),

        builder: (context, Box<TaskModel> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }

          final now = DateTime.now();

          final today = DateTime(now.year, now.month, now.day);

          final tomorrow = today.add(const Duration(days: 1));

          // Convert to List
          final tasks = box.values.toList();

          // Sort
          tasks.sort((a, b) {
            final aDT = DateTime(
              a.date.year,
              a.date.month,
              a.date.day,
              a.time.hour,
              a.time.minute,
            );

            final bDT = DateTime(
              b.date.year,
              b.date.month,
              b.date.day,
              b.time.hour,
              b.time.minute,
            );

            return aDT.compareTo(bDT);
          });

          // Groups
          List<TaskModel> missedTasks = [];
          List<TaskModel> todayTasks = [];
          List<TaskModel> tomorrowTasks = [];
          Map<String, List<TaskModel>> otherTasks = {};


          for (var task in tasks) {
            final taskDate = DateTime(
              task.date.year,
              task.date.month,
              task.date.day,
            );

            // 🔴 Missed
            if (_isMissed(task)) {
              missedTasks.add(task);
            }

            // 📍 Today
            else if (_isSameDay(taskDate, today)) {
              todayTasks.add(task);
            }

            // 📍 Tomorrow
            else if (_isSameDay(taskDate, tomorrow)) {
              tomorrowTasks.add(task);
            }

            // 📅 Others
            else {
              final key = '${taskDate.year}-${taskDate.month}-${taskDate.day}';

              otherTasks.putIfAbsent(key, () => []);
              otherTasks[key]!.add(task);
            }
          }


          return ListView(
            children: [
              // ===== MISSED =====
              if (missedTasks.isNotEmpty) ...[
                _buildHeader('⛔ Missed'),
                ...missedTasks.map((t) => _buildMissedTaskTile(context, t)),
              ],

              // ===== TODAY =====
              if (todayTasks.isNotEmpty) ...[
                _buildHeader('📍 Today'),
                ...todayTasks.map((t) => _buildTaskTile(context, t)),
              ],

              // ===== TOMORROW =====
              if (tomorrowTasks.isNotEmpty) ...[
                _buildHeader('📍 Tomorrow'),
                ...tomorrowTasks.map((t) => _buildTaskTile(context, t)),
              ],

              // ===== OTHER DATES =====
              ...otherTasks.entries.map((entry) {
                final parts = entry.key.split('-');

                final date = DateTime(
                  int.parse(parts[0]),
                  int.parse(parts[1]),
                  int.parse(parts[2]),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      '${date.day.toString().padLeft(2, '0')}-'
                      '${date.month.toString().padLeft(2, '0')}-'
                      '${date.year}',
                    ),

                    ...entry.value.map((t) => _buildTaskTile(context, t)),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }

  // Header Widget
  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),

      child: Text(
        text,

        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }
}
