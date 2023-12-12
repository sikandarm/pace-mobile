import 'dart:convert';

import 'package:com_a3_pace/services/get_Independent_tasks.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/constants.dart';

Future<void> getSingleTask({required String taskId}) async {
  IndependentTaskModel independentTaskModel = IndependentTaskModel();

  final tokenBox = await Hive.openBox('tokenBox');

  final token = tokenBox.get('token');
  final response =
      await http.get(Uri.parse('$BASE_URL/task/$taskId'), headers: {
    'Authorization': 'Bearer $token',
  });

  print(response.statusCode);
//  print(response.body);
  if (response.statusCode == 200) {
    final map =
        jsonDecode(response.body)['data']['task'] as Map<String, dynamic>;
    print(map);

    independentTaskModel;
  }
}
