import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class CAReportModel {
  int? id;
  String? originatorName;
  DateTime? caReportDate;
  String? status;
  String? description;

  CAReportModel({
    this.id,
    this.originatorName,
    this.caReportDate,
    this.status,
    this.description,
  });
}

Future<List<CAReportModel>> fetchAllCARList() async {
  int? userId = await getIntFromSF('UserId');

  var url = Uri.parse('$BASE_URL/CA-report');
  //////////////////////////
 // var requestUrl = url.replace(queryParameters: {'userId': userId.toString()});
 // var response = await http.get(requestUrl);
  ////////////////////////////////////////////
   var response = await http.get(url);
  var responseString = response.body;

  print('View CAR API: $responseString');

  Map<String, dynamic> jsonMap = jsonDecode(responseString);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonMap['data']['caReports']['data'];

    // ignore: unnecessary_type_check
    if (data is List<dynamic>) {
      final List<CAReportModel> jobs = data.map((item) {
        return CAReportModel(
          id: item['id'] ?? 0,
          originatorName: item['originatorName'] ?? '',
          caReportDate: item['caReportDate'] != null
              ? DateTime.parse(item['caReportDate'])
              : null,
          status: item['status'] ?? '',
          description: item['description'] ?? '',
        );
      }).toList();
      return jobs;
    } else {
      throw Exception('Data is not in the expected format.');
    }
  } else {
    throw Exception('Failed to fetch tasks');
  }
}
