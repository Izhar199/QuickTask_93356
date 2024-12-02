import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class EditTaskPage extends StatefulWidget {
  final ParseObject task; 

  EditTaskPage({required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  DateTime? _dueDate;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.get<String>('title'));
    _dueDate = widget.task.get<DateTime>('dueDate');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                setState(() {
                  _dueDate = pickedDate;
                });
              },
              child: Text(_dueDate == null ? 'Pick Due Date' : 'Due Date: ${_dueDate!.toLocal()}'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editTask,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTask() async {
    String taskTitle = _titleController.text.trim();

    if (taskTitle.isEmpty) {
      setState(() {
        _errorMessage = 'Task title cannot be empty';
      });
      return;
    }

    try {
      // Update task in Parse
      widget.task.set('title', taskTitle);
      widget.task.set('dueDate', _dueDate);
      final response = await widget.task.save();

      if (response.success) {
        Navigator.pop(context, true); // Return to the previous page
      } else {
        setState(() {
          _errorMessage = 'Failed to update task. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating task: ${e.toString()}';
      });
    }
  }
}
