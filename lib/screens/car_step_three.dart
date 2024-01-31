import 'dart:convert';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/add_car.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

import 'Dashboard.dart';
import 'department_list.dart';

class CARSTepThreeScreen extends StatefulWidget {
  final AddCARObj addCarModel;

  const CARSTepThreeScreen({super.key, required this.addCarModel});

  @override
  State<CARSTepThreeScreen> createState() => _CARStepThreeScreenState();
}

class _CARStepThreeScreenState extends State<CARSTepThreeScreen> {
  var companyIsTo = TextEditingController();
  var nameStepThree = TextEditingController();
  var stepThreeDate = TextEditingController();
  bool nameBorderShowRed = false;
  bool companyIsToBorderShowRed = false;

  @override
  void initState() {
    super.initState();
  }

  bool isTablet = false;

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
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

  callAddCAR() async {
    try {
      Map<String, dynamic> jsonData = widget.addCarModel.toJson();
      String jsonString = jsonEncode(jsonData);
      print(jsonString);

      // var response =
      //     await http.post(Uri.parse("$BASE_URL/CA-report"), body: jsonString);

      // int? userId = await getIntFromSF('UserId');

      var response = await http.post(Uri.parse("$BASE_URL/CA-report"), body: {
        "originatorName": widget.addCarModel.originatorName,
        "contractorSupplier": widget.addCarModel.contractorSupplier,
        "caReportDate": widget.addCarModel.caReportDate,
        "ncNo": widget.addCarModel.ncNo,
        "purchaseOrderNo": widget.addCarModel.purchaseOrderNo,
        "partDescription": widget.addCarModel.partDescription,
        "partId": widget.addCarModel.partId,
        "quantity": widget.addCarModel.quantity,
        "dwgNo": widget.addCarModel.dwgNo,
        "description": widget.addCarModel.description,
        "actionToPrevent": widget.addCarModel.actionToPrevent,
        "disposition": widget.addCarModel.disposition,
        "responsiblePartyName": widget.addCarModel.responsiblePartyName,
        "responsiblePartyDate": widget.addCarModel.responsiblePartyDate,
        "correctiveActionDesc": widget.addCarModel.correctiveActionDesc,
        "approvalName": widget.addCarModel.approvalName,
        "approvalDate": widget.addCarModel.approvalDate,
        "userId": widget.addCarModel.userId.toString(),
      });

      print(response.body);
      Map<String, dynamic> jsonMap = jsonDecode(response.body);
      print(jsonMap);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonMap['message'])));

        // ignore: use_build_context_synchronously

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const DeptList(),
        //   ),
        // );

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            ),
            (route) => false);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonMap['message'])));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
              ? Colors.white
              : Colors.black,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const DashboardScreen(),
            //   ),
            // );

            // Navigator.popUntil(context, ModalRoute.withName('/dashboard'));

            Navigator.pop(context);
          },
        ),
        title: Text(
          "Corrective/Preventive Action",
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Description of Proposed Action',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                //  fontSize: 17.0,
                                fontSize: isTablet ? 27 : 17.0,
                              ),
                            ),
                          ),
                        ),

                        // Add more CheckboxListTile widgets as needed
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    //  height: 50,
                    child: TextField(
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 15,
                        color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: companyIsTo,
                      keyboardType: TextInputType.name,
                      decoration: textFieldDecoration(
                        "Company is to",
                        false,
                        isRedColorBorder: companyIsToBorderShowRed,
                        isTablet: isTablet,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            100), // Restrict input to 10 characters
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Approval of corrective/preventive action',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: isTablet ? 27 : 17.0,
                              ),
                            ),
                          ),
                        ),

                        // Add more CheckboxListTile widgets as needed
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    // height: 50,
                    child: TextField(
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 15,
                        color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: nameStepThree,
                      keyboardType: TextInputType.name,
                      decoration: textFieldDecoration(
                        "Name",
                        false,
                        isRedColorBorder: nameBorderShowRed,
                        isTablet: isTablet,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            100), // Restrict input to 10 characters
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      //    height: 50,
                      child: TextField(
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 15,
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        controller: stepThreeDate,
                        keyboardType: TextInputType.datetime,
                        decoration: textFieldDecoration("Date", false,
                            isTablet: isTablet),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        enabled: false,
                        onTap: () {
                          _selectDate(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    // width: double.infinity,
                    // height: 50.0,
                    width: MediaQuery.of(context).size.width * 0.95,

                    //  height: 50.0,
                    height: MediaQuery.of(context).size.height * 0.067,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        (EasyDynamicTheme.of(context).themeMode !=
                                ThemeMode.dark)
                            ? BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              )
                            : const BoxShadow(),
                      ]),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameStepThree.text.trim().isEmpty) {
                            nameBorderShowRed = true;
                            setState(() {});
                          } else {
                            nameBorderShowRed = false;
                            setState(() {});
                          }

                          if (companyIsTo.text.trim().isEmpty) {
                            companyIsToBorderShowRed = true;
                            setState(() {});
                          } else {
                            companyIsToBorderShowRed = false;
                            setState(() {});
                          }

                          if (nameStepThree.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Enter a name!')));
                            return;
                          }

                          if (companyIsTo.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Enter Company is to field!')));
                            return;
                          }

                          if (stepThreeDate.text.trim() == '' ||
                              stepThreeDate.text.trim() == null.toString() ||
                              stepThreeDate.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Select a date!')));
                            return;
                          }

                          // Call API here to create CAR

                          int? userId = await getIntFromSF('UserId');
                          print(userId.toString());

                          widget.addCarModel.correctiveActionDesc =
                              companyIsTo.text;
                          widget.addCarModel.approvalName = nameStepThree.text;
                          widget.addCarModel.approvalDate = stepThreeDate.text;
                          widget.addCarModel.userId = userId.toString();

                          callAddCAR();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        child: Text("Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 30 : 17,
                            )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // Format the picked date to the desired format
      // final formattedDate = DateFormat('yyyy-MM-dd').format(picked);

      final formattedDate = DateFormat('MM-dd-yyyy').format(picked);

      // Update the TextField's value
      stepThreeDate.text = formattedDate;
    }
  }
}
