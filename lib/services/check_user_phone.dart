import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pace_application_fb/utils/constants.dart';

class CheckUserPhoneModel {
  bool? success;
  String? message;
  String? data;

  CheckUserPhoneModel({this.success, this.message, this.data});

  CheckUserPhoneModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['data'] = this.data;
    return data;
  }
}

Future<CheckUserPhoneModel> checkUserPhone({required String email}) async {
  final response = await http.get(Uri.parse('$BASE_URL/auth/check-user-phone/$email'));

  print('api response email to phone  :'+response.body);
  final decodedResponse = jsonDecode(response.body);

  return CheckUserPhoneModel.fromJson(decodedResponse);
}
