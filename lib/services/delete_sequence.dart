import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

Future<http.Response> deleteSequence({required int jobID}) async {
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');
  final response = await http.delete(
      Uri.parse(
        'http://192.168.1.7:3500/api/sequences/deletesequence/$jobID',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      });

  return response;
}
