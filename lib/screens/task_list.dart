import 'dart:async';
import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../components/task_list_card.dart';
import '../services/delete_sequence.dart';
import '../services/delete_sequence_task.dart';
import '../services/get_Independent_tasks.dart';
import '../services/get_sequences_and_its_tasks.dart';
import '../services/task_service.dart';
import '../services/update_sequence_tasks.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'ProfileScreen.dart';
import 'create_new_sequence.dart';
import 'notification.dart';

class TaskList extends StatefulWidget {
  final int jobId;

  const TaskList({Key? key, required this.jobId}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

bool _blShowNotificationsList = false;

bool _bShowTaskDetailScreen = false;

bool _bShowCreateSequenceIcon = false;

bool _b1ShowTask = false;

class _TaskListState extends State<TaskList> {
  Timer _timer = Timer(Duration.zero, () {});

  // Your existing method with Timer.periodic
  void startScrolling() {
    if (scrollController.offset == 0) {
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // scroll up
      scrollController.animateTo(
        scrollController.offset - 20,
        duration: const Duration(milliseconds: 75),
        curve: Curves.linear,
      );
    });
  }

  // New method to cancel the timer
  void cancelScrolling() {
    if (_timer.isActive) {
      _timer.cancel();
    }
  }

  final scrollController = ScrollController();
  final listViewKey = GlobalKey();
  List<SequenceModelNew> allSequences = [];
  final formkeySequence = GlobalKey<FormState>();
  final sequenceNameController = TextEditingController();
  final jobIDController = TextEditingController();

  int _selectedTaskIndex = -1;

  List<IndependentTaskModel> _futureTask = [];
  String _selectedValue = "all";

  List<SequenceModelNew> sequencesList = [];

  Future<void> callApiMethods() async {
    sequencesList.clear();
    sequencesList = [];

    final result = await getSequences(jobID: widget.jobId.toString());

    // for (var seq in result) {
    //   sequencesList.add(
    //     SequenceModelNew(
    //       SequenceId: seq.SequenceId,
    //       JobId: seq.JobId,
    //       sequenceName: seq.sequenceName,
    //       tasks: seq.tasks,
    //     ),
    //   );
    // }

    final result2 = await getAllEmptySequences(jobID: widget.jobId.toString());

    // for (var seq2 in result2) {
    //   sequencesList.add(SequenceModelNew(
    //     SequenceId: seq2.SequenceId,
    //     JobId: seq2.JobId,
    //     sequenceName: seq2.sequenceName,
    //     tasks: seq2.tasks,
    //   ));
    // }

    final combinedList = result + result2;

    sequencesList.addAll(combinedList);
    setState(() {});
  }

  // late ExpandableController _expandableController;

  @override
  void initState() {
    //  _expandableController = ExpandableController();
    getProfileImageToSharedPrefs();
    super.initState();
    callOtherApiMethod();
    callApiMethods();

    // Timer.periodic(const Duration(milliseconds: 100), (_) {
    //   // scroll up
    //   scrollController.animateTo(
    //     scrollController.offset - 20,
    //     duration: const Duration(milliseconds: 100),
    //     curve: Curves.linear,
    //   );
    // });

    checkPermissionAndUpdateBool("view_notifications", (localBool) {
      _blShowNotificationsList = localBool;
    });

    checkPermissionAndUpdateBool("view_task_detail", (localBool) {
      _bShowTaskDetailScreen = localBool;
    });

    checkPermissionAndUpdateBool("add_sequence", (localBool) {
      _bShowCreateSequenceIcon = localBool;
    });

    //  _b1ShowTask;
    checkPermissionAndUpdateBool("view_task", (localBool) {
      _b1ShowTask = localBool;
    });
    print('create seq permission:' + _bShowCreateSequenceIcon.toString());
    print('go to task detail permission:' + _bShowTaskDetailScreen.toString());
  }

  bool isLoading = false;
  Future<void> callOtherApiMethod() async {
    isLoading = true;
    _futureTask = await getIndependentTasks(jobID: widget.jobId.toString());
    _futureTask = getFilteredTasks(_futureTask);
    print('all future tasks:' + _futureTask.toString());
    isLoading = false;
    setState(() {});
  }

  void checkPermissionAndUpdateBool(
      String permValue, Function(bool) boolUpdater) async {
    var localBool = await hasPermission(permValue);

    setState(() {
      boolUpdater(localBool);
    });
  }

  void _onDropdownChanged(String? newValue) async {
    print('drop down val: ' + newValue.toString());
    setState(() {
      _selectedValue = newValue ?? "all";
    });
    await callOtherApiMethod();
  }

  List<IndependentTaskModel> getFilteredTasks(
      List<IndependentTaskModel> allTasks) {
    switch (_selectedValue) {
      case "all":
        return allTasks;
      case "approved":
        return allTasks.where((task) => task.status == "approved").toList();
      case "rejected":
        return allTasks.where((task) => task.status == "rejected").toList();
      case "pending":
        return allTasks.where((task) => task.status == "pending").toList();
      case "to_inspect":
        return allTasks.where((task) => task.status == "to_inspect").toList();
      case "in_process":
        return allTasks.where((task) => task.status == "in_process").toList();
      default:
        return allTasks;
    }
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
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   //  await getSingleTask(taskId: '166');
      //   final sharedPrefs = await SharedPreferences.getInstance();
      //   final token = sharedPrefs.getString(BL_USER_TOKEN);
      //   print('token: ' + token.toString());
      // }),
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
          "Tasks List",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 1.0),
                child: Stack(
                  children: [
                    Visibility(
                      //  visible: _bShowCreateSequenceIcon,
                      visible: true,
                      child: IconButton(
                        onPressed: () async {
                          if (!_bShowCreateSequenceIcon) {
                            await Fluttertoast.cancel();
                            showToast('You do not have permissions');
                            return;
                          }

                          final dialogResult = await showDialog<bool?>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Form(
                                  key: formkeySequence,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Create a new sequence',
                                        style: TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextFormField(
                                        controller: sequenceNameController,
                                        decoration: const InputDecoration(
                                          hintStyle: TextStyle(fontSize: 13.5),
                                          hintText: 'Enter a sequence title',
                                          labelText: 'Sequence title',
                                          labelStyle: TextStyle(fontSize: 13.5),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a sequence title';
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

                                      final validationResult = formkeySequence
                                          .currentState!
                                          .validate();

                                      if (!validationResult) {
                                        return;
                                      }

                                      final response = await createNewSequence(
                                        seqName:
                                            sequenceNameController.text.trim(),
                                        jobID: widget.jobId,
                                      );
                                      Map<String, dynamic> decodedResponse =
                                          jsonDecode(response.body);

                                      if (decodedResponse['message'] != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  decodedResponse['message'])),
                                        );
                                      }

                                      sequenceNameController.clear();
                                      Navigator.of(context).pop();
                                      await callApiMethods();
                                    },
                                    child: const Text('Create'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (dialogResult != true) {
                            sequenceNameController.clear();
                          }
                        },
                        icon: const Icon(
                          Icons.add_box_outlined,
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
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          //     height: MediaQuery.of(context).size.height,
          //    width: MediaQuery.of(context).size.width,
          child: ListView(
            key: listViewKey,
            controller: scrollController,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskListHeader(
                onDropdownChanged: _onDropdownChanged,
                selectedValue: _selectedValue,
              ),
              for (int i = 0; i < sequencesList.length; i++) ...{
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: ExpandablePanel(
                        key: ValueKey(i),

                        expanded: Column(
                          key: ValueKey(i),
                          children: [
                            for (int j = 0;
                                j < sequencesList[i].tasks.length;
                                j++) ...{
                              DragTarget(
                                onAccept: (data) async {
                                  await updateSequenceTasks(
                                    sequenceId: sequencesList[i].SequenceId,
                                    task_id: sequencesList[i].tasks[j]['id'],
                                  );

                                  await callApiMethods();

                                  await getIndependentTasks(
                                      jobID: widget.jobId.toString());
                                  setState(() {});
                                },
                                builder:
                                    (context, candidateData, rejectedData) {
                                  return Draggable<int>(
                                    data: sequencesList[i].tasks[j]['id'],
                                    feedback: Container(
                                        //   height: 120,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: TaskCard(
                                          hasPermissionToGoToTaskDetailScreen:
                                              _bShowTaskDetailScreen,
                                          onPressedDelete: () {},
                                          showDeleteIcon: true,
                                          id: sequencesList[i].tasks[j]['id'],
                                          taskName: sequencesList[i]
                                              .tasks[j]['PmkNumber']
                                              .toString(),
                                          //     taskName: '222not here effects',
                                          description: sequencesList[i]
                                              .tasks[j]['description']
                                              .toString(),
                                          endDate: DateTime.now(),
                                          startDate: DateTime.now(),
                                          status: sequencesList[i]
                                              .tasks[j]['status']
                                              .toString(),
                                          statusColor: Colors.transparent,
                                          onSelected: (_) {},
                                        )),
                                    child: DragTarget<int>(
                                      builder: (
                                        BuildContext context,
                                        List<dynamic> accepted,
                                        List<dynamic> rejected,
                                      ) {
                                        return Container(
                                            //    height: 120,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: TaskCard(
                                              hasPermissionToGoToTaskDetailScreen:
                                                  _bShowTaskDetailScreen,
                                              onPressedDelete: () async {
                                                print('sss here');

                                                final dialogResult =
                                                    await showDeleteAlertDialog(
                                                        context: context,
                                                        content:
                                                            'Are you sure to delete task from sequence?');
                                                print('dialogResult: ' +
                                                    dialogResult.toString());

                                                if (dialogResult == true) {
                                                  print('pmk num: ' +
                                                      sequencesList[i]
                                                          .tasks[j]['PmkNumber']
                                                          .toString());
                                                  //   _futureTask.add(value);

                                                  _futureTask.insert(
                                                    0,
                                                    IndependentTaskModel(
                                                      status: sequencesList[i]
                                                          .tasks[j]['status']
                                                          .toString(),
                                                      pmkNumber:
                                                          sequencesList[i]
                                                              .tasks[j]
                                                                  ['PmkNumber']
                                                              .toString(),
                                                      description:
                                                          sequencesList[i]
                                                              .tasks[j][
                                                                  'description']
                                                              .toString(),
                                                      approvedAt:
                                                          DateTime.now(),
                                                      completedAt:
                                                          DateTime.now(),
                                                      id: sequencesList[i]
                                                          .tasks[j]['id'],
                                                      startedAt: DateTime.now(),
                                                    ),
                                                  );

                                                  // sequencesList.removeWhere(
                                                  //     (element) =>
                                                  //         element.tasks[j]
                                                  //             ['id'] ==
                                                  //         sequencesList[i]
                                                  //             .tasks[j]['id']);
                                                  //
                                                  // setState(() {});

                                                  await deleteSequenceTask(
                                                      taskId: sequencesList[i]
                                                          .tasks[j]['id']
                                                          .toString(),
                                                      context: context);

                                                  // sequencesList.removeWhere(
                                                  //     (element) =>
                                                  //         element.tasks[j]
                                                  //             ['id'] ==
                                                  //         sequencesList[i]
                                                  //             .tasks[j]['id']);
                                                  //

                                                  await callApiMethods();
                                                  setState(() {});
                                                }
                                              },

                                              showDeleteIcon: true,
                                              id: sequencesList[i].tasks[j]
                                                  ['id'],
                                              taskName: sequencesList[i]
                                                  .tasks[j]['PmkNumber']
                                                  .toString(),
                                              //  taskName: 'ssssss',
                                              description: sequencesList[i]
                                                  .tasks[j]['description']
                                                  .toString(),
                                              endDate: DateTime.now(),
                                              startDate: DateTime.now(),
                                              status: sequencesList[i]
                                                  .tasks[j]['status']
                                                  .toString(),
                                              statusColor: Colors.transparent,
                                              onSelected: (_) {},
                                            ));
                                      },
                                      onAccept: (int data) async {
                                        await updateSequenceTasks(
                                          sequenceId:
                                              sequencesList[i].SequenceId,
                                          task_id: data,
                                        );

                                        await callApiMethods();
                                        //  _expandableController.toggle();
                                      },
                                    ),
                                  );
                                },
                              ),
                            }
                          ],
                        ),
                        // controller: ExpandableController(),
                        //      controller: _expandableController,
                        theme: ExpandableThemeData(
                          hasIcon:
                              sequencesList[i].tasks.isNotEmpty ? true : false,
                          inkWellBorderRadius: BorderRadius.zero,
                          useInkWell: false,
                          iconPlacement: ExpandablePanelIconPlacement.left,
                          headerAlignment:
                              ExpandablePanelHeaderAlignment.center,
                        ),
                        header: DragTarget<int>(
                          builder: (
                            BuildContext context,
                            List<dynamic> accepted,
                            List<dynamic> rejected,
                          ) {
                            return Container(
                                child: ListTile(
                              contentPadding: sequencesList[i].tasks.isNotEmpty
                                  ? EdgeInsets.all(-21)
                                  : EdgeInsets.only(left: 41),
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //  SizedBox(width: 33),
                                  Text(
                                    sequencesList[i].sequenceName.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: sequencesList[i].tasks.length < 1
                                  ? IconButton(
                                      onPressed: () async {
                                        final dialogResult =
                                            await showDeleteAlertDialog(
                                                context: context,
                                                content:
                                                    'Are you sure to delete this sequence?');
                                        if (dialogResult == true) {
                                          await deleteSequence(
                                              sequenceID: int.parse(
                                                  sequencesList[i]
                                                      .SequenceId
                                                      .toString()));

                                          await callApiMethods();
                                        }
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    )
                                  : SizedBox(),
                            ));
                          },
                          onAccept: (int taskId) async {
                            await updateSequenceTasks(
                              sequenceId: sequencesList[i].SequenceId,
                              task_id: taskId,
                            );

                            callApiMethods();
                          },
                        ),
                        collapsed: const SizedBox(),
                        //  builder: (context, collapsed, expanded) => expanded

                        // expanded: Column(
                        //   children: [
                        //     for (int j = 0;
                        //         j < sequencesList[i].tasks.length;
                        //         j++) ...{
                        //       DragTarget(
                        //         builder:
                        //             (context, candidateData, rejectedData) {
                        //           return Draggable<int>(
                        //             data: sequencesList[i].tasks[j]['id'],
                        //             feedback: Container(
                        //                 height: 120,
                        //                 width:
                        //                     MediaQuery.of(context).size.width,
                        //                 child: TaskCard(
                        //                   id: sequencesList[i].tasks[j]['id'],
                        //                   taskName: sequencesList[i]
                        //                       .tasks[j]['PmkNumber']
                        //                       .toString(),
                        //                   description: sequencesList[i]
                        //                       .tasks[j]['description']
                        //                       .toString(),
                        //                   endDate: DateTime.now(),
                        //                   startDate: DateTime.now(),
                        //                   status: sequencesList[i]
                        //                       .tasks[j]['status']
                        //                       .toString(),
                        //                   statusColor: Colors.transparent,
                        //                   onSelected: (_) {},
                        //                 )),
                        //             child: DragTarget<int>(
                        //               builder: (
                        //                 BuildContext context,
                        //                 List<dynamic> accepted,
                        //                 List<dynamic> rejected,
                        //               ) {
                        //                 return Container(
                        //                     height: 120,
                        //                     width: MediaQuery.of(context)
                        //                         .size
                        //                         .width,
                        //                     child: TaskCard(
                        //                       id: sequencesList[i].tasks[j]
                        //                           ['id'],
                        //                       taskName: sequencesList[i]
                        //                           .tasks[j]['PmkNumber']
                        //                           .toString(),
                        //                       description: sequencesList[i]
                        //                           .tasks[j]['description']
                        //                           .toString(),
                        //                       endDate: DateTime.now(),
                        //                       startDate: DateTime.now(),
                        //                       status: sequencesList[i]
                        //                           .tasks[j]['status']
                        //                           .toString(),
                        //                       statusColor: Colors.transparent,
                        //                       onSelected: (_) {},
                        //                     ));
                        //               },
                        //               onAccept: (int data) async {
                        //                 await updateSequenceTasks(
                        //                   sequenceId:
                        //                       sequencesList[i].SequenceId,
                        //                   task_id: data,
                        //                 );

                        //                 await callApiMethods();
                        //               },
                        //             ),
                        //           );
                        //         },
                        //       ),
                        //     }
                        //   ],
                        // ),
                      ),
                    ),
                  ),
                )
              },
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.5),
                child: Text(
                  "Independent Tasks",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(height: 11),

/////////////////////////////////////////aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

              isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          //  SizedBox(height: 100),
                          // Center(child: CircularProgressIndicator()),
                          Shimmer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                            ),
                          ),
                          SizedBox(height: 11),
                          Shimmer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                            ),
                          ),
                          SizedBox(height: 11),
                          Shimmer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                            ),
                          ),
                          SizedBox(height: 11),
                          Shimmer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                            ),
                          ),
                          SizedBox(height: 11),
                          Shimmer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                            ),
                          ),
                        ],
                      ),
                    )
                  : !isLoading && _futureTask.isEmpty
                      ? Visibility(
                          visible: _b1ShowTask,
                          child: Column(
                            children: [
                              SizedBox(height: 100),
                              Text('No independent tasks found'),
                            ],
                          ),
                        )
                      : Visibility(
                          visible: _b1ShowTask,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                for (int i = 0;
                                    i < _futureTask.length;
                                    i++) ...{
                                  // DragTarget(
                                  //   onAccept: (data) async {
                                  //     // await deleteSequenceTask(
                                  //     //     taskId: _futureTask[i].id.toString(),
                                  //     //     context: context);
                                  //     // print(data); //data is taskID
                                  //     // await deleteSequenceTask(
                                  //     //     taskId: data.toString(),
                                  //     //     context: context);

                                  //     // _futureTask.insert(
                                  //     //     0,
                                  //     //     IndependentTaskModel(
                                  //     //       id: _futureTask[i].id,
                                  //     //       approvedAt: _futureTask[i].approvedAt,
                                  //     //       approvedBy: _futureTask[i].approvedBy,
                                  //     //       cOPQ: _futureTask[i].cOPQ,
                                  //     //       comments: _futureTask[i].comments,
                                  //     //       completedAt:
                                  //     //           _futureTask[i].completedAt,
                                  //     //       description:
                                  //     //           _futureTask[i].description,
                                  //     //       estimatedHour:
                                  //     //           _futureTask[i].estimatedHour,
                                  //     //       fitter: _futureTask[i].fitter,
                                  //     //       foreman: _futureTask[i].foreman,
                                  //     //       heatNo: _futureTask[i].heatNo,
                                  //     //       image: _futureTask[i].image,
                                  //     //       jobId: _futureTask[i].jobId,
                                  //     //       painter: _futureTask[i].painter,
                                  //     //       pmkNumber: _futureTask[i].pmkNumber,
                                  //     //       projectManager:
                                  //     //           _futureTask[i].projectManager,
                                  //     //       qCI: _futureTask[i].qCI,
                                  //     //       rejectionReason:
                                  //     //           _futureTask[i].rejectionReason,
                                  //     //       startedAt: _futureTask[i].startedAt,
                                  //     //       status: _futureTask[i].status,
                                  //     //       userId: _futureTask[i].userId,
                                  //     //       welder: _futureTask[i].welder,
                                  //     //     ));
                                  //     // setState(() {});
                                  //   },
                                  //   builder:
                                  //       (context, candidateData, rejectedData) {
                                  //     return Draggable<int>(
                                  //       data: int.parse(
                                  //           _futureTask[i].id.toString()),
                                  //       feedback: Container(
                                  //         width:
                                  //             MediaQuery.of(context).size.width,
                                  //         //  height: 120,

                                  //         child: TaskCard(
                                  //             id: _futureTask[i].id!,
                                  //             taskName: _futureTask[i].pmkNumber!,
                                  //             description:
                                  //                 _futureTask[i].description!,
                                  //             startDate: _futureTask[i].startedAt,
                                  //             endDate: _futureTask[i].completedAt,
                                  //             status: _futureTask[i].status!,
                                  //             statusColor: Colors.transparent,
                                  //             onSelected: (index) {}),
                                  //       ),
                                  //       childWhenDragging: Container(
                                  //         width:
                                  //             MediaQuery.of(context).size.width,
                                  //         //  height: 120,
                                  //         child: TaskCard(
                                  //             id: _futureTask[i].id!,
                                  //             taskName: _futureTask[i].pmkNumber!,
                                  //             description:
                                  //                 _futureTask[i].description!,
                                  //             startDate: _futureTask[i].startedAt,
                                  //             endDate: _futureTask[i].completedAt,
                                  //             status: _futureTask[i].status!,
                                  //             statusColor: Colors.transparent,
                                  //             onSelected: (index) {}),
                                  //       ),
                                  //       child: TaskCard(
                                  //           id: _futureTask[i].id!,
                                  //           taskName: _futureTask[i].pmkNumber!,
                                  //           description:
                                  //               _futureTask[i].description!,
                                  //           startDate: _futureTask[i].startedAt,
                                  //           endDate: _futureTask[i].completedAt,
                                  //           status: _futureTask[i].status!,
                                  //           statusColor: Colors.transparent,
                                  //           onSelected: (index) {}),
                                  //       onDragCompleted: () async {
                                  //         //  final list = await getIndependentTasks(
                                  //         //    jobID: widget.jobId.toString());
                                  //         // _futureTask = getFilteredTasks(list);
                                  //         //   await callOtherApiMethod();
                                  //         //   await callOtherApiMethod();

                                  //         //   setState(() {});
                                  //         // Navigator.pop(context);
                                  //         // Navigator.push(
                                  //         //     context,
                                  //         //     MaterialPageRoute(
                                  //         //         builder: (context) =>
                                  //         //             TaskList(jobId: widget.jobId)));
                                  //         // await updateSequenceTasks(
                                  //         //   sequenceId: sequencesList[index].SequenceId,
                                  //         //   task_id: tasks.id!,
                                  //         // );

                                  //         // await callApiMethods();
                                  //         _futureTask.removeWhere((element) =>
                                  //             element.id == _futureTask[i].id!);
                                  //         //  setState(() {});
                                  //       },
                                  //     );
                                  //   },
                                  // )

                                  Draggable<int>(
                                    onDragStarted: () {
                                      // scrollController.animateTo(
                                      //     scrollController.offset - 20,
                                      //     duration: Duration(milliseconds: 500),
                                      //     curve: Curves.linear);
                                      // setState(() {});
                                      // Timer.periodic(
                                      //     const Duration(milliseconds: 100), (_) {
                                      //   // scroll up
                                      //   scrollController.animateTo(
                                      //     scrollController.offset - 20,
                                      //     duration:
                                      //         const Duration(milliseconds: 100),
                                      //     curve: Curves.linear,
                                      //   );
                                      // });
                                      startScrolling();
                                    },
                                    onDragEnd: (details) {
                                      //  scrollController.dispose();
                                      //  setState(() {});
                                      cancelScrolling();
                                    },
                                    data:
                                        int.parse(_futureTask[i].id.toString()),
                                    feedback: Container(
                                      width: MediaQuery.of(context).size.width,
                                      //  height: 120,

                                      child: TaskCard(
                                          hasPermissionToGoToTaskDetailScreen:
                                              _bShowTaskDetailScreen,
                                          id: _futureTask[i].id!,
                                          taskName: _futureTask[i].pmkNumber!,
                                          description:
                                              _futureTask[i].description!,
                                          startDate: _futureTask[i].startedAt,
                                          endDate: _futureTask[i].completedAt,
                                          status: _futureTask[i].status!,
                                          statusColor: Colors.transparent,
                                          onSelected: (index) {}),
                                    ),
                                    childWhenDragging: Container(
                                      width: MediaQuery.of(context).size.width,
                                      //  height: 120,
                                      child: TaskCard(
                                          hasPermissionToGoToTaskDetailScreen:
                                              _bShowTaskDetailScreen,
                                          id: _futureTask[i].id!,
                                          taskName: _futureTask[i].pmkNumber!,
                                          description:
                                              _futureTask[i].description!,
                                          startDate: _futureTask[i].startedAt,
                                          endDate: _futureTask[i].completedAt,
                                          status: _futureTask[i].status!,
                                          statusColor: Colors.transparent,
                                          onSelected: (index) {}),
                                    ),
                                    child: TaskCard(
                                        hasPermissionToGoToTaskDetailScreen:
                                            _bShowTaskDetailScreen,
                                        id: _futureTask[i].id!,
                                        taskName: _futureTask[i].pmkNumber!,
                                        description:
                                            _futureTask[i].description!,
                                        startDate: _futureTask[i].startedAt,
                                        endDate: _futureTask[i].completedAt,
                                        status: _futureTask[i].status!,
                                        statusColor: Colors.transparent,
                                        onSelected: (index) {}),
                                    onDragCompleted: () async {
                                      //  final list = await getIndependentTasks(
                                      //    jobID: widget.jobId.toString());
                                      // _futureTask = getFilteredTasks(list);
                                      //   await callOtherApiMethod();
                                      //   await callOtherApiMethod();

                                      //   setState(() {});
                                      // Navigator.pop(context);
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             TaskList(jobId: widget.jobId)));
                                      // await updateSequenceTasks(
                                      //   sequenceId: sequencesList[index].SequenceId,
                                      //   task_id: tasks.id!,
                                      // );

                                      // await callApiMethods();
                                      _futureTask.removeWhere((element) =>
                                          element.id == _futureTask[i].id!);
                                      //  setState(() {});
                                    },
                                  ),
                                }
                              ],
                            ),
                          ),
                        ),

