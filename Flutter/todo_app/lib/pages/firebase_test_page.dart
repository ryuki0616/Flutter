import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  String _connectionStatus = '接続確認中...';
  String _testResult = '';
  bool _isLoading = false;

  // Firebase接続先情報を取得
  Map<String, String> get firebaseInfo {
    final options = DefaultFirebaseOptions.currentPlatform;
    return {
      'projectId': options.projectId,
      'apiKey': options.apiKey,
      'appId': options.appId,
      'storageBucket': options.storageBucket ?? '-',
      'messagingSenderId': options.messagingSenderId,
      'authDomain': (options.authDomain ?? '-'),
      'measurementId': (options.measurementId ?? '-'),
    };
  }

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  Future<void> _checkFirebaseConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Firebase接続を確認中...';
    });

    try {
      // Firebase Appの状態を確認
      final app = Firebase.app();
      setState(() {
        _connectionStatus = 'Firebase App: ${app.name}';
      });

      // Firestore接続テスト
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('connection').get();
      
      setState(() {
        _connectionStatus = 'Firebase接続成功！';
        _testResult = 'Firestoreへの接続が正常に動作しています。';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Firebase接続エラー';
        _testResult = 'エラー: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testWriteData() async {
    setState(() {
      _isLoading = true;
      _testResult = 'データ書き込みテスト中...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('write_test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Flutterアプリからのテスト書き込み',
        'platform': 'Android',
      });

      setState(() {
        _testResult = 'データ書き込みテスト成功！';
      });
    } catch (e) {
      setState(() {
        _testResult = 'データ書き込みエラー: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testReadData() async {
    setState(() {
      _isLoading = true;
      _testResult = 'データ読み込みテスト中...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('test').doc('write_test').get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _testResult = 'データ読み込み成功！\nメッセージ: ${data['message']}\nプラットフォーム: ${data['platform']}';
        });
      } else {
        setState(() {
          _testResult = 'テストデータが見つかりません。先に書き込みテストを実行してください。';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'データ読み込みエラー: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = firebaseInfo;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase接続テスト'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Firebase接続先情報
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase接続先情報',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Project ID: ${info['projectId']}'),
                    Text('API Key: ${info['apiKey']}'),
                    Text('App ID: ${info['appId']}'),
                    Text('Storage Bucket: ${info['storageBucket']}'),
                    Text('Messaging Sender ID: ${info['messagingSenderId']}'),
                    if (info['authDomain'] != '-') Text('Auth Domain: ${info['authDomain']}'),
                    if (info['measurementId'] != '-') Text('Measurement ID: ${info['measurementId']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 接続状態表示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '接続状態',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _connectionStatus,
                      style: TextStyle(
                        color: _connectionStatus.contains('成功') 
                          ? Colors.green 
                          : _connectionStatus.contains('エラー') 
                            ? Colors.red 
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // テスト結果表示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'テスト結果',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_testResult),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // テストボタン
            ElevatedButton(
              onPressed: _isLoading ? null : _testWriteData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('データ書き込みテスト'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testReadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('データ読み込みテスト'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _checkFirebaseConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('接続再確認'),
            ),
            
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 