import 'package:flutter/material.dart';

class Start extends StatelessWidget {
  const Start({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Center(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            readOnly: true,
            onTap: () {
              Navigator.pushNamed(context, '/chat');
            },
            decoration: InputDecoration(
              labelText: 'Discuss Complications...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0)
              ),
            ),
          ),
        )
      ],
    );
  }
    
}