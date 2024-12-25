import 'dart:convert';

import 'package:find_my_doc/globals.dart';
import 'package:find_my_doc/widgets/ai_message.dart';
import 'package:find_my_doc/widgets/user_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class _Message {
    String type;
    String content;

    _Message(this.type, this.content);
}

class ChatPage extends StatefulWidget {
    const ChatPage({super.key});

    @override
    State<StatefulWidget> createState() {
        return _ChatPageState();
    }
}

class _ChatPageState extends State<ChatPage> {
    bool _canSend = false;
    String _message = "";
    final TextEditingController _chatController = TextEditingController();
    final List<_Message> _messages = [_Message("system", "You are a health expert.")];
    final List<Widget> _messageWidgets = [];

    @override
    void initState() {
        super.initState();
    }

    void updateWidget() {
        setState(() {
            _messageWidgets.clear();

            for(_Message message in _messages) {
                if(message.type == 'user') {
                    _messageWidgets.add(UserMessage(message.content));
                } else if(message.type == 'ai') {
                    _messageWidgets.add(AiMessage(message.content));
                }
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            title: const Text('AI Chat'),
        ),
        body: Column(
            children: [
                Expanded(
                    child: SingleChildScrollView(
                        reverse: true,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: _messageWidgets,
                        ),
                    )
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                    children: [
                        Expanded(
                            child: TextField(
                                controller: _chatController,
                                decoration: InputDecoration(
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(50.0)
                                    )
                                ),
                                onChanged: (newValue) {
                                    if(newValue.isEmpty && _canSend) {
                                        setState(() {
                                        _canSend = false;
                                        });
                                    } else if(newValue.isNotEmpty && !_canSend) {
                                        setState(() {
                                        _canSend = true;
                                        });
                                    }

                                    _message = newValue;
                                },
                            ),
                        ),
                        Container(
                            child: _canSend ? IconButton.filled(
                                onPressed: () {
                                    setState(() {
                                      _chatController.text = "";
                                    });
                                    _messages.add(_Message("user", _message));
                                    updateWidget();

                                    final List<Map<String, dynamic>> messagedBody = List.filled(_messages.length, {
                                        'type': '',
                                        'content': ''
                                    });

                                    for(int i = 0; i < _messages.length; ++i) {
                                        messagedBody[i] = {
                                            'type': _messages[i].type,
                                            'content': _messages[i].content
                                        };
                                    }

                                    http.post(
                                        Uri.parse('$APIHOST/llm'),
                                        body: jsonEncode({
                                            'messages': messagedBody,
                                            'acc-token': GlobalState().user!.accToken
                                        })
                                    ).then((response) {
                                        if(response.statusCode == 200) {
                                            _messages.add(_Message('ai', jsonDecode(response.body)));
                                            updateWidget();
                                        }
                                    });
                                },
                                icon: const Icon(Icons.send_rounded),
                            ): null,
                        )
                    ],
                    )
                )
            ],
        )
        );
    }
}