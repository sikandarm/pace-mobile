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
        title: const Text(
          "Corrective Action Report",
          style: TextStyle(
            fontSize: 18,
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
                    height: 55,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: orgName,
                      keyboardType: TextInputType.name,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      decoration: textFieldDecoration("Originator Name", false),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: contractorName,
                      keyboardType: TextInputType.name,
                      decoration:
                          textFieldDecoration("Contractor/Supplier", false),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
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
                      height: 50,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        controller: stepOneDate,
                        keyboardType: TextInputType.datetime,
                        decoration: textFieldDecoration("Date", false),
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
                    height: 50,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: nicNo,
                      keyboardType: TextInputType.phone,
                      decoration: textFieldDecoration("NIC No", false),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: purchaseOrder,
                      keyboardType: TextInputType.phone,
                      decoration:
                          textFieldDecoration("Purchase Order #", false),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: partDesc,
                      keyboardType: TextInputType.name,
                      decoration:
                          textFieldDecoration("Part Description", false),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: partId,
                      keyboardType: TextInputType.phone,
                      decoration: textFieldDecoration("Part ID", false),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: qty,
                      keyboardType: TextInputType.number,
                      decoration: textFieldDecoration("Qty", false),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: dwgNo,
                      keyboardType: TextInputType.phone,
                      decoration: textFieldDecoration("Dwg No", false),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Found During what activity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text("Incoming Inspection"),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: GestureDetector(
                            onTap: () {
                              setState(() {
                                _cbIncoming = !_cbIncoming;
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
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
                        ListTile(
                          title: const Text("In-process Inspection"),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: GestureDetector(
                            onTap: () {
                              setState(() {
                                _cbInprocess = !_cbInprocess;
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
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

                        ListTile(
                          title: const Text("Final Inspection"),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: GestureDetector(
                            onTap: () {
                              setState(() {
                                _cbFinalInspection = !_cbFinalInspection;
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
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
                              child: ListTile(
                                title: const Text("Shop"),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _cbShop = !_cbShop;
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
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
                              child: ListTile(
                                title: const Text("Critical"),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _cbCritical = !_cbCritical;
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
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
                              child: ListTile(
                                title: const Text("Field"),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _cbField = !_cbField;
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
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
                              child: ListTile(
                                title: const Text("NON Critical"),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _cbNonCritical = !_cbNonCritical;
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
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
                    height: 100,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: descOne,
                      keyboardType: TextInputType.multiline,
                      decoration: textFieldDecoration(
                          "Description of nonconformance", false),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            100), // Restrict input to 10 characters
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: descTwo,
                      keyboardType: TextInputType.multiline,
                      decoration: textFieldDecoration(
                          "Action taken to prevent misuse", false),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        )
                      ]),
                      child: ElevatedButton(
                        onPressed: () {
                          // int finalQty = 0;
                          // if (qty.text.isNotEmpty) {
                          //   finalQty = int.parse(qty.text);
                          // }

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
                        child: const Text("Next",
                            style: TextStyle(
                              color: Colors.white,
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
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);

      // Update the TextField's value
      stepOneDate.text = formattedDate;
    }
  }
}
