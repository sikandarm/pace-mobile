import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class UserContactList {
  bool? success;
  String? message;
  Data? data;

  UserContactList({this.success, this.message, this.data});

  UserContactList.fromJson(Map<String, dynamic> json) {
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
  List<Users>? users;

  Data({this.users});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(new Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  Null? address;
  Null? city;
  Null? state;
  Null? zip;
  bool? isActive;
  int? ratePerHour;
  String? resetToken;
  Null? resetTokenExpiry;
  List<Roles>? roles;

  Users(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.address,
      this.city,
      this.state,
      this.zip,
      this.isActive,
      this.ratePerHour,
      this.resetToken,
      this.resetTokenExpiry,
      this.roles});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    isActive = json['isActive'];
    ratePerHour = json['ratePerHour'];
    resetToken = json['resetToken'];
    resetTokenExpiry = json['resetTokenExpiry'];
    if (json['roles'] != null) {
      roles = <Roles>[];
      json['roles'].forEach((v) {
        roles!.add(new Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['zip'] = this.zip;
    data['isActive'] = this.isActive;
    data['ratePerHour'] = this.ratePerHour;
    data['resetToken'] = this.resetToken;
    data['resetTokenExpiry'] = this.resetTokenExpiry;
    if (this.roles != null) {
      data['roles'] = this.roles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  int? id;
  String? name;

  Roles({this.id, this.name});

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

Future<UserContactList> getAllUserContacts() async {
  // List<TasklogModel> taskLogList = [];
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');

  final response = await http.get(Uri.parse('$BASE_URL/user/'), headers: {
    'Authorization': 'Bearer $token',
  });
  final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

  print(decodedResponse);

  return UserContactList.fromJson(decodedResponse);
}
