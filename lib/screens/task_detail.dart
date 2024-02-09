import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:dio/dio.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:open_file/open_file.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/check_task_play_or_pause_status.dart';
import '../services/get_task_logs.dart';
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
bool _blRejectedTask = false;
bool _blSelfAssignATask = false;
bool _b1ShowProfile = false;
bool b1ViewContacts = false;
bool b1DownloadDiagram = false;

bool isStartButtonVisible = true;
int startButtonTaskId = -1;

///////////////////////////////////
bool myRejectedTask = false;
bool myApprovedTask = false;

class TaskDetail extends StatefulWidget {
  final int taskId;

  // const TaskList({Key? key}) : super(key: key);
  const TaskDetail({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
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

  // final formKey = GlobalKey<FormState>();
  // final commentController = TextEditingController();
  String? taskStatus;
  List<TaskDetailObj> taskDetailObj = [
    TaskDetailObj(
      task_iteration: -1,
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
  void didChangeDependencies() {
    checkTablet();
    getStartButtonVisibility();
    super.didChangeDependencies();
  }

  Future<void> getStartButtonVisibility() async {
    final startButtonBox = await Hive.openBox('startButtonBox');

    isStartButtonVisible = await startButtonBox.get('isStartButtonVisible');
    // isStartButtonVisible = bool.parse(isStartButtonVisible.toString());
    startButtonTaskId = await startButtonBox.get('taskId');
    // buttonAction(context, widget.id);

    setState(() {});
  }

  @override
  void initState() {
    getProfileImageToSharedPrefs();
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

    checkPermissionAndUpdateBool("view_contact", (localBool) {
      b1ViewContacts = localBool;
    });

    checkPermissionAndUpdateBool("download_diagram", (localBool) {
      b1DownloadDiagram = localBool;
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

    checkPermissionAndUpdateBool("rejected_task", (localBool) {
      myRejectedTask = localBool;
    });

    checkPermissionAndUpdateBool("approved_task", (localBool) {
      myApprovedTask = localBool;
    });
  }

  bool? taskPayOrPauseStatus = null;

  Future<void> callApiMethods() async {
    print('id:' + widget.taskId.toString());
    taskPayOrPauseStatus =
        await getTaskPlayOrPauseStatus(taskId: widget.taskId.toString());

    print('init method value taskPayOrPauseStatus: $taskPayOrPauseStatus');
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
    print('user profile image: $userProfileImage');
    setState(() {});
  }

  Future<void> getLocalStartButtonStatus() async {}

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        //  floatingActionButton: FloatingActionButton(onPressed: ()async{
        //    final tokenBox=await Hive.openBox('tokenBox');
        //   final token=await  tokenBox.get('token');
        // //  print(token);
        //    Map<String, dynamic>? decodedToken =
        //    JwtDecoder.decode(token);
        //
        //    print(decodedToken);
        //
        //  },child: Text('data')),
        // floatingActionButton: FloatingActionButton(onPressed: () async {
        //   //    print('task pay or pause status: $taskPayOrPauseStatus');

        //   List<TasklogModel> taskLogsList = [];
        //   // Future<void> callApiMethods() async {
        //   taskLogsList = await getTaskLogs(taskId: 101);

        //   (taskLogsList.length >= 2 &&
        //       (taskLogsList.last.iteration !=
        //           taskLogsList[taskLogsList.length - 2].iteration));

        //   print('taskLogsList.length: ' + taskLogsList.length.toString());
        //   print('taskLogsList.last.iteration: ' +
        //       taskLogsList.last.iteration.toString());
        //   print('taskLogsList[taskLogsList.length - 2].iteration: ' +
        //       taskLogsList[taskLogsList.length - 2].iteration.toString());
        // }),

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
          iconTheme: IconThemeData(
              // color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
              //     ? Colors.white
              //     : Colors.black,
              ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate to the last screen in the stack
              Navigator.pop(context);
              // Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          title: Text(
            "Task Detail",
            style: TextStyle(
              fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
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
                    icon: Icon(
                      Icons.view_kanban_outlined,
                      size: isTablet ? 40 : 24,
                    )),
                Visibility(
                  visible: _blShowNotificationsList,
                  child: Padding(
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
                            width: isTablet ? 45 : 32,
                            height: isTablet ? 45 : 32,
                            color: AdaptiveTheme.of(context).mode ==
                                    AdaptiveThemeMode.light
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        !hasNewNotifiaction
                            ? const SizedBox()
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
                ),
                Visibility(
                  visible: _b1ShowProfile,
                  child: GestureDetector(
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
                      padding: const EdgeInsets.only(right: 10.0, left: 5.0),
                      child: CircleAvatar(
                        backgroundImage: userProfileImage == null
                            ? const AssetImage('assets/images/ic_profile.png')
                            : NetworkImage(userProfileImage!) as ImageProvider,
                        radius: isTablet ? 25 : 15,
                      ),
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
  List<TaskDetailObj> mytaskDetailListSingle = [];
  final TaskDetailObj mytaskDetail = TaskDetailObj(
      id: 0,
      pmkNumber: 'pmkNumber',
      heatNo: 'heatNo',
      jobId: 0,
      userId: 0,
      description: '',
      startedAt: null,
      completedAt: null,
      approvedAt: null,
      approvedBy: null,
      status: 'status',
      comments: 'comments',
      image: 'image',
      projectManager: 'projectManager',
      QCI: 'QCI',
      fitter: 'fitter',
      welder: 'welder',
      painter: 'painter',
      foreman: 'foreman',
      task_iteration: -1);

  bool isStartEmptyButtonVisible = false;

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
  void didChangeDependencies() {
    getCurrentUserId();
    checkTablet();
    isbtnVisible();
    callMyMethod();
    super.didChangeDependencies();
  }

  int loginUserId = -1;
  Future<void> getCurrentUserId() async {
    final tokenBox = await Hive.openBox('tokenBox');
    final token = await tokenBox.get('token');
    //  print(token);
    Map<String, dynamic>? decodedToken = JwtDecoder.decode(token);

    print(decodedToken);
    loginUserId = decodedToken['id'];
    print('loginUserId: ' + loginUserId.toString());
    setState(() {});
  }

  Future<void> isbtnVisible() async {
    isStartEmptyButtonVisible =
        ((taskLogsList.isEmpty || taskLogsList.length == 1) &&
            (setButtonText(widget.status!, widget.userId!) != 'Pick Task'));
    setState(() {});
  }

  Future<void> callMyMethod() async {
    mytaskDetailListSingle = await fetchTaskDetail(widget.id);
    setState(() {});
  }

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

  List<TasklogModel> taskLogsList = [];

  Future<void> callApiMethods() async {
    taskLogsList = await getTaskLogs(taskId: widget.id);
    taskPayOrPauseStatus =
        await getTaskPlayOrPauseStatus(taskId: widget.id.toString());
    print('init method 222 value taskPayOrPauseStatus: $taskPayOrPauseStatus');
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

        print('isoDate:$isoDate');
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

        print('jsonMap: $jsonMap');

        // print(response.body);
        // Map<String, dynamic> jsonMap = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          //    ScaffoldMessenger.of(context)
          //        .showSnackBar(SnackBar(content: Text(jsonMap['message'])));

          showSnackbar(context, jsonMap['message']);

          // Navigate to the last screen in the stack
          // ignore: use_build_context_synchronously
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          // ignore: use_build_context_synchronously
          //   ScaffoldMessenger.of(context)
          //       .showSnackBar(SnackBar(content: Text(jsonMap['message'])));
          showSnackbar(context, jsonMap['message']);
        }
      } else {
        // Handle the case where userId is not available
        // ignore: use_build_context_synchronously
        //   ScaffoldMessenger.of(context)
        //       .showSnackBar(const SnackBar(content: Text('User ID not found')));
        showSnackbar(context, 'User ID not found');
      }
    } catch (e) {
      print('e: $e');
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
            SizedBox(height: isTablet ? 15 : 4),
            Text(
              "Pmk# ${widget.pmkNumber}",
              style: TextStyle(
                // color: Color(0xFF1E2022),
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 40 : 25.0,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Heat No.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 25 : 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.heatNo!,
                        style: TextStyle(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.grey[350]
                              : Colors.grey[600],
                          fontSize: isTablet ? 25 : 15.0,
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
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 25 : 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.description!,
                        style: TextStyle(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.grey[350]
                              : Colors.grey[600],
                          fontSize: isTablet ? 25 : 15.0,
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
                    'Start Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 25 : 15.0,
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
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.grey[350]
                              : Colors.grey[600],
                          fontSize: isTablet ? 25 : 15.0,
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
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 25 : 15.0,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        setStatusText(widget.status!),
                        style: TextStyle(
                          color: setCardBorderColor(widget.status!),
                          fontSize: isTablet ? 25 : 15.0,
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
            const SizedBox(
              height: 21,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: b1ViewContacts,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33)),
                      child: GestureDetector(
                        //  splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ViewContactsScreen(),
                              ));
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: isTablet ? 50 : 26,
                          child: Icon(
                            Icons.phone,
                            size: isTablet ? 40 : 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(visible: b1DownloadDiagram, child: const Spacer()),
                  Visibility(
                    visible: b1DownloadDiagram,
                    // visible: true,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33)),
                      child: GestureDetector(
                        onTap: () async {
                          await downloadImage(widget.imageUrl!);

                          //  await downloadImage('123', "TaskDiagram.png");
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: isTablet ? 50 : 26,
                          child: Icon(
                            Icons.download,
                            size: isTablet ? 40 : 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: b1DownloadDiagram,
                    // visible: _blCollaborate,
                    child: const Spacer(),
                  ),
                  Visibility(
                    visible: _blCollaborate,
                    child: Card(
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
                          radius: isTablet ? 50 : 26,
                          child: Icon(
                            Icons.edit_note,
                            size: isTablet ? 40 : 20,
                          ),
                        ),
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
                  child: SizedBox(
                    //   width: 285.0,
                    // height: 145.0,
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: CachedNetworkImage(
                      // width: 285.0,
                      // height: 145.0,
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.3,

                      imageUrl: widget.imageUrl!,
                      fit: BoxFit.cover,
                      //   imageUrl:
                      //     'http://206.81.5.26:3500/uploads/task_images/image%20(7)_1705576583697.jpeg',
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),

                      // placeholder: (context, url) =>
                      //     Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(
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

            Visibility(
              // visible: (taskLogsList.isEmpty || taskLogsList.length == 1) &&
              //     (setButtonText(widget.status!, widget.userId!) !=
              //         'Pick Task'),

              visible: (taskLogsList.isEmpty || taskLogsList.length == 1) &&
                  (widget.status == 'Pending' || widget.status == 'in_process'),

              //    visible: isStartEmptyButtonVisible,

              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      // final startButtonBox =
                      //     await Hive.openBox('startButtonBox');
                      // startButtonBox.clear();

                      // setState(() {});

                      commentController.clear();
                      print('empty resume button pressed');

                      if (taskPayOrPauseStatus != null &&
                          taskPayOrPauseStatus == true) {
                        print('empty here in resume button');
                        //      final dialogResult =
                        //        await commmentDialog(context);

                        if (true) {
                          final response = await playAndPauseTaskApi(
                            taskId: widget.id.toString(),
                            break_start_as_DateTime: DateTime.now().toString(),
                            break_end_as_DateTime: null,
                            comment: '',
                            //   commnet:'123'; wala ye ara tha pehly
                          );
                        }

                        taskPayOrPauseStatus = await getTaskPlayOrPauseStatus(
                            taskId: widget.id.toString());
                      }

                      taskLogsList = await getTaskLogs(taskId: widget.id);

                      setState(() {});
                      return;
                      setState(() {});
                    },

                    child: const Text('Start'), //Start Empty
                    style: ButtonStyle(
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.amber),
                        foregroundColor:
                            const MaterialStatePropertyAll(Colors.white),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)))),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: (taskLogsList.length >= 2 &&
                      (taskLogsList.last.iteration !=
                          taskLogsList[taskLogsList.length - 2].iteration))
                  ///////////////////////  remove condition below for error if getting any reject btn was visible somehow so in order to hide it this condition is used
                  &&
                  setButtonText(widget.status!, widget.userId!) != 'Reject'
              //                  &&
              //        widget.status!.toLowerCase() != 'Rejected'.toLowerCase()

              //   &&

              // widget.status!.toLowerCase() != 'Approved'.toLowerCase(),
              ,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      // final startButtonBox =
                      //     await Hive.openBox('startButtonBox');
                      // startButtonBox.clear();

                      // setState(() {});

                      commentController.clear();
                      print('resume button pressed');

                      if (taskPayOrPauseStatus != null &&
                          taskPayOrPauseStatus == true) {
                        print('here in resume button');
                        //      final dialogResult =
                        //        await commmentDialog(context);

                        if (true) {
                          final response = await playAndPauseTaskApi(
                            taskId: widget.id.toString(),
                            break_start_as_DateTime: DateTime.now().toString(),
                            break_end_as_DateTime: null,
                            comment: '',
                            //   commnet:'123'; wala ye ara tha pehly
                          );
                        }

                        taskPayOrPauseStatus = await getTaskPlayOrPauseStatus(
                            taskId: widget.id.toString());
                      }

                      taskLogsList = await getTaskLogs(taskId: widget.id);

                      setState(() {});
                      return;
                      setState(() {});
                      setState(() {});
                      return;
                      setState(() {});
                    },
                    child: const Text('Start'), // Start Not Empty Logs
                    style: ButtonStyle(
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.amber),
                        foregroundColor:
                            const MaterialStatePropertyAll(Colors.white),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)))),
                  ),
                ),
              ),
            ),

            taskPayOrPauseStatus == false &&
                    setButtonText(widget.status!, widget.userId!) == 'Complete'
                ? Visibility(
                    visible: ((taskLogsList.length >= 2 &&
                                (taskLogsList.last.iteration !=
                                    taskLogsList[taskLogsList.length - 2]
                                        .iteration)) ==
                            false &&
                        (taskLogsList.isEmpty || taskLogsList.length == 1) ==
                            false),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ///////  pause button pressed
                        Visibility(
                          visible: widget.userId == loginUserId,
                          child: SizedBox(
                            width: 130,
                            height: 50.0,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  foregroundColor:
                                      const MaterialStatePropertyAll(
                                          Colors.white),
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                          Colors.redAccent),
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(9)))),
                              onPressed: () async {
                                commentController.clear();
                                print('pause button pressed line 1358');

                                // if (taskPayOrPauseStatus != null &&
                                //     taskPayOrPauseStatus == false) {
                                //   taskPayOrPauseStatus =
                                //       await getTaskPlayOrPauseStatus(
                                //           taskId: widget.id.toString());
                                // }

                                if (taskPayOrPauseStatus != null &&
                                    taskPayOrPauseStatus == false) {
                                  print('hi');

                                  final dialogResult =
                                      await commmentDialog(context);

                                  if (dialogResult == true) {
                                    final response = playAndPauseTaskApi(
                                      taskId: widget.id.toString(),
                                      break_start_as_DateTime: null,
                                      break_end_as_DateTime:
                                          DateTime.now().toString(),
                                      comment: commentController.text.trim(),
                                    );

                                    taskPayOrPauseStatus =
                                        await getTaskPlayOrPauseStatus(
                                            taskId: widget.id.toString());

                                    print('taskPayOrPauseStatus: ' +
                                        taskPayOrPauseStatus.toString());

                                    setState(() {});
                                  }
                                }

                                taskPayOrPauseStatus =
                                    await getTaskPlayOrPauseStatus(
                                        taskId: widget.id.toString());

                                print('taskPayOrPauseStatus: ' +
                                    taskPayOrPauseStatus.toString());

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
                              child: const Text('Pause'),
                            ),
                          ),
                        ),

                        ///////////////////  2nd button also here
                        Visibility(
                          visible: widget.userId == loginUserId,
                          child: SizedBox(
                            width: 130,
                            height: 50.0,
                            child: Container(
                              decoration: BoxDecoration(boxShadow: [
                                // (EasyDynamicTheme.of(context).themeMode !=
                                //         ThemeMode.dark)
                                //     ? BoxShadow(
                                //         color: Colors.grey.withOpacity(0.5),
                                //         spreadRadius: 2,
                                //         blurRadius: 5,
                                //         offset: const Offset(
                                //             0, 3), // changes position of shadow
                                //       )
                                //     : const BoxShadow(),
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
                                          onPressed: () async {
                                            print('complete button 1 pressed');
                                            //    final startButtonBox =
                                            //      await Hive.openBox(
                                            //        'startButtonBox');

                                            // await startButtonBox.put(
                                            //     'isStartButtonVisible', true);

                                            // await startButtonBox.put(
                                            //     'taskId', widget.id);
                                            //  startButtonBox.clear();
                                            setState(() {});
                                            buttonAction(context, widget.id);
                                          },
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
                                              onPressed: () async {
                                                print(
                                                    'complete button 2 pressed');
                                                //   final startButtonBox =
                                                //      await Hive.openBox(
                                                //        'startButtonBox');

                                                // await startButtonBox.put(
                                                //     'isStartButtonVisible', true);

                                                // await startButtonBox.put(
                                                //     'taskId', widget.id);
                                                //  startButtonBox.clear();
                                                setState(() {});
                                                buttonAction(
                                                    context, widget.id);
                                              },
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
                                          : ElevatedButton(
                                              onPressed: () async {
                                                print(
                                                    'complete button 3 pressed');
                                                //     final startButtonBox =
                                                //         await Hive.openBox(
                                                //           'startButtonBox');

                                                // await startButtonBox.put(
                                                //     'isStartButtonVisible', true);

                                                // await startButtonBox.put(
                                                //     'taskId', widget.id);
                                                //   startButtonBox.clear();
                                                setState(() {});
                                                buttonAction(
                                                    context, widget.id);
                                              },
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
                                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : taskPayOrPauseStatus == true &&
                        setButtonText(widget.status!, widget.userId!) ==
                            'Complete'
                    ? Visibility(
                        visible: ((taskLogsList.length >= 2 &&
                                    (taskLogsList.last.iteration !=
                                        taskLogsList[taskLogsList.length - 2]
                                            .iteration)) ==
                                false &&
                            (taskLogsList.isEmpty ||
                                    taskLogsList.length == 1) ==
                                false),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Visibility(
                              visible: widget.userId == loginUserId,
                              child: SizedBox(
                                width: 130,
                                height: 50.0,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      foregroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.white),
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.green),
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(9)))),
                                  onPressed: () async {
                                    commentController.clear();
                                    print('resume button pressed');

                                    if (taskPayOrPauseStatus != null &&
                                        taskPayOrPauseStatus == true) {
                                      print('here in resume button');
                                      //      final dialogResult =
                                      //        await commmentDialog(context);

                                      if (true) {
                                        final response =
                                            await playAndPauseTaskApi(
                                          taskId: widget.id.toString(),
                                          break_start_as_DateTime:
                                              DateTime.now().toString(),
                                          break_end_as_DateTime: null,
                                          comment: '123',
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
                                  //       child: Text(
                                  //         taskLogsList.isEmpty ? 'Start' : 'Pause'),
                                  child: const Text('Resume'),
                                ),
                              ),
                            ),

                            /////////////////////////////////////////////  2nd complete button creating isssue here
                            Visibility(
                              visible: widget.userId == loginUserId,
                              child: SizedBox(
                                width: 130,
                                height: 50.0,
                                child: Container(
                                  decoration: BoxDecoration(boxShadow: [
                                    // (EasyDynamicTheme.of(context).themeMode !=
                                    //         ThemeMode.dark)
                                    //     ? BoxShadow(
                                    //         color: Colors.grey.withOpacity(0.5),
                                    //         spreadRadius: 2,
                                    //         blurRadius: 5,
                                    //         offset: const Offset(0,
                                    //             3), // changes position of shadow
                                    //       )
                                    //     : const BoxShadow(),
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
                                                                .circular(
                                                          10.0,
                                                        ),
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
                                              // : SizedBox.shrink(
                                              //     child: Text('data'),
                                              //   ),
                                              : ElevatedButton(
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
                                                    setSelfApprovedText(
                                                        widget.status!,
                                                        widget.userId!),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : setButtonText(widget.status!, widget.userId!) !=
                                'Complete' &&
                            setButtonText(widget.status!, widget.userId!) ==
                                'Pick Task'
                        ? Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 50.0,
                              child: Container(
                                  decoration: BoxDecoration(
                                      // color: Colors.blue,
                                      boxShadow: [
                                        // (EasyDynamicTheme.of(context)
                                        //             .themeMode !=
                                        //         ThemeMode.dark)
                                        //     ? BoxShadow(
                                        //         color: Colors.grey
                                        //             .withOpacity(0.5),
                                        //         spreadRadius: 2,
                                        //         blurRadius: 5,
                                        //         offset: const Offset(0,
                                        //             3), // changes position of shadow
                                        //       )
                                        //     : const BoxShadow(),
                                      ]),
                                  child: _blApprovedTask && _blSelfAssignATask
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            final response1 =
                                                await playAndPauseTaskApi(
                                              taskId: widget.id.toString(),
                                              break_start_as_DateTime:
                                                  DateTime.now().toString(),
                                              break_end_as_DateTime: null,
                                              comment: 'null',
                                              //  comment: '111'
                                            );

                                            final response2 =
                                                await playAndPauseTaskApi(
                                              taskId: widget.id.toString(),
                                              break_start_as_DateTime: null,
                                              break_end_as_DateTime:
                                                  DateTime.now().toString(),
                                              comment: 'null',
                                              //  comment: '111'
                                            );

                                            print(
                                                'purple 1 here is the button');
                                            // final startButtonBox =
                                            //     await Hive.openBox(
                                            //         'startButtonBox');
                                            //
                                            // await startButtonBox.put(
                                            //     'isStartButtonVisible', true);
                                            //
                                            // await startButtonBox.put(
                                            //     'taskId', widget.id);

                                            buttonAction(context, widget.id);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(setButtonText(
                                                            widget.status!,
                                                            widget.userId!) ==
                                                        'Reject'
                                                    ? Colors.red
                                                    : setButtonText(
                                                                widget.status!,
                                                                widget
                                                                    .userId!) ==
                                                            'Approve'
                                                        ? Colors.green
                                                        : Colors.blue),
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
                                              onPressed: () {
                                                print('purple 2');
                                                buttonAction(
                                                    context, widget.id);
                                              },
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
                                                  onPressed: () {
                                                    print('purple 3');
                                                    buttonAction(
                                                        context, widget.id);
                                                  },
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
                                                      onPressed: () {
                                                        print('purple 4');
                                                        buttonAction(
                                                            context, widget.id);
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty.all<
                                                                Color>(widget
                                                                        .status!
                                                                        .toLowerCase() ==
                                                                    'rejected'
                                                                ? Colors.blue
                                                                : Colors.red),
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
                                                      onPressed: () {
                                                        print('purple 5');
                                                        buttonAction(
                                                            context, widget.id);
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                          widget.status!
                                                                      .toLowerCase() ==
                                                                  'rejected'
                                                              ? Colors.blue
                                                              : Colors.green,
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
                        : (setButtonText(widget.status!, widget.userId!) !=
                                        'Complete' &&
                                    setButtonText(
                                            widget.status!, widget.userId!) !=
                                        'Pick Task') &&
                                (setButtonText(
                                            widget.status!, widget.userId!) ==
                                        'Approve' ||
                                    setButtonText(
                                            widget.status!, widget.userId!) ==
                                        'Reject')
                            ? Visibility(
                                visible: (myApprovedTask == true ||
                                    myRejectedTask == true),
                                child: Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: 50.0,
                                    child: Container(
                                        decoration: BoxDecoration(
                                            // color: Colors.blue,
                                            boxShadow: [
                                              // (EasyDynamicTheme.of(context)
                                              //             .themeMode !=
                                              //         ThemeMode.dark)
                                              //     ? BoxShadow(
                                              //         color: Colors.grey
                                              //             .withOpacity(0.5),
                                              //         spreadRadius: 2,
                                              //         blurRadius: 5,
                                              //         offset: const Offset(0,
                                              //             3), // changes position of shadow
                                              //       )
                                              //     : const BoxShadow(),
                                            ]),
                                        child: _blApprovedTask &&
                                                _blSelfAssignATask
                                            ? ElevatedButton(
                                                onPressed: () async {
                                                  final response1 =
                                                      await playAndPauseTaskApi(
                                                    taskId:
                                                        widget.id.toString(),
                                                    break_start_as_DateTime:
                                                        DateTime.now()
                                                            .toString(),
                                                    break_end_as_DateTime: null,
                                                    comment: 'null',
                                                    //  comment: '111'
                                                  );

                                                  final response2 =
                                                      await playAndPauseTaskApi(
                                                    taskId:
                                                        widget.id.toString(),
                                                    break_start_as_DateTime:
                                                        null,
                                                    break_end_as_DateTime:
                                                        DateTime.now()
                                                            .toString(),
                                                    comment: 'null',
                                                    //  comment: '111'
                                                  );

                                                  print(
                                                      'purple 1 here is the button');
                                                  // final startButtonBox =
                                                  //     await Hive.openBox(
                                                  //         'startButtonBox');
                                                  //
                                                  // await startButtonBox.put(
                                                  //     'isStartButtonVisible', true);
                                                  //
                                                  // await startButtonBox.put(
                                                  //     'taskId', widget.id);

                                                  buttonAction(
                                                      context, widget.id);
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(setButtonText(
                                                                  widget
                                                                      .status!,
                                                                  widget
                                                                      .userId!) ==
                                                              'Reject'
                                                          ? Colors.red
                                                          : setButtonText(
                                                                      widget
                                                                          .status!,
                                                                      widget
                                                                          .userId!) ==
                                                                  'Approve'
                                                              ? Colors.green
                                                              : Colors.blue),
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
                                                  setButtonText(widget.status!,
                                                      widget.userId!),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : (_blSelfAssignATask &&
                                                    (widget.status ==
                                                            "in_process" ||
                                                        widget.status ==
                                                            "pending"))
                                                ? ElevatedButton(
                                                    onPressed: () {
                                                      print('purple 2');
                                                      buttonAction(
                                                          context, widget.id);
                                                    },
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
                                                                  .circular(
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
                                                        widget.status ==
                                                            "to_inspect"
                                                    ? ElevatedButton(
                                                        onPressed: () {
                                                          print('purple 3');
                                                          buttonAction(context,
                                                              widget.id);
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .blue),
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
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      )
                                                    : _blApprovedTask &&
                                                            widget.status ==
                                                                "rejected"
                                                        ? ElevatedButton(
                                                            onPressed: () {
                                                              print('purple 4');
                                                              buttonAction(
                                                                  context,
                                                                  widget.id);
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all<
                                                                  Color>(widget
                                                                          .status!
                                                                          .toLowerCase() ==
                                                                      'rejected'
                                                                  ? Colors.blue
                                                                  : Colors.red),
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
                                                                  widget
                                                                      .status!,
                                                                  widget
                                                                      .userId!),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          )

                                                        /// this button is now diaplay all the time if not complete button
                                                        : ElevatedButton(
                                                            onPressed: () {
                                                              print('purple 5');
                                                              buttonAction(
                                                                  context,
                                                                  widget.id);
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all<
                                                                          Color>(
                                                                widget.status!
                                                                            .toLowerCase() ==
                                                                        'rejected'
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .green,
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
                                                                  widget
                                                                      .status!,
                                                                  widget
                                                                      .userId!),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          )
                                        //  SizedBox.shrink(
                                        //     child: Text('111')),
                                        ),
                                  ),
                                ),
                              )
                            : const SizedBox(
                                child: Text(''),
                              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> commmentDialog(BuildContext context) {
    return showDialog<bool?>(
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
                    hintStyle: TextStyle(fontSize: 13),
                    labelText: 'Comment',
                    hintText: 'Enter a comment',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
                ScaffoldMessenger.of(context).clearSnackBars();

                final validationResult = formKey.currentState!.validate();
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
        //  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //      content: Text('Task must be paused to proceed for completion!')));
        showSnackbar(context, 'Task must be paused to proceed for completion!');
        return;
      }

      // if (taskPayOrPauseStatus!) {
      //   final response1 = await playAndPauseTaskApi(
      //     taskId: widget.id.toString(),
      //     break_start_as_DateTime: null,
      //     break_end_as_DateTime: DateTime.now().toString(),
      //     comment: commentController.text.trim(),
      //     //  comment: '111'
      //   );
      // }

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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 25 : 15.0,
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
                  fontSize: isTablet ? 25 : 15.0,
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

  Future<void> downloadImage(String imageUrl) async {
//    String fileExtension = path.extension(imageUrl).toLowerCase();

    String fileNameWithExtension = path.basename(imageUrl);

    final response = await http.get(Uri.parse(imageUrl));

    await FlutterFileSaver().writeFileAsBytes(
      fileName: fileNameWithExtension,
      bytes: response.bodyBytes,
    );
  }

  void showOverlayFileDownload(String percentage) {
    context.loaderOverlay.show(
        widgetBuilder: (progress) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.blue,
              ),
              //     SizedBox(height: 0),

              SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: Text(
                    '${double.parse(progress.toString()).toInt()}%',
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
