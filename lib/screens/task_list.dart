import 'dart:convert';

import 'package:com_a3_pace/screens/create_new_sequence.dart';
import 'package:com_a3_pace/screens/task_detail.dart';
import 'package:com_a3_pace/services/delete_sequence.dart';
import 'package:com_a3_pace/services/get_all_sequences_by_job_id.dart';
import 'package:com_a3_pace/services/get_all_task_tasks_of_sequence.dart';
import 'package:com_a3_pace/utils/constants.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../components/task_list_card.dart';
import '../services/task_service.dart';
import 'Dashboard.dart';
import 'ProfileScreen.dart';
import 'notification.dart';

class TaskList extends StatefulWidget {
  final int jobId;

  // const TaskList({Key? key}) : super(key: key);
  const TaskList({Key? key, required this.jobId}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

bool _blShowNotificationsList = false;

class _TaskListState extends State<TaskList> {
  final formkeySequence = GlobalKey<FormState>();
  final sequenceNameController = TextEditingController();
  final jobIDController = TextEditingController();

  int _selectedTaskIndex = -1;
  late Future<List<Task>> _futureTask = Future.value([]);
  String _selectedValue = "all";

  List<SequenceModel> sequencesList = [];
  List<dynamic> allTasks2List = [];

  Future<void> callApiMethods() async {
    print('widget.jobId:' + widget.jobId.toString());
    sequencesList = await getAllSequncesByJobId(jobId: widget.jobId);
    final map = await getAllTasksWithSequence(jobID: widget.jobId.toString());
    allTasks2List = map['tasks2ModelList'];

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    callApiMethods();
    _futureTask = fetchTasks(widget.jobId);

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

  // Function to filter tasks based on the selected value
  List<Task> getFilteredTasks(List<Task> allTasks) {
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
      floatingActionButton: FloatingActionButton(onPressed: () async {
        // print('widget.jobId:' + widget.jobId.toString());
        // sequencesList = await getAllSequncesByJobId(jobId: widget.jobId);
        //  print(response.toList()[0].job);

        // print(sequencesList.first.sequenceName);
        //     final responseMap =
        //        await getAllTasksWithSequence(jobID: widget.jobId.toString());
        //   print(responseMap['tasks2ModelList'][1]);

        print('widget.jobId:' + widget.jobId.toString());
        sequencesList = await getAllSequncesByJobId(jobId: widget.jobId);
        final map =
            await getAllTasksWithSequence(jobID: widget.jobId.toString());
        allTasks2List = map['tasks2ModelList'];
        print(allTasks2List);
      }),
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
                    // InkWell(
                    //   onTap: () {
                    //     if (_blShowNotificationsList) {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) =>
                    //                 const NotificationsScreen()),
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
                                      //  controller: emailController,
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

                                        // You can add more complex validation logic here for email format.

                                        return null; // Return null if the input is valid.
                                      },
                                    ),
                                    // TextFormField(
                                    //   controller: jobIDController,
                                    //   decoration: const InputDecoration(
                                    //     labelText: 'Job ID',
                                    //     hintText: 'Enter a job ID',
                                    //     hintStyle: TextStyle(fontSize: 13),
                                    //   ),
                                    //   validator: (value) {
                                    //     if (value == null || value.isEmpty) {
                                    //       return 'Please enter a job ID';
                                    //     }
                                    //     if (int.tryParse(value) == null) {
                                    //       return 'Job ID must be an integer';
                                    //     }

                                    //     // You can add more complex validation logic here for email format.

                                    //     return null; // Return null if the input is valid.
                                    //   },
                                    // ),
                                  ],
                                ),
                              ),
                              //   content: Text('Create a new sequence'),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    // Close the dialog

                                    final validationResult = formkeySequence
                                        .currentState!
                                        .validate();

                                    if (!validationResult) {
                                      return;
                                    }

                                    final response = await createNewSequence(
                                      seqName:
                                          sequenceNameController.text.trim(),
                                      // jobID: int.parse(
                                      //     jobIDController.text.trim()),
                                      jobID: widget.jobId,
                                      //   context: context,
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

                                    print(response.body);
                                    Navigator.of(context).pop();

                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TaskList(jobId: widget.jobId)));
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskListHeader(
                onDropdownChanged: _onDropdownChanged,
                selectedValue: _selectedValue,
              ),
              ////////////////////////////////////////////////

              for (int i = 0; i < sequencesList.length; i++) ...{
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: ExpandablePanel(
                        controller: ExpandableController(),
                        theme: const ExpandableThemeData(
                          inkWellBorderRadius: BorderRadius.zero,
                          useInkWell: false,
                          //   hasIcon: false,
                          iconPlacement: ExpandablePanelIconPlacement.left,
                          headerAlignment:
                              ExpandablePanelHeaderAlignment.center,
                        ),
                        header: ListTile(
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sequencesList[i].sequenceName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              // IconButton(
                              //   onPressed: () {},
                              //   icon: Icon(
                              //     Icons.arrow_drop_down,
                              //     color: Colors.grey,
                              //   ),
                              // ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await deleteSequence(
                                      jobID: sequencesList[i].id!);

                                  //      await getAllSequncesByJobId(
                                  //        jobId: widget.jobId);

                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TaskList(jobId: widget.jobId)));
                                  //    setState(() {});
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        collapsed: const SizedBox(),
                        expanded: Column(
                          children: [
                            // Text(
                            //   sequencesList[i].id.toString(),
                            // ),
                            // Text(
                            //   sequencesList[i].job!,
                            // ),

                            for (int i = 0; i < allTasks2List.length; i++) ...{
                              // Text(allTasks2List[i]['id'].toString())
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TaskDetail(
                                              taskId: allTasks2List[i]['id'])));
                                },
                                child: TaskCard(
                                    id: allTasks2List[i]['id'],
                                    taskName: allTasks2List[i]['pmkNumber'],
                                    description: allTasks2List[i]
                                        ['description'],
                                    startDate: DateTime.parse(
                                        allTasks2List[i]['startedAt']),
                                    endDate: DateTime.parse(
                                        allTasks2List[i]['completedAt']),
                                    status: allTasks2List[i]['status'],
                                    statusColor: Colors.transparent,
                                    onSelected: (_) {}),
                              ),
                            }
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              },

              /////////////////////////////////////////////////////
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

              Expanded(
                child: FutureBuilder<List<Task>>(
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
                        itemCount: getFilteredTasks(snapshot.data!).length,
                        itemBuilder: (context, index) {
                          final tasks = getFilteredTasks(snapshot.data!)[index];
                          final statusColor =
                              index % 2 == 0 ? Colors.green : Colors.red;
                          print(tasks.taskDate);
                          return TaskCard(
                              id: tasks.id,
                              taskName: tasks.pmkNumber,
                              description: tasks.description!,
                              startDate: tasks.taskDate,
                              endDate: tasks.taskDate,
                              status: tasks.status,
                              statusColor: statusColor,
                              onSelected: (index) {
                                setState(() {
                                  if (_selectedTaskIndex == index) {
                                    _selectedTaskIndex = -1;
                                  } else {
                                    _selectedTaskIndex = index;
                                  }
                                });
                              });
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskListHeader extends StatelessWidget {
  final Function(String?) onDropdownChanged;
  final String selectedValue; // Add the selectedValue property here

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
                        isExpanded: true, // Set isExpanded to true
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
