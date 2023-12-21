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
  Future<NotificationModel> _futureList = Future.value(NotificationModel());

  final groupedNotifications = <String, NotificationModel>{};
  final today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _futureList = fetchAllNotifications();
    groupNotificationsByDate();
  }

  void groupNotificationsByDate() {
    final yesterday = today.subtract(const Duration(days: 1));
    _futureList.then((notificationList) {
      for (final notification in notificationList.data!.notifications!) {
        final notificationDate = notification.updatedAt;

        print('date: ' + notificationDate.toString());

        final isToday = today.year == extractYear(notificationDate!) &&
            today.month == extractMonth(notificationDate) &&
            today.day == extractDay(notificationDate);
        final isYesterday = yesterday.year == extractYear(notificationDate!) &&
            yesterday.month == extractMonth(notificationDate) &&
            yesterday.day == extractDay(notificationDate);
        final headerText = isToday
            ? "Today"
            : isYesterday
            ? "Yesterday"
            : DateFormat("MMM dd, yyyy")
            .format(DateTime.parse(notificationDate!));
        groupedNotifications.putIfAbsent(headerText, () => NotificationModel());
      }
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
        child: FutureBuilder<NotificationModel>(
          future: _futureList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                child: Text("Error : ${snapshot.error}"),
              );
            } else if (!snapshot.hasData ||
                snapshot.data!.data!.notifications!.isEmpty) {
              return const Center(
                child: Text("No record found"),
              );
            } else {
              return ListView.builder(
                itemCount: groupedNotifications.length,
                itemBuilder: (context, index) {
                  final headerText = groupedNotifications.keys.elementAt(index);
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
                      // Replace the inner ListView.builder with a Column
                      Column(
                        children: snapshot.data!.data!.notifications!
                            .map((notification) => ListItemWidget(
                          id: notification.id,
                          title: notification.title,
                          body: notification.body!,
                          time: DateTime.parse(notification.updatedAt!),
                        ))
                            .toList(),
                      ),
                    ],
                  );
                },
              );
            }
          },
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
    Key? key,
    this.id,
    this.title,
    this.body,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle onTap if needed
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 20.0,
                child: Icon(
                  Icons.notifications_on_outlined,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 10.0),
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
                      maxLines: 3,
                      overflow: TextOverflow.clip,
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

// Helper functions to extract year, month, and day
int extractYear(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  return dateTime.year;
}

int extractMonth(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  return dateTime.month;
}

int extractDay(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  return dateTime.day;
}
