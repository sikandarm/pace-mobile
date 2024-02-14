import 'package:adaptive_theme/adaptive_theme.dart';
//import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/purchase_order_list.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'purchase_order_detail_screen.dart';

class PurchaseOrder extends StatefulWidget {
  const PurchaseOrder({super.key});

  @override
  State<PurchaseOrder> createState() => _PurchaseOrderState();
}

class _PurchaseOrderState extends State<PurchaseOrder> {
  bool isLoading = false;

  bool blViewPurchaseOrderDetail = false;

  @override
  void initState() {
    checkPermissionAndUpdateBool("view_purchasedetails", (localBool) {
      blViewPurchaseOrderDetail = localBool;
    });
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
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.,
        backgroundColor:
            AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                ? Color.fromARGB(255, 7, 21, 32)
                : Colors.white,
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
            Navigator.pop(context);
            // Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
          },
        ),
        title: Text(
          "Purchase Orders",
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
            fontWeight: FontWeight.bold,
            // color:
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
          // color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
          //     ? Color.fromARGB(255, 7, 21, 32)
          //     : Colors.white,
          color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
              ? Color.fromARGB(255, 7, 21, 32)
              : Colors.white,
          boxShadow: [
            // (EasyDynamicTheme.of(context).themeMode != ThemeMode.dark)
            //     ? BoxShadow(
            //         color: Colors.grey.withOpacity(0.5),
            //         spreadRadius: 2,
            //         blurRadius: 5,
            //         offset: const Offset(0, 3), // changes position of shadow
            //       )
            //     : const BoxShadow(),
          ],
        ),

        // child: isLoading
        //     ? Center(child: CircularProgressIndicator())
        //     : Padding(
        //         padding:
        //             const EdgeInsets.symmetric(vertical: 19, horizontal: 19),
        //         child: ListView.separated(
        //           itemCount: purchaseOrdersList.length,
        //           separatorBuilder: (context, index) {
        //             return SizedBox(
        //               height: 11,
        //             );
        //           },
        //           itemBuilder: (context, index) {
        //             return InkWell(
        //               onTap: () {
        //                 Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                         builder: (context) => PurchaseOrderDetailScreen(
        //                             purchaseOrder: purchaseOrdersList[index])));
        //               },
        //               child: purchaseOrderCard(
        //                 companyName:
        //                     purchaseOrdersList[index].company!.name.toString(),
        //                 poId: purchaseOrdersList[index].poNumber.toString(),
        //                 address: purchaseOrdersList[index].address.toString(),
        //                 orderDate:
        //                     purchaseOrdersList[index].orderDate.toString(),
        //               ),
        //             );
        //           },
        //         ),
        //       ),
        child: FutureBuilder<List<PurchaseOrders>>(
          future: getAllPurchaseOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text("${snapshot.error}"),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text("No data found"),
              );
            } else {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 19, horizontal: 19),
                child: ListView.separated(
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 11,
                    );
                  },
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return InkWell(
                      onTap: () {
                        // Handle item tap
                        if (!blViewPurchaseOrderDetail) {
                          showToast('You do not have permissions.');
                          return;
                        }

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PurchaseOrderDetailScreen(
                                    purchaseOrder: purchaseOrdersList[index])));
                      },
                      child: purchaseOrderCard(

                          // color: index % 2 == 0
                          //     ? Colors.redAccent
                          //     : Colors.green.withOpacity(0.8),
                          color: item.status?.toLowerCase() !=
                                  'Received'.toLowerCase()
                              ? Colors.redAccent
                              : Colors.green.withOpacity(0.8),
                          companyName: item.company!.name.toString(),
                          address: item.address.toString(),
                          orderDate: item.orderDate.toString(),
                          poId: item.poNumber.toString()),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget purchaseOrderCard({
    required String companyName,
    required String poId,
    required String address,
    required String orderDate,
    required Color color,
  }) {
    return Container(
      height: isTablet ? 170 : 85,
      child: Card(
        color: color,
        child: Column(
          children: [
            SizedBox(height: isTablet ? 30 : 15),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 13),
                Text(
                  // "#$id",
                  poId,

                  style: TextStyle(
                    // color: Color(0xFF1E2022),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 27 : 13.0,
                  ),
                ),
                Spacer(),
                Text(
                  // DateFormat(US_DATE_FORMAT).format(createdAt!),
                  DateFormat(US_DATE_FORMAT).format(DateTime.parse(orderDate)),
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 11.0,
                    //  color: Color(0xFF77838F),
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 13),
              ],
            ),

            SizedBox(height: isTablet ? 20 : 8.0),
            Row(
              children: [
                SizedBox(width: 13),
                Text(
                  // ediStdNomenclature![0].toUpperCase() +
                  //     ediStdNomenclature!.substring(1),
                  address,
                  style: TextStyle(
                    // color: getProgressColor(status),
                    color: Colors.white,
                    fontSize: isTablet ? 22 : 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  // "Shape:$shape",
                  companyName,
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 12.0,
                    color: Colors.white,
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
      ),
    );
  }

  void checkPermissionAndUpdateBool(
      String permValue, Function(bool) boolUpdater) async {
    var localBool = await hasPermission(permValue);

    setState(() {
      boolUpdater(localBool);
    });
  }
}
