import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../services/car_detail_service.dart';
import '../utils/constants.dart';
import 'UserList.dart';
import 'department_list.dart';

class CARDetail extends StatefulWidget {
  final int carId;

  const CARDetail({Key? key, required this.carId}) : super(key: key);

  @override
  State<CARDetail> createState() => _CARDetailState();
}

class _CARDetailState extends State<CARDetail> {
  Future<List<CarDetailObj>> _futureList = Future.value([]);

  @override
  void initState() {
    super.initState();
    _futureList = fetchCARDetail(widget.carId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the last screen in the stack
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: const Text(
          "Corrective Action Report",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //
        //     },
        //     child: Container(
        //       margin: const EdgeInsets.only(
        //           right: 20.0), // Adjust the value as needed
        //       child: const Icon(
        //         Icons.share,
        //         size: 24,
        //         color: Colors.blue,
        //       ),
        //     ),
        //   )
        // ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder<List<CarDetailObj>>(
              future: _futureList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(
                    child: Text("Error : ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No Record found"),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final tasks = snapshot.data![index];

                      return CARDetailWidget(
                        id: tasks.id,
                        originatorName: tasks.originatorName,
                        contractorSupplier: tasks.contractorSupplier,
                        caReportDate: tasks.caReportDate,
                        ncNo: tasks.ncNo,
                        status: tasks.status,
                        purchaseOrderNo: tasks.purchaseOrderNo,
                        quantity: tasks.quantity,
                        dwgNo: tasks.dwgNo,
                        correctiveActionDesc: tasks.correctiveActionDesc,
                        approvalName: tasks.approvalName,
                        approvalDate: tasks.approvalDate,
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

class CARDetailWidget extends StatelessWidget {
  final int? id;
  final String? originatorName;
  final String? contractorSupplier;
  final DateTime? caReportDate;
  final String? ncNo;
  final String? status;
  final String? purchaseOrderNo;
  final int? quantity;
  final String? dwgNo;
  final String? correctiveActionDesc;
  final String? approvalName;
  final DateTime? approvalDate;

  const CARDetailWidget({
    Key? key,
    this.id,
    this.originatorName,
    this.contractorSupplier,
    this.caReportDate,
    this.ncNo,
    this.status,
    this.purchaseOrderNo,
    this.quantity,
    this.dwgNo,
    this.correctiveActionDesc,
    this.approvalName,
    this.approvalDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to TaskDetail screen
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => TaskDetail(taskId: taskId),
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildGradeRow("Originator Name", originatorName!),
            buildGradeRow("Contractor/Supplier", contractorSupplier!),
            buildGradeRow(
                "Date", DateFormat(US_DATE_FORMAT).format(caReportDate!)),
            buildGradeRow("NC#", ncNo!),
            buildGradeRow("Purchase Order#", purchaseOrderNo!),
            buildGradeRow("Quantity", quantity.toString()),
            buildGradeRow("Dwg#", dwgNo!),
            const SizedBox(height: 20),
            const Text(
              'Corrective/Preventive Action',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Description of proposed action',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              correctiveActionDesc!,
              style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0,
                  color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Approval of corrective/preventive action',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 10),
            buildGradeRow("Name", approvalName!),
            buildGradeRow(
                "Date", DateFormat(US_DATE_FORMAT).format(approvalDate!)),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      callUpdateCAR(context, id!, "rejected");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red, // Set button background color to blue
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        color: Colors.white, // Set button text color to white
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      callUpdateCAR(context, id!, "approved");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green, // Set button background color to blue
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        color: Colors.white, // Set button text color to white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> callUpdateCAR(
      BuildContext context, int taskId, String status) async {
    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = await getIntFromSF('UserId');

      // ignore: unnecessary_null_comparison
      if (userId != null) {
        var request = http.MultipartRequest(
            'PUT', Uri.parse('$BASE_URL/CA-report/$taskId/status'));
        request.fields['status'] = status;

        var response = await request.send();
        var responseString = await response.stream.bytesToString();
        print(responseString);
        Map<String, dynamic> jsonMap = jsonDecode(responseString);

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(jsonMap['message'])));

          // Navigate to TaskDetail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserList(carId: id!),
            ),
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(jsonMap['message'])));
        }
      } else {
        // Handle the case where userId is not available
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User ID not found')));
      }
    } catch (e) {
      print(e);
    }
  }

  Widget buildGradeRow(String heading, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                heading,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
