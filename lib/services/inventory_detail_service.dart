import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class InventoryDetailModel {
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

  InventoryDetailModel({
    this.id,
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
  });
}

Future<List<InventoryDetailModel>> fetchInventoryDetail(int taskId) async {
  final response = await http.get(Uri.parse('$BASE_URL/inventory/$taskId'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = json.decode(response.body);

    if (responseBody['success'] == true) {
      final dynamic taskData = responseBody['data']['inventory'];
      print(taskData);

      if (taskData != null && taskData is Map<String, dynamic>) {
        final InventoryDetailModel task = InventoryDetailModel(
          id: taskData['id'],
          ediStdNomenclature: taskData['ediStdNomenclature'] ?? '',
          createdAt: taskData['createdAt'] != null
              ? DateTime.parse(taskData['createdAt'])
              : null,
          aiscManualLabel: taskData['aiscManualLabel'] ?? '',
          shape: taskData['shape'] ?? '',
          weight: taskData['weight'] ?? '',
          depth: taskData['depth'] ?? '',
          grade: taskData['grade'] ?? '',
          poNumber: taskData['poNumber'] ?? '',
          heatNumber: taskData['heatNumber'] ?? '',
          orderArrivedInFull: taskData['orderArrivedInFull'],
          orderArrivedCMTR: taskData['orderArrivedCMTR'],
          itemType: taskData['itemType'] ?? '',
          lengthReceivedFoot: taskData['lengthReceivedFoot'] ?? 0,
          lengthReceivedInch: taskData['lengthReceivedInch'] ?? 0,
          quantity: taskData['quantity'] ?? 0,
          poPulledFromNumber: taskData['poPulledFromNumber'] ?? '',
          lengthUsedFoot: taskData['lengthUsedFoot'] ?? 0,
          lengthUsedInch: taskData['lengthUsedInch'] ?? 0,
          lengthRemainingFoot: taskData['lengthRemainingFoot'] ?? 0,
          lengthRemainingInch: taskData['lengthRemainingInch'] ?? 0,
        );

        return [task];
      }
    }
  }

  throw Exception('Failed to fetch Inventory Record');
}
