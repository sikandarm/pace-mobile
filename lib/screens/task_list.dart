import 'dart:async';
import 'dart:convert';

import 'package:com_a3_pace/screens/create_new_sequence.dart';
import 'package:com_a3_pace/screens/task_detail.dart';
import 'package:com_a3_pace/services/delete_sequence.dart';
import 'package:com_a3_pace/services/get_Independent_tasks.dart';
import 'package:com_a3_pace/services/get_all_sequences_by_job_id.dart';
import 'package:com_a3_pace/services/get_all_task_tasks_of_sequence.dart';
import 'package:com_a3_pace/services/get_sequences_and_its_tasks.dart';
import 'package:com_a3_pace/services/update_sequence_tasks.dart';
import 'package:com_a3_pace/utils/constants.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/task_list_card.dart';
import '../services/task_service.dart';
import 'Dashboard.dart';
import 'ProfileScreen.dart';
import 'notification.dart';

class TaskList extends StatefulWidget {
  final int jobId;

  const TaskList({Key? key, required this.jobId}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

bool _blShowNotificationsList = false;

class _TaskListState extends State<TaskList> {
  List<SequenceModelNew> allSequences = [];
  final formkeySequence = GlobalKey<FormState>();
  final sequenceNameController = TextEditingController();
  final jobIDController = TextEditingController();

  int _selectedTaskIndex = -1;

  late Future<List<IndependentTaskModel>> _futureTask = Future.value([]);
  String _selectedValue = "all";

  List<SequenceModelNew> sequencesList = [];

  Future<void> callApiMethods() async {
    sequencesList.clear();
    sequencesList = [];

    final result = await getSequences(jobID: widget.jobId.toString());

    for (var seq in result) {
      sequencesList.add(
        SequenceModelNew(
          SequenceId: seq.SequenceId,
          JobId: seq.JobId,
          sequenceName: seq.sequenceName,
          tasks: seq.tasks,
        ),
      );
    }

    final result2 = await getAllEmptySequences(jobID: widget.jobId.toString());

    for (var seq2 in result2) {
      sequencesList.add(SequenceModelNew(
        SequenceId: seq2.SequenceId,
        JobId: seq2.JobId,
        sequenceName: seq2.sequenceName,
        tasks: seq2.tasks,
      ));
    }

    setState(() {});
  }

  // late ExpandableController _expandableController;

  @override
  void initState() {
    //  _expandableController = ExpandableController();
    super.initState();
    callApiMethods();

    _futureTask = getIndependentTasks(jobID: widget.jobId.toString());
    checkPermissionAndUpdateBool("view_notifications", (localBool) {
      _blShowNotificationsList = localBool;
    });
  }

  void checkPermissionAndUpdateBool(
      String permValue, Function(bool) boolUpdater) async {
    var localBool = await hasPermission(permValue);

    setState(() {
      boolUpdater(localBool);
    });
  }

  void _onDropdownChanged(String? newValue) {
    setState(() {
      _selectedValue = newValue ?? "all";
    });
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
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Form(
                                key: formkeySequence,
                                child: Column(
                                  children: [
                                    const Text(
                                      'Create a new sequence',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextFormField(
                                      controller: sequenceNameController,
                                      decoration: const InputDecoration(
                                        hintStyle: TextStyle(fontSize: 13),
                                        labelText: 'Sequence title',
                                        hintText: 'Enter a sequence title',
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

                                    Navigator.of(context).pop();
                                    await callApiMethods();
                                  },
                                  child: const Text('Create'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.add_box_outlined,
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
      body: Container(
        //     height: MediaQuery.of(context).size.height,
        //    width: MediaQuery.of(context).size.width,
        child: ListView(
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
                              builder: (context, candidateData, rejectedData) {
                                return Draggable<int>(
                                  data: sequencesList[i].tasks[j]['id'],
                                  feedback: Container(
                                      //   height: 120,
                                      width: MediaQuery.of(context).size.width,
                                      child: TaskCard(
                                        id: sequencesList[i].tasks[j]['id'],
                                        taskName: sequencesList[i]
                                            .tasks[j]['PmkNumber']
                                            .toString(),
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
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: TaskCard(
                                            id: sequencesList[i].tasks[j]['id'],
                                            taskName: sequencesList[i]
                                                .tasks[j]['PmkNumber']
                                                .toString(),
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
                                        sequenceId: sequencesList[i].SequenceId,
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
                        headerAlignment: ExpandablePanelHeaderAlignment.center,
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
                                : EdgeInsets.only(left: 21),
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  sequencesList[i].sequenceName.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                await deleteSequence(
                                    sequenceID: int.parse(sequencesList[i]
                                        .SequenceId
                                        .toString()));

                                await callApiMethods();
                              },
                              icon: sequencesList[i].tasks.length < 1
                                  ? Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    )
                                  : SizedBox(),
                            ),
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
            Container(
              width: MediaQuery.of(context).size.width,
              //  height: MediaQuery.of(context).size.height,
              child: FutureBuilder<List<IndependentTaskModel>>(
                future: _futureTask,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        SizedBox(height: 90),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return Column(
                      children: [
                        SizedBox(height: 90),
                        Center(
                          child: Text("${snapshot.error}"),
                        ),
                      ],
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No tasks found"),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: getFilteredTasks(snapshot.data!).length,
                      itemBuilder: (context, index) {
                        final tasks = getFilteredTasks(snapshot.data!)[index];
                        final statusColor =
                            index % 2 == 0 ? Colors.green : Colors.red;

                        return Draggable<int>(
                          data: int.parse(tasks.id.toString()),
                          feedback: Container(
                            width: MediaQuery.of(context).size.width,
                            //  height: 120,
                            child: TaskCard(
                                id: tasks.id!,
                                taskName: tasks.pmkNumber!,
                                description: tasks.description!,
                                startDate: tasks.startedAt,
                                endDate: tasks.completedAt,
                                status: tasks.status!,
                                statusColor: statusColor,
                                onSelected: (index) {}),
                          ),
                          childWhenDragging: Container(
                            width: MediaQuery.of(context).size.width,
                            //  height: 120,
                            child: TaskCard(
                                id: tasks.id!,
                                taskName: tasks.pmkNumber!,
                                description: tasks.description!,
                                startDate: tasks.startedAt,
                                endDate: tasks.completedAt,
                                status: tasks.status!,
                                statusColor: statusColor,
                                onSelected: (index) {}),
                          ),
                          child: TaskCard(
                              id: tasks.id!,
                              taskName: tasks.pmkNumber!,
                              description: tasks.description!,
                              startDate: tasks.startedAt,
                              endDate: tasks.completedAt,
                              status: tasks.status!,
                              statusColor: statusColor,
                              onSelected: (index) {}),
                          onDragCompleted: () async {
                            // Navigator.pop(context);
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             TaskList(jobId: widget.jobId)));
                            await updateSequenceTasks(
                              sequenceId: sequencesList[index].SequenceId,
                              task_id: tasks.id!,
                            );

                            await callApiMethods();

                            // setState(() {});
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
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
