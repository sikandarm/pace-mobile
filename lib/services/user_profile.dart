import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class UserProfile {
  final int id;
  final String firstName;
  final String? lastName;
  final String? email;
  final String phone;
  final int? ratePerHour;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.ratePerHour,
  });
}

Future<UserProfile> fetchUserProfile() async {
  int? userId = await getIntFromSF('UserId');

  final response = await http.get(Uri.parse("$BASE_URL/user/$userId"));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = json.decode(response.body);

    final dynamic userData = responseBody['data'];

    if (userData != null && userData is Map<String, dynamic>) {
      final dynamic user = userData['user'];

      if (user != null) {
        return UserProfile(
          id: user['id'],
          firstName: user['firstName'] ?? '',
          lastName: user['lastName'],
          email: user['email'],
          phone: user['phone'] ?? '',
          ratePerHour: user['ratePerHour'],
        );
      }
    }
  }
  throw Exception('Failed to fetch profile');
}
