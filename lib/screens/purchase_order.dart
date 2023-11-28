import 'package:com_a3_pace/screens/Dashboard.dart';
import 'package:com_a3_pace/screens/purchase_order_detail_screen.dart';
import 'package:com_a3_pace/services/purchase_order_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';

class PurchaseOrder extends StatefulWidget {
  const PurchaseOrder({super.key});

  @override
  State<PurchaseOrder> createState() => _PurchaseOrderState();
}

class _PurchaseOrderState extends State<PurchaseOrder> {
  bool isLoading = false;
  @override
  void initState() {
    callApiMethods();
    super.initState();
  }

  List<PurchaseOrders> purchaseOrdersList = [];
  Future<void> callApiMethods() async {
    isLoading = true;
    purchaseOrdersList = await getAllPurchaseOrders();
    isLoading = false;
    setState(() {});
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
            // Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
          },
        ),
        title: const Text(
          "Purchase Order",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          // Row(
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(right: 10.0),
          //       child: Stack(
          //         children: [
          //           // InkWell(
          //           //   onTap: () {
          //           //     if (_blShowNotificationsList) {
          //           //       Navigator.push(
          //           //         context,
          //           //         MaterialPageRoute(
          //           //             builder: (context) =>
          //           //                 const NotificationsScreen()),
          //           //       );
          //           //     } else {
          //           //       showToast(
          //           //           "You do not have permission to see notifications.");
          //           //     }
          //           //   },
          //           //   child: Image.asset(
          //           //     "assets/images/ic_bell.png",
          //           //     width: 32,
          //           //     height: 32,
          //           //   ),
          //           // ),
          //           Positioned(
          //             top: 5,
          //             right: 0,
          //             child: Container(
          //               padding: const EdgeInsets.all(5),
          //               decoration: BoxDecoration(
          //                 color: Colors.red,
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     // GestureDetector(
          //     //   onTap: () {
          //     //     Navigator.push(
          //     //       context,
          //     //       MaterialPageRoute(
          //     //           builder: (context) => const ProfileScreen()),
          //     //     );
          //     //   },
          //     //   child: const Padding(
          //     //     padding: EdgeInsets.only(right: 10.0, left: 5.0),
          //     //     child: CircleAvatar(
          //     //       backgroundImage:
          //     //           AssetImage('assets/images/ic_profile.png'),
          //     //       radius: 15,
          //     //     ),
          //     //   ),
          //     // ),
          //   ],
          // )
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 19, horizontal: 19),
                child: ListView.separated(
                  itemCount: purchaseOrdersList.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 11,
                    );
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PurchaseOrderDetailScreen(
                                    purchaseOrder: purchaseOrdersList[index])));
                      },
                      child: purchaseOrderCard(
                        companyName: purchaseOrdersList[index].company.name,
                        poId: purchaseOrdersList[index].poNumber.toString(),
                        address: purchaseOrdersList[index].address.toString(),
                        orderDate:
                            purchaseOrdersList[index].orderDate.toString(),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Card purchaseOrderCard({
    required String companyName,
    required String poId,
    required String address,
    required String orderDate,
  }) {
    return Card(
      child: Column(
        children: [
          SizedBox(height: 15),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 13),
              Text(
                // "#$id",
                poId,

                style: const TextStyle(
                  color: Color(0xFF1E2022),
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
              Spacer(),
              Text(
                // DateFormat(US_DATE_FORMAT).format(createdAt!),
                DateFormat(US_DATE_FORMAT).format(DateTime.parse(orderDate)),
                style: const TextStyle(
                  fontSize: 11.0,
                  color: Color(0xFF77838F),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 13),
            ],
          ),

          const SizedBox(height: 8.0),
          Row(
            children: [
              SizedBox(width: 13),
              Text(
                // ediStdNomenclature![0].toUpperCase() +
                //     ediStdNomenclature!.substring(1),
                address,
                style: const TextStyle(
                  // color: getProgressColor(status),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                // "Shape:$shape",
                companyName,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 13),
            ],
          ),
          // const SizedBox(height: 8.0),
          // Container(
          //   width: double.infinity,
          //   height: 6,
          //   decoration: BoxDecoration(
          //       color: Colors.grey.shade300,
          //       borderRadius: BorderRadius.circular(12)),
          //   child: Row(
          //     children: [
          //       Container(
          //         width: MediaQuery.of(context).size.width * 0.5,
          //         decoration: BoxDecoration(
          //             color: const Color(0xFFF4BE4F),
          //             borderRadius: BorderRadius.circular(12)),
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
