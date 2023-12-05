import 'dart:convert';

import 'package:com_a3_pace/utils/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

// /purchaseorder/changestatus/:id

Future<bool> changePurchaseOrderStatusByID({required int id}) async {
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');
  // print('token in api:' + token);
  final response = await http.patch(
      body: jsonEncode({'status': 'Received'}),
      Uri.parse("$BASE_URL/purchaseorder/changestatus/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-type': 'application/json',
      });

  print('Api Response:' + response.body);
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}
