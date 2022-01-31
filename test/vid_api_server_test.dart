import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  test('It should give a 200 response', () async {
    final res =
        await http.get(Uri(scheme: 'http', host: 'localhost', port: 8080));
    expect(res.statusCode, 200);
  });
}
