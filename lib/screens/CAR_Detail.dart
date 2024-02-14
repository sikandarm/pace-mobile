import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
//import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../services/car_detail_service.dart';
import '../utils/constants.dart';
import 'UserList.dart';
import 'department_list.dart';

class CARDetail extends StatefulWidget {
  final int carId;
  bool isJustViewingReport;

  CARDetail({Key? key, required this.carId, this.isJustViewingReport = false})
      : super(key: key);

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

  bool isTablet = false;

  @override
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

  void checkTablet() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // You can customize these threshold values based on your criteria
    if (screenWidth >= 768 && screenHeight >= 1024) {
      setState(() {
        isTablet = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        iconTheme: IconThemeData(
            // color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
            //     ? Colors.white
            //     : Colors.black,
            ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the last screen in the stack
            //  Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Corrective Action Report",
          style: TextStyle(
            fontSize: isTablet ? 28 : 18,
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
                        partDescription: tasks.partDescription,
                        activityFound: tasks.activityFound,
                        disposition: tasks.disposition,
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
                        description: tasks.description,
                        partID: tasks.partId,
                        responsibleDate: tasks.responsiblePartyDate,
                        responsibleName: tasks.responsiblePartyName,
                        isJustViewingReport: widget.isJustViewingReport,
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

class CARDetailWidget extends StatefulWidget {
  final bool? isJustViewingReport;
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
  final String? description;
  final String? partDescription;
  final String? partID;
  final String? responsibleName;
  final DateTime? responsibleDate;
  final String? activityFound;
  final String? disposition;

  //final String? approvalName;
  //final String? approvalDate;

  const CARDetailWidget({
    Key? key,
    this.id,
    this.partDescription,
    this.isJustViewingReport,
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
    this.description,
    this.partID,
    this.responsibleName,
    this.responsibleDate,
    this.activityFound,
    this.disposition,
  }) : super(key: key);

  @override
  State<CARDetailWidget> createState() => _CARDetailWidgetState();
}

class _CARDetailWidgetState extends State<CARDetailWidget> {
  bool isTablet = false;

  @override
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

  void checkTablet() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // You can customize these threshold values based on your criteria
    if (screenWidth >= 768 && screenHeight >= 1024) {
      setState(() {
        isTablet = true;
      });
    }
  }

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
            buildGradeRow("Originator Name", widget.originatorName!, isTablet),
            buildGradeRow(
                "Contractor/Supplier", widget.contractorSupplier!, isTablet),
            buildGradeRow(
                "Date",
                widget.caReportDate != null
                    ? DateFormat(US_DATE_FORMAT).format(widget.caReportDate!)
                    : 'N/A',
                isTablet),
            buildGradeRow("NC#", widget.ncNo!, isTablet),
            buildGradeRow("Purchase Order#", widget.purchaseOrderNo!, isTablet),
            ////////////////////////////////////////
            buildGradeRow("Part Description", widget.partDescription.toString(),
                isTablet),
            buildGradeRow("Part ID", widget.partID.toString(), isTablet),
            ///////////////////////////////////////
            buildGradeRow("Quantity", widget.quantity.toString(), isTablet),
            buildGradeRow("Dwg#", widget.dwgNo!, isTablet),

            const SizedBox(height: 20),
            Text(
              'Found during these activites',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 33 : 20.0,
              ),
            ),
            const SizedBox(height: 10),
            Text((widget.activityFound != null && widget.activityFound != '')
                ? widget.activityFound!
                    .toString()
                    .substring(1, widget.activityFound!.toString().length - 1)
                : 'N/A'),
            const SizedBox(height: 20),

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
            Text(
              'Corrective/Preventive Action',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 33 : 20.0,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Description of proposed action',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 26 : 16.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.correctiveActionDesc!,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                color: AdaptiveTheme.of(context).mode.isDark
                    ? Colors.grey[350]
                    : Colors.grey[600],
              ),
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
            Text(
              'Disposition',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 26 : 16.0,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              widget.disposition.toString(),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                color: AdaptiveTheme.of(context).mode.isDark
                    ? Colors.grey[350]
                    : Colors.grey[600],
              ),
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
            Text(
              'Responsible Party',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 26 : 16.0,
              ),
            ),
            const SizedBox(height: 10),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border(
            //       bottom: BorderSide(
            //         color: Colors.grey[300]!,
            //         width: 1.0,
            //       ),
            //     ),
            //   ),
            // ),
            buildGradeRow("Name", widget.responsibleName!, isTablet),
            buildGradeRow(
                "Date",
                widget.approvalDate != null
                    ? DateFormat(US_DATE_FORMAT).format(widget.responsibleDate!)
                    : 'N/A',
                isTablet),
            const SizedBox(height: 20),
            Text(
              'Approval of corrective/preventive action',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 26 : 16.0,
              ),
            ),
            const SizedBox(height: 15),
            buildGradeRow("Name", widget.approvalName!, isTablet),
            buildGradeRow(
                "Date",
                widget.approvalDate != null
                    ? DateFormat(US_DATE_FORMAT).format(widget.approvalDate!)
                    : 'N/A',
                isTablet),
            widget.isJustViewingReport == true
                ? SizedBox()
                : Row(
                    children: [
                      Expanded(
                        //   height:
                        //       isTablet ? MediaQuery.of(context).size.height * 0.06 : 45,
                        child: Container(
                          height: isTablet ? 75 : 45,
                          child: ElevatedButton(
                            onPressed: () async {
                              await callUpdateCAR(
                                  context, widget.id!, "rejected");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .red, // Set button background color to blue
                            ),
                            child: Text(
                              'Reject',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 27 : 14,
                                // Set button text color to white
                              ),
                            ),
                          ),
                        ),
                      ),
                      //  const SizedBox(width: 10),
                      SizedBox(width: 4),
                      Expanded(
                        //    height:
                        //        isTablet ? MediaQuery.of(context).size.height * 0.06 : 45,
                        child: Container(
                          height: isTablet ? 75 : 45,
                          child: ElevatedButton(
                            onPressed: () async {
                              await callUpdateCAR(
                                  context, widget.id!, "approved");
                              //  Navigator.pop(context);
                              //  Navigator.pop(context);
                              //  Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .green, // Set button background color to blue
                            ),
                            child: Text(
                              'Approve',
                              style: TextStyle(
                                fontSize: isTablet ? 27 : 14,
                                color: Colors
                                    .white, // Set button text color to white
                              ),
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
          //      ScaffoldMessenger.of(context)
          //         .showSnackBar(SnackBar(content: Text(jsonMap['message'])));

          showSnackbar(context, jsonMap['message']);
          // Navigate to TaskDetail screen

          if (status == 'approved') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserList(carId: widget.id!),
              ),
            );
          }
          if (status == 'rejected') {
            Navigator.pop(context);
            Navigator.pop(context);
            //  Navigator.pop(context);

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => UserList(carId: widget.id!),
            //   ),
            // );
          }
        } else {
          // ignore: use_build_context_synchronously
          //    ScaffoldMessenger.of(context)
          //      .showSnackBar(SnackBar(content: Text(jsonMap['message'])));

          showSnackbar(context, jsonMap['message']);
        }
      } else {
        // Handle the case where userId is not available
        // ignore: use_build_context_synchronously
        //   ScaffoldMessenger.of(context)
        //     .showSnackBar(const SnackBar(content: Text('User ID not found')));
        showSnackbar(context, 'User ID not found');
      }
    } catch (e) {
      print(e);
    }
  }

  Widget buildGradeRow(String heading, String value, bool isTablet) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                heading,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 25 : 15.0,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: AdaptiveTheme.of(context).mode.isDark
                          ? Colors.grey[350]
                          : Colors.grey[600],
                      fontSize: isTablet ? 25 : 15.0,
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
