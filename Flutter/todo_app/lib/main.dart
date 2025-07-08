// Flutterのマテリアルデザインウィジェットをインポート
import 'package:flutter/material.dart';
// Firebase Coreをインポート
import 'package:firebase_core/firebase_core.dart';
// Firebase設定をインポート
import 'firebase_options.dart';
// トップページのウィジェットをインポート
import 'pages/home_page.dart';

// アプリケーションのエントリーポイント
void main() async {
  // Flutterエンジンを初期化
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebaseを初期化
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase初期化成功');
  } catch (e) {
    print('Firebase初期化エラー: $e');
  }
  
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
      home: const HomePage(),
    );
  }
}

