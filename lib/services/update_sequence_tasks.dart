import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

Future<void> updateSequenceTasks({
  required int sequenceId,
  required int task_id,
}) async {
//   /sequences/updatesequencetask
// formData : sequence_id = $sequenceid and  task_id = $taskid

  final tokenBox = await Hive.openBox('tokenBox');

  final token = tokenBox.get('token');

  print('seqId: ' + sequenceId.toString());
  print('taskId: ' + task_id.toString());

  print('here');

  // Create FormData
  var formData = http.MultipartRequest(
    'POST',
    Uri.parse('$BASE_URL/sequencestask/updatesequencetask'),
  );
  formData.fields.putIfAbsent('sequence_id', () => sequenceId.toString());
  formData.fields.putIfAbsent('task_id', () => task_id.toString());
  // formData.fields.putIfAbsent('sequence_id', () => '42');
  // formData.fields.putIfAbsent('task_id', () => '12');
  /////////////////////////////////////////////////////////////////
  // formData.fields.p.add(MapEntry('key1', 'value1'));
  //formData.fields.add(MapEntry('key2', 'value2'));

  // final response = await http
  //     .post(Uri.parse("$BASE_URL/sequencestask/updatesequencetask"), headers: {
  //   'Authorization': 'Bearer $token',
  // }, body: {
  //   // 'sequence_id ': int.parse(sequenceId.toString()),
  //   // 'task_id': int.parse(task_id.toString()),
  //   'sequence_id ': 42.toString(),
  //   'task_id': 10.toString(),
  //   // 'sequence_id ': sequenceId.toString(),
  //   // 'task_id': task_id.toString(),
  // });
  // Set Authorization header
  formData.headers.addAll({'Authorization': 'Bearer $token'});

  final stream = await formData.send();
  print(stream.statusCode.toString());
  print(stream.stream.first);
  print('here done');
  print('==================================================');
  // print('updateSequenceTasks api response: ' + response.body.toString());
  print('==================================================');
}
