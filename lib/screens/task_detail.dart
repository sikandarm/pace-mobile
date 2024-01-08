import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/check_task_play_or_pause_status.dart';
import '../services/play_pause_task.dart';
import '../services/task_detail_service.dart';
import '../utils/constants.dart';
import 'ProfileScreen.dart';
import 'display_full_screen_image.dart';
import 'notification.dart';
import 'task_approve_reject.dart';
import 'task_logs_screens.dart';
import 'view_contacts_screen.dart';

bool _blCollaborate = false;
bool _blShowNotificationsList = false;
bool _blApprovedTask = false;
bool _blSelfAssignATask = false;
bool _b1ShowProfile = false;

class TaskDetail extends StatefulWidget {
  final int taskId;

  // const TaskList({Key? key}) : super(key: key);
  const TaskDetail({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  // final formKey = GlobalKey<FormState>();
  // final commentController = TextEditingController();
  String? taskStatus;
  List<TaskDetailObj> taskDetailObj = [
    TaskDetailObj(
      id: 0,
      pmkNumber: null,
      heatNo: null,
      jobId: null,
      userId: null,
      description: null,
      startedAt: null,
      completedAt: null,
      approvedAt: null,
      approvedBy: null,
      status: null,
      comments: null,
      image: null,
      projectManager: null,
      QCI: null,
      fitter: null,
      welder: null,
      painter: null,
      foreman: null,
    )
  ];
  Future<List<TaskDetailObj>> _futureTask = Future.value([]);
  PlayAndPauseTask playAndPausetask = PlayAndPauseTask(
    id: null,
    taskId: null,
    breakStart: null,
    comment: null,
    // createdBy: null,
    // updatedAt: null,
    // createdAt: null,
  );

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      hasNewNotifiaction = true;
      setState(() {});
    });
    super.initState();
    _futureTask = fetchTaskDetail(widget.taskId);
    callApiMethods();
    checkPermissionAndUpdateBool("view_profile", (localBool) {
      _b1ShowProfile = localBool;
    });

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

  bool? taskPayOrPauseStatus = null;

