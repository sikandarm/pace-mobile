import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/constants.dart';

class BillOfLadingModel {
  bool? success;
  String? message;
  Data? data;

  BillOfLadingModel({this.success, this.message, this.data});

  BillOfLadingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Billdata>? billdata;

  Data({this.billdata});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['Billdata'] != null) {
      billdata = <Billdata>[];
      json['Billdata'].forEach((v) {
        billdata!.add(new Billdata.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.billdata != null) {
      data['Billdata'] = this.billdata!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Billdata {
  int? id;
  String? billTitle;
  String? address;
  String? dilveryDate;
  String? orderDate;
  String? terms;
  String? shipVia;
  BillofLadingItems? billofLadingItems;

  Billdata(
      {this.id,
      this.billTitle,
      this.address,
      this.dilveryDate,
      this.orderDate,
      this.terms,
      this.shipVia,
      this.billofLadingItems});

  Billdata.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    billTitle = json['billTitle'];
    address = json['address'];
    dilveryDate = json['dilveryDate'];
    orderDate = json['orderDate'];
    terms = json['terms'];
    shipVia = json['shipVia'];
    billofLadingItems = json['BillofLadingItems'] != null
        ? new BillofLadingItems.fromJson(json['BillofLadingItems'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['billTitle'] = this.billTitle;
    data['address'] = this.address;
    data['dilveryDate'] = this.dilveryDate;
    data['orderDate'] = this.orderDate;
    data['terms'] = this.terms;
    data['shipVia'] = this.shipVia;
    if (this.billofLadingItems != null) {
      data['BillofLadingItems'] = this.billofLadingItems!.toJson();
    }
    return data;
  }
}

class BillofLadingItems {
  int? quantity;
  String? companyName;
  String? companyAddress;
  int? poNumber;
  String? vendorName;
  String? fabricatedItems;

  BillofLadingItems(
      {this.quantity,
      this.companyName,
      this.companyAddress,
      this.poNumber,
      this.vendorName,
      this.fabricatedItems});

  BillofLadingItems.fromJson(Map<String, dynamic> json) {
    quantity = json['Quantity'];
    companyName = json['CompanyName'];
    companyAddress = json['CompanyAddress'];
    poNumber = json['po_number'];
    vendorName = json['vendor_name'];
    fabricatedItems = json['FabricatedItems'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Quantity'] = this.quantity;
    data['CompanyName'] = this.companyName;
    data['CompanyAddress'] = this.companyAddress;
    data['po_number'] = this.poNumber;
    data['vendor_name'] = this.vendorName;
    data['FabricatedItems'] = this.fabricatedItems;
    return data;
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
