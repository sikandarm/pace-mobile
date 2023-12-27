import 'package:com_a3_pace/screens/purchase_order.dart';
import 'package:com_a3_pace/screens/view_contacts_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../components/dashboard_card.dart';
import '../components/job_list_card.dart';
import '../services/job_service.dart';
import '../services/purchase_order_items_list.dart';
import '../utils/constants.dart';
import 'InventoryList.dart';
import 'ProfileScreen.dart';
import 'SharedCARListScreen.dart';
import 'notification.dart';

bool blShowProfile = false;
bool blShowJobList = false;
bool blShowNotificationsList = false;
bool blShowSharedCAR = false;
bool blShowCAR = false;
bool blShowInventory = false;

bool b1ViewDashBoardWithGraphs =
    false; // not used yet as was found b1ShowInventoryList

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<List<Job>> _futureJob = Future.value([]);
  String jobCount = "";
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void updateJobCount(int count) {
    setState(() {
      jobCount = count.toString();
    });
  }

  Future<void> _refreshData() async {
    // Simulate a delay for fetching new data
    // await Future.delayed(const Duration(seconds: 2));

    // Fetch new data
    List<Job> refreshedJobs = await fetchJobs();

    // Update the job count and the job list
    setState(() {
      _futureJob = Future.value(refreshedJobs);
      updateJobCount(refreshedJobs.length);
    });
  }

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      hasNewNotifiaction=true;
      setState(() {

      });
    });


    super.initState();

    _futureJob = fetchJobs();
    _futureJob.then((jobs) {
      updateJobCount(jobs.length);
    });

    checkPermissionAndUpdateBool("view dashboard with graphs", (localBool) {
      b1ViewDashBoardWithGraphs = localBool;
    }); // not used yet

    checkPermissionAndUpdateBool("view_profile", (localBool) {
      blShowProfile = localBool;
    });

    checkPermissionAndUpdateBool("view_job", (localBool) {
      blShowJobList = localBool;
    });

    checkPermissionAndUpdateBool("view_notifications", (localBool) {
      blShowNotificationsList = localBool;
    });

    checkPermissionAndUpdateBool("view_past_cars", (localBool) {
      blShowSharedCAR = localBool;
    });

    checkPermissionAndUpdateBool("view_rejected_tasks", (localBool) {
      print(localBool);
      print("show car");
      blShowCAR = localBool;
    });

    checkPermissionAndUpdateBool("view_inventory", (localBool) {
      blShowInventory = localBool;
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
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   final items = await fetchPurchaseOrderItemsDataList();
      //   print(items.length);
      // }),
      key: scaffoldKey,
      drawer: _buildSideDrawer(context),
      appBar: _buildAppBar(context, scaffoldKey),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            _buildDashboardCard(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: 'Jobs',
                      showList: blShowInventory,
                      // showList: true,   just wrote to check if it's connected or not to something

                      subtitle: jobCount,
                      icon: 'assets/images/ic_briefcase.png',
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: [Color(0xff80C776), Color(0xff80C776)],
                      ),
                    ),
                  ),
                  Expanded(
                    child: DashboardCard(
                      title: 'Departments',
                      showList: blShowCAR,
                      subtitle: '0',
                      icon: 'assets/images/ic_dept.png',
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: [Color(0xffEA6B60), Color(0xffEA6B60)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: blShowJobList,
              child: Expanded(
                child: FutureBuilder<List<Job>>(
                  future: _futureJob,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(
                        child: Text("Error: ${snapshot.error}"),
                      );
                    } else if (!snapshot.hasData) {
                      return const Center(
                        child: Text("No Data"),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final task = snapshot.data![index];

                          return JobList(
                            jobId: task.id,
                            totalTasks: task.totalTasks,
                            completedTasks: task.completedTasks,
                            status: task.status,
                            startDate: task.startDate,
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(
    context, GlobalKey<ScaffoldState> scaffoldKey) {
  return AppBar(
    backgroundColor: Colors.white,
    leading: IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        scaffoldKey.currentState?.openDrawer(); // Open the side drawer
      },
    ),
    title: FutureBuilder<String?>(
      future: getStringFromSF(BL_USER_FULL_NAME),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          String? title = snapshot.data;
          return Text(
            "Hi, ${title ?? ''}",
            style: const TextStyle(
              color: Color(0xff1E2022),
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          );
        } else if (snapshot.hasError) {
          // Handle the error case
          return Text('Error: ${snapshot.error}');
        } else {
          // Display a loading indicator while waiting for the data
          return const CircularProgressIndicator();
        }
      },
    ),
    actions: [
      Row(
        children: [
          Visibility(
            visible: blShowNotificationsList,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {

                      hasNewNotifiaction=false;


                      print('notifications permission: ' +
                          blShowNotificationsList.toString());
                      if (blShowNotificationsList) {
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
               !hasNewNotifiaction? SizedBox():   Positioned(
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
            visible: blShowProfile,
            child: GestureDetector(
              onTap: () {
                // showModalBottomSheet(
                //     context: context,
                //     builder: (context) {
                //       return Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           ListTile(
                //             leading: const CircleAvatar(
                //               backgroundImage:
                //                   AssetImage('assets/images/ic_profile.png'),
                //               radius: 23.5,
                //             ),
                //             title: const Text('Jimmy Campbell'),
                //             onTap: () {
                //               Navigator.push(
                //                 context,
                //                 MaterialPageRoute(
                //                     builder: (context) =>
                //                         const ProfileScreen()),
                //               );
                //             },
                //             subtitle: const Text('jimmycampbell@gmail.com'),
                //           ),
                //           const Divider(),
                //           ListTile(
                //             leading: const Icon(
                //               Icons.logout,
                //               color: Color(0xFFF03738),
                //             ),
                //             title: const Text(
                //               'Log out',
                //               style: TextStyle(
                //                 color: Color(0xFFF03738),
                //               ),
                //             ),
                //             onTap: () {
                //               showDialog(
                //                 context: context,
                //                 builder: (BuildContext context) {
                //                   return AlertDialog(
                //                     title: const Text('Logout Confirmation'),
                //                     content: const Text(
                //                         'Are you sure you want to logout?'),
                //                     actions: <Widget>[
                //                       TextButton(
                //                         child: const Text('Cancel'),
                //                         onPressed: () {
                //                           Navigator.of(context).pop();
                //                         },
                //                       ),
                //                       TextButton(
                //                         child: const Text('Logout'),
                //                         onPressed: () {
                //                           Navigator.of(context).pop();
                //                           // Handle side drawer item 1 tap
                //                           saveBoolToSP(
                //                               false, BL_USER_LOGGED_IN);
                //                           saveStringToSP("", BL_USER_TOKEN);
                //
                //                           Navigator.pushNamedAndRemoveUntil(
                //                             context,
                //                             '/login',
                //                             (route) => false,
                //                           );
                //                         },
                //                       ),
                //                     ],
                //                   );
                //                 },
                //               );
                //             },
                //           ),
                //         ],
                //       );
                //     });
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
          ),
        ],
      )
    ],
  );
}

Widget _buildSideDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
          ),
          child: Center(
            child: Image.asset(
              'assets/images/SFM_Logo.png',
              // width: 120,
              // height: 120,
              width: 150,
              height: 150,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Visibility(
                      visible: blShowProfile,
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Profile'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(
                      visible: blShowSharedCAR,
                      child: ListTile(
                        title: const Text('View Shared CAR'),
                        leading: const Icon(Icons.share),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SharedCARList(),
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(
                      //     visible: blShowSharedCAR,
                      child: ListTile(
                        title: const Text('Purchase Orders'),
                        leading: const Icon(Icons.inventory),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PurchaseOrder(),
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(
                      //  visible: blShowSharedCAR,
                      child: ListTile(
                        title: const Text('View Contacts'),
                        leading: const Icon(Icons.call),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewContactsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Logout'),
                leading: const Icon(Icons.logout),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout Confirmation'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Logout'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Handle side drawer item 1 tap
                              saveBoolToSP(false, BL_USER_LOGGED_IN);
                              saveStringToSP("", BL_USER_TOKEN);

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: const Row(
            children: [
              Text(
                '\u00a9',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '2023 SFM by A3 Assurance',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDashboardCard(BuildContext context) {
  return GestureDetector(
    onTap: () {
      if (blShowInventory) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const InventoryList(),
          ),
        );
      } else {
        showToast("You do not have permission to see inventory list.");
      }
    },
    child: SizedBox(
      height: 116.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Icon(
                      Icons.dashboard,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