  Future<void> callApiMethods() async {
    taskPayOrPauseStatus =
        await getTaskPlayOrPauseStatus(taskId: widget.taskId.toString());
    print('init method value taskPayOrPauseStatus: ' +
        taskPayOrPauseStatus.toString());
    taskDetailObj = await _futureTask;
    setState(() {});
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
    return LoaderOverlay(
      child: Scaffold(
        // floatingActionButton: taskDetailObj[0].status != 'in_process'
        //     ? null
        //     : FloatingActionButton.extended(
        //         onPressed: () async {
        //           commentController.clear();

        //           print('Status: ' + taskPayOrPauseStatus.toString());

        //           if (taskPayOrPauseStatus != null &&
        //               taskPayOrPauseStatus == false) {
        //             final dialogResult = await showDialog<bool?>(
        //               context: context,
        //               builder: (BuildContext context) {
        //                 return AlertDialog(
        //                   title: Form(
        //                     //   key: formkeySequence,
        //                     key: formKey,
        //                     child: Column(
        //                       children: [
        //                         const Text(
        //                           'Add a comment',
        //                           style: TextStyle(
        //                             fontSize: 15,
        //                             color: Colors.deepPurple,
        //                             fontWeight: FontWeight.bold,
        //                           ),
        //                         ),
        //                         TextFormField(
        //                           controller: commentController,
        //                           decoration: const InputDecoration(
        //                             hintStyle: TextStyle(fontSize: 13),
        //                             labelText: 'Comment',
        //                             hintText: 'Enter a comment',
        //                           ),
        //                           validator: (value) {
        //                             if (value == null || value.isEmpty) {
        //                               return 'Please enter a comment';
        //                             }

        //                             return null;
        //                           },
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                   actions: [
        //                     TextButton(
        //                       onPressed: () async {
        //                         //  sequenceNameController.clear();
        //                         ScaffoldMessenger.of(context).clearSnackBars();

        //                         final validationResult =
        //                             formKey.currentState!.validate();
        //                         if (!validationResult) {
        //                           return;
        //                         }

        //                         //  Map<String, dynamic> decodedResponse =
        //                         //      jsonDecode(response.body);

        //                         //   sequenceNameController.clear();
        //                         Navigator.of(context).pop(true);
        //                         //        await callApiMethods();
        //                       },
        //                       child: const Text('Add Comment'),
        //                     ),
        //                   ],
        //                 );
        //               },
        //             );

        //             if (dialogResult == true) {
        //               if (!taskPayOrPauseStatus!) {
        //                 final response1 = await playAndPauseTaskApi(
        //                   taskId: widget.taskId.toString(),
        //                   break_start_as_DateTime: DateTime.now().toString(),
        //                   break_end_as_DateTime: null,
        //                   comment: commentController.text.trim(),
        //                 );
        //               } else {
        //                 final response1 = await playAndPauseTaskApi(
        //                   taskId: widget.taskId.toString(),
        //                   break_start_as_DateTime: null,
        //                   break_end_as_DateTime: DateTime.now().toString(),
        //                   comment: commentController.text.trim(),
        //                 );
        //               }
        //               taskPayOrPauseStatus = await getTaskPlayOrPauseStatus(
        //                   taskId: widget.taskId.toString());
        //               setState(() {});
        //               return;
        //               return;
        //             }
        //           } else {
        //             if (!taskPayOrPauseStatus!) {
        //               final response1 = await playAndPauseTaskApi(
        //                 taskId: widget.taskId.toString(),
        //                 break_start_as_DateTime: DateTime.now().toString(),
        //                 break_end_as_DateTime: null,
        //                 comment: commentController.text.trim(),
        //               );
        //             } else {
        //               final response1 = await playAndPauseTaskApi(
        //                 taskId: widget.taskId.toString(),
        //                 break_start_as_DateTime: null,
        //                 break_end_as_DateTime: DateTime.now().toString(),
        //                 comment: commentController.text.trim(),
        //               );
        //             }
        //             taskPayOrPauseStatus = await getTaskPlayOrPauseStatus(
        //                 taskId: widget.taskId.toString());
        //           }

        //           setState(() {});
        //           return;
        //           // PlayAndPauseTask(
        //           //     id: null,
        //           //     taskId: taskId,
        //           //     breakStart: null,
        //           //     comment: 'comment',
        //           //     createdBy: null,
        //           //     updatedAt: null,
        //           //     createdAt: null);

        //           final response1 = await playAndPauseTaskApi(
        //             taskId: widget.taskId.toString(),
        //             break_start_as_DateTime: DateTime.now().toString(),
        //             break_end_as_DateTime: null,
        //             comment: 'a test comment',
        //           );
        //           playAndPausetask = response1;
        //           print('1st Response:' + response1.toJson().toString());

        //           if (response1.id == null &&
        //                   response1.breakStart == null &&
        //                   response1.breakEnd == null &&
        //                   //   response.createdAt == null &&
        //                   response1.comment == null &&
        //                   //  response.createdAt == null &&
        //                   //   response.createdBy == null &&
        //                   response1.taskId == null
        //               // &&
        //               //   response.updatedAt == null &&
        //               //   response.de == null &&
        //               //   response.id == null
        //               ) {
        //             print('here');
        //             final response2 = await playAndPauseTaskApi(
        //               taskId: widget.taskId.toString(),
        //               break_start_as_DateTime: null,
        //               break_end_as_DateTime: DateTime.now().toString(),
        //               comment: 'a test new one comment',
        //             );

        //             playAndPausetask = response2;
        //             print('2nd Response:' + response2.toJson().toString());
        //             //   print('oopos');
        //             //   setState(() {});
        //           }

        //           // final playAndPauseTaskBox = await Hive.openBox('playAndPauseTaskBox');
        //           // await playAndPauseTaskBox.putAll({
        //           //   'break_start': '',
        //           //   'break_end': '',
        //           // });
        //           setState(() {});
        //           print('==================================');
        //           print('======================================');
        //           print('============================================');
        //           setState(() {});
        //         },
        //         label: Text(taskPayOrPauseStatus == false ? 'RESUME' : 'PAUSE'),
        //         icon: Icon(taskPayOrPauseStatus == false
        //             ? Icons.play_arrow
        //             : Icons.pause),
        //         backgroundColor:
        //             taskPayOrPauseStatus == false ? Colors.green : Colors.red,
        //         foregroundColor: Colors.white,
        //       ),
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
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return TaskLogsScreen(
                              taskId: widget.taskId,
                            );
                          },
                        ),
                      );
                    },
                    icon: Icon(Icons.view_kanban_outlined)),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          hasNewNotifiaction = false;
                          setState(() {});
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
                    if (!_b1ShowProfile) {
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
      ),
    );
  }
}

