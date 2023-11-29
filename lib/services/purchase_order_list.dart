import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class PurchaseOrders {
  PurchaseOrders({
    required this.id,
    required this.companyName,
    required this.address,
    required this.phone,
    required this.fax,
    required this.email,
    required this.status,
    required this.userId,
    required this.poNumber,
    required this.orderDate,
    required this.deliveryDate,
    required this.vendorName,
    required this.shipTo,
    required this.shipVia,
    required this.term,
    required this.orderBy,
    required this.confirmWith,
    required this.placedVia,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedAt,
    required this.deletedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.company,
    required this.vendor,
    required this.firstName,
  });
  late final int? id;
  late final int? companyName;
  late final String? address;
  late final String? phone;
  late final String? fax;
  late final String? email;
  late final String? status;
  late final int? userId;
  late final int? poNumber;
  late final String? orderDate;
  late final String? deliveryDate;
  late final int? vendorName;
  late final String? shipTo;
  late final String? shipVia;
  late final String? term;
  late final String? orderBy;
  late final String? confirmWith;
  late final String? placedVia;
  late final int? createdBy;
  late final int? updatedBy;
  late final String? deletedAt;
  late final int? deletedBy;
  late final String? createdAt;
  late final String? updatedAt;
  late final Company? company;
  late final Vendor? vendor;
  late final FirstName? firstName;

  PurchaseOrders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyName = json['company_name'];
    address = json['address'];
    phone = json['phone'];
    fax = json['fax'];
    email = json['email'];
    status = json['status'];
    userId = json['userId'];
    poNumber = json['po_number'];
    orderDate = json['order_date'];
    deliveryDate = json['delivery_date'];
    vendorName = json['vendor_name'];
    shipTo = json['ship_to'];
    shipVia = json['ship_via'];
    term = json['term'];
    orderBy = json['order_by'];
    confirmWith = json['confirm_with'];
    placedVia = json['placed_via'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    deletedAt = json['deleted_at'];
    deletedBy = json['deleted_by'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    company = Company.fromJson(json['company']);
    vendor = Vendor.fromJson(json['vendor']);
    firstName = FirstName.fromJson(json['firstName']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['company_name'] = companyName;
    _data['address'] = address;
    _data['phone'] = phone;
    _data['fax'] = fax;
    _data['email'] = email;
    _data['status'] = status;
    _data['userId'] = userId;
    _data['po_number'] = poNumber;
    _data['order_date'] = orderDate;
    _data['delivery_date'] = deliveryDate;
    _data['vendor_name'] = vendorName;
    _data['ship_to'] = shipTo;
    _data['ship_via'] = shipVia;
    _data['term'] = term;
    _data['order_by'] = orderBy;
    _data['confirm_with'] = confirmWith;
    _data['placed_via'] = placedVia;
    _data['created_by'] = createdBy;
    _data['updated_by'] = updatedBy;
    _data['deleted_at'] = deletedAt;
    _data['deleted_by'] = deletedBy;
    _data['createdAt'] = createdAt;
    _data['updatedAt'] = updatedAt;
    _data['company'] = company?.toJson();
    _data['vendor'] = vendor?.toJson();
    _data['firstName'] = firstName?.toJson();
    return _data;
  }
}

class Company {
  Company({
    required this.name,
  });
  late final String name;

  Company.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    return _data;
  }
}

class Vendor {
  Vendor({
    required this.vendorName,
  });
  late final String vendorName;

  Vendor.fromJson(Map<String, dynamic> json) {
    vendorName = json['vendor_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['vendor_name'] = vendorName;
    return _data;
  }
}

class FirstName {
  FirstName({
    required this.firstName,
  });
  late final String firstName;

  FirstName.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['firstName'] = firstName;
    return _data;
  }
}

Future<List<PurchaseOrders>> getAllPurchaseOrders() async {
  List<PurchaseOrders> purchaseOrdersList = [];
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');
  final response = await http
      .get(Uri.parse("$BASE_URL/purchaseorder/getpurchaseOrder"), headers: {
    'Authorization': 'Bearer $token',
  });

  // print('====================');
  // print('Response BODY: ' + response.body);
  // print('====================');

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = json.decode(response.body);

    final dynamic purchaseOrderData = responseBody['data'];

    if (purchaseOrderData != null &&
        purchaseOrderData is Map<String, dynamic> &&
        purchaseOrderData.isEmpty) {
      return [];
    }

    final dynamic purchaseOrderDataList = purchaseOrderData['purchaseOrders'];
    if (purchaseOrderDataList != null && purchaseOrderDataList is List) {
      purchaseOrdersList =
          purchaseOrderDataList.map((e) => PurchaseOrders.fromJson(e)).toList();
      purchaseOrdersList;
    }
  }

  // print('====================');
  // print(purchaseOrdersList);
  // print('====================');
  return purchaseOrdersList;
}
