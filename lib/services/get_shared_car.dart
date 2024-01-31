import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class CAReportModel {
  List<String>? activityFound;
  int? id;
  String? originatorName;
  String? contractorSupplier;
  DateTime? caReportDate;
  String? ncNo;
  String? purchaseOrderNo;
  String? partDescription;
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

  CAReportModel(
      {this.activityFound,
      this.id,
      this.originatorName,
      this.contractorSupplier,
      this.caReportDate,
      this.ncNo,
      this.purchaseOrderNo,
      this.partDescription,
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

  // String get formattedDate => DateFormat('dd MMMM yyyy').format(startDate);
}

Future<List<CAReportModel>> fetchSharedCARList() async {
  int? userId = await getIntFromSF('UserId');
  // userId = 211; // to view data for layout
  print('userId in shared car api:' + userId.toString());

  var request = http.MultipartRequest(
      'GET', Uri.parse('$BASE_URL/CA-report/shared/$userId'));
  // request.fields['userId'] = userId.toString();

  var response = await request.send();
  var responseString = await response.stream.bytesToString();
  print('responseString: ' + responseString);
  Map<String, dynamic> jsonMap = jsonDecode(responseString);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonMap['data']['sharedReports'];

    final List<CAReportModel> jobs = data.map((item) {
      return CAReportModel(
        id: item['id'] ?? 0,
        originatorName: item['originatorName'] ?? '',
        contractorSupplier: item['contractorSupplier'] ?? '',
        caReportDate: item['caReportDate'] != null
            ? DateTime.parse(item['caReportDate'])
            : null,
        ncNo: item['ncNo'] ?? '',
        purchaseOrderNo: item['purchaseOrderNo'] ?? '',
        partDescription: item['partDescription'] ?? '',
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
    }).toList();
    return jobs;
  } else {
    throw Exception('Failed to fetch tasks');
  }
}