class TaskDetailWidget extends StatefulWidget {
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
  State<TaskDetailWidget> createState() => _TaskDetailWidgetState();
}

class _TaskDetailWidgetState extends State<TaskDetailWidget> {
  final formKey = GlobalKey<FormState>();
  final commentController = TextEditingController();
  Future<List<TaskDetailObj>> _futureTask = Future.value([]);
  PlayAndPauseTask playAndPausetask = PlayAndPauseTask(
    id: null,
    taskId: null,
    breakStart: null,
    comment: null,
    // createdBy: null,
    // updatedAt: null,
    // createdAt: null,
  );

  bool? taskPayOrPauseStatus = null;

  Future<void> callApiMethods() async {
    taskPayOrPauseStatus =
        await getTaskPlayOrPauseStatus(taskId: widget.id.toString());
    print('init method 222 value taskPayOrPauseStatus: ' +
        taskPayOrPauseStatus.toString());
    //  taskDetailObj = await _futureTask;
    setState(() {});
  }

  @override
  void initState() {
    callApiMethods();
    super.initState();
  }

  //////////////////////////////////////////////////////////////////////
  //Future<void> callApiMethod2({required}) async {}

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

        //  print(object)

        var response = await request.send();
        var responseString = await response.stream.bytesToString();
        // print(responseString);
        Map<String, dynamic> jsonMap = jsonDecode(responseString);

