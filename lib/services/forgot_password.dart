import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/constants.dart';

class ForgotPassword {
  bool? success;
  String? message;

  ForgotPassword({this.success, this.message});

  ForgotPassword.fromJson(Map<String, dynamic> json) {
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

Future<ForgotPassword> forgotPasswordApi({required String email}) async {
  // final tokenBox = await Hive.openBox('tokenBox');
  // final token = tokenBox.get('token');

  final response = await http.post(Uri.parse('$BASE_URL/user/forget-password'),
      //   headers: {
      //   'Authorization': 'Bearer $token',
//  }
      body: {
        'email': email,
      });

  final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

  return ForgotPassword.fromJson(decodedResponse);
}
