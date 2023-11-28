import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class Reason {
  final int id;
  final String name;
  final int parentId;

  Reason({
    required this.id,
    required this.name,
    required this.parentId,
  });

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(
      id: json['id'],
      name: json['name'],
      parentId: json['parentId'],
    );
  }
}

class ReasonCategory {
  final int id;
  final String name;
  final List<Reason> children;

  ReasonCategory({
    required this.id,
    required this.name,
    required this.children,
  });

  factory ReasonCategory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> childrenJson = json['children'];
    final List<Reason> children =
        childrenJson.map((item) => Reason.fromJson(item)).toList();

    return ReasonCategory(
      id: json['id'],
      name: json['name'],
      children: children,
    );
  }
}

Future<List<ReasonCategory>> fetchRejectionReasons() async {
  final response = await http.get(Uri.parse('$BASE_URL/rejected-reasons'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = json.decode(response.body);
    final List<dynamic> data = responseBody['data']['reasons'];

    print("fetchRejectionReasons");
    print(data);
    final List<ReasonCategory> rejectionReasonCategories = data.map((item) {
      return ReasonCategory.fromJson(item);
    }).toList();

    return rejectionReasonCategories;
  } else {
    throw Exception('Failed to fetch records');
  }
}
