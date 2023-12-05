import 'package:com_a3_pace/utils/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

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

  return response;
}
