import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

// /purchaseorder/changestatus/:id

Future<bool> changePurchaseOrderStatusByID({required int id}) async {
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');
  // print('token in api:' + token);
  final response = await http.post(
      body: {'status': 'Recieved'},
      Uri.parse("http://192.168.1.2:3500/api/purchaseorder/changestatus/$id"),
      headers: {
        'Authorization': 'Bearer $token',
      });

  if (response.statusCode == 200) {
    return true;
  }
  return false;
}
