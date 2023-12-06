import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/task_detail_service.dart';
import '../utils/constants.dart';
import 'ProfileScreen.dart';
import 'notification.dart';
import 'task_approve_reject.dart';

bool _blCollaborate = false;
bool _blShowNotificationsList = false;
bool _blApprovedTask = false;
bool _blSelfAssignATask = false;

class TaskDetail extends StatefulWidget {
  final int taskId;

  // const TaskList({Key? key}) : super(key: key);
  const TaskDetail({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  Future<List<TaskDetailObj>> _futureTask = Future.value([]);

  @override
  void initState() {
    super.initState();
    _futureTask = fetchTaskDetail(widget.taskId);

    checkPermissionAndUpdateBool("collaborate_on_microsoft_whiteboard",
        (localBool) {
      _blCollaborate = localBool;
    });

    checkPermissionAndUpdateBool("view_notifications", (localBool) {
      _blShowNotificationsList = localBool;
    });
    checkPermissionAndUpdateBool("self_assign_a_task", (localBool) {
      _blSelfAssignATask = localBool;
    });
    checkPermissionAndUpdateBool("review_tasks", (localBool) {
      _blApprovedTask = localBool;
    });
  }

  void checkPermissionAndUpdateBool(
      String permValue, Function(bool) boolUpdater) async {
    var localBool = await hasPermission(permValue);

    setState(() {
      boolUpdater(localBool);
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
            // Navigate to the last screen in the stack
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: const Text(
          "Task Detail",
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
                    Positioned(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 10.0, left: 5.0),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/ic_profile.png'),
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
          Expanded(
            child: FutureBuilder<List<TaskDetailObj>>(
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
                        pmkNumber: tasks.pmkNumber,
                        heatNo: tasks.heatNo,
                        jobId: tasks.jobId,
                        userId: tasks.userId,
                        description: tasks.description,
                        startedAt: tasks.startedAt,
                        completedAt: tasks.completedAt,
                        approvedAt: tasks.approvedAt,
                        approvedBy: tasks.approvedBy,
                        status: tasks.status,
                        comments: tasks.comments,
                        imageUrl: tasks.image,
                        projectManager: tasks.projectManager,
                        QCI: tasks.QCI,
                        fitter: tasks.fitter,
                        welder: tasks.welder,
                        painter: tasks.painter,
                        foreman: tasks.foreman,
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

class TaskDetailWidget extends StatelessWidget {
  final int id;
  final String? pmkNumber;
  final String? heatNo;
  final int? jobId;
  final int? userId;
  final String? description;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? status;
  final String? comments;
  final String? imageUrl;
  final String? projectManager;
  final String? QCI;
  final String? fitter;
  final String? welder;
  final String? painter;
  final String? foreman;

  Future<void> callUpdateTask(BuildContext context, int taskId, int jobId,
      DateTime startDate, String status) async {
    try {
      print('in try');
      int? userId = await getIntFromSF('UserId');

      // ignore: unnecessary_null_comparison
      if (userId != null) {
        var request =
            http.MultipartRequest('PUT', Uri.parse('$BASE_URL/task/$taskId'));
        request.fields['userId'] = userId.toString();
        request.fields['jobId'] = jobId.toString();
        request.fields['status'] = status;

        String isoDate = startDate.toIso8601String();
        // String isoDate = utcDateTime.toIso8601String().substring(0, 23);

        print('isoDate:' + isoDate);
        if (status == "to_inspect") {
          request.fields['completedAt'] = isoDate;
        }
        if (status == "in_process") {
          request.fields['startedAt'] = isoDate;
        }

        print('isoDate: $isoDate');

        var response = await request.send();
        var responseString = await response.stream.bytesToString();
        // print(responseString);
        Map<String, dynamic> jsonMap = jsonDecode(responseString);

        // print(response.body);
        // Map<String, dynamic> jsonMap = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(jsonMap['message'])));

          // Navigate to the last screen in the stack
          // ignore: use_build_context_synchronously
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(jsonMap['message'])));
        }
      } else {
        // Handle the case where userId is not available
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User ID not found')));
      }
    } catch (e) {
      print('e: ' + e.toString());
    }
  }

  const TaskDetailWidget({
    Key? key,
    required this.id,
    required this.pmkNumber,
    required this.heatNo,
    required this.jobId,
    required this.userId,
    required this.description,
    required this.startedAt,
    required this.completedAt,
    required this.approvedAt,
    required this.approvedBy,
    required this.status,
    required this.comments,
    required this.imageUrl,
    required this.projectManager,
    required this.QCI,
    required this.fitter,
    required this.welder,
    required this.painter,
    required this.foreman,
  }) : super(key: key);

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pmk# $pmkNumber",
              style: const TextStyle(
                // color: Color(0xFF1E2022),
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Heat No.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        heatNo!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15.0,
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
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15.0,
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
                  const Text(
                    'Start Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        startedAt == null
                            ? "N/A"
                            : DateFormat(US_DATE_FORMAT).format(startedAt!),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15.0,
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
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        setStatusText(status!),
                        style: TextStyle(
                          color: setCardBorderColor(status!),
                          fontSize: 15.0,
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
            buildRolesFields("Project Manager", projectManager!),
            drawLine(),
            const SizedBox(height: 10),
            buildRolesFields("QCI", QCI!),
            drawLine(),
            const SizedBox(height: 10),
            buildRolesFields("Fitter", fitter!),
            drawLine(),
            const SizedBox(height: 10),
            buildRolesFields("Welder", welder!),
            drawLine(),
            const SizedBox(height: 10),
            buildRolesFields("Painter", painter!),
            drawLine(),
            const SizedBox(height: 10),
            buildRolesFields("Foreman", foreman!),
            drawLine(),
            const SizedBox(height: 10),
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Center(
                child: GestureDetector(
                  onTap: () {
                    downloadImage(imageUrl!, "TaskDiagram.png");

                    // _openExternalLink(
                    //     "https://play.google.com/store/apps/details?id=com.microsoft.whiteboard.publicpreview");
                  },

                  // onTap: () => _openExternalLink(
                  //     "https://play.google.com/store/apps/details?id=com.microsoft.whiteboard.publicpreview"),
                  child: Image.network(
                    imageUrl!,
                    width: 300.0,
                    height: 300.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  )
                ]),
                child: _blApprovedTask && _blSelfAssignATask
                    ? ElevatedButton(
                        onPressed: () => buttonAction(context),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        child: Text(
                          setButtonText(status!, userId!),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : (_blSelfAssignATask &&
                            (status == "in_process" || status == "pending"))
                        ? ElevatedButton(
                            onPressed: () => buttonAction(context),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            child: Text(
                              setSelfApprovedText(status!, userId!),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : _blApprovedTask && status == "to_inspect"
                            ? ElevatedButton(
                                onPressed: () => buttonAction(context),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  setInspectionText(status!, userId!),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buttonAction(BuildContext context) async {
    // if same user is opening a task
    if (status == "pending") {
      // ignore: use_build_context_synchronously
      callUpdateTask(context, id, jobId!, DateTime.now(), "in_process");
    } else if (status == "in_process") {
      // ignore: use_build_context_synchronously
      callUpdateTask(context, id, jobId!, DateTime.now(), "to_inspect");
    } else if (status == "to_inspect") {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskApproveRejectScreen(
            taskId: id,
            jobId: jobId,
            startedAt: startedAt,
          ),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      callUpdateTask(context, id, jobId!, DateTime.now(), "approved");
    }
  }

  Widget buildRolesFields(String fieldName, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            fieldName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget drawLine() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  void _openExternalLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String setButtonText(String? value, int? userIdValue) {
    if (userIdValue == userId) {
      // if same user
      if (value == "pending") {
        return 'Pick Task';
      } else if (value == "in_process") {
        return 'Complete';
      } else if (value == "to_inspect") {
        return 'Approve';
      } else {
        return 'Reject';
      }
    } else {
      // If not the same user
      if (value == "pending") {
        return 'Pick Task';
      }
    }

    // Add a default return statement to handle all other cases
    return '';
  }

  String setSelfApprovedText(String? value, int? userIdValue) {
    if (userIdValue == userId) {
      // if same user
      if (value == "pending") {
        return 'Pick Task';
      } else if (value == "in_process") {
        return 'Complete';
      }
    } else {
      // If not the same user
      if (value == "pending") {
        return 'Pick Task';
      }
    }

    // Add a default return statement to handle all other cases
    return '';
  }

  String setInspectionText(String? value, int? userIdValue) {
    if (userIdValue == userId) {
      // if same user
      if (value == "to_inspect") {
        return 'Approve';
      } else {
        return 'Reject';
      }
    } else {
      // If not the same user
      if (value == "pending") {
        return 'Pick Task';
      }
    }

    // Add a default return statement to handle all other cases
    return '';
  }
  // bool showHideButton(String? value, int? userIdValue) {
  //   if (value == "in_process" && userIdValue != 0 && userIdValue != userId) {
  //     return false; // Disable button
  //   } else if (value == "approved" && userIdValue != userId) {
  //     return false;
  //   } else if (value == "rejected" && userIdValue != userId) {
  //     return false;
  //   } else if (value == "approved" || value == "rejected") {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  Future<void> downloadImage(String imageUrl, String fileName) async {
    debugPrint(imageUrl.replaceAll(' ', '%20'));
    debugPrint(fileName);

    var dio = Dio();

    Directory? externalDir = await getExternalStorageDirectory();

    if (externalDir != null) {
      // Ensure the file name has a valid image file extension, like .jpg or .png
      if (!fileName.toLowerCase().endsWith('.jpg') &&
          !fileName.toLowerCase().endsWith('.png')) {
        debugPrint('Invalid image file extension.');
        return;
      }

      // String filePath = '${externalDir.path}/$fileName';
      String filePath = '/storage/emulated/0/DCIM/$fileName';

      await dio.download(
        imageUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Calculate the download percentage
            double percentage = (received / total) * 100;
            debugPrint('Downloaded: ${percentage.toStringAsFixed(2)}%');

            if (percentage == 100) {
              // debugPrint('File download complete');
              showToast('File download complete');

              if (_blCollaborate) {
                _openExternalLink(
                    "https://play.google.com/store/apps/details?id=com.microsoft.whiteboard.publicpreview");
              }
            }
          }
        },
      );
    } else {
      debugPrint('External storage directory not available.');
    }
  }
}
