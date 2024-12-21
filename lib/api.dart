import 'dart:convert';

import 'package:find_my_doc/globals.dart';
import 'package:http/http.dart' as http;

Future<http.Response> register(String id, String accToken) {
    return http
        .post(
            Uri.parse('$APIHOST/register'),
            body: jsonEncode({
                'id': id,
                'acc-token': accToken,
            })
        );
}