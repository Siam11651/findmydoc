import 'package:flutter/material.dart';
import 'package:icare/widgets/pages/chat.dart';
import 'package:icare/widgets/pages/home.dart';

void main() {
  runApp(const ICareApp());
}

class ICareApp extends StatelessWidget {
  const ICareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) {
          return const HomePage();
        },
        '/chat': (context) {
          return const ChatPage();
        }
      },
    );
  }
}
