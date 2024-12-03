import 'package:flutter/material.dart';
import 'package:find_my_doc/widgets/pages/chat.dart';
import 'package:find_my_doc/widgets/pages/home.dart';
import 'package:find_my_doc/widgets/pages/map.dart';

void main() {
  runApp(const FindMyDocApp());
}

class FindMyDocApp extends StatelessWidget {
  const FindMyDocApp({super.key});

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
        },
        '/map': (context) {
          return const MapPage();
        }
      },
    );
  }
}
