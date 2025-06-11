// Flutterのマテリアルデザインウィジェットをインポート
import 'package:flutter/material.dart';
// JSONのエンコード/デコード用
import 'dart:convert';
// ファイル操作用
import 'dart:io';
// アプリケーションのドキュメントディレクトリを取得するためのパッケージ
import 'package:path_provider/path_provider.dart';
// アプリケーションの初期データを読み込むためのパッケージ
import 'package:flutter/services.dart';

// アプリケーションのエントリーポイント
void main() {
  runApp(const MyApp());
}

// アプリケーションのルートウィジェット
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        // アプリケーションのテーマ設定
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      home: const MyHomePage(title: 'ToDo'),
    );
  }
}

// ホームページのウィジェット（状態を持つウィジェット）
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // ウィジェットの設定値を保持するプロパティ
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ホームページの状態を管理するクラス
class _MyHomePageState extends State<MyHomePage> {
  // ToDoタスクのリスト（タイトル、日付、完了状態を保持）
  List<Map<String, dynamic>> _todos = [];
  // タスク追加時のテキスト入力コントローラー
  final _titleController = TextEditingController();
  // 選択された日付（デフォルトは現在の日付）
  DateTime _selectedDate = DateTime.now();
  // ソート順を管理する変数
  String _sortBy = 'date'; // 'date' or 'completed'
  // フィルター状態を管理する変数
  String _filterBy = 'all'; // 'all', 'completed', 'uncompleted'

  // フィルタリングされたタスクリストを取得する関数
  List<Map<String, dynamic>> get _filteredTodos {
    switch (_filterBy) {
      case 'completed':
        return _todos.where((todo) => todo['completed'] == true).toList();
      case 'uncompleted':
        return _todos.where((todo) => todo['completed'] == false).toList();
      default:
        return _todos;
    }
  }

  // タスクをソートする関数
  void _sortTodos() {
    setState(() {
      if (_sortBy == 'date') {
        _todos.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      } else if (_sortBy == 'completed') {
        _todos.sort((a, b) => a['completed'].toString().compareTo(b['completed'].toString()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // アプリ起動時に保存されたタスクを読み込む
    _loadTodos();
  }

  // 保存されたToDoタスクをJSONファイルから読み込む
  Future<void> _loadTodos() async {
    try {
      // アプリケーションのドキュメントディレクトリを取得
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/todo.json');
      
      // ファイルが存在する場合、内容を読み込む
      if (await file.exists()) {
        final contents = await file.readAsString();
        setState(() {
          _todos = List<Map<String, dynamic>>.from(json.decode(contents));
          _sortTodos(); // 読み込み後にソート
        });
      } else {
        // ドキュメントディレクトリにファイルが存在しない場合、初期データを読み込む
        try {
          final initialData = await rootBundle.loadString('lib/todo.json');
          final decodedData = json.decode(initialData);
          setState(() {
            _todos = List<Map<String, dynamic>>.from(decodedData);
            _sortTodos();
          });
          // 初期データをドキュメントディレクトリに保存
          await file.writeAsString(initialData);
        } catch (e) {
          print('Error loading initial data: $e');
          // 初期データの読み込みに失敗した場合、空のリストを設定
          setState(() {
            _todos = [];
          });
        }
      }
    } catch (e) {
      print('Error in _loadTodos: $e');
      setState(() {
        _todos = [];
      });
    }
  }

  // ToDoタスクをJSONファイルに保存
  Future<void> _saveTodos() async {
    try {
      // アプリケーションのドキュメントディレクトリを取得
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/todo.json');
      // タスクリストをJSON形式で保存
      await file.writeAsString(json.encode(_todos));
    } catch (e) {
      print('Error saving todos: $e');
    }
  }

  // タスク追加用のダイアログを表示
  Future<void> _showAddTodoDialog() async {
    _titleController.clear();
    _selectedDate = DateTime.now();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          '新しいタスク',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タスク内容の入力フィールド
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'タスク内容',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 期限選択ボタン
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          surface: Colors.black,
                          onSurface: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text('期限: ${_selectedDate.toString().split(' ')[0]}'),
            ),
          ],
        ),
        actions: [
          // キャンセルボタン
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Colors.white),
            ),
          ),
          // 追加ボタン
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
            child: const Text(
              '追加',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // アプリバーの設定
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // アプリバーの右側に新規追加ボタンを配置
        actions: [
          // フィルターボタン
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (String value) {
              setState(() {
                _filterBy = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'all',
                child: Text('すべて表示'),
              ),
              const PopupMenuItem<String>(
                value: 'completed',
                child: Text('実行済みのみ'),
              ),
              const PopupMenuItem<String>(
                value: 'uncompleted',
                child: Text('未実行のみ'),
              ),
            ],
          ),
          // ソートボタン
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (String value) {
              setState(() {
                _sortBy = value;
                _sortTodos();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'date',
                child: Text('日付順'),
              ),
              const PopupMenuItem<String>(
                value: 'completed',
                child: Text('完了状態'),
              ),
            ],
          ),
          // 新規追加ボタン
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showAddTodoDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      // ToDoリストの表示
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: _filteredTodos.isEmpty
            ? const Center(
                child: Text(
                  'タスクがありません',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = _filteredTodos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        todo['title'],
                        style: TextStyle(
                          decoration: todo['completed']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '期限: ${todo['date']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      leading: Checkbox(
                        value: todo['completed'],
                        onChanged: (bool? value) {
                          _toggleTodo(index);
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTodo(index),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index]['completed'] = !_todos[index]['completed'];
    });
    _saveTodos();
  }

  void _deleteTodo(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タスクの削除'),
        content: const Text('このタスクを削除してもよろしいですか？'),
        actions: [
          // キャンセルボタン
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          // 削除ボタン
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
  }

  @override
  void dispose() {
    // コントローラーの破棄
    _titleController.dispose();
    super.dispose();
  }
}

