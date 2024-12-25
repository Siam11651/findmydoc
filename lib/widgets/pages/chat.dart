import 'dart:convert';
import 'dart:io';

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

    void updateWidget({GlobalKey<AiMessageState>? key}) {
        setState(() {
            _messageWidgets.clear();

            for(int i = 0; i < _messages.length; ++i) {
                if(_messages[i].type == 'user') {
                    _messageWidgets.add(UserMessage(_messages[i].content));
                } else if(_messages[i].type == 'ai') {
                    if(i == _messages.length - 1 && key != null) {
                        _messageWidgets.add(
                            AiMessage(
                                _messages[i].content,
                                key: key,
                            )
                        );
                    } else {
                        _messageWidgets.add(AiMessage(_messages[i].content));
                    }
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

                                    final List<Map<String, dynamic>> messagedBody = _messages.map((item) {
                                        return {
                                            'type': item.type,
                                            'content': item.content
                                        };
                                    }).toList();

                                    final request = http.Request(
                                        'POST',
                                        Uri.parse('$APIHOST/llm')
                                    );
                                    request.body = jsonEncode({
                                        'messages': messagedBody,
                                        'acc-token': GlobalState().user!.accToken
                                    });

                                    request.headers.addAll({
                                        'accept': 'text/event-stream'
                                    });

                                    final http.Client client = http.Client();
                                    
                                    client.send(request).then((response) {
                                        if(response.statusCode == 200) {
                                            _messages.add(_Message('ai', ''));

                                            final GlobalKey<AiMessageState> aiMessageKey = GlobalKey<AiMessageState>();

                                            updateWidget(
                                                key: aiMessageKey
                                            );

                                            response
                                                .stream
                                                .transform(utf8.decoder)
                                                .listen((data) {
                                                    Map<String, dynamic> json = jsonDecode(data);

                                                    if(json['type'] == 'part') {
                                                        final String content = json['content'];
                                                        _messages.last.content = '${_messages.last.content}$content';

                                                        if(aiMessageKey.currentState != null) {
                                                            aiMessageKey.currentState!.update(_messages.last.content);
                                                        }
                                                    }
                                                });
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