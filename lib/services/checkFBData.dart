import 'dart:convert';

import '../utils/constants.dart';
import 'package:http/http.dart' as http;


class CheckFBData {
  bool? success;
  String? message;
  Data? data;

  CheckFBData({this.success, this.message, this.data});

  CheckFBData.fromJson(Map<String, dynamic> json) {
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
  Fbdata? fbdata;
  bool? assignrole;

  Data({this.fbdata, this.assignrole});

  Data.fromJson(Map<String, dynamic> json) {
    fbdata =
        json['fbdata'] != null ? new Fbdata.fromJson(json['fbdata']) : null;
    assignrole = json['assignrole'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fbdata != null) {
      data['fbdata'] = this.fbdata!.toJson();
    }
    data['assignrole'] = this.assignrole;
    return data;
  }
}

class Fbdata {
  String? phone;
  String? email;

  Fbdata({this.phone, this.email});

  Fbdata.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['email'] = this.email;
    return data;
  }
}

Future<CheckFBData> checkFBDataApi({required String uid}) async {
  final response =
      await http.get(Uri.parse('$BASE_URL/auth/check-fb-data/$uid'));

  print('api response email to phone  :' + response.body);
  final decodedResponse = jsonDecode(response.body);

  return CheckFBData.fromJson(decodedResponse);
}
