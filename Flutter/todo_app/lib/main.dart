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
// タイマー用
import 'dart:async';
// 画像選択用
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

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
  String _filterBy = 'uncompleted'; // デフォルトを未実行に
  // メールアドレス
  String _emailAddress = '';
  final _emailController = TextEditingController();

  // スライドショー用の変数
  int _currentImageIndex = 0;
  List<Map<String, dynamic>> _images = [];
  Timer? _timer;
  final ImagePicker _picker = ImagePicker();

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
    _loadConfig();
    _loadTodos();
    _loadImages();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 画像情報を読み込む
  Future<void> _loadImages() async {
    try {
      final imageData = await rootBundle.loadString('lib/images.json');
      final decodedData = json.decode(imageData);
      setState(() {
        _images = List<Map<String, dynamic>>.from(decodedData['images']);
        print('読み込んだ画像数: ${_images.length}');
      });
      if (_images.isNotEmpty) {
        _startSlideShow();
      }
    } catch (e) {
      print('画像情報の読み込みエラー: $e');
      setState(() {
        _images = [];
      });
    }
  }

  void _startSlideShow() {
    _timer?.cancel();  // 既存のタイマーをキャンセル
    if (_images.isEmpty) {
      print('画像が読み込まれていません');
      return;
    }
    print('スライドショーを開始します');
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {  // ウィジェットがマウントされているか確認
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _images.length;
          print('画像を切り替え: $_currentImageIndex');
        });
      }
    });
  }

  // 設定ファイルを読み込む
  Future<void> _loadConfig() async {
    try {
      final configData = await rootBundle.loadString('lib/config.json');
      final config = json.decode(configData);
      setState(() {
        _emailAddress = config['email'] ?? '';
      });
    } catch (e) {
      print('設定ファイルの読み込みエラー: $e');
      setState(() {
        _emailAddress = '';
      });
    }
  }

  // 保存されたToDoタスクをJSONファイルから読み込む
  Future<void> _loadTodos() async {
    try {
      final initialData = await rootBundle.loadString('lib/todo.json');
      final decodedData = json.decode(initialData);
      setState(() {
        _todos = List<Map<String, dynamic>>.from(decodedData);
        _sortTodos();
      });
    } catch (e) {
      print('初期データの読み込みエラー: $e');
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

  // 日付と時間を日本語形式にフォーマットする関数
  String _formatDateTime(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}年${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // メールアドレスを保存する関数
  Future<void> _saveEmailAddress(String email) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/config.json');
      final config = {'email': email};
      await file.writeAsString(json.encode(config));
      setState(() {
        _emailAddress = email;
      });
    } catch (e) {
      print('メールアドレスの保存エラー: $e');
    }
  }

  // メールアドレス編集ダイアログを表示
  Future<void> _showEmailEditDialog() async {
    _emailController.text = _emailAddress;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'メールアドレスの編集',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'メールアドレス',
            labelStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_emailController.text.isNotEmpty) {
                _saveEmailAddress(_emailController.text);
                Navigator.pop(context);
              }
            },
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 画像をアップロード
  Future<void> _uploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // アプリのドキュメントディレクトリを取得
        final directory = await getApplicationDocumentsDirectory();
        final imageDir = Directory('${directory.path}/images');
        if (!await imageDir.exists()) {
          await imageDir.create(recursive: true);
        }

        // 画像をコピー
        final newImagePath = '${imageDir.path}/image${_images.length + 1}.jpg';
        await File(image.path).copy(newImagePath);

        // 画像情報を更新
        setState(() {
          _images.add({
            'id': _images.length + 1,
            'path': newImagePath,
            'title': '画像${_images.length + 1}',
          });
        });

        // images.jsonを更新
        await _saveImages();
        
        // スライドショーを再開
        _startSlideShow();
        
        // ダイアログを閉じる
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('画像をアップロードしました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('画像アップロードエラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('画像のアップロードに失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 画像を削除
  Future<void> _deleteImage(int index) async {
    try {
      if (index < 0 || index >= _images.length) {
        throw Exception('無効な画像インデックスです');
      }

      final image = _images[index];
      final file = File(image['path']);
      
      // ファイルが存在する場合のみ削除
      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        _images.removeAt(index);
        // IDを振り直し
        for (var i = 0; i < _images.length; i++) {
          _images[i]['id'] = i + 1;
        }
      });

      // images.jsonを更新
      await _saveImages();
      
      // スライドショーを再開
      _startSlideShow();
      
      // 削除成功のメッセージを表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('画像を削除しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('画像削除エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('画像の削除に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 画像情報を保存
  Future<void> _saveImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/images.json');
      final imageData = json.encode({'images': _images});
      await file.writeAsString(imageData);
      print('画像情報を保存しました: ${_images.length}枚');
    } catch (e) {
      print('画像情報の保存エラー: $e');
      throw Exception('画像情報の保存に失敗しました');
    }
  }

  // 画像管理ダイアログを表示
  Future<void> _showImageManagementDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          '画像の管理',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 画像一覧
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final image = _images[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: kIsWeb
                          ? Image.asset(
                              image['path'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(image['path']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('サムネイル読み込みエラー: $error');
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error, color: Colors.red),
                                );
                              },
                            ),
                      ),
                      title: Text(
                        image['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: kIsWeb
                        ? Tooltip(
                            message: 'Webでは削除できません',
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: null,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteImage(index),
                          ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // 画像アップロードボタン
              kIsWeb
                ? Tooltip(
                    message: 'Webではアップロードできません',
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('画像をアップロード'),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _uploadImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('画像をアップロード'),
                  ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '閉じる',
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
        toolbarHeight: 100, // アプリバーの高さを増やす
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'メール: $_emailAddress',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70, size: 16),
                        onPressed: _showEmailEditDialog,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_images.isNotEmpty)
              Expanded(
                flex: 3,
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: kIsWeb
                          ? Image.asset(
                              key: ValueKey<int>(_currentImageIndex),
                              _images[_currentImageIndex]['path'],
                              fit: BoxFit.fill,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                print('画像読み込みエラー: $error');
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.error, color: Colors.red),
                                  ),
                                );
                              },
                            )
                          : Image.file(
                              key: ValueKey<int>(_currentImageIndex),
                              File(_images[_currentImageIndex]['path']),
                              fit: BoxFit.fill,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                print('画像読み込みエラー: $error');
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.error, color: Colors.red),
                                  ),
                                );
                              },
                            ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // アプリバーの右側に新規追加ボタンを配置
        actions: [
          // 画像管理ボタン
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: _showImageManagementDialog,
          ),
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
              onPressed: () async {
                final newTodo = await _showAddTodoDialog();
                if (newTodo != null) {
                  setState(() {
                    _todos.add(newTodo);
                    _filterBy = 'all';
                  });
                  _saveTodos();
                }
              },
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
                    color: Colors.black,
                    child: ListTile(
                      title: Text(
                        todo['title'],
                        style: TextStyle(
                          color: Colors.white,
                          decoration: todo['completed']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '期限: ${_formatDateTime(todo['date'])}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      leading: Checkbox(
                        value: todo['completed'],
                        onChanged: (bool? value) {
                          _toggleTodo(index);
                        },
                        fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white;
                          }
                          return Colors.white;
                        }),
                        checkColor: Colors.black,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
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

  // タスク追加用のダイアログを表示
  Future<Map<String, dynamic>?> _showAddTodoDialog() async {
    _titleController.clear();
    _selectedDate = DateTime.now();
    final _hourController = TextEditingController(text: _selectedDate.hour.toString());
    final _minuteController = TextEditingController(text: _selectedDate.minute.toString());

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
              // 日付選択ボタン
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
                      _selectedDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        _selectedDate.hour,
                        _selectedDate.minute,
                      );
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: Text('日付: ${_selectedDate.toString().split(' ')[0]}'),
              ),
              const SizedBox(height: 16),
              // 時間入力フィールド
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hourController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '時',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _minuteController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '分',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
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
                  final hour = int.tryParse(_hourController.text) ?? 0;
                  final minute = int.tryParse(_minuteController.text) ?? 0;
                  final newTodo = {
                    'title': _titleController.text,
                    'date': DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      hour.clamp(0, 23),
                      minute.clamp(0, 59),
                    ).toString(),
                    'completed': false,
                  };
                  Navigator.pop(context, newTodo); // 追加したタスクを返す
                }
              },
              child: const Text(
                '追加',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