        print('jsonMap: ' + jsonMap.toString());

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
              "Pmk# ${widget.pmkNumber}",
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
                        widget.heatNo!,
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
                        widget.description!,
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
                        widget.startedAt == null
                            ? "N/A"
                            : DateFormat(US_DATE_FORMAT)
                                .format(widget.startedAt!),
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
                        setStatusText(widget.status!),
                        style: TextStyle(
                          color: setCardBorderColor(widget.status!),
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
            buildRolesFields("Project Manager", widget.projectManager!),
            drawLine(),
            const SizedBox(height: 10),
            buildRolesFields("QCI", widget.QCI!),
            drawLine(),
            const SizedBox(height: 10),
            buildRolesFields("Fitter", widget.fitter!),
            drawLine(),
            const SizedBox(height: 10),
            buildRolesFields("Welder", widget.welder!),
            drawLine(),
            const SizedBox(height: 10),
            buildRolesFields("Painter", widget.painter!),
            drawLine(),
            const SizedBox(height: 10),
            buildRolesFields("Foreman", widget.foreman!),
            drawLine(),
            SizedBox(
              height: 21,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(33)),
                    child: GestureDetector(
                      //  splashColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewContactsScreen(),
                            ));
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 26,
                        child: Icon(Icons.phone),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(33)),
                    child: GestureDetector(
                      onTap: () async {
                        await downloadImage(
                            widget.imageUrl!, "TaskDiagram.png");
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 26,
                        child: Icon(Icons.download),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(33)),
                    child: GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          _openExternalLink(
                              "https://play.google.com/store/apps/details?id=com.microsoft.whiteboard.publicpreview");
                        } else if (Platform.isIOS) {
                          _openExternalLink(
                              "https://apps.apple.com/us/app/microsoft-whiteboard/id1352499399");
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 26,
                        child: Icon(Icons.edit_note),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
              Center(
                child: GestureDetector(
                  onTap: () {
                    //   downloadImage(widget.imageUrl!, "TaskDiagram.png");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayFullScreenImage(
                              imageUrl: widget.imageUrl!),
                        ));
                    // _openExternalLink(
                    //     "https://play.google.com/store/apps/details?id=com.microsoft.whiteboard.publicpreview");
                  },

                  // onTap: () => _openExternalLink(
                  //     "https://play.google.com/store/apps/details?id=com.microsoft.whiteboard.publicpreview"),
                  // child: Image.network(
                  //   widget.imageUrl!,
                  //   width: 285.0,
                  //   height: 145.0,
                  //   fit: BoxFit.cover,
                  // ),
                  child: Container(
                    width: 285.0,
                    height: 145.0,
                    child: CachedNetworkImage(
                      width: 285.0,
                      height: 145.0,
                      imageUrl: widget.imageUrl!,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                      // placeholder: (context, url) =>
                      //     Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     ElevatedButton(
            //         onPressed: () {
            //           Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => ViewContactsScreen(),
            //               ));
            //         },
            //         child: Text('Call')),
            //     ElevatedButton(
            //         onPressed: () async {
            //           await downloadImage(widget.imageUrl!, "TaskDiagram.png");
            //         },
            //         child: Text('Download')),
            //     ElevatedButton(
            //         onPressed: () async {
            //           if (Platform.isAndroid) {
            //             _openExternalLink(
            //                 "https://play.google.com/store/apps/details?id=com.microsoft.whiteboard.publicpreview");
            //           } else if (Platform.isIOS) {
            //             _openExternalLink(
            //                 "https://apps.apple.com/us/app/microsoft-whiteboard/id1352499399");
            //           }
            //         },
            //         child: Text('Collaborate')),
            //   ],
            // ),
            const SizedBox(height: 20),
            taskPayOrPauseStatus == true &&
                    setButtonText(widget.status!, widget.userId!) == 'Complete'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 130,
                        height: 50.0,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              foregroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.redAccent),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9)))),
                          onPressed: () async {
                            commentController.clear();
                            print('pause button pressed');

                            if (taskPayOrPauseStatus != null &&
                                taskPayOrPauseStatus == false) {
                              final dialogResult = await showDialog<bool?>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Form(
                                      //   key: formkeySequence,
                                      key: formKey,
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Add a comment',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.deepPurple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextFormField(
                                            controller: commentController,
                                            decoration: const InputDecoration(
                                              hintStyle:
                                                  TextStyle(fontSize: 13),
                                              labelText: 'Comment',
                                              hintText: 'Enter a comment',
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter a comment';
                                              }

                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          //  sequenceNameController.clear();
                                          ScaffoldMessenger.of(context)
                                              .clearSnackBars();

                                          final validationResult =
                                              formKey.currentState!.validate();
                                          if (!validationResult) {
                                            return;
                                          }

                                          //  Map<String, dynamic> decodedResponse =
                                          //      jsonDecode(response.body);

                                          //   sequenceNameController.clear();
                                          Navigator.of(context).pop(true);
                                          //        await callApiMethods();
                                        },
                                        child: const Text('Add Comment'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (dialogResult == true) {
                                if (!taskPayOrPauseStatus!) {
                                  final response1 = await playAndPauseTaskApi(
                                    taskId: widget.id.toString(),
                                    break_start_as_DateTime:
                                        DateTime.now().toString(),
                                    break_end_as_DateTime: null,
                                    comment: commentController.text.trim(),
                                    //  comment: '111'
                                  );
                                } else {
                                  final response1 = await playAndPauseTaskApi(
                                      taskId: widget.id.toString(),
                                      break_start_as_DateTime: null,
                                      break_end_as_DateTime:
                                          DateTime.now().toString(),
                                      //     comment: commentController.text.trim(),
                                      comment: '222');
                                }
                                taskPayOrPauseStatus =
                                    await getTaskPlayOrPauseStatus(
                                        taskId: widget.id.toString());
                                setState(() {});
                                return;
                                return;
                              }
                            } else {
                              if (!taskPayOrPauseStatus!) {
                                final response1 = await playAndPauseTaskApi(
                                  taskId: widget.id.toString(),
                                  break_start_as_DateTime:
                                      DateTime.now().toString(),
                                  break_end_as_DateTime: null,
                                  comment: commentController.text.trim(),
                                  // comment: '333',
                                );
                              } else {
                                final response1 = await playAndPauseTaskApi(
                                  taskId: widget.id.toString(),
                                  break_start_as_DateTime: null,
                                  break_end_as_DateTime:
                                      DateTime.now().toString(),
                                  comment: commentController.text.trim(),
                                  //   comment: '444',
                                );
                              }
                              taskPayOrPauseStatus =
                                  await getTaskPlayOrPauseStatus(
                                      taskId: widget.id.toString());
                            }

                            setState(() {});
                            return;
                            // PlayAndPauseTask(
                            //     id: null,
                            //     taskId: taskId,
                            //     breakStart: null,
                            //     comment: 'comment',
                            //     createdBy: null,
                            //     updatedAt: null,
                            //     createdAt: null);
                            //     setState(() {});
                          },
                          child: Text('Pause'),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        height: 50.0,
                        child: Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            )
                          ]),
                          child: _blApprovedTask && _blSelfAssignATask
                              ? ElevatedButton(
                                  onPressed: () =>
                                      buttonAction(context, widget.id),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blue),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    setButtonText(
                                        widget.status!, widget.userId!),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : (_blSelfAssignATask &&
                                      (widget.status == "in_process" ||
                                          widget.status == "pending"))
                                  ? ElevatedButton(
                                      onPressed: () =>
                                          buttonAction(context, widget.id),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.blue),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        setSelfApprovedText(
                                            widget.status!, widget.userId!),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : _blApprovedTask &&
                                          widget.status == "to_inspect"
                                      ? ElevatedButton(
                                          onPressed: () =>
                                              buttonAction(context, widget.id),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.blue),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            setInspectionText(
                                                widget.status!, widget.userId!),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                        ),
                      ),
                    ],
                  )
                : taskPayOrPauseStatus == false &&
                        setButtonText(widget.status!, widget.userId!) ==
                            'Complete'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 130,
                            height: 50.0,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStatePropertyAll(Colors.white),
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.green),
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(9)))),
                              onPressed: () async {
                                commentController.clear();
                                print('resume button pressed');

                                if (taskPayOrPauseStatus != null &&
                                    taskPayOrPauseStatus == false) {
                                  final dialogResult = await showDialog<bool?>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Form(
                                          //   key: formkeySequence,
                                          key: formKey,
                                          child: Column(
                                            children: [
                                              const Text(
                                                'Add a comment',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.deepPurple,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextFormField(
                                                controller: commentController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintStyle:
                                                      TextStyle(fontSize: 13),
                                                  labelText: 'Comment',
                                                  hintText: 'Enter a comment',
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter a comment';
                                                  }

                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              //  sequenceNameController.clear();
                                              ScaffoldMessenger.of(context)
                                                  .clearSnackBars();

                                              final validationResult = formKey
                                                  .currentState!
                                                  .validate();
                                              if (!validationResult) {
                                                return;
                                              }

                                              //  Map<String, dynamic> decodedResponse =
                                              //      jsonDecode(response.body);

                                              //   sequenceNameController.clear();
                                              Navigator.of(context).pop(true);
                                              //        await callApiMethods();
                                            },
                                            child: const Text('Add Comment'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (dialogResult == true) {
                                    if (!taskPayOrPauseStatus!) {
                                      final response1 =
                                          await playAndPauseTaskApi(
                                        taskId: widget.id.toString(),
                                        break_start_as_DateTime:
                                            DateTime.now().toString(),
                                        break_end_as_DateTime: null,
                                        comment: commentController.text.trim(),
                                        //  comment: '111',
                                      );
                                    } else {
                                      final response1 =
                                          await playAndPauseTaskApi(
                                        taskId: widget.id.toString(),
                                        break_start_as_DateTime: null,
                                        break_end_as_DateTime:
                                            DateTime.now().toString(),
                                        comment: commentController.text.trim(),
                                        //  comment: '222',
                                      );
                                    }
                                    taskPayOrPauseStatus =
                                        await getTaskPlayOrPauseStatus(
                                            taskId: widget.id.toString());
                                    setState(() {});
                                    return;
                                    return;
                                  }
                                } else {
                                  if (!taskPayOrPauseStatus!) {
                                    final response1 = await playAndPauseTaskApi(
                                      taskId: widget.id.toString(),
                                      break_start_as_DateTime:
                                          DateTime.now().toString(),
                                      break_end_as_DateTime: null,
                                      comment: commentController.text.trim(),
                                      //                                    comment: '333'
                                    );
                                  } else {
                                    final response1 = await playAndPauseTaskApi(
                                      taskId: widget.id.toString(),
                                      break_start_as_DateTime: null,
                                      break_end_as_DateTime:
                                          DateTime.now().toString(),
                                      comment: commentController.text.trim(),
                                      // comment: '444',
                                    );
                                  }
                                  taskPayOrPauseStatus =
                                      await getTaskPlayOrPauseStatus(
                                          taskId: widget.id.toString());
                                }

                                setState(() {});
                                return;
                                setState(() {});
                              },
                              child: Text('Resume'),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            height: 50.0,
                            child: Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                )
                              ]),
                              child: _blApprovedTask && _blSelfAssignATask
                                  ? ElevatedButton(
                                      onPressed: () =>
                                          buttonAction(context, widget.id),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.blue),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        setButtonText(
                                            widget.status!, widget.userId!),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : (_blSelfAssignATask &&
                                          (widget.status == "in_process" ||
                                              widget.status == "pending"))
                                      ? ElevatedButton(
                                          onPressed: () =>
                                              buttonAction(context, widget.id),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.blue),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            setSelfApprovedText(
                                                widget.status!, widget.userId!),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : _blApprovedTask &&
                                              widget.status == "to_inspect"
                                          ? ElevatedButton(
                                              onPressed: () => buttonAction(
                                                  context, widget.id),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.blue),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                setInspectionText(
                                                    widget.status!,
                                                    widget.userId!),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                            ),
                          ),
                        ],
                      )
                    : setButtonText(widget.status!, widget.userId!) !=
                            'Complete'
                        ? Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 50.0,
                              child: Container(
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    )
                                  ]),
                                  child: _blApprovedTask && _blSelfAssignATask
                                      ? ElevatedButton(
                                          onPressed: () =>
                                              buttonAction(context, widget.id),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.blue),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            setButtonText(
                                                widget.status!, widget.userId!),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : (_blSelfAssignATask &&
                                              (widget.status == "in_process" ||
                                                  widget.status == "pending"))
                                          ? ElevatedButton(
                                              onPressed: () => buttonAction(
                                                  context, widget.id),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.blue),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                setSelfApprovedText(
                                                    widget.status!,
                                                    widget.userId!),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : _blApprovedTask &&
                                                  widget.status == "to_inspect"
                                              ? ElevatedButton(
                                                  onPressed: () => buttonAction(
                                                      context, widget.id),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.blue),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    setInspectionText(
                                                        widget.status!,
                                                        widget.userId!),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : _blApprovedTask &&
                                                      widget.status ==
                                                          "rejected"
                                                  ? ElevatedButton(
                                                      onPressed: () =>
                                                          buttonAction(context,
                                                              widget.id),
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors.red),
                                                        shape: MaterialStateProperty
                                                            .all<
                                                                RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        setInspectionText(
                                                            widget.status!,
                                                            widget.userId!),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )

                                                  /// this button is now diaplay all the time if not complete button
                                                  : ElevatedButton(
                                                      onPressed: () =>
                                                          buttonAction(context,
                                                              widget.id),
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                          widget.status ==
                                                                  'rejected'
                                                              ? Colors.blue
                                                              : Colors.red,
                                                        ),
                                                        shape: MaterialStateProperty
                                                            .all<
                                                                RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        setButtonText(
                                                            widget.status!,
                                                            widget.userId!),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                  //  SizedBox.shrink(
                                  //     child: Text('111')),
                                  ),
                            ),
                          )
                        : SizedBox(child: Text('222'))
          ],
        ),
      ),
    );
  }

  buttonAction(BuildContext context, int taskId) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    // if same user is opening a task
    if (widget.status == "pending") {
      // ignore: use_build_context_synchronously
      callUpdateTask(
          context, widget.id, widget.jobId!, DateTime.now(), "in_process");
    } else if (widget.status == "approved") {
      // ignore: use_build_context_synchronously
      callUpdateTask(
          context, widget.id, widget.jobId!, DateTime.now(), "rejected");
    } else if (widget.status == "in_process") {
      final boolResult =
          await getTaskPlayOrPauseStatus(taskId: taskId.toString());
      if (boolResult == false) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Task must be resumed to proceed for completion!')));
        return;
      }
      if (taskPayOrPauseStatus!) {
        final response1 = await playAndPauseTaskApi(
          taskId: widget.id.toString(),
          break_start_as_DateTime: null,
          break_end_as_DateTime: DateTime.now().toString(),
          comment: commentController.text.trim(),
          //  comment: '111'
        );
      }
      // ignore: use_build_context_synchronously
      callUpdateTask(
          context, widget.id, widget.jobId!, DateTime.now(), "to_inspect");
    } else if (widget.status == "to_inspect") {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskApproveRejectScreen(
            taskId: widget.id,
            jobId: widget.jobId,
            startedAt: widget.startedAt,
          ),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      callUpdateTask(
          context, widget.id, widget.jobId!, DateTime.now(), "approved");
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
    if (userIdValue == widget.userId) {
      // if same user
      if (value == "pending") {
        return 'Pick Task';
      } else if (value == "in_process") {
        return 'Complete';
      } else if (value == "to_inspect") {
        return 'Approve';
      } else if (value == "rejected") {
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
    if (userIdValue == widget.userId) {
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
    if (userIdValue == widget.userId) {
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
  Future<void> downloadImage(String imageUrl, String fileName) async {
    var dio = Dio();

    // Directory? externalDir = await getExternalStorageDirectory();

    Directory? externalDir = await getApplicationDocumentsDirectory();

    if (externalDir != null) {
      // Ensure the file name has a valid image file extension, like .jpg or .png
      if (!fileName.toLowerCase().endsWith('.jpg') &&
          !fileName.toLowerCase().endsWith('.png')) {
        debugPrint('Invalid image file extension.');
        return;
      }

      String filePath = '${externalDir.path}/$fileName';
      //  String filePath = '/storage/emulated/0/DCIM/$fileName';

      await dio.download(
        imageUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Calculate the download percentage
            double percentage = (received / total) * 100;
            debugPrint('Downloaded: ${percentage.toStringAsFixed(2)}%');

            Fluttertoast.cancel();
            showOverlayFileDownload(percentage.toString());

            //     showToast(percentage.toString());

            // showSimpleNotification(
            //     Column(
            //       children: [
            //         CircularProgressIndicator(),
            //         Text(percentage.toString())
            //       ],
            //     ),
            //     background: Colors.green,
            //     position: NotificationPosition.bottom);
            debugPrint(
                'imageUrl.replaceAll: ' + imageUrl.replaceAll(' ', '%20'));
            debugPrint('fileName: ' + fileName);

            if (percentage == 100) {
              context.loaderOverlay.hide();
              // debugPrint('File download complete');
              showToast('File download complete');

              // if (_blCollaborate) {
              //   _openExternalLink(
              //       "https://play.google.com/store/apps/details?id=com.microsoft.whiteboard.publicpreview");
              // }
            }
          }
        },
      );
    } else {
      debugPrint('External storage directory not available.');
    }
  }

  void showOverlayFileDownload(String percentage) {
    context.loaderOverlay.show(
        widgetBuilder: (progress) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.blue,
              ),
              //     SizedBox(height: 0),

              Container(
                width: 100,
                height: 100,
                child: Center(
                  child: Text(
                    double.parse(progress.toString()).toInt().toString() + '%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        progress: percentage);
  }
}
