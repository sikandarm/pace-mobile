import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../services/rejection_reason.dart';
import '../services/task_detail_service.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';

class TaskApproveRejectScreen extends StatefulWidget {
  final int taskId;
  final int? jobId;
  final DateTime? startedAt;

  // const TaskList({Key? key}) : super(key: key);
  const TaskApproveRejectScreen({
    Key? key,
    required this.taskId,
    required this.jobId,
    required this.startedAt,
  }) : super(key: key);

  @override
  State<TaskApproveRejectScreen> createState() => _TaskApproveRejectState();
}

class _TaskApproveRejectState extends State<TaskApproveRejectScreen> {
  Future<List<TaskDetailObj>> _futureTask = Future.value([]);
  // Future<List<Reason>> _futureReasons = Future.value([]);
  String _selectedValue = "approve"; // Default selected value
  // String _selectedRejectionValue = ""; // Default selected value

  // void _onDropdownChanged(String newValue) {
  //   setState(() {
  //     _selectedValue = newValue; // Update selected value
  //   });
  // }

  // void _onReasonDropdownChanged(String newValue) {
  //   setState(() {
  //     _selectedRejectionValue = newValue; // Update selected value
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _futureTask = fetchTaskDetail(widget.taskId);
    _futureTask.then((taskList) {
      if (taskList.isNotEmpty) {
        TaskDetailObj taskDetailObj =
            taskList[0]; // Access the first TaskDetailObj
        // Use the taskDetailObj as needed
        print(taskDetailObj);
      } else {
        print("No TaskDetailObj available.");
      }
    });

    // _futureReasons = fetchRejectionReasons();
  }

  @override
  Widget build(BuildContext context) {
    // final jobId = ModalRoute.of(context)!.settings.arguments;

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
          "Task Status",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SizedBox(
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskListHeader(
              taskId: widget.taskId,
              jobId: widget.jobId,
              startedAt: widget.startedAt,
              onDropdownChanged: (selectedValue) {
                setState(() {
                  _selectedValue = selectedValue!; // Update selected value
                });
              },
              selectedValue: _selectedValue,
              selectedStatusValue:
                  "approve", // Pass selected value to TaskListHeader
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class TaskListHeader extends StatefulWidget {
  final int? taskId;
  final int? jobId;
  final DateTime? startedAt;
  final String? selectedValue; // Update to nullable String
  final ValueChanged<String?>? onDropdownChanged; // Update to nullable String
  // final ValueChanged<String?>? onReasonDropdownChanged; // Update to nullable String

  final String selectedStatusValue;

  const TaskListHeader({
    Key? key,
    required this.taskId,
    required this.jobId,
    required this.startedAt,
    required this.selectedValue, // Receive selectedValue
    required this.onDropdownChanged,
    required this.selectedStatusValue,
  }) : super(key: key);

  @override
  State<TaskListHeader> createState() => _TaskListHeaderState();
}

class _TaskListHeaderState extends State<TaskListHeader> {
  String? selectedStatusValue = "approve";
  String? selectedRejectionValue;
  TextEditingController commentController = TextEditingController();

  Future<void> callUpdateTask(
      BuildContext context,
      int taskId,
      int jobId,
      DateTime startDate,
      String status,
      String comments,
      String? rejectionReason) async {
    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = await getIntFromSF('UserId');

      // ignore: unnecessary_null_comparison
      if (userId != null) {
        var request =
            http.MultipartRequest('PUT', Uri.parse('$BASE_URL/task/$taskId'));
        request.fields['userId'] = userId.toString();
        request.fields['jobId'] = jobId.toString();
        request.fields['startedAt'] =
            DateFormat('yyyy-MM-dd').format(widget.startedAt!);
        request.fields['status'] = status;

        if (comments.isNotEmpty) {
          request.fields['comments'] = comments;
        }
        if (rejectionReason != null && rejectionReason.isNotEmpty) {
          request.fields['rejectionReason'] = rejectionReason;
        }

        // print(DateFormat('yyyy-MM-dd').format(startDate));

        var response = await request.send();
        var responseString = await response.stream.bytesToString();
        // print(responseString);
        Map<String, dynamic> jsonMap = jsonDecode(responseString);

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
      print(e);
    }
  }

  List<DropdownMenuItem<String>> prepareDropDownItems(
      List<ReasonCategory> reasons) {
    List<DropdownMenuItem<String>> _items = [];

    for (var reason in reasons) {
      _items.add(DropdownMenuItem<String>(
        value: null,
        child: Text(
          reason.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ));

      for (var element in reason.children) {
        _items.add(DropdownMenuItem<String>(
          value: element.name.toLowerCase() == "misc"
              ? "${element.name} - ${element.id}"
              : element.name,
          child: Text(
            element.name,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ));
      }
    }

    return _items;
  }

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
                            value: "approve",
                            child: Text("Approve"),
                          ),
                          DropdownMenuItem(
                            value: "reject",
                            child: Text("Reject"),
                          ),
                        ],
                        onChanged: (newStatusValue) {
                          widget.onDropdownChanged?.call(newStatusValue);
                          selectedStatusValue = newStatusValue;
                          print(selectedStatusValue);
                          // call update task function here
                        },
                        value: widget.selectedValue,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24.0,
                        elevation: 16,
                        underline: const SizedBox(),
                        dropdownColor: Colors.white,
                        isExpanded: true, // Set isExpanded to true
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: widget.selectedValue == "reject",
            child: Row(
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
                      child: FutureBuilder<List<ReasonCategory>>(
                        future: fetchRejectionReasons(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<ReasonCategory> reasons = snapshot.data!;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: DropdownButton<String>(
                                  items: [
                                    const DropdownMenuItem(
                                      value:
                                          "", // Empty value to represent the initial prompt text or an unset value
                                      child: Text("Select Reason"),
                                    ),
                                    // ...reasons.map((reason) {
                                    //   return DropdownMenuItem<String>(
                                    //     value: reason.name,
                                    //     child: Text(reason.name),
                                    //   );
                                    // }).toList(),
                                    ...prepareDropDownItems(reasons)
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedRejectionValue = value;
                                      });
                                    }
                                    print("updated");
                                    print(selectedRejectionValue);
                                    // call update task function here
                                  },
                                  value: selectedRejectionValue ?? "",
                                  icon: const Icon(Icons.arrow_drop_down),
                                  iconSize: 24.0,
                                  elevation: 16,
                                  underline: const SizedBox(),
                                  dropdownColor: Colors.white,
                                  isExpanded: true,
                                ),
                              ),
                            );
                          }
                        },
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 250.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Leave SOKPI evaluation remarks',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Perform action for the second button
                    // Navigate to the last screen in the stack
                    // ignore: use_build_context_synchronously
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white, // Set button background color to blue
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.blue, // Set button text color to white
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Updating task now
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedStatusValue == "approve") {
                      callUpdateTask(
                          context,
                          widget.taskId!,
                          widget.jobId!,
                          widget.startedAt!,
                          "approved",
                          commentController.text,
                          selectedRejectionValue);
                    } else {
                      print("reject");
                      callUpdateTask(
                          context,
                          widget.taskId!,
                          widget.jobId!,
                          widget.startedAt!,
                          "rejected",
                          commentController.text,
                          selectedRejectionValue);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue, // Set button background color to blue
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white, // Set button text color to white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
