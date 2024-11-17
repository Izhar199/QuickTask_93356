import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import './main.dart';
class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _titleController = TextEditingController();
  DateTime? _selectedDueDate;
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
   void _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }
  void _submitTask() {
    final title = _titleController.text;

    if (title.isEmpty || _selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide both title and due date.')),
      );
      return;
    }

    addTask(title, _selectedDueDate!).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task added successfully!')),
      );
      //Navigator.pop(context); // Return to the previous screen
    });
  }
  Future<void> addTask(String title,DateTime dueDate) async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      final task = ParseObject('Task')
        ..set('title', title)
        ..set('dueDate', dueDate)
        ..set('isCompleted', true)
        ..set('user', user);

      final response = await task.save();
      if (response.success) {
        fetchTasks(); // Refresh the task list
        //taskController.clear();
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
            child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(_selectedDueDate == null
                    ? 'No Due Date Selected'
                    : 'Due Date: ${_selectedDueDate!.toLocal()}'),
                Spacer(),
                TextButton(
                  onPressed: _pickDueDate,
                  child: Text('Pick Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTask,
              child: Text('Add Task'),
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