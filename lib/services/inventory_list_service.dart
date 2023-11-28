import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class InventoryListModel {
  int? id;
  String? ediStdNomenclature;
  String? aiscManualLabel;
  String? shape;
  String? weight;
  String? depth;
  String? grade;
  String? poNumber;
  String? heatNumber;
  bool? orderArrivedInFull;
  bool? orderArrivedCMTR;
  String? itemType;
  int? lengthReceivedFoot;
  int? lengthReceivedInch;
  int? quantity;
  String? poPulledFromNumber;
  int? lengthUsedFoot;
  int? lengthUsedInch;
  int? lengthRemainingFoot;
  int? lengthRemainingInch;
  DateTime? createdAt;
  DateTime? updatedAt;

  InventoryListModel(
      {this.id,
      this.ediStdNomenclature,
      this.aiscManualLabel,
      this.shape,
      this.weight,
      this.depth,
      this.grade,
      this.poNumber,
      this.heatNumber,
      this.orderArrivedInFull,
      this.orderArrivedCMTR,
      this.itemType,
      this.lengthReceivedFoot,
      this.lengthReceivedInch,
      this.quantity,
      this.poPulledFromNumber,
      this.lengthUsedFoot,
      this.lengthUsedInch,
      this.lengthRemainingFoot,
      this.lengthRemainingInch,
      this.createdAt,
      this.updatedAt
      });
}

Future<List<InventoryListModel>> fetchInventoryList() async {
  final response = await http.get(Uri.parse("$BASE_URL/inventory"));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = json.decode(response.body);

    final dynamic inventoryData = responseBody['data'];

    if (inventoryData != null &&
        inventoryData is Map<String, dynamic> &&
        inventoryData.isEmpty) {
      return []; // Return an empty list when no tasks are found
    }

    final dynamic inventoryList = inventoryData['inventories'];

    if (inventoryList != null && inventoryList is List<dynamic>) {
      final List<InventoryListModel> inventory = inventoryList.map((item) {
        return InventoryListModel(
          id: item['id'],
          ediStdNomenclature: item['ediStdNomenclature'],
          aiscManualLabel: item['aiscManualLabel'] ?? '',
          shape: item['shape'],
          weight: item['weight'],
          depth: item['depth'],
          grade: item['grade'] ?? '',
          poNumber: item['poNumber'],
          heatNumber: item['heatNumber'],
          orderArrivedInFull: item['orderArrivedInFull'],
          orderArrivedCMTR: item['orderArrivedCMTR'] ?? '',
          itemType: item['itemType'],
          lengthReceivedFoot: item['lengthReceivedFoot'],
          lengthReceivedInch: item['lengthReceivedInch'] ?? '',
          quantity: item['quantity'],
          poPulledFromNumber: item['poPulledFromNumber'],
          lengthUsedFoot: item['lengthUsedFoot'],
          lengthUsedInch: item['lengthUsedInch'] ?? '',
          lengthRemainingFoot: item['lengthRemainingFoot'],
          lengthRemainingInch: item['lengthRemainingInch'],
          createdAt: item['createdAt'] != null
              ? DateTime.parse(item['createdAt'])
              : null,
        );
      }).toList();
      return inventory;
    }
  }
  throw Exception('Failed to fetch Inventory List');
}
