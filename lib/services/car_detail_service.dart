import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class CarDetailObj {
  final List<String>? activityFound;
  final int? id;
  String? originatorName;
  String? contractorSupplier;
  DateTime? caReportDate;
  String? ncNo;
  String? purchaseOrderNo;
  String? partDescription;
  String? status;
  String? partId;
  int? quantity;
  String? dwgNo;
  String? description;
  String? actionToPrevent;
  String? disposition;
  String? responsiblePartyName;
  DateTime? responsiblePartyDate;
  String? correctiveActionDesc;
  String? approvalName;
  DateTime? approvalDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  CarDetailObj(
      {this.activityFound,
      this.id,
      this.originatorName,
      this.contractorSupplier,
      this.caReportDate,
      this.ncNo,
      this.purchaseOrderNo,
      this.partDescription,
      this.status,
      this.partId,
      this.quantity,
      this.dwgNo,
      this.description,
      this.actionToPrevent,
      this.disposition,
      this.responsiblePartyName,
      this.responsiblePartyDate,
      this.correctiveActionDesc,
      this.approvalName,
      this.approvalDate,
      this.createdAt,
      this.updatedAt});
}

Future<List<CarDetailObj>> fetchCARDetail(int carId) async {
  final response = await http.get(Uri.parse('$BASE_URL/CA-report/$carId'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = json.decode(response.body);

    if (responseBody['success'] == true) {
      final dynamic item = responseBody['data']['caReport'];
      print(item);

      if (item != null && item is Map<String, dynamic>) {
        final CarDetailObj carObj = CarDetailObj(
          id: item['id'] ?? 0,
          originatorName: item['originatorName'] ?? '',
          contractorSupplier: item['contractorSupplier'] ?? '',
          caReportDate: item['caReportDate'] != null
              ? DateTime.parse(item['caReportDate'])
              : null,
          ncNo: item['ncNo'] ?? '',
          purchaseOrderNo: item['purchaseOrderNo'] ?? '',
          partDescription: item['partDescription'] ?? '',
          status: item['status'] ?? '',
          partId: item['partId'] ?? '',
          quantity: item['quantity'] ?? 0,
          dwgNo: item['dwgNo'] ?? '',
          description: item['description'] ?? '',
          actionToPrevent: item['actionToPrevent'] ?? '',
          disposition: item['disposition'] ?? '',
          responsiblePartyName: item['responsiblePartyName'] ?? '',
          responsiblePartyDate: item['responsiblePartyDate'] != null
              ? DateTime.parse(item['responsiblePartyDate'])
              : null,
          correctiveActionDesc: item['correctiveActionDesc'] ?? '',
          approvalName: item['approvalName'] ?? '',
          approvalDate: item['approvalDate'] != null
              ? DateTime.parse(item['approvalDate'])
              : null,
          createdAt: item['createdAt'] != null
              ? DateTime.parse(item['createdAt'])
              : null,
        );

        return [carObj];
      }
    }
  }

  throw Exception('Failed to fetch tasks');
}
