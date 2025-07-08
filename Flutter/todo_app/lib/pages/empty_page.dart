import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('空のページ'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (bool? value) {},
          ),
          Text('タスク'),
        ],
      ),
    );
  }
} 