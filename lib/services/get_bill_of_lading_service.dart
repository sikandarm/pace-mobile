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
  List<BillData>? billData;

  Data({this.billData});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['billData'] != null) {
      billData = <BillData>[];
      json['billData'].forEach((v) {
        billData!.add(new BillData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.billData != null) {
      data['billData'] = this.billData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BillData {
  int? quantity;
  String? address;
  String? dilveryDate;
  String? orderDate;
  String? terms;
  String? shipVia;
  String? vendorName;
  String? fabricatedItems;
  int? pONumber;
  String? companyName;
  String? companyAddress;

  BillData(
      {this.quantity,
      this.address,
      this.dilveryDate,
      this.orderDate,
      this.terms,
      this.shipVia,
      this.vendorName,
      this.fabricatedItems,
      this.pONumber,
      this.companyName,
      this.companyAddress});

  BillData.fromJson(Map<String, dynamic> json) {
    quantity = json['quantity'];
    address = json['address'];
    dilveryDate = json['dilveryDate'];
    orderDate = json['orderDate'];
    terms = json['terms'];
    shipVia = json['shipVia'];
    vendorName = json['VendorName'];
    fabricatedItems = json['FabricatedItems'];
    pONumber = json['PO_Number'];
    companyName = json['CompanyName'];
    companyAddress = json['CompanyAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['quantity'] = this.quantity;
    data['address'] = this.address;
    data['dilveryDate'] = this.dilveryDate;
    data['orderDate'] = this.orderDate;
    data['terms'] = this.terms;
    data['shipVia'] = this.shipVia;
    data['VendorName'] = this.vendorName;
    data['FabricatedItems'] = this.fabricatedItems;
    data['PO_Number'] = this.pONumber;
    data['CompanyName'] = this.companyName;
    data['CompanyAddress'] = this.companyAddress;
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
