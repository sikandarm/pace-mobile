import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

Future<http.Response> deleteSequence({required int sequenceID}) async {
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');
  final response = await http.delete(
      Uri.parse(
        '$BASE_URL/sequences/deletesequence/$sequenceID',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      });

  print('delete response:' + response.body);

  return response;
}
