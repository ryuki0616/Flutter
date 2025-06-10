import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'ToDo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _todos = [];
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/todo.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        setState(() {
          _todos = List<Map<String, dynamic>>.from(json.decode(contents));
        });
      }
    } catch (e) {
      print('Error loading todos: $e');
    }
  }

  Future<void> _saveTodos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/todo.json');
      await file.writeAsString(json.encode(_todos));
    } catch (e) {
      print('Error saving todos: $e');
    }
  }

  Future<void> _showAddTodoDialog() async {
    _titleController.clear();
    _selectedDate = DateTime.now();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいタスク'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タスク内容',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Text('期限: ${_selectedDate.toString().split(' ')[0]}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                setState(() {
                  _todos.add({
                    'title': _titleController.text,
                    'date': _selectedDate.toString(),
                    'completed': false,
                  });
                });
                _saveTodos();
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return ListTile(
            title: Text(todo['title']),
            subtitle: Text('期限: ${todo['date'].toString().split(' ')[0]}'),
            leading: Checkbox(
              value: todo['completed'],
              onChanged: (bool? value) {
                setState(() {
                  todo['completed'] = value ?? false;
                });
                _saveTodos();
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('タスクの削除'),
                    content: const Text('このタスクを削除してもよろしいですか？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _todos.removeAt(index);
                          });
                          _saveTodos();
                          Navigator.pop(context);
                        },
                        child: const Text('削除'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        tooltip: 'タスクを追加',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

