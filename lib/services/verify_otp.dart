import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/constants.dart';

class VerifyOtp {
  bool? success;
  String? message;

  VerifyOtp({this.success, this.message});

  VerifyOtp.fromJson(Map<String, dynamic> json) {
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

Future<VerifyOtp> verifyOtpApi({required String otp}) async {
  // final tokenBox = await Hive.openBox('tokenBox');
  // final token = tokenBox.get('token');

  final response = await http.post(Uri.parse('$BASE_URL/user/verify-otp'),
      //   headers: {
      //   'Authorization': 'Bearer $token',
//  }
      body: {
        'otp': otp,
      });

  final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

  return VerifyOtp.fromJson(decodedResponse);
}
