import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

//import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:pace_application_fb/services/get_bill_of_lading_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
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
              await generateAndViewPdf();
            },
            child: const Chip(
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
                    return Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:  21.0,vertical: 3),
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
                                Text('Company Name:', style: headingStyle),
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
                           SizedBox(height: 3),
                            Divider(),
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

  Future<void> generateAndViewPdf() async {
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
    final pdf = pw.Document();
final apiData=await getBillOfLading();
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        // return pw.Center(
        //   child: pw.Text('Data: '+ apiData.data.dataList.toString()),
        // );
         String formattedTime = DateFormat('h:mm a').format(DateTime.now());
        return pw.Column(children: [
         pw.Center(child:  pw.Text('Bill of Lading Report',style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 19))),
          pw.SizedBox(height: 50),
          pw.Row(children: [
          //  pw.Text('Generated Invoice Date: ',style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

            pw.Text('Issuance Date: ',style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(DateFormat('MM/dd/yyyy').format(DateTime.now())),
            pw.Spacer(),
            pw.Text('Time: ',style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(formattedTime),
          ]),
          pw.SizedBox(height: 2.5),

          for(int i=0;i<apiData.data.dataList.length;i++)...{
           // pw.Text(apiData.data.dataList[i].fabricatedItemName,)
   pw.Column(children: [
     pw.SizedBox(height: 9),

     pw.Container(
       padding: pw.EdgeInsets.all(21),
         decoration:pw.BoxDecoration(
           
           border: pw.Border.all(width: 0.5, color: PdfColor.fromHex('#808080')),

         ),
         child: pw.Column(children: [

      pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [ pw.Text('Fabricated Item:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),pw.Text(apiData.data.dataList[i].fabricatedItemName)]),
       pw.Divider(color: PdfColor.fromHex('#D3D3D3')),
           pw.Row(
               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
               children: [ pw.Text('Company Name:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),pw.Text(apiData.data.dataList[i].companyName)]),
           pw.Divider(color: PdfColor.fromHex('#D3D3D3')),
           pw.Row(
               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
               children: [ pw.Text('Vendor Name:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),pw.Text(apiData.data.dataList[i].vendorName)]),
           pw.Divider(color: PdfColor.fromHex('#D3D3D3')),
           pw.Row(
               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
               children: [ pw.Text('Item Quantity:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),pw.Text(apiData.data.dataList[i].quantity.toString())]),
     ])),
   ]),


          }
        ]);
      },
    ));
    final path = await getTemporaryDirectory();
    final file = File(path.path + '/bill of lading.pdf');
    final f = await file.writeAsBytes(await pdf.save());
    print('f path:' + f.toString());

    final result = await OpenFile.open(file.path);
    print('messsage: ${result.message}');
  }
}
