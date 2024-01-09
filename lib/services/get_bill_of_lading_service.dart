import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/constants.dart';

class BillOfLadingModel {
  bool success;
  String message;
  Data data;

  BillOfLadingModel(
      {required this.success, required this.message, required this.data});

  factory BillOfLadingModel.fromJson(Map<String, dynamic> json) {
    return BillOfLadingModel(
      success: json['success'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  List<Item> dataList;

  Data({required this.dataList});

  factory Data.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Item> items = list.map((item) => Item.fromJson(item)).toList();

    return Data(dataList: items);
  }
}

class Item {
  String fabricatedItemName;
  int quantity;
  String companyName;
  String vendorName;

  Item({
    required this.fabricatedItemName,
    required this.quantity,
    required this.companyName,
    required this.vendorName,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      fabricatedItemName: json['fabricatedItemName'],
      quantity: json['quantity'],
      companyName: json['companyName'],
      vendorName: json['vendorName'],
    );
  }
}

Future<BillOfLadingModel> getBillOfLading() async {
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');

  final response =
      await http.get(Uri.parse('$BASE_URL/bill/get-bill'), headers: {
    'Authorization': 'Bearer $token',
  });
  final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

  print(decodedResponse);

  return BillOfLadingModel.fromJson(decodedResponse);
}
