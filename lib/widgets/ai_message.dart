import 'package:flutter/material.dart';

class AiMessage extends StatefulWidget {
    final String _message;
    
    const AiMessage(this._message, {super.key});

    @override
    State<StatefulWidget> createState() {
        return AiMessageState();
    }
}

class AiMessageState extends State<AiMessage> {
    String message = "";

    @override
    void initState() {
        super.initState();
        
        message = widget._message;
    }

    void update(String newMessage) {
        setState(() {
          message = newMessage;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24)
                    ),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                        message,
                        style: const TextStyle(color: Colors.black),
                    ),
                )
            ],
        ),
        );
    }
}