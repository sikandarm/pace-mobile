import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/get_shared_car.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'ProfileScreen.dart';
import 'notification.dart';

class SharedCARList extends StatefulWidget {
  const SharedCARList({Key? key}) : super(key: key);

  @override
  State<SharedCARList> createState() => _SharedListState();
}

bool _blShowNotificationsList = false;
bool _blShowProfile = false;

class _SharedListState extends State<SharedCARList> {
  Future<List<CAReportModel>> _futureList = Future.value([]);

  @override
  void initState() {
    getProfileImageToSharedPrefs();
    FirebaseMessaging.onMessage.listen((event) {
      hasNewNotifiaction = true;
      setState(() {});
    });
    super.initState();
    _futureList = fetchSharedCARList();

    checkPermissionAndUpdateBool("view_notifications", (localBool) {
      _blShowNotificationsList = localBool;
    });

    checkPermissionAndUpdateBool("view_profile", (localBool) {
      _blShowProfile = localBool;
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
    print('user profile image: ' + userProfileImage.toString());
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
          "Shared CA Reports",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              Padding(
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
                        width: 32,
                        height: 32,
                      ),
                    ),
                    !hasNewNotifiaction
                        ? SizedBox()
                        : Positioned(
                            top: 5,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_blShowProfile) {
                    showToast('You do not have permissions.');
                    return;
                  }
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
                        : NetworkImage(userProfileImage!) as ImageProvider,
                    radius: 15,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const TaskListHeader(
          //   title: "Shared CA Reports",
          // ),
          Expanded(
            child: FutureBuilder<List<CAReportModel>>(
              future: _futureList,
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
                    child: Text("No record found"),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];

                      return CARListItemWidget(
                        id: item.id,
                        originatorName: item.originatorName,
                        description: item.description!,
                        disposition: item.disposition!,
                        caReportDate: item.caReportDate,
                      );
                    },
                  );
                }
              },
            ),

            // chi
          ),
        ],
      ),
    );
  }
}

class TaskListHeader extends StatelessWidget {
  final String title;

  const TaskListHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CARListItemWidget extends StatelessWidget {
  final int? id;
  final String? originatorName;
  final String? description;
  final String? disposition;
  final DateTime? caReportDate;

  const CARListItemWidget({
    super.key,
    this.id,
    this.originatorName,
    this.description,
    required this.disposition,
    required this.caReportDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => InventoryDetailScreen(itemId: id),
        //   ),
        // );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "#$id - ${originatorName!}",
                    style: const TextStyle(
                      color: Color(0xFF1E2022),
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    DateFormat(US_DATE_FORMAT).format(caReportDate!),
                    style: const TextStyle(
                      fontSize: 11.0,
                      color: Color(0xFF77838F),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    disposition!,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              Text(
                description!,
                style: const TextStyle(
                  // color: getProgressColor(status),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
