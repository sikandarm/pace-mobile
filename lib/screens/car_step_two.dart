import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/add_car.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'car_step_three.dart';

class CARSTepTwoScreen extends StatefulWidget {
  final AddCARObj addCarModel;

  const CARSTepTwoScreen({super.key, required this.addCarModel});

  @override
  State<CARSTepTwoScreen> createState() => _CARStepTwoScreenState();
}

class _CARStepTwoScreenState extends State<CARSTepTwoScreen> {
  var name = TextEditingController();
  var stepTwoDate = TextEditingController();

  int? _selectedOption;
  String _rbDispositionTitle = "";
  bool nameBorderShowRed = false;

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
        title: const Text(
          "Disposition",
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
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        RadioListTile(
                          title: const Text(
                            "Use-as-is",
                          ),
                          value: 1,
                          groupValue: _selectedOption,
                          dense: false,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value;
                              _rbDispositionTitle = "Use-as-is";
                            });
                          },
                        ),
                        RadioListTile(
                          title: const Text("Rework"),
                          value: 2,
                          groupValue: _selectedOption,
                          dense: false,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value;
                              _rbDispositionTitle = "Rework";
                            });
                          },
                        ),
                        RadioListTile(
                          title: const Text("Repair"),
                          value: 3,
                          groupValue: _selectedOption,
                          dense: false,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value;
                              _rbDispositionTitle = "Repair";
                            });
                          },
                        ),
                        RadioListTile(
                          title: const Text("Reject"),
                          value: 4,
                          groupValue: _selectedOption,
                          dense: false,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value;
                              _rbDispositionTitle = "Reject";
                            });
                          },
                        ),
                        RadioListTile(
                          title: const Text("Return to Supplier"),
                          value: 5,
                          groupValue: _selectedOption,
                          dense: false,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value;
                              _rbDispositionTitle = "Return to Supplier";
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Responsible Party',
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
                    height: 50,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: name,
                      keyboardType: TextInputType.name,
                      decoration: textFieldDecoration(
                        "Name",
                        false,
                        isRedColorBorder: nameBorderShowRed,
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
                      height: 50,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        controller: stepTwoDate,
                        keyboardType: TextInputType.datetime,
                        decoration: textFieldDecoration(
                          "Date",
                          false,
                        ),
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
                    width: double.infinity,
                    height: 50.0,
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
                        onPressed: () {
                          if (name.text.trim().isEmpty) {
                            nameBorderShowRed = true;
                            setState(() {});
                          } else {
                            nameBorderShowRed = false;
                            setState(() {});
                          }

                          if (name.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Enter a name!')));
                            return;
                          }
                          if (stepTwoDate.text.trim() == '' ||
                              stepTwoDate.text.trim() == null.toString() ||
                              stepTwoDate.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Select a date!')));
                            return;
                          }

                          if (_rbDispositionTitle.trim() == '' ||
                              _rbDispositionTitle.trim() == null.toString() ||
                              _rbDispositionTitle.trim().isEmpty) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Select a disposition option!')));
                            return;
                          }

                          widget.addCarModel.responsiblePartyName = name.text;
                          widget.addCarModel.responsiblePartyDate =
                              stepTwoDate.text;
                          widget.addCarModel.disposition = _rbDispositionTitle;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CARSTepThreeScreen(
                                  addCarModel: widget.addCarModel),
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
      stepTwoDate.text = formattedDate;
    }
  }
}
