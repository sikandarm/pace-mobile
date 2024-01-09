import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pace_application_fb/services/get_bill_of_lading_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/constants.dart';

class BillOfLading extends StatelessWidget {
  BillOfLading({super.key});

  final headingStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async {
        final billOfLading = await getBillOfLading();
        print(billOfLading.data.dataList.toList());
      }),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
            fontSize: appBarTiltleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          InkWell(
            onTap: () async {
              final pdf = pw.Document();

// Add content to the PDF (see examples below)

// Save the PDF

              final path = await getApplicationDocumentsDirectory();
              final file = File('${path.path}/my_document.pdf');
              await file.writeAsBytes(await pdf.save());

              pdf.addPage(pw.Page(
                build: (pw.Context context) {
                  return pw.Center(
                    child: pw.Text('Hello, world!'),
                  );
                },
              ));

              pdf.addPage(pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (pw.Context context) {
                  return pw.Column(
                    children: [
                      pw.Header(
                        child: pw.Text('My Document'),
                      ),
                      pw.Paragraph(text: 'This is some content.'),
                      // Add more content here
                    ],
                  );
                },
              ));

              final tableData = [
                ['Column 1', 'Column 2', 'Column 3'],
                ['Data 1', 'Data 2', 'Data 3'],
                // Add more rows here
              ];

              pdf.addPage(pw.Page(
                build: (pw.Context context) {
                  return pw.Table(
                    border: pw.TableBorder.all(),
                    children: tableData
                        .map((row) => pw.TableRow(
                            children:
                                row.map((cell) => pw.Text(cell)).toList()))
                        .toList(), // Map each cell to a pw.Text widget
                  );
                },
              ));

              ///////////////////////////////////////////////////////
              // final pdf = pw.Document();

              // pdf.addPage(pw.Page(
              //     pageFormat: PdfPageFormat.a4,
              //     build: (pw.Context context) {
              //       return pw.Center(
              //         child: pw.Text("Hello World"),
              //       ); // Center
              //     })); //

              // On Flutter, use the [path_provider](https://pub.dev/packages/path_provider) library:
//   final output = await getTemporaryDirectory();
//   final file = File("${output.path}/example.pdf");
              //   final file = File("example.pdf");
              // await file.writeAsBytes(await pdf.save());
              // final output = await getApplicationDocumentsDirectory();
              // final file = File("${output.path}/pdf_pace");
              // final p = await file.writeAsBytes(await pdf.save());
              // print(p.absolute);
              // print(p.path);
              // print(p.parent);
            },
            child: Chip(
                backgroundColor: Colors.green,
                label: Text(
                  'Generate PDF',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )),
          ),
          SizedBox(width: 11),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 27),
          FutureBuilder(
            future: getBillOfLading(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(child: CircularProgressIndicator()));
              }
              final dataList = snapshot.data?.data.dataList;
              return Expanded(
                child: ListView.builder(
                  itemCount: dataList!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(21.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('Fabricated Item:', style: headingStyle),
                                Spacer(),
                                Text(dataList[index]
                                    .fabricatedItemName
                                    .toString()),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text('Quantity:', style: headingStyle),
                                Spacer(),
                                Text(dataList[index].quantity.toString()),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text('companyName:', style: headingStyle),
                                Spacer(),
                                Text(dataList[index].companyName.toString()),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text('Vendor:', style: headingStyle),
                                Spacer(),
                                Text(dataList[index].vendorName.toString()),
                              ],
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
