import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/get_all_notifications.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'ProfileScreen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationsScreen> {
  Future<List<NotificationModel>> _futureList = Future.value([]);

  final groupedNotifications = <String, List<NotificationModel>>{};
  final today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _futureList = fetchAllCNotifications();
    groupNotificationsByDate();
  }

  void groupNotificationsByDate() {
    final yesterday = today.subtract(const Duration(days: 1));
    _futureList.then((notificationList) {
      for (final notification in notificationList) {
        final notificationDate = notification.updatedAt;
        final isToday = today.year == notificationDate?.year &&
            today.month == notificationDate?.month &&
            today.day == notificationDate?.day;
        final isYesterday = yesterday.year == notificationDate?.year &&
            yesterday.month == notificationDate?.month &&
            yesterday.day == notificationDate?.day;
        final headerText = isToday
            ? "Today"
            : isYesterday
                ? "Yesterday"
                : DateFormat("MMM dd, yyyy").format(notificationDate!);
        groupedNotifications
            .putIfAbsent(headerText, () => [])
            .add(notification);
      }
      // Call setState to trigger a rebuild of the UI with the updated groupedNotifications
      setState(() {});
    });
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
          "Notifications",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/ic_profile.png'),
                radius: 15,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<NotificationModel>>(
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
                      itemCount: groupedNotifications.length,
                      itemBuilder: (context, index) {
                        final headerText =
                            groupedNotifications.keys.elementAt(index);
                        final notifications = groupedNotifications[headerText]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                headerText,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: notifications.length,
                              itemBuilder: (context, notificationIndex) {
                                final notification =
                                    notifications[notificationIndex];
                                return ListItemWidget(
                                  id: notification.id,
                                  title: notification.title,
                                  body: notification.body!,
                                  time: notification.updatedAt,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListItemWidget extends StatelessWidget {
  final int? id;
  final String? title;
  final String? body;
  final DateTime? time;

  const ListItemWidget({
    super.key,
    this.id,
    this.title,
    this.body,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // if (id! > 0 && status == "approved" || status == "rejected") {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => CARDetail(carId: id!),
        //     ),
        //   );
        // }
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor:
                    Colors.blue, // Set the background color to blue
                radius: 20.0,
                child: Icon(
                  Icons.notifications_on_outlined,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
              const SizedBox(
                  width:
                      10.0), // Adjust the space between the image and the text if needed
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      body.toString(),
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Color(0xFF1E2022),
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 3, // Allow unlimited lines
                      overflow: TextOverflow
                          .clip, // or TextOverflow.ellipsis for '...' at the end
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      DateFormat(NOTIFICATION_DATE_FORMAT).format(time!),
                      style: const TextStyle(
                        color: Color(0xFF77838F),
                        fontSize: 12.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
