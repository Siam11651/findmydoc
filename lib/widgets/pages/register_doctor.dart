import 'dart:convert';

import 'package:find_my_doc/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterDoctorPage extends StatefulWidget {
  const RegisterDoctorPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterDoctorPageState();
  }   
}

class _RegisterDoctorPageState extends State<RegisterDoctorPage> {
    bool _loading = false;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("Register Doctor"),
            ),
            body: _loading ? const Center(
                child: CircularProgressIndicator(),
            ) : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: FilledButton(
                            onPressed: () {
                                setState(() {
                                    _loading = true;
                                });

                                http
                                    .post(
                                        Uri.parse('$APIHOST/register-doctor'),
                                        body: jsonEncode({
                                            'acc-token': GlobalState().user!.accToken
                                        })
                                    )
                                    .then((response) {
                                        if(response.statusCode == 200) {
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                                Navigator.pop(context);
                                            });
                                        }
                                    });
                            },
                            child: const Text("Register")
                        ),
                    )
                ],
            ),
        );
    }
}