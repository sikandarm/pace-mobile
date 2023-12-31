import 'package:com_a3_pace/screens/CAR_Detail.dart';
import 'package:com_a3_pace/screens/car_list.dart';
import 'package:com_a3_pace/screens/rejected_reasons_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/dept_list_card.dart';
import '../components/task_list_card.dart';
import '../services/all_rejected_task_service.dart';
import '../services/get_all_car.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'ProfileScreen.dart';
import 'car_step_one.dart';
import 'notification.dart';

String _selectedReason = "";
bool blAddCar = false;
bool blViewCar = false;
bool _blShowNotificationsList = false;
bool blRejectedTasks = false;
int _totalEstimatedHours = 0;
double _totalCOPQ = 0.00;

class DeptList extends StatefulWidget {
  const DeptList({Key? key}) : super(key: key);

  @override
  State<DeptList> createState() => _DeptListState();
}

class _DeptListState extends State<DeptList> {
  int _selectedTaskIndex = -1;
  late Future<List<Task>> _futureTask = Future.value([]);
  String _selectedValue = "all";

  @override
  void initState() {
    super.initState();
    _futureTask = fetchAllRejectedTasks();

    checkPermissionAndUpdateBool("add_car", (localBool) {
      blAddCar = localBool;
    });

    checkPermissionAndUpdateBool("view_car", (localBool) {
      blViewCar = localBool;
    });

    checkPermissionAndUpdateBool("view_rejected_tasks", (localBool) {
      blRejectedTasks = localBool;
    });

    checkPermissionAndUpdateBool("view_notifications", (localBool) {
      _blShowNotificationsList = localBool;
    });

    _calculateTotalHours();
    _calculateTotalCOPQ();
  }

  void _calculateTotalHours() {
    _futureTask.then((tasks) {
      int total = 0;
      for (var task in tasks) {
        total += task.estimatedHour;
      }
      setState(() {
        _totalEstimatedHours = total;
      });
    });
  }

  void _calculateTotalCOPQ() {
    _futureTask.then((tasks) {
      double total = 0.00;
      for (var task in tasks) {
        total += double.parse(task.copq);
      }
      setState(() {
        _totalCOPQ = total;
      });
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
      // _selectedValue = newValue ?? "all";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RejectedReasonsScreen(),
        ),
      );
    });
  }

  // Function to filter tasks based on the selected value
  List<CAReportModel> getFilteredTasks(List<CAReportModel> allTasks) {
    switch (_selectedValue) {
      case "all":
        return allTasks;
      case "approved":
        return allTasks.where((task) => task.status == "approved").toList();
      case "rejected":
        return allTasks.where((task) => task.status == "rejected").toList();
      case "pending":
        return allTasks.where((task) => task.status == "pending").toList();
      default:
        return allTasks;
    }
  }

  Future updateCOPQ() async {
    print("updateCOPQ called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token =
        prefs.getString(BL_REJECTED_REASON) ?? "Select Rejected Reason";
    _futureTask.then((tasks) {
      double total = 0.00;
      for (var task in tasks) {
        if (token == "Select Rejected Reason") {
          total += double.parse(task.copq);
        } else if (task.rejectionReason
            .toString()
            .toLowerCase()
            .contains(token.toString().toLowerCase())) {
          print("calculate");
          total += double.parse(task.copq);
        }
      }
      setState(() {
        _selectedReason = token;
        _totalCOPQ = total;
      });
    });
  }

  Future<String> loadReasonText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token =
        prefs.getString(BL_REJECTED_REASON) ?? "Select Rejected Reason";

    _selectedReason = token;
    return token;
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
          "Dashboard",
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
          TaskListHeader(
            onDropdownChanged: _onDropdownChanged,
            selectedValue: _selectedValue,
            updateCOPQ: updateCOPQ,
          ),
          blRejectedTasks
              ? Expanded(
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
                          child: Text("No record found"),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final tasks = snapshot.data![index];
                            final statusColor =
                                index % 2 == 0 ? Colors.green : Colors.red;

                            // final rejectedReason =
                            //     snapshot.data ?? "Select Rejected Reason";

                            print("Saved Reason:$_selectedReason");

                            if (_selectedReason == "Select Rejected Reason") {
                              return TaskCard(
                                  id: tasks.id,
                                  taskName: tasks.pmkNumber,
                                  description: tasks.description!,
                                  startDate: tasks.taskDate!,
                                  endDate: tasks.taskDate!,
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
                            } else {
                              if (tasks.rejectionReason
                                  .contains(_selectedReason)) {
                                return TaskCard(
                                    id: tasks.id,
                                    taskName: tasks.pmkNumber,
                                    description: tasks.description!,
                                    startDate: tasks.taskDate!,
                                    endDate: tasks.taskDate!,
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
                              } else {
                                print("No reason matched");
                                // Return an empty container or null if you want to exclude the item
                                return Container();
                              }
                            }
                          },
                        );
                      }
                    },
                  ),

                  // chi
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class TaskListHeader extends StatelessWidget {
  final Function(String?) onDropdownChanged;
  final Function() updateCOPQ;
  final String selectedValue; // Add the selectedValue property here

  const TaskListHeader(
      {Key? key,
      required this.onDropdownChanged,
      required this.selectedValue,
      required this.updateCOPQ})
      : super(key: key);

  Future<String> loadReasonText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token =
        prefs.getString(BL_REJECTED_REASON) ?? "Select Rejected Reason";
    _selectedReason = token;
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RejectedReasonsScreen(),
                      ),
                    );
                  },
                  child: Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: const Color(0xff06A3F6),
                          width: 1.0,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          print("RejectedReasonsScreen");
                          // Add navigation logic here to go to the next screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RejectedReasonsScreen()),
                          ).then((value) {
                            print("closed");
                            updateCOPQ();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          // backgroundColor: const Color(0xff06A3F6),
                          // foregroundColor: const Color(0xff06A3F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: const BorderSide(color: Color(0xff06A3F6)),
                          ),
                        ),
                        child: FutureBuilder<String>(
                          future: loadReasonText(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(); // You can also show a loading indicator here
                            } else if (snapshot.hasError) {
                              return const Text(
                                  'Error loading data'); // Error case
                            } else {
                              return Align(
                                alignment: Alignment.center,
                                child: Text(
                                  snapshot.data ?? "Select Rejected Reason",
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xff06A3F6),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CARSTepOneScreen(),
                    ),
                  );
                },
                child: Visibility(
                  visible: blAddCar,
                  child: const Text(
                    "Add CAR",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff06A3F6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CARList(),
                    ),
                  );
                },
                child: Visibility(
                  visible: blViewCar,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "View CAR",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xff06A3F6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDashboardCard(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Expanded(
                //   child: DeptListCard(
                //     title: 'Labor Cost',
                //     subtitle: "120,000",
                //     textColor: Colors.green,
                //     gradient: LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.topRight,
                //       colors: [Color(0xffffffff), Color(0xffffffff)],
                //     ),
                //   ),
                // ),
                Expanded(
                  child: DeptListCard(
                    title: 'COPQ',
                    subtitle: _totalCOPQ.toString(),
                    textColor: Colors.orange,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Color(0xffffffff), Color(0xffffffff)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

Widget _buildDashboardCard() {
  return SizedBox(
    height: 116.0,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [Color(0xff06A3F6), Color(0xff06A3F6)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 2.0),
                    child: Icon(
                      Icons.history,
                      size: 50.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Monthly Hours",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "$_totalEstimatedHours Hours",
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
