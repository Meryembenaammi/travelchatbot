import 'package:flutter/material.dart';
import 'pages/chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAMWay LLM',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFFCEEFF),
      ),
      home: ChatPage(),
    );
  }
}
