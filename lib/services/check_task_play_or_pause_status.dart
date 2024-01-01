import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

Future<bool> getTaskPlayOrPauseStatus({required String taskId}) async {
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');

  final response = await http.get(
      Uri.parse('$BASE_URL/break-task/check-break-status/$taskId'),
      headers: {
        'Authorization': 'Bearer $token',
      });
  final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

  if (response.statusCode == 200) {
    return decodedResponse['data'] as bool;
  } else {
    throw 'Something went wrong';
  }
}
