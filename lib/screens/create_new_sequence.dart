import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

Future<http.Response> createNewSequence({
  required String seqName,
  required int jobID,
  //  required BuildContext context,
}) async {
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');
  // print(token);
  // return;

  final response =
      await http.post(Uri.parse('$BASE_URL/sequences/createsequence'), body: {
    'sequence_name': seqName,
    'job_id': jobID.toString(),
  }, headers: {
    'Authorization': 'Bearer $token',
  });

  return response;

  // print(response.body);
}
