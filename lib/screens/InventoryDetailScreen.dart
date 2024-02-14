import 'package:adaptive_theme/adaptive_theme.dart';
//import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/inventory_detail_service.dart';
import '../utils/constants.dart';
import 'InventoryList.dart';
import 'ProfileScreen.dart';
import 'notification.dart';

class InventoryDetailScreen extends StatefulWidget {
  final int? itemId;

  const InventoryDetailScreen({Key? key, required this.itemId})
      : super(key: key);

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailState();
}

bool _blShowNotificationsList = false;
bool blShowProfile = false;

class _InventoryDetailState extends State<InventoryDetailScreen> {
  Future<List<InventoryDetailModel>> _futureTask = Future.value([]);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getProfileImageToSharedPrefs();
    FirebaseMessaging.onMessage.listen((event) {
      hasNewNotifiaction = true;
      setState(() {});
    });

    super.initState();
    _futureTask = fetchInventoryDetail(widget.itemId!);

    checkPermissionAndUpdateBool("view_notifications", (localBool) {
      _blShowNotificationsList = localBool;
    });

    checkPermissionAndUpdateBool("view_profile", (localBool) {
      blShowProfile = localBool;
    });
  }

  void checkPermissionAndUpdateBool(
      String permValue, Function(bool) boolUpdater) async {
    var localBool = await hasPermission(permValue);

    setState(() {
      boolUpdater(localBool);
    });
  }

  String? userProfileImage;

  Future<void> getProfileImageToSharedPrefs() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    userProfileImage =
        await sharedPrefs.getString(BL_USER_GOOGLE_OR_FACEBOOK_IMAGE);
    print('user profile image: $userProfileImage');
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
      key: scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(
            context,
            scaffoldKey,
            userProfileImage,
            isTablet,
          ),
          Expanded(
            child: FutureBuilder<List<InventoryDetailModel>>(
              future: _futureTask,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(
                    child: Text("Error : ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No tasks found"),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final tasks = snapshot.data![index];

                      return TaskDetailWidget(
                        id: tasks.id,
                        ediStdNomenclature: tasks.ediStdNomenclature,
                        aiscManualLabel: tasks.aiscManualLabel,
                        shape: tasks.shape,
                        weight: tasks.weight,
                        depth: tasks.depth,
                        grade: tasks.grade,
                        poNumber: tasks.poNumber,
                        heatNumber: tasks.heatNumber,
                        orderArrivedInFull: tasks.orderArrivedInFull,
                        orderArrivedCMTR: tasks.orderArrivedCMTR,
                        itemType: tasks.itemType,
                        lengthReceivedFoot: tasks.lengthReceivedFoot,
                        lengthReceivedInch: tasks.lengthReceivedInch,
                        quantity: tasks.quantity,
                        poPulledFromNumber: tasks.poPulledFromNumber,
                        lengthUsedFoot: tasks.lengthUsedFoot,
                        lengthUsedInch: tasks.lengthUsedInch,
                        lengthRemainingFoot: tasks.lengthRemainingFoot,
                        lengthRemainingInch: tasks.lengthRemainingInch,
                        createdAt: tasks.createdAt,
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildAppBar(context, GlobalKey<ScaffoldState> scaffoldKey,
    String? userProfileImage, bool isTablet) {
  return AppBar(
    // backgroundColor: Colors.white,
    backgroundColor: Colors.transparent,

    leading: IconButton(
      icon: Icon(
        Icons.arrow_back,
        // color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
        //     ? Colors.white
        //     : Colors.black,
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const InventoryList(),
          ),
        );
      },
    ),
    title: FutureBuilder<String?>(
      future: getStringFromSF(BL_USER_FULL_NAME),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          // String? title = snapshot.data;
          return Text(
            "Inventory Detail",
            style: TextStyle(
              // color: Color(0xff1E2022),
              // color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
              //     ? Colors.white
              //     : Colors.black,

              fontWeight: FontWeight.bold,
              fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
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
          Visibility(
            visible: _blShowNotificationsList,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      hasNewNotifiaction = false;
                      if (_blShowNotificationsList) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationsScreen()),
                        );
                      } else {
                        showToast(
                            "You do not have permission to see notifications.");
                      }
                    },
                    child: Image.asset(
                      "assets/images/ic_bell.png",
                      width: isTablet ? 45 : 32,
                      height: isTablet ? 45 : 32,
                      color: AdaptiveTheme.of(context).mode ==
                              AdaptiveThemeMode.light
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  hasNewNotifiaction
                      ? Positioned(
                          top: 5,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
          Visibility(
            visible: blShowProfile,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(right: 10.0, left: 5.0),
                child: CircleAvatar(
                  backgroundImage: userProfileImage == null
                      ? AssetImage('assets/images/ic_profile.png')
                      : NetworkImage(userProfileImage) as ImageProvider,
                  radius: isTablet ? 25 : 15,
                ),
              ),
            ),
          ),
        ],
      )
    ],
  );
}

