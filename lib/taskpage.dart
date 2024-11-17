import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import './main.dart';
class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController taskController = TextEditingController();
  List<ParseObject> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      final query = QueryBuilder<ParseObject>(ParseObject('Task'))
        ..whereEqualTo('user', user);

      final response = await query.query();
      if (response.success && response.results != null) {
        setState(() {
          tasks = response.results as List<ParseObject>;
        });
      }
    }
  }

  Future<void> addTask(String title) async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      final task = ParseObject('Task')
        ..set('title', title)
        ..set('isCompleted', false)
        ..set('user', user);

      final response = await task.save();
      if (response.success) {
        fetchTasks(); // Refresh the task list
        taskController.clear();
      }
    }
  }

  Future<void> toggleTaskStatus(ParseObject task) async {
    task.set('isCompleted', !(task.get<bool>('isCompleted') ?? false));
    final response = await task.save();
    if (response.success) {
      fetchTasks(); // Refresh the task list
    }
  }

  Future<void> deleteTask(ParseObject task) async {
    final response = await task.delete();
    if (response.success) {
      fetchTasks(); // Refresh the task list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final user = await ParseUser.currentUser() as ParseUser?;
              await user?.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthenticationPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(labelText: 'New Task'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (taskController.text.isNotEmpty) {
                      addTask(taskController.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(
                    task.get<String>('title') ?? '',
                    style: TextStyle(
                      decoration: (task.get<bool>('isCompleted') ?? false)
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: task.get<bool>('isCompleted') ?? false,
                    onChanged: (value) {
                      toggleTaskStatus(task);
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteTask(task);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
