import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/constants.dart';

class UpdatePassword {
  bool? success;
  String? message;

  UpdatePassword({this.success, this.message});

  UpdatePassword.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    return data;
  }
}

Future<UpdatePassword> updatePasswordApi(
    {required String email, required String newPassword}) async {
  // final tokenBox = await Hive.openBox('tokenBox');
  // final token = tokenBox.get('token');

  final response = await http.post(Uri.parse('$BASE_URL/user/reset-password'),
      //   headers: {
      //   'Authorization': 'Bearer $token',
//  }
      body: {
        'email': email,
        'password': newPassword,
      });

  final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

  return UpdatePassword.fromJson(decodedResponse);
}
