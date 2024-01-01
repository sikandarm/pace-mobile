import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ItemsdataModel {
  int? id;
  int? poId;
  String? inventoryItem;
  int? quantity;
  // String? createdAt;

  ItemsdataModel({
    this.poId,
    this.inventoryItem,
    this.quantity,
    this.id,
    //  this.createdAt,
  });

  ItemsdataModel.fromJson(Map<String, dynamic> json) {
    poId = json['po_id'];
    inventoryItem = json['InventoryItem'];
    quantity = json['quantity'];
    id = json['id'];
    // createdAt = json['createdat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['po_id'] = this.poId;
    data['InventoryItem'] = this.inventoryItem;
    data['quantity'] = this.quantity;

    //  data['createdat'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}

Future<List<ItemsdataModel>> fetchPurchaseOrderItemsDataList() async {
  List<ItemsdataModel> itemsListData = [];
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');
  // print('token in api:' + token);
  final response = await http.get(
      Uri.parse("http://192.168.1.2:3500/api/purchaseorder/getitems"),
      headers: {
        'Authorization': 'Bearer $token',
      });

  print('response: ${response.body}');
  print('status code: ${response.statusCode}');

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = json.decode(response.body);

    final itemsData = responseBody['data'];

    //   print('itemsData:' + itemsData.toString());

    if (itemsData != null &&
        itemsData is Map<String, dynamic> &&
        itemsData.isEmpty) {
      return []; // Return an empty list when no items are found
    }

    final itemsList = itemsData['Itemsdata'];
    // print('itemsList: ${itemsData['Itemsdata']}');
    if (itemsList != null && itemsList is List) {
      List<ItemsdataModel> items = itemsList.map((item) {
        // print(item);
        return ItemsdataModel.fromJson(item);
      }).toList();
      // print('items: ' + items.toString());
      itemsListData = items;
      //  return items;
    }
  }
  print('final itemsListData: $itemsListData');
  return itemsListData;
  // throw Exception('Failed to fetch purchase orders items List');
}
