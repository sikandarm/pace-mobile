import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

Future<void> deleteSequenceTask(
    {required String taskId, required BuildContext context}) async {
  final tokenBox = await Hive.openBox('tokenBox');

  final token = tokenBox.get('token');
  final response = await http.delete(
      Uri.parse('$BASE_URL/sequencestask/delete-sequence-task/$taskId'),
      headers: {
        'Authorization': 'Bearer $token',
      });
  if (response.statusCode == 200) {
    print(response.body);
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Something went wrong')));
  }
}
