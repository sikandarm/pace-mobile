import 'package:com_a3_pace/screens/purchase_order.dart';
import 'package:com_a3_pace/services/change_status_purchase_order.dart';
import 'package:com_a3_pace/services/get_purchase_order_item.dart';
import 'package:com_a3_pace/utils/constants.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../services/purchase_order_list.dart';

class PurchaseOrderDetailScreen extends StatefulWidget {
  const PurchaseOrderDetailScreen({super.key, required this.purchaseOrder});
  static const routeName = '/purchase-order-detail-screen';
  final PurchaseOrders purchaseOrder;

  @override
  State<PurchaseOrderDetailScreen> createState() =>
      _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState extends State<PurchaseOrderDetailScreen> {
  List<PurchaseOrderItems> purchaseOrderItemsList = [];
  @override
  void initState() {
    callApiMethod();
    super.initState();
  }

  bool isApiLoading = false;
  Future<void> callApiMethod() async {
    isApiLoading = true;
    purchaseOrderItemsList = await fetchPurchaseOrderItemsDetailListData(
        id: widget.purchaseOrder.id!);
    isApiLoading = false;
    setState(() {});
  }

  ScrollController? controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   final result = await fetchPurchaseOrderItemsDetailListData(
      //       id: widget.purchaseOrder.id!);
      //   print('result:${result.first.inventoryItem}');
      // }),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          //    const SizedBox(height: 10),

          //  SfDataGrid(source: DataGridS, columns: <GridColumn>[])

          /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
          /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
          /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
          ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 7),
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height * 0.74,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Scrollbar(
                radius: const Radius.circular(33),

                thumbVisibility: true,
                //   trackVisibility: true,
                //   showTrackOnHover: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTileItem(
                        label: 'ID',
                        value: widget.purchaseOrder.id.toString(),
                      ),

                      // ListTileItem(
                      //   label: 'Company Name',
                      //   value: purchaseOrder.companyName.toString(),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                      //   child: Divider(),
                      // ),

                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Address',
                        value: widget.purchaseOrder.address.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Phone',
                        value: widget.purchaseOrder.phone.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Fax',
                        value: widget.purchaseOrder.fax.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Email',
                        value: widget.purchaseOrder.email.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Status',
                        value: widget.purchaseOrder.status.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      // ListTileItem(
                      //   label: 'User ID',
                      //   value: purchaseOrder.userId.toString(),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                      //   child: Divider(),
                      // ),
                      ListTileItem(
                        label: 'PO Number',
                        value: widget.purchaseOrder.poNumber.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Order Date',
                        // value: purchaseOrder.orderDate.toString(),
                        value: DateFormat(US_DATE_FORMAT).format(DateTime.parse(
                            widget.purchaseOrder.orderDate.toString())),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Delivery Date',
                        //  value: purchaseOrder.deliveryDate.toString(),
                        value: DateFormat(US_DATE_FORMAT).format(DateTime.parse(
                            widget.purchaseOrder.deliveryDate.toString())),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Vender Name',
                        value: widget.purchaseOrder.vendorName.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Ship To',
                        value: widget.purchaseOrder.shipTo.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Ship Via',
                        value: widget.purchaseOrder.shipVia.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Term',
                        value: widget.purchaseOrder.term.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Order By',
                        value: widget.purchaseOrder.orderBy.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Confirm With',
                        value: widget.purchaseOrder.confirmWith.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Placed Via',
                        value: widget.purchaseOrder.placedVia.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      // ListTileItem(
                      //   label: 'Created By',
                      //   value: purchaseOrder.createdBy.toString(),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                      //   child: Divider(),
                      // ),
                      // ListTileItem(
                      //   label: 'Updated By',
                      //   value: purchaseOrder.updatedBy.toString(),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                      //   child: Divider(),
                      // ),
                      // ListTileItem(
                      //   label: 'Deleted At',
                      //   value: purchaseOrder.deletedAt.toString(),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                      //   child: Divider(),
                      // ),
                      // ListTileItem(
                      //   label: 'Deleted By',
                      //   value: purchaseOrder.deletedBy.toString(),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                      //   child: Divider(),
                      // ),
                      ListTileItem(
                        label: 'Created At',
                        value: widget.purchaseOrder.createdAt.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      // ListTileItem(
                      //   label: 'Updated At',
                      //   value: purchaseOrder.updatedAt.toString(),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                      //   child: Divider(),
                      // ),
                      ListTileItem(
                        label: 'Company',
                        value: widget.purchaseOrder.company!.name.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'Vendor',
                        value: widget.purchaseOrder.vendorName.toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                      ListTileItem(
                        label: 'First Name',
                        value: widget.purchaseOrder.firstName!.firstName
                            .toString(),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        child: Divider(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Container(
          //     margin: EdgeInsets.symmetric(horizontal: 20),
          //     width: MediaQuery.of(context).size.width,
          //     child: ElevatedButton(
          //         style: ButtonStyle(
          //           backgroundColor: MaterialStatePropertyAll(Colors.blue),
          //           foregroundColor: MaterialStatePropertyAll(Colors.white),
          //         ),
          //         onPressed: () {},
          //         child: Text('Recieved')))

          isApiLoading
              ? const Column(
                  children: [
                    SizedBox(
                      height: 70,
                    ),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
              : Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView(
                    //  margin: const EdgeInsets.all(21),
                    //             width: MediaQuery.of(context).size.width,
                    //             // height: MediaQuery.of(context).size.height * 0.74,
                    //             height: MediaQuery.of(context).size.height * 0.5,
                    //             child: Card(
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(4),
                    //               ),
                    //               child: Scrollbar(
                    //                 radius: const Radius.circular(33),

                    //                 thumbVisibility: true,

                    children: [
                      for (int i = 0;
                          i < purchaseOrderItemsList.length;
                          i++) ...{
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 7),
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            child: Column(
                              children: [
                                // Text(purchaseOrderItemsList[i].id.toString()),
                                ListTileItem(
                                    label: 'ID',
                                    value: purchaseOrderItemsList[i]
                                        .id
                                        .toString()),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 20),
                                  child: Divider(),
                                ),

                                ListTileItem(
                                    label: 'PO ID',
                                    value: purchaseOrderItemsList[i]
                                        .poId
                                        .toString()),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 20),
                                  child: Divider(),
                                ),

                                ListTileItem(
                                    label: 'Inventory Item',
                                    value: purchaseOrderItemsList[i]
                                        .inventoryItem
                                        .toString()),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 20),
                                  child: Divider(),
                                ),

                                ListTileItem(
                                    label: 'Quantity',
                                    value: purchaseOrderItemsList[i]
                                        .quantity
                                        .toString()),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 20),
                                  child: Divider(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      },
                    ],
                  ),
                ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50.0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 23),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                )
              ]),
              child: ElevatedButton(
                onPressed: () async {
                  final isRecievied = await changePurchaseOrderStatusByID(
                      id: widget.purchaseOrder.id!);

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'Your Recieved Status',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(isRecievied
                            ? 'Purchase order successfully recieved'
                            : 'Failed to purchase order recieved'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Close the dialog
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: const Text("Received",
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ),
          ),
          const SizedBox(height: 11),
        ],
      ),
    );
  }

  Padding ListTileItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
          if (value.length > 25) ...{
            const Spacer(),
          } else ...{
            const SizedBox(),
          },
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                //    softWrap: true,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

