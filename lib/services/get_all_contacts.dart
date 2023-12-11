import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class ContactList {
  bool success;
  String message;
  ContactListData data;

  ContactList({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ContactList.fromJson(Map<String, dynamic> json) {
    return ContactList(
      success: json['success'],
      message: json['message'],
      data: ContactListData.fromJson(json['data']),
    );
  }
}

class ContactListData {
  List<ContactModel> contacts;

  ContactListData({
    required this.contacts,
  });

  factory ContactListData.fromJson(Map<String, dynamic> json) {
    List<dynamic> contactsList = json['contacts'];
    List<ContactModel> contacts =
        contactsList.map((contact) => ContactModel.fromJson(contact)).toList();

    return ContactListData(
      contacts: contacts,
    );
  }
}

class ContactModel {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;

  ContactModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

Future<ContactList> getAllContacts() async {
  // List<TasklogModel> taskLogList = [];
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');

  final response = await http.get(Uri.parse('$BASE_URL/contact/'), headers: {
    'Authorization': 'Bearer $token',
  });
  final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

  print(decodedResponse);

  return ContactList.fromJson(decodedResponse);
}