class TaskDetailWidget extends StatefulWidget {
  final int? id;
  final String? ediStdNomenclature;
  final String? aiscManualLabel;
  final String? shape;
  final String? weight;
  final String? depth;
  final String? grade;
  final String? poNumber;
  final String? heatNumber;
  final bool? orderArrivedInFull;
  final bool? orderArrivedCMTR;
  final String? itemType;
  final int? lengthReceivedFoot;
  final int? lengthReceivedInch;
  final int? quantity;
  final String? poPulledFromNumber;
  final int? lengthUsedFoot;
  final int? lengthUsedInch;
  final int? lengthRemainingFoot;
  final int? lengthRemainingInch;
  final DateTime? createdAt;

  const TaskDetailWidget({
    Key? key,
    this.id,
    this.ediStdNomenclature,
    this.aiscManualLabel,
    this.shape,
    this.weight,
    this.depth,
    this.grade,
    this.poNumber,
    this.heatNumber,
    this.orderArrivedInFull,
    this.orderArrivedCMTR,
    this.itemType,
    this.lengthReceivedFoot,
    this.lengthReceivedInch,
    this.quantity,
    this.poPulledFromNumber,
    this.lengthUsedFoot,
    this.lengthUsedInch,
    this.lengthRemainingFoot,
    this.lengthRemainingInch,
    this.createdAt,
  }) : super(key: key);

  @override
  State<TaskDetailWidget> createState() => _TaskDetailWidgetState();
}

class _TaskDetailWidgetState extends State<TaskDetailWidget> {
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
    return GestureDetector(
      onTap: () {
        // Navigate to TaskDetail screen
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => TaskDetail(taskId: taskId),
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: isTablet ? 11 : 0,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shape',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 27 : 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.shape!,
                        style: TextStyle(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.grey[350]
                              : Colors.grey[600],
                          fontSize: isTablet ? 27 : 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weight',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 27 : 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.weight!,
                        style: TextStyle(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.grey[350]
                              : Colors.grey[600],
                          fontSize: isTablet ? 27 : 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Depth',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 27 : 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.depth!,
                        style: TextStyle(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.grey[350]
                              : Colors.grey[600],
                          fontSize: isTablet ? 27 : 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grade',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 27 : 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.grade!,
                        style: TextStyle(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.grey[350]
                              : Colors.grey[600],
                          fontSize: isTablet ? 27 : 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            buildGradeRow("PO#", widget.poNumber!, isTablet),
            buildGradeRow("Heat#", widget.heatNumber!, isTablet),
            buildGradeRow("Order Arrived in Full",
                (widget.orderArrivedInFull!) ? "Yes" : "No", isTablet),
            buildGradeRow("Order Arrived in CMTR",
                (widget.orderArrivedCMTR!) ? "Yes" : "No", isTablet),
            buildGradeRow("Stock/Job", widget.itemType!, isTablet),
            buildGradeRow(
                "Length Received",
                "${widget.lengthReceivedFoot}ft "
                    "${widget.lengthReceivedInch}in",
                isTablet),
            buildGradeRow("Quantity", widget.quantity.toString(), isTablet),
            buildGradeRow(
                "PO# Pulled From", widget.poPulledFromNumber!, isTablet),
            buildGradeRow(
                "Length Used",
                "${widget.lengthUsedFoot}ft " "${widget.lengthUsedInch}in",
                isTablet),
            buildGradeRow(
                "Length Remaining in Stock",
                "${widget.lengthRemainingFoot}ft "
                    "${widget.lengthRemainingInch}in",
                isTablet),
          ],
        ),
      ),
    );
  }

  Widget buildGradeRow(String heading, String value, bool isTablet) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                heading,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 27 : 15.0,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: AdaptiveTheme.of(context).mode.isDark
                          ? Colors.grey[350]
                          : Colors.grey[600],
                      fontSize: isTablet ? 27 : 15.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
