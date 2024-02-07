import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/add_car.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'car_step_two.dart';
// import 'package:http/http.dart' as http;

class CARSTepOneScreen extends StatefulWidget {
  const CARSTepOneScreen({super.key});

  @override
  State<CARSTepOneScreen> createState() => _CARStepOneScreenState();
}

class _CARStepOneScreenState extends State<CARSTepOneScreen> {
  var orgName = TextEditingController();
  var contractorName = TextEditingController();
  var stepOneDate = TextEditingController();
  var nicNo = TextEditingController();
  var purchaseOrder = TextEditingController();
  var partDesc = TextEditingController();
  var partId = TextEditingController();
  var qty = TextEditingController();
  var dwgNo = TextEditingController();
  var descOne = TextEditingController();
  var descTwo = TextEditingController();

  bool orgNameBorderShowRed = false;
  bool contractorNameBorderShowRed = false;
  bool stepOneDateBorderShowRed = false;
  bool nicNoBorderShowRed = false;
  bool purchaseOrderBorderShowRed = false;
  bool partDescBorderShowRed = false;
  bool partIdBorderShowRed = false;
  bool qtyBorderShowRed = false;
  bool dwgNoBorderShowRed = false;
  bool descOneBorderShowRed = false;
  bool descTwoBorderShowRed = false;

