import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class allRolesModel {
  int? id;
  String? name;
  bool? isNotification;

  allRolesModel({
    this.id,
    this.name,
    this.isNotification,
  });
}

Future<List<allRolesModel>> fetchAllRoles() async {
  var url = Uri.parse('$BASE_URL/role');
  var response = await http.get(url);
  var responseString = response.body;

  Map<String, dynamic> jsonMap = jsonDecode(responseString);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonMap['data']['roles'];

    // ignore: unnecessary_type_check
    if (data is List<dynamic>) {
      final List<allRolesModel> jobs = data.map((item) {
        return allRolesModel(
          id: item['id'] ?? 0,
          name: item['name'] ?? '',
          isNotification: item['isNotification'] ?? false,
        );
      }).toList();
      return jobs;
    } else {
      throw Exception('Data is not in the expected format.');
    }
  } else {
    throw Exception('Failed to fetch records');
  }
}