AppBar _buildAppBar(context) {
  return AppBar(
    backgroundColor: Colors.white,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const InventoryList(),
        //   ),
        // );
      },
    ),
    title: FutureBuilder<String?>(
      future: getStringFromSF(BL_USER_FULL_NAME),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          // String? title = snapshot.data;
          return const Text(
            "Purchase Order Detail",
            style: TextStyle(
              color: Color(0xff1E2022),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          );
        } else if (snapshot.hasError) {
          // Handle the error case
          return Text('Error: ${snapshot.error}');
        } else {
          // Display a loading indicator while waiting for the data
          return const CircularProgressIndicator();
        }
      },
    ),
    actions: [
      const Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Stack(
              children: [
                // InkWell(
                //   onTap: () {
                //     if (_blShowNotificationsList) {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => const NotificationsScreen()),
                //       );
                //     } else {
                //       showToast(
                //           "You do not have permission to see notifications.");
                //     }
                //   },
                //   child: Image.asset(
                //     "assets/images/ic_bell.png",
                //     width: 32,
                //     height: 32,
                //   ),
                // ),
                // Positioned(
                //   top: 5,
                //   right: 0,
                //   child: Container(
                //     padding: const EdgeInsets.all(5),
                //     decoration: BoxDecoration(
                //       color: Colors.red,
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const ProfileScreen()),
          //     );
          //   },
          //   child: const Padding(
          //     padding: EdgeInsets.only(right: 10.0, left: 5.0),
          //     child: CircleAvatar(
          //       backgroundImage: AssetImage('assets/images/ic_profile.png'),
          //       radius: 15,
          //     ),
          //   ),
          // ),
        ],
      )
    ],
  );
}
