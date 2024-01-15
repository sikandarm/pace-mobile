import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class NotificationModel {
  bool? success;
  String? message;
  Data? data;

  NotificationModel({this.success, this.message, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Notifications>? notifications;

  Data({this.notifications});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <Notifications>[];
      json['notifications'].forEach((v) {
        notifications!.add(new Notifications.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notifications != null) {
      data['notifications'] =
          this.notifications!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Notifications {
  int? id;
  String? title;
  String? body;
  String? updatedAt;
  int? userId;

  Notifications({this.id, this.title, this.body, this.updatedAt, this.userId});

  Notifications.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    body = json['body'];
    updatedAt = json['updatedAt'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['body'] = this.body;
    data['updatedAt'] = this.updatedAt;
    data['userId'] = this.userId;
    return data;
  }
}

Future<NotificationModel> fetchAllNotifications() async {
  int? userId = await getIntFromSF('UserId');

  var url = Uri.parse('$BASE_URL/notifications');
  var requestUrl = url.replace(queryParameters: {'userId': userId.toString()});

  var response = await http.get(requestUrl);
//  var response = await http.get(url);

  var responseString = response.body;
  print(responseString);

  Map<String, dynamic> jsonMap = jsonDecode(responseString);
  print('Notification API Message: ' + jsonMap['message'].toString());
  if (jsonMap['message'] == 'No notifications found') {
    return NotificationModel(
        data: Data(notifications: []), message: null, success: true);
  }
  return NotificationModel.fromJson(jsonMap);
}
