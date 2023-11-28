import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class UserListModel {
  int? id;
  String? firstName;
  String? lastName;
  String? email;

  UserListModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
  });
}

Future<List<UserListModel>> fetchUserList() async {
  final response = await http.get(Uri.parse("$BASE_URL/user"));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = json.decode(response.body);

    final dynamic inventoryData = responseBody['data'];

    if (inventoryData != null &&
        inventoryData is Map<String, dynamic> &&
        inventoryData.isEmpty) {
      return []; // Return an empty list when no tasks are found
    }

    final dynamic inventoryList = inventoryData['users'];

    if (inventoryList != null && inventoryList is List<dynamic>) {
      final List<UserListModel> inventory = inventoryList.map((json) {
        return UserListModel(
          id: json['id'],
          firstName: json['firstName'],
          lastName: json['lastName'],
          email: json['email'],
        );
      }).toList();
      return inventory;
    }
  }
  throw Exception('Failed to fetch User List');
}
