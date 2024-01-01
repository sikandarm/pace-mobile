import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class PurchaseOrderItemModel {
  int? id;
  String? companyName;
  String? vendorName;
  int? poNumber;
  String? createdAt;
  String? orderBy;
  String? shipTo;
  String? shipVia;
  String? orderDate;
  String? deliveryDate;
  String? placedVia;

  PurchaseOrderItemModel(
      {this.id,
      this.companyName,
      this.vendorName,
      this.poNumber,
      this.createdAt,
      this.orderBy,
      this.shipTo,
      this.shipVia,
      this.orderDate,
      this.deliveryDate,
      this.placedVia});

  PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyName = json['companyName'];
    vendorName = json['vendorName'];
    poNumber = json['PoNumber'];
    createdAt = json['createdAt'];
    orderBy = json['OrderBy'];
    shipTo = json['shipTo'];
    shipVia = json['shipVia'];
    orderDate = json['orderDate'];
    deliveryDate = json['deliveryDate'];
    placedVia = json['placedVia'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['companyName'] = this.companyName;
    data['vendorName'] = this.vendorName;
    data['PoNumber'] = this.poNumber;
    data['createdAt'] = this.createdAt;
    data['OrderBy'] = this.orderBy;
    data['shipTo'] = this.shipTo;
    data['shipVia'] = this.shipVia;
    data['orderDate'] = this.orderDate;
    data['deliveryDate'] = this.deliveryDate;
    data['placedVia'] = this.placedVia;
    return data;
  }
}

class PurchaseOrderItems {
  int? id;
  int? poId;
  String? inventoryItem;
  int? quantity;

  PurchaseOrderItems({this.id, this.poId, this.inventoryItem, this.quantity});

  PurchaseOrderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    poId = json['po_id'];
    inventoryItem = json['InventoryItem'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['po_id'] = this.poId;
    data['InventoryItem'] = this.inventoryItem;
    data['quantity'] = this.quantity;
    return data;
  }
}

Future<List<PurchaseOrderItems>> fetchPurchaseOrderItemsDetailListData(
    {required int id}) async {
  List<PurchaseOrderItems> itemsListData = [];
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');
  // print('token in api:' + token);
  final response = await http.get(
      Uri.parse("$BASE_URL/purchaseorder/getpurchaseorderitems/$id"),
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

    final itemsList = itemsData['PurchaseOrderItems'];
    // print('itemsList: ${itemsData['Itemsdata']}');
    if (itemsList != null && itemsList is List) {
      List<PurchaseOrderItems> items = itemsList.map((item) {
        // print(item);
        return PurchaseOrderItems.fromJson(item);
      }).toList();
      // print('items: ' + items.toString());
      itemsListData = items;
      //  return items;
    }
  }
  print('final PurchaseOrderItems: $itemsListData');
  return itemsListData;
  // throw Exception('Failed to fetch purchase orders items List');
}