/////////////////////////////////////////bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb

              // Container(
              //   width: MediaQuery.of(context).size.width,
              //   //  height: MediaQuery.of(context).size.height,
              //   child: FutureBuilder<List<IndependentTaskModel>>(
              //     future: _futureTask,
              //     builder: (context, snapshot) {
              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return Column(
              //           children: [
              //             SizedBox(height: 90),
              //             const Center(child: CircularProgressIndicator()),
              //           ],
              //         );
              //       } else if (snapshot.hasError) {
              //         print(snapshot.error);
              //         return Column(
              //           children: [
              //             SizedBox(height: 90),
              //             Center(
              //               child: Text("${snapshot.error}"),
              //             ),
              //           ],
              //         );
              //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //         return const Center(
              //           child: Text("No tasks found"),
              //         );
              //       } else {
              //         return ListView.builder(
              //           shrinkWrap: true,
              //           physics: NeverScrollableScrollPhysics(),
              //           itemCount: getFilteredTasks(snapshot.data!).length,
              //           itemBuilder: (context, index) {
              //             final tasks = getFilteredTasks(snapshot.data!)[index];
              //             final statusColor =
              //                 index % 2 == 0 ? Colors.green : Colors.red;

              //             return Draggable<int>(
              //               data: int.parse(tasks.id.toString()),
              //               feedback: Container(
              //                 width: MediaQuery.of(context).size.width,
              //                 //  height: 120,
              //                 child: TaskCard(
              //                     id: tasks.id!,
              //                     taskName: tasks.pmkNumber!,
              //                     description: tasks.description!,
              //                     startDate: tasks.startedAt,
              //                     endDate: tasks.completedAt,
              //                     status: tasks.status!,
              //                     statusColor: statusColor,
              //                     onSelected: (index) {}),
              //               ),
              //               childWhenDragging: Container(
              //                 width: MediaQuery.of(context).size.width,
              //                 //  height: 120,
              //                 child: TaskCard(
              //                     id: tasks.id!,
              //                     taskName: tasks.pmkNumber!,
              //                     description: tasks.description!,
              //                     startDate: tasks.startedAt,
              //                     endDate: tasks.completedAt,
              //                     status: tasks.status!,
              //                     statusColor: statusColor,
              //                     onSelected: (index) {}),
              //               ),

              //               child: TaskCard(
              //                   id: tasks.id!,
              //                   taskName: tasks.pmkNumber!,
              //                   description: tasks.description!,
              //                   startDate: tasks.startedAt,
              //                   endDate: tasks.completedAt,
              //                   status: tasks.status!,
              //                   statusColor: statusColor,
              //                   onSelected: (index) {}),
              //               onDragCompleted: () async {
              //                 Navigator.pop(context);
              //                 Navigator.push(
              //                     context,
              //                     MaterialPageRoute(
              //                         builder: (context) =>
              //                             TaskList(jobId: widget.jobId)));
              //                 // await updateSequenceTasks(
              //                 //   sequenceId: sequencesList[index].SequenceId,
              //                 //   task_id: tasks.id!,
              //                 // );

              //                 // await callApiMethods();

              //                 // setState(() {});
              //               },
              //             );
              //           },
              //         );
              //       }
              //     },
              //   ),
              // ),
              SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> showDeleteAlertDialog({
    required BuildContext context,
    // required String title,
    required String content,
    // required VoidCallback onOkPressed,
  }) {
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text(
          //   title,
          //   style: TextStyle(
          //     fontSize: 20.0,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          content: Text(
            content,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                //      onOkPressed(); // Perform the action associated with the "OK" button
                Navigator.of(context).pop(true); // Close the dialog
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TaskListHeader extends StatelessWidget {
  final Function(String?) onDropdownChanged;
  final String selectedValue;

  const TaskListHeader({
    Key? key,
    required this.onDropdownChanged,
    required this.selectedValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: DropdownButton<String>(
                        items: const [
                          DropdownMenuItem(
                            value: "all",
                            child: Text("All Tasks"),
                          ),
                          DropdownMenuItem(
                            value: "approved",
                            child: Text("Approved"),
                          ),
                          DropdownMenuItem(
                            value: "rejected",
                            child: Text("Rejected"),
                          ),
                          DropdownMenuItem(
                            value: "pending",
                            child: Text("Pending"),
                          ),
                          DropdownMenuItem(
                            value: "to_inspect",
                            child: Text("To Inspect"),
                          ),
                          DropdownMenuItem(
                            value: "in_process",
                            child: Text("In Process"),
                          ),
                        ],
                        onChanged: onDropdownChanged,
                        value: selectedValue,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24.0,
                        elevation: 16,
                        underline: const SizedBox(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        dropdownColor: Colors.white,
                        isDense: true,
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
