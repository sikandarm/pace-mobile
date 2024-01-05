import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pace_application_fb/utils/constants.dart';

class CheckUserRoleModel {
  bool? success;
  String? message;
  bool? data;

  CheckUserRoleModel({this.success, this.message, this.data});

  CheckUserRoleModel.fromJson(Map<String, dynamic> json) {
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

Future<CheckUserRoleModel> checkUserRole({required String email}) async {
  final response =
      await http.get(Uri.parse('$BASE_URL/auth/check-user-role/$email'));

  print('api response user role   :' + response.body);
  final decodedResponse = jsonDecode(response.body);

  return CheckUserRoleModel.fromJson(decodedResponse);
}
