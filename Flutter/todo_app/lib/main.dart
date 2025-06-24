// Flutterのマテリアルデザインウィジェットをインポート
import 'package:flutter/material.dart';
// トップページのウィジェットをインポート
import 'pages/home_page.dart';

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
      home: const HomePage(),
    );
  }
}

