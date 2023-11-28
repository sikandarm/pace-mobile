import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class NotificationModel {
  int? id;
  String? title;
  String? body;
  DateTime? updatedAt;

  NotificationModel({
    this.id,
    this.title,
    this.body,
    this.updatedAt,
  });
}

Future<List<NotificationModel>> fetchAllCNotifications() async {
  int? userId = await getIntFromSF('UserId');

  var url = Uri.parse('$BASE_URL/notifications');
  var requestUrl = url.replace(queryParameters: {'userId': userId.toString()});

  var response = await http.get(requestUrl);
  var responseString = response.body;
  print(responseString);

  Map<String, dynamic> jsonMap = jsonDecode(responseString);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonMap['data']['notifications']['data'];

    // ignore: unnecessary_type_check
    if (data is List<dynamic> && data.isNotEmpty) {
      final List<NotificationModel> jobs = data.map((item) {
        DateTime? updatedAt;
        if (item['updatedAt'] != null) {
          updatedAt = DateTime.tryParse(item['updatedAt']);
        }

        return NotificationModel(
          id: item['id'] ?? 0,
          title: item['title'] ?? '',
          updatedAt: updatedAt ?? DateTime(1970),
          body: item['body'] ?? '',
        );
      }).toList();
      return jobs;
    } else if (data.isEmpty) {
      return [];
    } else {
      throw Exception('Data is not in the expected format.');
    }
  } else {
    throw Exception('Failed to fetch data');
  }
}
