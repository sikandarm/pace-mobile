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
  int? poNumber;
  String? address;
  String? dilveryDate;
  String? orderDate;
  String? terms;
  String? shipVia;
  List<BillofLadingItems>? billofLadingItems;

  Billdata(
      {this.id,
      this.billTitle,
      this.poNumber,
      this.address,
      this.dilveryDate,
      this.orderDate,
      this.terms,
      this.shipVia,
      this.billofLadingItems});

  Billdata.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    billTitle = json['billTitle'];
    poNumber = json['poNumber'];
    address = json['address'];
    dilveryDate = json['dilveryDate'];
    orderDate = json['orderDate'];
    terms = json['terms'];
    shipVia = json['shipVia'];
    if (json['BillofLadingItems'] != null) {
      billofLadingItems = <BillofLadingItems>[];
      json['BillofLadingItems'].forEach((v) {
        billofLadingItems!.add(new BillofLadingItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['billTitle'] = this.billTitle;
    data['poNumber'] = this.poNumber;
    data['address'] = this.address;
    data['dilveryDate'] = this.dilveryDate;
    data['orderDate'] = this.orderDate;
    data['terms'] = this.terms;
    data['shipVia'] = this.shipVia;
    if (this.billofLadingItems != null) {
      data['BillofLadingItems'] =
          this.billofLadingItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BillofLadingItems {
  int? quantity;
  String? fabricatedItems;
  String? companyName;
  String? fax;
  String? phone;

  BillofLadingItems(
      {this.quantity,
      this.fabricatedItems,
      this.companyName,
      this.fax,
      this.phone});

  BillofLadingItems.fromJson(Map<String, dynamic> json) {
    quantity = json['Quantity'];
    fabricatedItems = json['FabricatedItems'];
    companyName = json['CompanyName'];
    fax = json['Fax'];
    phone = json['Phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Quantity'] = this.quantity;
    data['FabricatedItems'] = this.fabricatedItems;
    data['CompanyName'] = this.companyName;
    data['Fax'] = this.fax;
    data['Phone'] = this.phone;
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
