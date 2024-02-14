import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
//import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/get_bill_of_lading_service.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'ProfileScreen.dart';

class SubmitReceivedStatusBillOfLadingScreen extends StatefulWidget {
  SubmitReceivedStatusBillOfLadingScreen({super.key, required this.billdata});

  Billdata? billdata;

  @override
  State<SubmitReceivedStatusBillOfLadingScreen> createState() =>
      _SubmitReceivedStatusBillOfLadingScreenState();
}

class _SubmitReceivedStatusBillOfLadingScreenState
    extends State<SubmitReceivedStatusBillOfLadingScreen> {
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

  List<TextEditingController> allControllers = [];

  @override
  void didChangeDependencies() {
    checkTablet();
    for (int i = 0; i < widget.billdata!.billofLadingItems!.length; i++) {
      allControllers.add(TextEditingController());
      allControllers[i].text =
          widget.billdata!.billofLadingItems![i].quantity.toString();
    }
    print('Dynamically generated controllers: ' +
        allControllers.length.toString());
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
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Bill of Lading Status",
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   Row(
        //     children: [
        //       Padding(
        //         padding: const EdgeInsets.only(right: 1.0),
        //         child: Stack(
        //           children: [
        //             Visibility(
        //               visible: _bShowCreateSequenceIcon,
        //               // visible: true,
        //               child: IconButton(
        //                 onPressed: () async {
        //                   if (!_bShowCreateSequenceIcon) {
        //                     await Fluttertoast.cancel();
        //                     showToast('You do not have permissions');
        //                     return;
        //                   }
        //
        //                   final dialogResult = await showDialog<bool?>(
        //                     context: context,
        //                     builder: (BuildContext context) {
        //                       return AlertDialog(
        //                         title: Form(
        //                           key: formkeySequence,
        //                           child: Column(
        //                             crossAxisAlignment:
        //                             CrossAxisAlignment.start,
        //                             children: [
        //                               const Text(
        //                                 'Create a new sequence',
        //                                 style: TextStyle(
        //                                   fontSize: 15.5,
        //                                   fontWeight: FontWeight.bold,
        //                                 ),
        //                               ),
        //                               TextFormField(
        //                                 controller: sequenceNameController,
        //                                 decoration: const InputDecoration(
        //                                   hintStyle: TextStyle(fontSize: 13.5),
        //                                   hintText: 'Enter a sequence title',
        //                                   labelText: 'Sequence title',
        //                                   labelStyle: TextStyle(fontSize: 13.5),
        //                                 ),
        //                                 validator: (value) {
        //                                   if (value == null || value.isEmpty) {
        //                                     return 'Please enter a sequence title';
        //                                   }
        //
        //                                   return null;
        //                                 },
        //                               ),
        //                             ],
        //                           ),
        //                         ),
        //                         actions: [
        //                           TextButton(
        //                             onPressed: () async {
        //                               //  sequenceNameController.clear();
        //                               ScaffoldMessenger.of(context)
        //                                   .clearSnackBars();
        //
        //                               final validationResult = formkeySequence
        //                                   .currentState!
        //                                   .validate();
        //
        //                               if (!validationResult) {
        //                                 return;
        //                               }
        //
        //                               final response = await createNewSequence(
        //                                 seqName:
        //                                 sequenceNameController.text.trim(),
        //                                 jobID: widget.jobId,
        //                               );
        //                               Map<String, dynamic> decodedResponse =
        //                               jsonDecode(response.body);
        //
        //                               if (decodedResponse['message'] != null) {
        //                                 ScaffoldMessenger.of(context)
        //                                     .showSnackBar(
        //                                   SnackBar(
        //                                       content: Text(
        //                                           decodedResponse['message'])),
        //                                 );
        //                               }
        //
        //                               sequenceNameController.clear();
        //                               Navigator.of(context).pop();
        //                               await callApiMethods();
        //                             },
        //                             child: const Text(
        //                               'Create',
        //                               style: TextStyle(
        //                                 color: Colors.blue,
        //                                 fontSize: 16.0,
        //                               ),
        //                             ),
        //                           ),
        //                         ],
        //                       );
        //                     },
        //                   );
        //                   if (dialogResult != true) {
        //                     sequenceNameController.clear();
        //                   }
        //                 },
        //                 icon: const Icon(
        //                   Icons.add_box_outlined,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       Visibility(
        //         visible: _b1ShowProfile,
        //         child: GestureDetector(
        //           onTap: () {
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => const ProfileScreen()),
        //             );
        //           },
        //           child: Padding(
        //             padding: EdgeInsets.only(right: 10.0, left: 5.0),
        //             child: CircleAvatar(
        //               backgroundImage: userProfileImage == null
        //                   ? AssetImage('assets/images/ic_profile.png')
        //                   : NetworkImage(userProfileImage!) as ImageProvider,
        //               radius: 15,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   )
        //  ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(21.0),
        child: Container(
          child: ListView(
            children: [
              SizedBox(
                height: isTablet ? 21 : 0,
              ),

              for (int i = 0;
                  i < widget.billdata!.billofLadingItems!.length;
                  i++) ...{
                Container(
                  //  height: 150,
                  child: TextFormField(
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      allControllers[i].text = value;

                      if (int.parse(value) >
                          widget.billdata!.billofLadingItems![i].quantity!) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //       content: Text(
                        //           '${widget.billdata!.billofLadingItems![i].fabricatedItems} quanity can not exceed ${widget.billdata!.billofLadingItems![i].quantity}')),
                        // );

                        showSnackbar(context,
                            '${widget.billdata!.billofLadingItems![i].fabricatedItems} quanity can not exceed ${widget.billdata!.billofLadingItems![i].quantity}');
                        allControllers[i].clear();
                        value = '';
                      }
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: allControllers[i],
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'quantity',
                        labelText: 'Enter ' +
                            widget
                                .billdata!.billofLadingItems![i].fabricatedItems
                                .toString() +
                            ' Quantity'
                        // labelText: 'sdd'
                        ),
                  ),
                ),
                SizedBox(height: 15),
              },

              //  Spacer(),
              // SizedBox(height: MediaQuery.of(context).size.height*0.35,),
              SizedBox(
                //  width: double.infinity,
                //  height: 47,
                //   width: 340,
                width: MediaQuery.of(context).size.width * 0.95,

                //  height: 50.0,
                height: MediaQuery.of(context).size.height * 0.065,

                child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blue),
                      foregroundColor: MaterialStatePropertyAll(Colors.white),
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      final tokenBox = await Hive.openBox('tokenBox');
                      final token = tokenBox.get('token');

                      List<Map<String, dynamic>> allMaps = [];
                      for (int i = 0;
                          i < widget.billdata!.billofLadingItems!.length;
                          i++) {
                        allMaps.add({
                          "id": widget.billdata!.billofLadingItems![i].id,
                          "quantity":
                              widget.billdata!.billofLadingItems![i].quantity
                        });
                      }

                      print('all maps:' + allMaps.toString());
                      print('billId: ' + widget.billdata!.id.toString());
                      /////////////////////////////////////////
                      final response = await http.patch(
                          // Uri.parse('${BASE_URL}/bill/update-bill'),
                          Uri.parse(
                              'http://206.81.5.26:3500/api/bill/update-bill'),
                          body: jsonEncode({
                            "item": allMaps,
                            "billId": widget.billdata!.id,
                          }),
                          headers: {
                            "Authorization": "Bearer $token",
                            'Content-Type': 'application/json',
                          });

                      print('bill response:' + response.body.toString());
                      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      //       content: Text('Bill status changed to received!')));

                      showSnackbar(context, 'Bill status changed to received!');
                      Navigator.pop(context, false);
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: isTablet ? 27 : 14,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
