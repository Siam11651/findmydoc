import 'package:flutter/material.dart';

class UserMessage extends StatelessWidget {
    final String _message;

    const UserMessage(this._message, {super.key});

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(24)
                        ),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                            _message,
                            style: const TextStyle(
                                color: Colors.white
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}