import 'dart:io';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pace_application_fb/screens/submit_received_bill_of_lading_screen.dart';

//import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:pace_application_fb/services/get_bill_of_lading_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../utils/constants.dart';

class BillOfLading extends StatefulWidget {
  BillOfLading({super.key});

  @override
  State<BillOfLading> createState() => _BillOfLadingState();
}

class _BillOfLadingState extends State<BillOfLading> {
  bool b1_show_submit_received_bill_button = false;

  final headingStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  final headingStyleTablet = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 27,
  );

  //////////////////////////////

  final valueStyle = const TextStyle(
    //  fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  final valueStyleTablet = const TextStyle(
    // fontWeight: FontWeight.bold,
    fontSize: 27,
  );

  List<bool> allBillStatuses = [];

  @override
  void didChangeDependencies() {
    checkPermissionAndUpdateBool("bill_of_lading", (localBool) {
      b1_show_submit_received_bill_button = localBool;
    });

    setState(() {});
    checkTablet();
    callMethodStatus();
    super.didChangeDependencies();
  }

  void checkPermissionAndUpdateBool(
      String permValue, Function(bool) boolUpdater) async {
    var localBool = await hasPermission(permValue);

    setState(() {
      boolUpdater(localBool);
    });
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

  Future<void> callMethodStatus() async {
    BillOfLadingModel allBills = await getBillOfLading();
    for (var bill in allBills.data!.billdata!) {
      allBillStatuses.add(true);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   final billOfLading = await getBillOfLading();
      //   print(billOfLading.data.dataList.toList());
      // }),
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
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        leadingWidth: 40,
        title: Text(
          "Bill of Lading",
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // InkWell(
          //   onTap: () async {
          //     //  await generateAndViewPdf(context,);
          //   },
          //   child: const Chip(
          //       backgroundColor: Colors.green,
          //       label: Text(
          //         'Generate PDF',
          //         style: TextStyle(
          //           color: Colors.white,
          //         ),
          //       )),
          // ),
          // SizedBox(width: 11),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 30),
          FutureBuilder(
            future: getBillOfLading(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(child: CircularProgressIndicator()));
              }

              if (snapshot.data!.data!.billdata.isEmpty) {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(child: Text('No Bill Available')));
              }

              final billList = snapshot.data!.data!.billdata;
              return Expanded(
                  child: ListView.builder(
                itemCount: billList!.length,
                itemBuilder: (context, index) {
                  return LadingContainer(billList[index], context, index);
                },
              ));
            },
          ),
        ],
      ),
    );
  }

  Container LadingContainer(
      Billdata billdata, BuildContext context, int statusIndex) {
    print('Delivery Date:' + billdata.dilveryDate.toString());
    return Container(
      //  color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21.0, vertical: 3),
        child: Column(
          children: [
            Row(
              children: [
                Text('PO Number:',
                    style: isTablet ? headingStyleTablet : headingStyle),
                Spacer(),
                Text(
                  billdata.poNumber.toString(),
                  style: isTablet ? valueStyleTablet : valueStyle,
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Bill Title:',
                    style: isTablet ? headingStyleTablet : headingStyle),
                Spacer(),
                Text(
                  billdata.billTitle!.toString(),
                  style: isTablet ? valueStyleTablet : valueStyle,
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Address:',
                    style: isTablet ? headingStyleTablet : headingStyle),
                Spacer(),
                Text(
                  billdata.address!.toString(),
                  style: isTablet ? valueStyleTablet : valueStyle,
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Company Name:',
                    style: isTablet ? headingStyleTablet : headingStyle),
                Spacer(),
                Text(
                  billdata.companyName!.toString(),
                  style: isTablet ? valueStyleTablet : valueStyle,
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Company Address:',
                    style: isTablet ? headingStyleTablet : headingStyle),
                Spacer(),
                Text(
                  billdata.companyAddress!.toString(),
                  style: isTablet ? valueStyleTablet : valueStyle,
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Delivery Date:',
                    style: isTablet ? headingStyleTablet : headingStyle),
                Spacer(),

                // Text(dataList[index].dilveryDate!.toString()),
                billdata.dilveryDate != null
                    ? Text(
                        DateFormat('MMMM d, y')
                            .format(DateTime.parse(billdata.dilveryDate!)),
                        style: isTablet ? valueStyleTablet : valueStyle,
                      )
                    : Text(
                        'NA',
                        style: isTablet ? valueStyleTablet : valueStyle,
                      ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Order Date:',
                    style: isTablet ? headingStyleTablet : headingStyle),
                Spacer(),
                //  Text(dataList[index].orderDate!.toString()),
                billdata.orderDate != null
                    ? Text(
                        DateFormat('MMMM d, y')
                            .format(DateTime.parse(billdata.orderDate!)),
                        style: isTablet ? valueStyleTablet : valueStyle,
                      )
                    : Text(
                        'NA',
                        style: isTablet ? valueStyleTablet : valueStyle,
                      ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Ship Via:',
                    style: isTablet ? headingStyleTablet : headingStyle),
                Spacer(),
                Text(
                  billdata.shipVia!.toString(),
                  style: isTablet ? valueStyleTablet : valueStyle,
                ),
              ],
            ),
            SizedBox(height: 3),
            Row(
              children: [
                Text('Terms:',
                    style: isTablet ? headingStyleTablet : headingStyle),
                Spacer(),
                Container(
                  width: billdata.terms!.trim().length <= 50 ? 83 : 140,
                  child: Text(
                    billdata.terms!.trim().toString(),
                    style: isTablet ? valueStyleTablet : valueStyle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 13),
            Visibility(
              //  visible: allBillStatuses[statusIndex],
              visible: billdata.receivedStatus != 'Received' &&
                  b1_show_submit_received_bill_button,
              child: Container(
                //  width: double.infinity,
                width: MediaQuery.of(context).size.width * 0.95,

                //  height: 50.0,
                height: MediaQuery.of(context).size.height * 0.055,
                child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green),
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
                      print('editing bill');

                      // final dialogResult = await showDialog<bool?>(
                      //   context: context,
                      //   builder: (BuildContext context) {
                      //     return AlertDialog(
                      //       title: Form(
                      //       //  key: formkeySequence,
                      //         child: Column(
                      //           crossAxisAlignment:
                      //           CrossAxisAlignment.start,
                      //           children: [
                      //             const Text(
                      //               'Enter Total Quantity',
                      //               style: TextStyle(
                      //                 fontSize: 15.5,
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //             TextFormField(
                      //           //    controller: sequenceNameController,
                      //               decoration: const InputDecoration(
                      //                 hintStyle: TextStyle(fontSize: 13.5),
                      //                 hintText: 'Enter a sequence title',
                      //                 labelText: 'Sequence title',
                      //                 labelStyle: TextStyle(fontSize: 13.5),
                      //               ),
                      //               validator: (value) {
                      //                 if (value == null || value.isEmpty) {
                      //                   return 'Please enter a sequence title';
                      //                 }
                      //
                      //                 return null;
                      //               },
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       actions: [
                      //         TextButton(
                      //           onPressed: () async {
                      //             //  sequenceNameController.clear();
                      //             ScaffoldMessenger.of(context)
                      //                 .clearSnackBars();
                      //
                      //
                      //
                      //
                      //          //   sequenceNameController.clear();
                      //             Navigator.of(context).pop();
                      //        //     await callApiMethods();
                      //           },
                      //           child: const Text(
                      //             'Create',
                      //             style: TextStyle(
                      //               color: Colors.blue,
                      //               fontSize: 16.0,
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // );
                      //

                      final boolResult = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SubmitReceivedStatusBillOfLadingScreen(
                                    billdata: billdata,
                                  )));

                      print('boolResult:' + boolResult.toString());

                      if (!boolResult) {
                        allBillStatuses[statusIndex] = false;
                      }

                      setState(() {});
                    },
                    child: Text(
                      'Submit Receiving Status',
                      style: TextStyle(fontSize: isTablet ? 24 : 14.5),
                    )),
              ),
            ),
            SizedBox(height: 4),
            Container(
              //   width: double.infinity,
              width: MediaQuery.of(context).size.width * 0.95,

              //  height: 50.0,
              height: MediaQuery.of(context).size.height * 0.055,
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
                    await generateAndViewPdf(
                      context,
                      billdata,
                    );
                  },
                  child: Text(
                    'Generate PDF',
                    style: TextStyle(fontSize: isTablet ? 24 : 14.5),
                  )),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Future<void> generateAndViewPdf(
    BuildContext Mycontext,
    Billdata billData,
  ) async {
    // final pdf = pw.Document();

    // // Add content to the PDF
    // pdf.addPage(pw.Page(
    //   build: (pw.Context context) {
    //     return pw.Center(
    //       child: pw.Text(
    //         'Hello, world!',
    //       ),
    //     ); // Replace this with your desired content
    //   },
    // ));

    // // Get a temporary directory path for saving the PDF
    // final outputDirectory = await getTemporaryDirectory();
    // final file = File('${outputDirectory.path}/example.pdf');

    // // Save the generated PDF to the file
    // final f = await file.writeAsBytes(await pdf.save());

    // // View the generated PDF using Syncfusion PDF Viewer
    // // SfPdfViewer.openFromBytes(file.readAsBytesSync());
    // //  SfPdfViewer.file(f);
    // // SfPdfViewer.memory(f.readAsBytesSync());
    // SfPdfViewer.file(f);
    final pdf = pw.Document(
      pageMode: PdfPageMode.fullscreen,
    );
    final apiData = await getBillOfLading();
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        // return pw.Center(
        //   child: pw.Text('Data: '+ apiData.data.dataList.toString()),
        // );
        String formattedTime = DateFormat('h:mm a').format(DateTime.now());
        return pw.Column(children: [
          pw.Center(
              child: pw.Text('Bill of Lading',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 19))),
          pw.SizedBox(height: 50),
          pw.Row(children: [
            //  pw.Text('Generated Invoice Date: ',style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

            pw.Text('Issuance Date: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(DateFormat('MM/dd/yyyy').format(DateTime.now())),
            pw.Spacer(),
            pw.Text('Time: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(formattedTime),
          ]),
          pw.SizedBox(height: 2.5),

          pw.Container(
            width: 1000,
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
            child: pw.Column(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(

                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('PO Number',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 55),
                        pw.Container(
                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        pw.Text(billData.poNumber!.toString(),
                            style: pw.TextStyle()),
                      ]),
                ),
                pw.Divider(height: 0),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Bill Title:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 70.3),
                        pw.Container(
                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        pw.Text(billData.billTitle!, style: pw.TextStyle()),
                      ]),
                ),
                pw.Divider(height: 0),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Address:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 69.1),
                        pw.Container(
                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        pw.Text(billData.address!, style: pw.TextStyle()),
                      ]),
                ),

                pw.Divider(height: 0),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Company Name:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 26.5),
                        pw.Container(
                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        pw.Text(billData.companyName!, style: pw.TextStyle()),
                      ]),
                ),

                pw.Divider(height: 0),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Company Address:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 11.2),
                        pw.Container(
                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10.5),
                        pw.Text(billData.companyAddress!,
                            style: pw.TextStyle()),
                      ]),
                ),
                pw.Divider(height: 0),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Delivery Date:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 41.2),
                        pw.Container(
                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        pw.Text(billData.dilveryDate == null
                            ? 'N/A'
                            : DateFormat('MMMM d, y')
                                .format(DateTime.parse(billData.dilveryDate!))),
                      ]),
                ),
                pw.Divider(height: 0),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Order Date:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 55.3),
                        pw.Container(
                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        pw.Text(billData.orderDate == null
                            ? 'N/A'
                            : DateFormat('MMMM d, y')
                                .format(DateTime.parse(billData.orderDate!))),
                      ]),
                ),

                pw.Divider(height: 0),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Telephone:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 57.25),
                        pw.Container(

                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        pw.Text(billData.phone!, style: pw.TextStyle()),
                      ]),
                ),

                pw.Divider(height: 0),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Fax:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 96.5),
                        pw.Container(

                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        pw.Text(billData.fax!, style: pw.TextStyle()),
                      ]),
                ),
                pw.Divider(height: 0),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Terms:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 81.2),
                        pw.Container(
                            //  width: MediaQuery.of(Mycontext).size.width,
                            height:
                                billData.terms!.trim().length <= 50 ? 20 : 150,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        // dataList[index].terms!.trim().length <= 50
                        //                 ? 83
                        //                 : 140,
                        pw.Container(
                          width:
                              billData.terms!.trim().length <= 50 ? 1000 : 350,
                          child:
                              pw.Text(billData.terms!, style: pw.TextStyle()),
                        ),
                      ]),
                ),
                pw.Divider(height: 0),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Ship Via:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 70),
                        pw.Container(

                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        pw.Text(billData.shipVia!, style: pw.TextStyle()),
                      ]),
                ),
                ////////////////////////////////////////////////////////////  items parts from here
                ///////////////////////////////////////////////////////////
                ///////////////////////////////////////////////////////////
                ///////////////////////////////////////////////////////////

                for (int i = 0;
                    i < billData.billofLadingItems!.length;
                    i++) ...{
                  pw.Divider(height: 0),
                  pw.SizedBox(height: 5.5),
                  pw.Divider(height: 0),
                  pw.Padding(
                    padding:
                        pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    child: pw.Row(
                      //    mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Item Name:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 56.5),
                        pw.Container(
                            //  width: MediaQuery.of(Mycontext).size.width,
                            height: 20,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(width: 1))),
                        pw.SizedBox(width: 10),
                        pw.Text(billData.billofLadingItems![i].fabricatedItems!,
                            style: pw.TextStyle()),
                        pw.Spacer(),
                        pw.Text('Quantity :',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 11),
                        pw.Text(
                            billData.billofLadingItems![i].quantity.toString(),
                            style: pw.TextStyle()),
                        pw.SizedBox(width: 60),

                        // pw.SizedBox(width: 172),
                      ],
                    ),
                  ),
                  // pw.Padding(
                  //   padding:
                  //       pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  //   child: pw.Row(
                  //       //    mainAxisAlignment: pw.MainAxisAlignment.center,
                  //       children: [
                  //         pw.Text('Quantity:',
                  //             style:
                  //                 pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  //         pw.SizedBox(width: 68.52),

                  //         pw.Container(

                  //             //  width: MediaQuery.of(Mycontext).size.width,
                  //             height: 20,
                  //             decoration: pw.BoxDecoration(
                  //                 border: pw.Border.all(width: 1))),
                  //         pw.SizedBox(width: 10),
                  //         pw.Text(
                  //             billData.billofLadingItems![i].quantity
                  //                 .toString(),
                  //             style: pw.TextStyle()),
                  // pw.Text('Company Name:',
                  //     style:
                  //         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  // pw.SizedBox(width: 19),
                  // pw.Container(
                  //     //  width: MediaQuery.of(Mycontext).size.width,
                  //     height: 20,
                  //     decoration: pw.BoxDecoration(
                  //         border: pw.Border.all(width: 1))),
                  // pw.SizedBox(width: 10),
                  // pw.Text(billData.billofLadingItems![i].companyName!,
                  //     style: pw.TextStyle()),
                  // pw.SizedBox(width: 90),
                  // pw.Text('PO Number:',
                  //     style:
                  //         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  // pw.SizedBox(width: 1),
                  // pw.Container(
                  //     //  width: MediaQuery.of(Mycontext).size.width,
                  //     height: 20,
                  //     decoration: pw.BoxDecoration(
                  //         border: pw.Border.all(width: 1))),
                  // pw.SizedBox(width: 10),
                  // pw.Text(
                  //     apiData.data!.billdata![0].billofLadingItems![i]
                  //         .poNumber
                  //         .toString(),
                  //     style: pw.TextStyle()),
                  //     ]),
                  // ),
                  // pw.Padding(
                  //   padding:
                  //       pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  //   child: pw.Row(
                  //       //    mainAxisAlignment: pw.MainAxisAlignment.center,
                  //       children: [
                  //         pw.Text('Telephone:',
                  //             style:
                  //                 pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  //         pw.SizedBox(width: 57.2),

                  //         pw.Container(
                  //             //  width: MediaQuery.of(Mycontext).size.width,
                  //             height: 20,
                  //             decoration: pw.BoxDecoration(
                  //                 border: pw.Border.all(width: 1))),
                  //         pw.SizedBox(width: 10),
                  //      //   pw.Text(billData.billofLadingItems![i].phone!,
                  //        //     style: pw.TextStyle()),
                  //         pw.SizedBox(width: 172),
                  //         // pw.Text('Quantity:',
                  //         //     style:
                  //         //         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  //         // pw.SizedBox(width: 20),
                  //         // pw.Container(
                  //         //     //  width: MediaQuery.of(Mycontext).size.width,
                  //         //     height: 20,
                  //         //     decoration: pw.BoxDecoration(
                  //         //         border: pw.Border.all(width: 1))),
                  //         // pw.SizedBox(width: 20),
                  //         // pw.Text(
                  //         //     apiData.data!.billdata![0].billofLadingItems![i]
                  //         //         .quantity
                  //         //         .toString(),
                  //         //     style: pw.TextStyle()),
                  //       ]),
                  // ),
                  // pw.Padding(
                  //   padding:
                  //       pw.EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  //   child: pw.Row(
                  //       //    mainAxisAlignment: pw.MainAxisAlignment.center,
                  //       children: [
                  //         pw.Text('Fax:',
                  //             style:
                  //                 pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  //         pw.SizedBox(width: 96.55),

                  //         pw.Container(
                  //             //  width: MediaQuery.of(Mycontext).size.width,
                  //             height: 20,
                  //             decoration: pw.BoxDecoration(
                  //                 border: pw.Border.all(width: 1))),
                  //         pw.SizedBox(width: 10),
                  //         pw.Text(billData.billofLadingItems![i].fax!,
                  //             style: pw.TextStyle()),
                  //         pw.SizedBox(width: 103),

                  //         // pw.Text('Quantity:',
                  //         //     style:
                  //         //         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  //         // pw.SizedBox(width: 20),
                  //         // pw.Container(
                  //         //     //  width: MediaQuery.of(Mycontext).size.width,
                  //         //     height: 20,
                  //         //     decoration: pw.BoxDecoration(
                  //         //         border: pw.Border.all(width: 1))),
                  //         // pw.SizedBox(width: 20),
                  //         // pw.Text(
                  //         //     apiData.data!.billdata![0].billofLadingItems![i]
                  //         //         .quantity
                  //         //         .toString(),
                  //         //     style: pw.TextStyle()),
                  //         // pw.Text('PO Number:',
                  //         //     style:
                  //         //         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  //         // pw.SizedBox(width: 2),

                  //         // pw.Container(
                  //         //     //  width: MediaQuery.of(Mycontext).size.width,
                  //         //     height: 20,
                  //         //     decoration: pw.BoxDecoration(
                  //         //         border: pw.Border.all(width: 1))),
                  //         // pw.SizedBox(width: 10),
                  //         // pw.Text(
                  //         //     billData.billofLadingItems![i].poNumber
                  //         //         .toString(),
                  //         //     style: pw.TextStyle()),
                  //       ]),
                  // ),
                },

                pw.Divider(height: 0),
                pw.SizedBox(height: 18.5),

                pw.Divider(height: 0),

                pw.Divider(height: 0),
                pw.SizedBox(height: 4),
                pw.Row(children: [
                  pw.SizedBox(width: 5),
                  pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Text('Signature is required for all deliveries',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ]),
                pw.Divider(height: 3),
                pw.SizedBox(height: 15),
                pw.Divider(height: 5),

                pw.Row(children: [
                  pw.SizedBox(width: 5),
                  pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Text(
                        'ALL MATERIAL SHOULD BE MARKED WITH A ID# PO# SIZE GRADE AND HEAT NUMBER',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                ]),
                pw.Divider(height: 5),

                //   pw.Divider(height: 5),

                pw.Row(children: [
                  pw.SizedBox(width: 5),
                  pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Text(
                        'BEAMS: A992\\A572-GR,50 TUBES: AS01GR.B\\C BARS:A36.A892YA5T2 MTR\'S REQUIRED',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                ]),
                //       pw.SizedBox(height: 2.5),

                pw.Divider(height: 3),
                pw.SizedBox(height: 15),

                /////////////////////////////////////////////////////  prev ok

                pw.Divider(height: 5),

                pw.Row(children: [
                  pw.SizedBox(width: 5),
                  pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Text(
                        'We reserve the right to reject any material shipped under thi Purchase Order',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                  pw.SizedBox(width: 70),
                  pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Text('PER',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                ]),
                pw.Divider(height: 3),

                //  pw.Divider(height: 5),

                pw.Row(children: [
                  pw.SizedBox(width: 5),
                  pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Text(
                        'in part or full, that does not conform to every specification of this order, and for any',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                ]),
                pw.Divider(height: 3),

                // pw.Divider(height: 5),

                pw.Row(children: [
                  pw.SizedBox(width: 5),
                  pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Text(
                        'material that is damaged or shipped in an unacceptable manner',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                ]),
                //  pw.Divider(height: 3),

                pw.Divider(height: 3),
                pw.SizedBox(height: 15),
                //   pw.Divider(height: 5),
              ],
            ),
          ),

          //  for(int i=0;i<apiData.data.z.length;i++)...{
          // pw.Text(apiData.data.dataList[i].fabricatedItemName,)
          // pw.Column(children: [
          //   pw.SizedBox(height: 9),

          //   pw.Container(
          //     padding: pw.EdgeInsets.all(21),
          //       decoration:pw.BoxDecoration(

          //         border: pw.Border.all(width: 0.5, color: PdfColor.fromHex('#808080')),

          //       ),
          //     child: pw.Column(children: [

          //  pw.Row(
          //      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //      children: [ pw.Text('Fabricated Item:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),pw.Text(apiData.data.dataList[i].fabricatedItemName)]),
          //   pw.Divider(color: PdfColor.fromHex('#D3D3D3')),
          //       pw.Row(
          //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //           children: [ pw.Text('Company Name:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),pw.Text(apiData.data.dataList[i].companyName)]),
          //       pw.Divider(color: PdfColor.fromHex('#D3D3D3')),
          //       pw.Row(
          //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //           children: [ pw.Text('Vendor Name:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),pw.Text(apiData.data.dataList[i].vendorName)]),
          //       pw.Divider(color: PdfColor.fromHex('#D3D3D3')),
          //       pw.Row(
          //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //           children: [ pw.Text('Item Quantity:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),pw.Text(apiData.data.dataList[i].quantity.toString())]),
          // ])),
          // ]),

          //  }

//          previous pdf starts from here.
          // pw.Container(
          //     //  width: MediaQuery.of(Mycontext).size.width,
          //     width: 1000,
          //     decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
          //     child: pw.Column(children: [
          //       //  pw.SizedBox(height: 7),
          //       pw.Text('Purchase Order'),
          //       pw.Divider(),
          //       pw.SizedBox(height: 3),
          //       pw.Divider(),
          //       pw.Row(children: [
          //         pw.Column(
          //           // mainAxisAlignment: pw.MainAxisAlignment.start,
          //           children: [
          //             pw.Padding(
          //               padding: pw.EdgeInsets.all(0),
          //               child: pw.Text('Company:',
          //                   style:
          //                       pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //             ),
          //             pw.Container(
          //                 width: 100,
          //                 decoration: pw.BoxDecoration(
          //                     border: pw.Border.all(width: 1))),
          //             pw.SizedBox(height: 20),
          //             pw.Container(
          //                 width: 100,
          //                 decoration: pw.BoxDecoration(
          //                     border: pw.Border.all(width: 1))),
          //             pw.SizedBox(height: 20),
          //             pw.Container(
          //                 width: 100,
          //                 decoration: pw.BoxDecoration(
          //                     border: pw.Border.all(width: 1))),
          //             pw.SizedBox(height: 20),
          //             pw.Container(
          //                 width: 100,
          //                 decoration: pw.BoxDecoration(
          //                     border: pw.Border.all(width: 1))),
          //             pw.SizedBox(height: 20),
          //             pw.Container(
          //                 width: 100,
          //                 decoration: pw.BoxDecoration(
          //                     border: pw.Border.all(width: 1))),
          //             pw.SizedBox(height: 20),
          //             pw.Container(
          //                 width: 100,
          //                 decoration: pw.BoxDecoration(
          //                     border: pw.Border.all(width: 1))),
          //             pw.SizedBox(height: 20),
          //             pw.Container(
          //                 width: 100,
          //                 decoration: pw.BoxDecoration(
          //                     border: pw.Border.all(width: 1))),
          //             pw.SizedBox(height: 20),
          //             pw.Container(
          //                 width: 100,
          //                 decoration: pw.BoxDecoration(
          //                     border: pw.Border.all(width: 1))),
          //           ],
          //         ),
          //         pw.Container(
          //             height: 150,
          //             decoration:
          //                 pw.BoxDecoration(border: pw.Border.all(width: 1))),
          //         // pw.VerticalDivider(width: 3),
          //         //   pw.VerticalDivider(width: 10,color: PdfColor.fromHex('#808080')),

          //         /////////////////////////////////////////////////////////////////////////// --------(-col-2-)--------
          //         pw.Column(
          //             //    crossAxisAlignment: pw.CrossAxisAlignment.start,
          //             children: [
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(0),
          //                 child: pw.Text('(Company) Inc.',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.SizedBox(height: 10),
          //               pw.Container(
          //                   width: 100,
          //                   decoration: pw.BoxDecoration(
          //                       border: pw.Border.all(width: 1))),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(0),
          //                 child: pw.Text('Address',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Container(
          //                   width: 100,
          //                   decoration: pw.BoxDecoration(
          //                       border: pw.Border.all(width: 1))),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(0),
          //                 child: pw.Text('Address, CT 08080:',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Container(
          //                   width: 100,
          //                   decoration: pw.BoxDecoration(
          //                       border: pw.Border.all(width: 1))),
          //               pw.Container(
          //                   width: 100,
          //                   decoration: pw.BoxDecoration(
          //                       border: pw.Border.all(width: 1))),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(0),
          //                 child: pw.Text('Tel: (860) 354-XXXX',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Container(
          //                   width: 100,
          //                   decoration: pw.BoxDecoration(
          //                       border: pw.Border.all(width: 1))),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(0),
          //                 child: pw.Text('Fax: (860) 354-XXXX',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Container(
          //                   width: 100,
          //                   decoration: pw.BoxDecoration(
          //                       border: pw.Border.all(width: 1))),
          //               pw.SizedBox(height: 20),
          //               pw.Container(
          //                   width: 100,
          //                   decoration: pw.BoxDecoration(
          //                       border: pw.Border.all(width: 1))),
          //               pw.SizedBox(height: 20),
          //               pw.Container(
          //                   width: 100,
          //                   decoration: pw.BoxDecoration(
          //                       border: pw.Border.all(width: 1))),
          //             ]),
          //         pw.Container(
          //             height: 150,
          //             decoration:
          //                 pw.BoxDecoration(border: pw.Border.all(width: 1))),

          //         ///  col-3
          //         pw.Column(
          //             crossAxisAlignment: pw.CrossAxisAlignment.start,
          //             children: [
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.SizedBox(width: 40),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //             ]),
          //         pw.Container(
          //             height: 100,
          //             decoration:
          //                 pw.BoxDecoration(border: pw.Border.all(width: 1))),

          //         ////////////  col-4
          //         pw.Column(
          //             crossAxisAlignment: pw.CrossAxisAlignment.start,
          //             children: [
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.SizedBox(width: 40),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //             ]),
          //         pw.Container(
          //             height: 100,
          //             decoration:
          //                 pw.BoxDecoration(border: pw.Border.all(width: 1))),

          //         ///////////// col-5--------------
          //         pw.Column(
          //             crossAxisAlignment: pw.CrossAxisAlignment.start,
          //             children: [
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('PO Number:',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('Order Date:',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('Delivery Date:',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               pw.Padding(
          //                 padding: pw.EdgeInsets.all(3),
          //                 child: pw.Text('Page:',
          //                     style:
          //                         pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               ),
          //               // pw.Padding(
          //               //   padding: pw.EdgeInsets.all(3),
          //               //   child: pw.Text('Fax: (860) 354-XXXX',
          //               //       style:
          //               //       pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //               // ),
          //             ]),
          //       ]),
          //       //   pw.Divider(),
          //     ])),

          ////////////// new pdf starts from here...

          // pw.Container(
          //   width: 1000,
          //   decoration: pw.BoxDecoration(
          //     border: pw.Border.all(width: 1),
          //   ),
          //   child: pw.Column(children: [
          //     // row-1-----------------------------------
          //     pw.SizedBox(height: 2),
          //     pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
          //       pw.Center(
          //           child: pw.Text('Automated Invoice',
          //               style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))
          //     ]),
          //     pw.SizedBox(height: 2),
          //     // row-2-----------------------------------
          //     pw.Container(
          //       width: 1000,
          //       height: 11,
          //       decoration: pw.BoxDecoration(
          //         border: pw.Border.all(width: 1),
          //       ),
          //     ),

          //     // row-3-----------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),
          //       pw.Text('Company:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 17),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 17),
          //       pw.Text('(Company) Inc.:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 18.5),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       pw.Text('PO Number:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     //// row-2
          //     pw.Divider(height: 0),

          //     // row-4---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('---------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 15.9),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 8),
          //       pw.Text(apiData.data!.billdata![0].address!,
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 10.7),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       pw.Text('Order Date:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 17),
          //     ]),
          //     pw.Divider(height: 0),
          //     // row-5---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('---------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 15.9),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 17),
          //       pw.Text('Address:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 57),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       pw.Text('Delivery Date:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     pw.Divider(height: 0),
          //     // row-6---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('---------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 15.9),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 8),
          //       pw.Text('Tel: (860) 354-XXXX',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 6),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       pw.Text('Page:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     pw.Divider(height: 0),

          //     // row-7---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('---------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 15.9),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 6),
          //       pw.Text('Fax: (860) 354-XXXX',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 4.5),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       //  pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     pw.Divider(height: 0),
          //     // row-8---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('---------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 15.9),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 6),
          //       //// here
          //       pw.Text('-----------------------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 4),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       //  pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     /////////////////////////////////

          //     pw.Divider(height: 0),
          //     // row-9---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('---------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 15.9),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 6),
          //       //// here
          //       pw.Text('-----------------------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 4),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       //  pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     //////////////////////////////////////////

          //     pw.Divider(height: 0),
          //     // row-10---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('Vendor:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 30.5),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 6),
          //       //// here
          //       pw.Text('-----------------------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 4),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       //  pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     pw.Divider(height: 0),

          //     for (int i = 0;
          //         i < apiData.data!.billdata![0].billofLadingItems!.length;
          //         i++) ...{
          //       // row-11---------------------------------
          //       pw.Row(children: [
          //         pw.SizedBox(width: 17),

          //         pw.Text('---------------',
          //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //         pw.SizedBox(width: 15.9),
          //         pw.Container(
          //           width: 0,
          //           height: 21,
          //           decoration: pw.BoxDecoration(
          //             border: pw.Border.all(width: 1),
          //           ),
          //         ),
          //         pw.SizedBox(width: 6),
          //         //// here
          //         // pw.Text('-----------------------------',
          //         //     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //         pw.Text(
          //             apiData.data!.billdata![0].billofLadingItems![i]
          //                 .fabricatedItems!,
          //             style: pw.TextStyle()),
          //         pw.SizedBox(width: 4),

          //         pw.Container(
          //           width: 0,
          //           height: 21,
          //           decoration: pw.BoxDecoration(
          //             border: pw.Border.all(width: 1),
          //           ),
          //         ),
          //         pw.SizedBox(width: 3),

          //         // pw.Text('-----------------',
          //         //     style: pw.TextStyle(
          //         //         fontWeight: pw.FontWeight.bold,
          //         //         color: PdfColor.fromHex('#FFFFFF'))),
          //         pw.Text(
          //             apiData.data!.billdata![0].billofLadingItems![i].quantity
          //                 .toString(),
          //             style: pw.TextStyle()),
          //         pw.Container(
          //           width: 0,
          //           height: 21,
          //           decoration: pw.BoxDecoration(
          //             border: pw.Border.all(width: 1),
          //           ),
          //         ),
          //         pw.SizedBox(width: 3),
          //         pw.Text('-----------------',
          //             style: pw.TextStyle(
          //                 fontWeight: pw.FontWeight.bold,
          //                 color: PdfColor.fromHex('#FFFFFF'))),
          //         pw.Container(
          //           width: 0,
          //           height: 21,
          //           decoration: pw.BoxDecoration(
          //             border: pw.Border.all(width: 1),
          //           ),
          //         ),
          //         //  pw.SizedBox(width: 3),
          //         pw.SizedBox(width: 17),
          //         //  pw.SizedBox(width: 3),
          //         pw.Text('-----------------',
          //             style: pw.TextStyle(
          //                 fontWeight: pw.FontWeight.bold,
          //                 color: PdfColor.fromHex('#FFFFFF'))),
          //         pw.SizedBox(width: 17),
          //       ]),

          //       pw.Divider(height: 0),
          //     },

          //     // row-12---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('---------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 15.9),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 6),
          //       //// here
          //       pw.Text('-----------------------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 4),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       //  pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     pw.Divider(height: 0),
          //     // row-13---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('---------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 15.9),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 6),
          //       //// here
          //       pw.Text('-----------------------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 4),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       //  pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     //////////////////////////////////////////////////////////////
          //     ////////////////////////////////////////////////////////////
          //     ///////////////////////////////////////////////////////////

          //     //////////////////////////////////////////

          //     pw.Divider(height: 0),
          //     // row-14---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('Ship Via:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 24.5),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 6),
          //       //// here
          //       pw.Text('--------------------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 16),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       //  pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     pw.Divider(height: 0),

          //     //   pw.Divider(height: 0),
          //     // row-15---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 17),

          //       pw.Text('Terms:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 36),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 6),
          //       //// here
          //       pw.Text('--------------------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 16),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       //  pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.SizedBox(width: 17),
          //     ]),

          //     pw.Divider(height: 0),

          //     //   pw.Divider(height: 0),
          //     // row-15---------------------------------
          //     pw.Row(children: [
          //       pw.SizedBox(width: 18.5),

          //       pw.Text('FOB:',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 46.5),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 6),
          //       //// here
          //       pw.Text('--------------------------',
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(width: 16),

          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),

          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.Container(
          //         width: 0,
          //         height: 21,
          //         decoration: pw.BoxDecoration(
          //           border: pw.Border.all(width: 1),
          //         ),
          //       ),
          //       //  pw.SizedBox(width: 3),
          //       pw.SizedBox(width: 17),
          //       //  pw.SizedBox(width: 3),
          //       pw.Text('-----------------',
          //           style: pw.TextStyle(
          //               fontWeight: pw.FontWeight.bold,
          //               color: PdfColor.fromHex('#FFFFFF'))),
          //       pw.SizedBox(width: 17),
          //     ]),
          //   ]),
          // ),
        ]);
      },
    ));
    final path = await getTemporaryDirectory();
    final file =
        File(path.path + '/(${billData.billTitle})_bill of lading.pdf');
    final f = await file.writeAsBytes(await pdf.save());
    print('f path:' + f.toString());

    final result = await OpenFile.open(file.path);
    print('messsage: ${result.message}');
  }
}
