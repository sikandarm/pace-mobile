import 'package:com_a3_pace/screens/purchase_order.dart';
import 'package:com_a3_pace/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/purchase_order_list.dart';

class PurchaseOrderDetailScreen extends StatelessWidget {
  const PurchaseOrderDetailScreen({super.key, required this.purchaseOrder});
  static const routeName = '/purchase-order-detail-screen';
  final PurchaseOrders purchaseOrder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            ListTileItem(
              label: 'ID',
              value: purchaseOrder.id.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Company Name',
              value: purchaseOrder.companyName.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Address',
              value: purchaseOrder.address.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Phone',
              value: purchaseOrder.phone.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Fax',
              value: purchaseOrder.fax.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Email',
              value: purchaseOrder.email.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Status',
              value: purchaseOrder.status.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'User ID',
              value: purchaseOrder.userId.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'PO Number',
              value: purchaseOrder.poNumber.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Order Date',
              // value: purchaseOrder.orderDate.toString(),
              value: DateFormat(US_DATE_FORMAT)
                  .format(DateTime.parse(purchaseOrder.orderDate.toString())),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Delivery Date',
              //  value: purchaseOrder.deliveryDate.toString(),
              value: DateFormat(US_DATE_FORMAT).format(
                  DateTime.parse(purchaseOrder.deliveryDate.toString())),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Vender Name',
              value: purchaseOrder.vendorName.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Ship To',
              value: purchaseOrder.shipTo.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Ship Via',
              value: purchaseOrder.shipVia.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Term',
              value: purchaseOrder.term.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Order By',
              value: purchaseOrder.orderBy.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Confirm With',
              value: purchaseOrder.confirmWith.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Placed Via',
              value: purchaseOrder.placedVia.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Created By',
              value: purchaseOrder.createdBy.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Updated By',
              value: purchaseOrder.updatedBy.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Deleted At',
              value: purchaseOrder.deletedAt.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Deleted By',
              value: purchaseOrder.deletedBy.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Created At',
              value: purchaseOrder.createdAt.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Updated At',
              value: purchaseOrder.updatedAt.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Company',
              value: purchaseOrder.company.name.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'Vendor',
              value: purchaseOrder.vendorName.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
            ListTileItem(
              label: 'First Name',
              value: purchaseOrder.firstName.firstName.toString(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: Divider(),
            ),
          ],
        ),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
          if (value.length > 25) ...{
            Spacer(),
          } else ...{
            SizedBox(),
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
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
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