  bool _cbIncoming = false;
  bool _cbInprocess = false;
  bool _cbFinalInspection = false;
  bool _cbShop = false;
  bool _cbCritical = false;
  bool _cbField = false;
  bool _cbNonCritical = false;

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
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const DashboardScreen(),
            //   ),
            // );
            ////////////////////////////////////////////
            Navigator.pop(context);
            ////////////////////////////////////////////
            // Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
          },
        ),
        title: Text(
          "Corrective Action Report",
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    // height: 55,
                    child: TextField(
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 15,
                        //   color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: orgName,
                      keyboardType: TextInputType.name,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      decoration: textFieldDecoration(
                        "Originator Name",
                        false,
                        isRedColorBorder: orgNameBorderShowRed,
                        isTablet: isTablet,
                        context: context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    //  height: 55,
                    child: TextField(
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 15,
                        //    color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: contractorName,
                      keyboardType: TextInputType.name,
                      decoration: textFieldDecoration(
                        "Contractor/Supplier",
                        false,
                        isRedColorBorder: contractorNameBorderShowRed,
                        isTablet: isTablet,
                        context: context,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await _selectDate(context);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      //    height: 50,
                      child: TextField(
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 15,
                          //  color: Colors.black.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        controller: stepOneDate,
                        keyboardType: TextInputType.datetime,
                        decoration: textFieldDecoration(
                          "Date",
                          false,
                          isRedColorBorder: stepOneDateBorderShowRed,
                          isTablet: isTablet,
                          context: context,
                        ),
                        enabled: false,
                        onTap: () {
                          _selectDate(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    //  height: 50,
                    child: TextField(
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 15,
                        //  color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: nicNo,
                      keyboardType: TextInputType.phone,
                      decoration: textFieldDecoration(
                        "NC No",
                        false,
                        isRedColorBorder: nicNoBorderShowRed,
                        isTablet: isTablet,
                        context: context,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
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
                        //    color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: purchaseOrder,
                      keyboardType: TextInputType.phone,
                      decoration: textFieldDecoration(
                        "Purchase Order #",
                        false,
                        isRedColorBorder: purchaseOrderBorderShowRed,
                        isTablet: isTablet,
                        context: context,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    //  height: 55,
                    child: TextField(
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 15,
                        //     color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: partDesc,
                      keyboardType: TextInputType.name,
                      decoration: textFieldDecoration(
                        "Part Description",
                        false,
                        isRedColorBorder: partDescBorderShowRed,
                        isTablet: isTablet,
                        context: context,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
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
                        //   color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: partId,
                      keyboardType: TextInputType.phone,
                      decoration: textFieldDecoration(
                        "Part ID",
                        false,
                        isRedColorBorder: partIdBorderShowRed,
                        isTablet: isTablet,
                        context: context,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
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
                        //  color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: qty,
                      keyboardType: TextInputType.number,
                      decoration: textFieldDecoration(
                        "Qty",
                        false,
                        isRedColorBorder: qtyBorderShowRed,
                        isTablet: isTablet,
                        context: context,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(3),
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
                        //  color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: dwgNo,
                      keyboardType: TextInputType.phone,
                      decoration: textFieldDecoration(
                        "Dwg No",
                        false,
                        isRedColorBorder: dwgNoBorderShowRed,
                        isTablet: isTablet,
                        context: context,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Found during what activity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 30 : 20.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _cbIncoming = !_cbIncoming;
                            });
                          },
                          child: ListTile(
                            title: Text(
                              "Incoming Inspection",
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 14.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: isTablet ? 30 : 24,
                              height: isTablet ? 30 : 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      _cbIncoming ? Colors.blue : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: _cbIncoming
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.blue,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _cbInprocess = !_cbInprocess;
                            });
                          },
                          child: ListTile(
                            title: Text(
                              "In-process Inspection",
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 14.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: isTablet ? 30 : 24,
                              height: isTablet ? 30 : 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      _cbInprocess ? Colors.blue : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: _cbInprocess
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.blue,
                                    )
                                  : null,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _cbFinalInspection = !_cbFinalInspection;
                            });
                          },
                          child: ListTile(
                            title: Text(
                              "Final Inspection",
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 14.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            dense: false,
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: isTablet ? 30 : 24,
                              height: isTablet ? 30 : 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _cbFinalInspection
                                      ? Colors.blue
                                      : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: _cbFinalInspection
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.blue,
                                    )
                                  : null,
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _cbShop = !_cbShop;
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    "Shop",
                                    style: TextStyle(
                                      fontSize: isTablet ? 24 : 14.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  dense: false,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: isTablet ? 30 : 24,
                                    height: isTablet ? 30 : 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            _cbShop ? Colors.blue : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: _cbShop
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.blue,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _cbCritical = !_cbCritical;
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    "Critical",
                                    style: TextStyle(
                                      fontSize: isTablet ? 24 : 14.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  dense: false,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: isTablet ? 30 : 24,
                                    height: isTablet ? 30 : 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _cbCritical
                                            ? Colors.blue
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: _cbCritical
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.blue,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _cbField = !_cbField;
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    "Field",
                                    style: TextStyle(
                                      fontSize: isTablet ? 24 : 14.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  dense: false,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: isTablet ? 30 : 24,
                                    height: isTablet ? 30 : 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _cbField
                                            ? Colors.blue
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: _cbField
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.blue,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _cbNonCritical = !_cbNonCritical;
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    "NON Critical",
                                    style: TextStyle(
                                      fontSize: isTablet ? 24 : 14.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  dense: false,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: isTablet ? 30 : 24,
                                    height: isTablet ? 30 : 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _cbNonCritical
                                            ? Colors.blue
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: _cbNonCritical
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.blue,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )

                        // Add more CheckboxListTile widgets as needed
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    // height: 100,
                    child: TextField(
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 15,
                        //   color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: descOne,
                      keyboardType: TextInputType.multiline,
                      decoration: textFieldDecoration(
                        "Description of nonconformance",
                        false,
                        isRedColorBorder: descOneBorderShowRed,
                        isTablet: isTablet,
                        context: context,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            100), // Restrict input to 10 characters
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    //  height: 100,
                    child: TextField(
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 15,
                        //  color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: descTwo,
                      keyboardType: TextInputType.multiline,
                      decoration: textFieldDecoration(
                        "Action taken to prevent misuse",
                        false,
                        isRedColorBorder: descTwoBorderShowRed,
                        isTablet: isTablet,
                        context: context,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                    ),
                  ),
                  const SizedBox(height: 17),
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
                          if (orgName.text.trim().isEmpty) {
                            orgNameBorderShowRed = true;
                            setState(() {});
                          } else {
                            orgNameBorderShowRed = false;
                            setState(() {});
                          }

                          if (contractorName.text.trim().isEmpty) {
                            contractorNameBorderShowRed = true;
                            setState(() {});
                          } else {
                            contractorNameBorderShowRed = false;
                            setState(() {});
                          }

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
                          print('Date in Value: ' + stepOneDate.text.trim());
                          if ((stepOneDate.text.trim().isEmpty ||
                              stepOneDate.text.trim() == '')) {
                            stepOneDateBorderShowRed = true;
                            setState(() {});
                          }
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

                          if (nicNo.text.trim().isEmpty) {
                            nicNoBorderShowRed = true;
                            setState(() {});
                          } else {
                            nicNoBorderShowRed = false;
                            setState(() {});
                          }

                          if (purchaseOrder.text.trim().isEmpty) {
                            purchaseOrderBorderShowRed = true;
                            setState(() {});
                          } else {
                            purchaseOrderBorderShowRed = false;
                            setState(() {});
                          }

                          if (partDesc.text.trim().isEmpty) {
                            partDescBorderShowRed = true;
                            setState(() {});
                          } else {
                            partDescBorderShowRed = false;
                            setState(() {});
                          }

                          if (partId.text.trim().isEmpty) {
                            partIdBorderShowRed = true;
                            setState(() {});
                          } else {
                            partIdBorderShowRed = false;
                            setState(() {});
                          }

                          if (qty.text.trim().isEmpty) {
                            qtyBorderShowRed = true;
                            setState(() {});
                          } else {
                            qtyBorderShowRed = false;
                            setState(() {});
                          }

                          if (dwgNo.text.trim().isEmpty) {
                            dwgNoBorderShowRed = true;
                            setState(() {});
                          } else {
                            dwgNoBorderShowRed = false;
                            setState(() {});
                          }

                          if (descOne.text.trim().isEmpty) {
                            descOneBorderShowRed = true;
                            setState(() {});
                          } else {
                            descOneBorderShowRed = false;
                            setState(() {});
                          }

                          if (descTwo.text.trim().isEmpty) {
                            descTwoBorderShowRed = true;
                            setState(() {});
                          } else {
                            descTwoBorderShowRed = false;
                            setState(() {});
                          }

                          // int finalQty = 0;
                          // if (qty.text.isNotEmpty) {
                          //   finalQty = int.parse(qty.text);
                          // }

                          if (orgName.text.trim().isEmpty ||
                              contractorName.text.trim().isEmpty ||
                              nicNo.text.trim().isEmpty ||
                              purchaseOrder.text.trim().isEmpty ||
                              partDesc.text.trim().isEmpty ||
                              partId.text.trim().isEmpty ||
                              qty.text.trim().isEmpty ||
                              dwgNo.text.trim().isEmpty ||
                              descOne.text.trim().isEmpty ||
                              descTwo.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Fill all the given fields!')));
                            return;
                          }

                          if (stepOneDate.text.trim() == '' ||
                              stepOneDate.text.trim() == null.toString() ||
                              stepOneDate.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Select a date!')));
                            return;
                          }

                          List<String> foundDuringWhatActivityList = [];
                          if (_cbIncoming) {
                            foundDuringWhatActivityList
                                .add('Inconming Inspection');
                          }
                          if (_cbInprocess) {
                            foundDuringWhatActivityList
                                .add('In-process Inspection');
                          }
                          if (_cbFinalInspection) {
                            foundDuringWhatActivityList.add('Final Inspection');
                          }
                          if (_cbShop) {
                            foundDuringWhatActivityList.add('Shop');
                          }

                          if (_cbCritical) {
                            foundDuringWhatActivityList.add('Critical');
                          }

                          if (_cbField) {
                            foundDuringWhatActivityList.add('Field');
                          }

                          if (_cbNonCritical) {
                            foundDuringWhatActivityList.add('Non Critical');
                          }

                          ///////////////////////////////////

                          AddCARObj addCarModel = AddCARObj(
                            originatorName: orgName.text,
                            contractorSupplier: contractorName.text,
                            caReportDate: stepOneDate.text,
                            ncNo: nicNo.text,
                            purchaseOrderNo: purchaseOrder.text,
                            partDescription: partDesc.text,
                            partId: partId.text,
                            quantity: qty.text,
                            dwgNo: dwgNo.text,
                            description: descOne.text,
                            actionToPrevent: descTwo.text,
                            activityFound: foundDuringWhatActivityList,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CARSTepTwoScreen(addCarModel: addCarModel),
                            ),
                          );
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
                        child: Text("Next",
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
      // final formattedDate = DateFormat('yyyy-MM-dd').format(picked);   // was previous and working
      final formattedDate = DateFormat('MM-dd-yyyy').format(picked);

      // Update the TextField's value
      stepOneDate.text = formattedDate;
    } else {
      // ScaffoldMessenger.of(context).clearSnackBars();
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('Select a date!')));
      // return;
    }
  }
}
