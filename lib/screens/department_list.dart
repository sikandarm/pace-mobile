import 'package:adaptive_theme/adaptive_theme.dart';
//import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/dept_list_card.dart';
import '../components/task_list_card.dart';
import '../services/all_rejected_task_service.dart';
import '../services/get_all_car.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'ProfileScreen.dart';
import 'car_list.dart';
import 'car_step_one.dart';
import 'notification.dart';
import 'rejected_reasons_screen.dart';

String _selectedReason = "";
bool blAddCar = false;
bool blViewCar = false;
bool _blShowNotificationsList = false;
bool blRejectedTasks = false;
bool _b1ShowProfile = false;
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
    FirebaseMessaging.onMessage.listen((event) {
      hasNewNotifiaction = true;
      setState(() {});
    });
    getProfileImageToSharedPrefs();
    super.initState();
    _futureTask = fetchAllRejectedTasks();

    checkPermissionAndUpdateBool("add_car", (localBool) {
      blAddCar = localBool;
    });

    checkPermissionAndUpdateBool("view_profile", (localBool) {
      _b1ShowProfile = localBool;
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

    print('total COPQ final: ' + _totalCOPQ.toString());
  }

  Future updateMonthlyHours() async {
    print("update monthly hours called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token =
        prefs.getString(BL_REJECTED_REASON) ?? "Select Rejected Reason";
    _futureTask.then((tasks) {
      double total = 0.00;
      for (var task in tasks) {
        if (token == "Select Rejected Reason") {
          total += (task.estimatedHour);
        } else if (task.rejectionReason
            .toString()
            .toLowerCase()
            .contains(token.toString().toLowerCase())) {
          print("calculate hours");
          total += (task.estimatedHour);
        }
      }

      setState(() {
        _selectedReason = token;
        _totalEstimatedHours = total.toInt();
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

  String? userProfileImage;

  Future<void> getProfileImageToSharedPrefs() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    userProfileImage =
        await sharedPrefs.getString(BL_USER_GOOGLE_OR_FACEBOOK_IMAGE);
    print('user profile image: ' + userProfileImage.toString());
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
            // Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
          },
        ),
        title: Text(
          // "Dashboard",
          "Departments",
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              Visibility(
                visible: _blShowNotificationsList,
                child: Padding(
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
                          width: isTablet ? 45 : 32,
                          height: isTablet ? 45 : 32,
                          color: AdaptiveTheme.of(context).mode ==
                                  AdaptiveThemeMode.light
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      hasNewNotifiaction
                          ? Positioned(
                              top: 5,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          : SizedBox(),
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
                    padding: EdgeInsets.only(right: 10.0, left: 5.0),
                    child: CircleAvatar(
                      backgroundImage: userProfileImage == null
                          ? AssetImage('assets/images/ic_profile.png')
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
          TaskListHeader(
            onDropdownChanged: _onDropdownChanged,
            selectedValue: _selectedValue,
            updateCOPQ: updateCOPQ,
            updatMonthlyHours: updateMonthlyHours,
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
                                  // startDate: tasks.taskDate!,
                                  // endDate: tasks.taskDate!,
                                  startDate: DateTime.now(),
                                  endDate: DateTime.now(),
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

class TaskListHeader extends StatefulWidget {
  final Function(String?) onDropdownChanged;
  final Function() updateCOPQ;
  final Function()? updatMonthlyHours;
  final String selectedValue; // Add the selectedValue property here

  const TaskListHeader({
    Key? key,
    required this.onDropdownChanged,
    required this.selectedValue,
    required this.updateCOPQ,
    required this.updatMonthlyHours,
  }) : super(key: key);

  @override
  State<TaskListHeader> createState() => _TaskListHeaderState();
}

class _TaskListHeaderState extends State<TaskListHeader> {
  Future<String> loadReasonText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token =
        prefs.getString(BL_REJECTED_REASON) ?? "Select Rejected Reason";
    _selectedReason = token;
    return token;
  }

  @override
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

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
                //   width: 165,
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
                      // height: 50.0,

                      height: isTablet ? 70 : 43,
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
                            widget.updateCOPQ();
                            widget.updatMonthlyHours!();
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
                                  //   snapshot.data ?? "Select Rejected Reason",
                                  (snapshot.data == 'Select Rejected Reason' ||
                                          snapshot.data == null)
                                      ? 'Rejected Reason'
                                      : snapshot.data.toString(),

                                  style: TextStyle(
                                    fontSize: isTablet ? 24 : 16.0,
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
                  if (!blAddCar) {
                    showToast('You do not have permissions.');
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CARSTepOneScreen(),
                    ),
                  );
                },
                child: Visibility(
                  visible: blAddCar,
                  // visible: true,
                  child: Text(
                    "Add CAR",
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 16,
                      color: Color(0xff06A3F6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (!blViewCar) {
                    showToast('You do not have permissions.');
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CARList(),
                    ),
                  );
                },
                child: Visibility(
                  visible: blViewCar,
                  // visible: true,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "View CAR",
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 16,
                        color: Color(0xff06A3F6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 5),
            ],
          ),
          const SizedBox(height: 10),
          _buildDashboardCard(isTablet),
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

Widget _buildDashboardCard(bool isTablet) {
  return SizedBox(
    height: isTablet ? 170 : 116.0,
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
                  Padding(
                    padding: EdgeInsets.only(left: 2.0),
                    child: Icon(
                      Icons.history,
                      size: isTablet ? 90 : 50.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Monthly Hours",
                        style: TextStyle(
                          fontSize: isTablet ? 30 : 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "$_totalEstimatedHours Hours",
                        style: TextStyle(
                          fontSize: isTablet ? 33 : 25,
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
