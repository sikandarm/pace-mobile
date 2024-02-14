import 'package:adaptive_theme/adaptive_theme.dart';
//import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pace_application_fb/screens/submit_received_bill_of_lading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/dashboard_card.dart';
import '../components/job_list_card.dart';
import '../services/job_service.dart';
import '../services/purchase_order_items_list.dart';
import '../utils/constants.dart';
import 'InventoryList.dart';
import 'ProfileScreen.dart';
import 'SharedCARListScreen.dart';
import 'bill_of_lading_screen.dart';
import 'notification.dart';
import 'purchase_order.dart';
import 'view_contacts_screen.dart';

bool blShowProfile = false;
bool blShowJobList = false;
bool blShowNotificationsList = false;
bool blShowSharedCAR = false;
bool blShowCAR = false;
bool b1ShowPurchaseOrder = false;
bool blShowInventory = false;
//////////////////////////////////
///
bool b1_bill_of_lading = false;

ValueNotifier<bool> isDarkMode = ValueNotifier(false);

bool b1ViewDashBoardWithGraphs =
    false; // not used yet as was found b1ShowInventoryList
bool b1ViewContacts = false;

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

  String? userProfileImage;

  Future<void> getProfileImageToSharedPrefs() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    userProfileImage =
        await sharedPrefs.getString(BL_USER_GOOGLE_OR_FACEBOOK_IMAGE);
    print('user profile image: $userProfileImage');
    setState(() {});
  }

  Future<void> getIPLocally() async {
    final ipBox = await Hive.openBox('ipBox');

    final ip = await ipBox.get('ip');
    print('ip in dashboard screen: $ip');
    // BASE_URL = ip;
    setState(() {});
  }

  Future<void> callAllInitStateHere() async {
    await getIPLocally();
    getProfileImageToSharedPrefs();
    FirebaseMessaging.onMessage.listen((event) {
      hasNewNotifiaction = true;
      setState(() {});
    });

    _futureJob = fetchJobs();
    _futureJob.then((jobs) {
      updateJobCount(jobs.length);
    });

    checkPermissionAndUpdateBool("view_purchasedetails", (localBool) {
      b1ShowPurchaseOrder = localBool;
    }); // not used yet

    checkPermissionAndUpdateBool("view_dashboard_with_graphs", (localBool) {
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
//view_contact

    checkPermissionAndUpdateBool("view_contact", (localBool) {
      b1ViewContacts = localBool;
    });

    checkPermissionAndUpdateBool("bill_of_lading", (localBool) {
      b1_bill_of_lading = localBool;
    });

    setState(() {});
  }

  @override
  void initState() {
    // getIPLocally();
    // getProfileImageToSharedPrefs();
    // FirebaseMessaging.onMessage.listen((event) {
    //   hasNewNotifiaction = true;
    //   setState(() {});
    // });
    callAllInitStateHere();

    super.initState();
  }

  void checkPermissionAndUpdateBool(
      String permValue, Function(bool) boolUpdater) async {
    var localBool = await hasPermission(permValue);

    setState(() {
      boolUpdater(localBool);
    });
  }

  @override
  void didChangeDependencies() {
    checkTablet();
    getThemeMode();
    super.didChangeDependencies();
  }

  AdaptiveThemeMode? currentThemeMode;

  Future<void> getThemeMode() async {
    currentThemeMode = await AdaptiveTheme.getThemeMode();
    isDarkMode.value = currentThemeMode!.isDark;

    setState(() {});
  }

  bool isTablet = false;
  void checkTablet() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // You can customize these threshold values based on your criteria
    if (screenWidth >= 768 &&
        (screenHeight >= 1024
        // || screenHeight >= 950
        )) {
      setState(() {
        isTablet = true;
      });
    }
    print('screen height is: ' + MediaQuery.of(context).size.height.toString());
    print('screen width is: ' + MediaQuery.of(context).size.width.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white.withOpacity(0.92),
      //     backgroundColor: EasyDynamicTheme.of(context).themeMode != ThemeMode.dark
      //       ? Colors.white.withOpacity(0.92)
      //     : const Color.fromARGB(255, 7, 21, 32),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   final items = await fetchPurchaseOrderItemsDataList();
      //   print(items.length);
      // }),
      key: scaffoldKey,

      drawer: _buildSideDrawer(context, isTablet, currentThemeMode),

      appBar: _buildAppBar(context, scaffoldKey, userProfileImage, isTablet),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            _buildDashboardCard(context, isTablet),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    //  width: MediaQuery.of(context).size.width * 0.47,
                    //   height: isTablet ? 200 : 125,
                    child: DashboardCard(
                      title: 'Jobs',
                      showList: blShowJobList,
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
                    //  width: isTablet
                    //      ? MediaQuery.of(context).size.width * 0.5
                    //      : MediaQuery.of(context).size.width * 0.433,
                    //  height: isTablet ? 200 : 125,
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
                          snapshot.data!.sort(
                            (a, b) => b.startDate.compareTo(a.startDate),
                          );

                          final task = snapshot.data![index];

                          return JobList(
                            jobName: task.name,
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

PreferredSizeWidget _buildAppBar(context, GlobalKey<ScaffoldState> scaffoldKey,
    String? userProfileImage, bool isTablet) {
  return AppBar(
    // backgroundColor: Colors.white,

    backgroundColor: Colors.transparent,

    leading: IconButton(
      //  color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
      //     ? Colors.white
      //    : Colors.black,
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
            style: TextStyle(
              //   color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
              //     ? Colors.white
              //   : Color(0xff1E2022),
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
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
                      hasNewNotifiaction = false;

                      print(
                          'notifications permission: $blShowNotificationsList');
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
                      width: isTablet ? 45 : 32,
                      height: isTablet ? 45 : 32,
                      //   color: Colors.white,
                      //   color: EasyDynamicTheme.of(context).themeMode ==
                      //         ThemeMode.dark
                      //   ? Colors.white
                      // : Color(0xff1E2022),
                      color: AdaptiveTheme.of(context).mode ==
                              AdaptiveThemeMode.light
                          ? Colors.black
                          : Colors.white,
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
              child: Padding(
                padding: EdgeInsets.only(right: 10.0, left: 5.0),
                child: CircleAvatar(
                  backgroundImage: userProfileImage == null
                      ? AssetImage('assets/images/ic_profile.png')
                      : NetworkImage(userProfileImage) as ImageProvider,
                  radius: isTablet ? 25 : 15,
                ),
              ),
            ),
          ),
        ],
      )
    ],
  );
}

Widget _buildSideDrawer(
    BuildContext context, bool isTablet, AdaptiveThemeMode? adaptiveThemeMode) {
  return Drawer(
    width: isTablet
        ? MediaQuery.of(context).size.width * 0.65
        : MediaQuery.of(context).size.width * 0.83,
    child: Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: isTablet ? 300 : 200,
          color: Colors.white,
          child: Image.asset(
            'assets/images/SFM_Logo.png',
          ),
        ),
        // DrawerHeader(
        //   decoration: BoxDecoration(
        //     image: DecorationImage(
        //       image: AssetImage(
        //         'assets/images/SFM_Logo.png',
        //       ),
        //       fit: isTablet ? BoxFit.contain : BoxFit.contain,
        //     ),
        //     color: Colors.white.withOpacity(0.7),
        //   ),
        //   // child: Image.asset(
        //   //   'assets/images/SFM_Logo.png',
        //   //   // width: 120,
        //   //   // height: 120,
        //   //   //   width: isTablet ? 1350 : 150,
        //   //   //   height: isTablet ? 1350 : 150,
        //   // ),
        //   child: null,
        // ),
        Expanded(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 21,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Visibility(
                      visible: blShowProfile,
                      child: ListTile(
                        leading: Icon(Icons.person, size: isTablet ? 30 : 24),
                        title: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: isTablet ? 31 : 17,
                          ),
                        ),
                        onTap: () {
                          if (!blShowProfile) {
                            showToast('You do not have permissions.');
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isTablet ? 11 : 0),
                    Visibility(
                      visible: blShowSharedCAR,
                      child: ListTile(
                        title: Text(
                          'View Shared CAR',
                          style: TextStyle(
                            fontSize: isTablet ? 31 : 17,
                          ),
                        ),
                        leading: Icon(Icons.share, size: isTablet ? 30 : 24),
                        onTap: () {
                          if (!blShowSharedCAR) {
                            showToast('You do not have permissions');
                            return;
                          }

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
                    SizedBox(height: isTablet ? 11 : 0),
                    Visibility(
                      visible: b1ShowPurchaseOrder,
                      child: ListTile(
                        title: Text(
                          'Purchase Orders',
                          style: TextStyle(
                            fontSize: isTablet ? 31 : 17,
                          ),
                        ),
                        leading:
                            Icon(Icons.inventory, size: isTablet ? 30 : 24),
                        onTap: () {
                          if (!b1ShowPurchaseOrder) {
                            showToast('You do not have permissions.');
                            return;
                          }

                          ///////////////////////////////

                          Navigator.pop(context);
////////////////////////////////
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PurchaseOrder(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isTablet ? 11 : 0),
                    Visibility(
                      visible: b1ViewContacts,
                      child: ListTile(
                        title: Text(
                          'View Contacts',
                          style: TextStyle(
                            fontSize: isTablet ? 31 : 17,
                          ),
                        ),
                        leading: Icon(
                          Icons.call,
                          size: isTablet ? 30 : 24,
                        ),
                        onTap: () {
                          if (!b1ViewContacts) {
                            showToast('You do not have permissions.');
                            return;
                          }

                          Navigator.pop(context); // closes the drawer

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ViewContactsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isTablet ? 11 : 0),
                    ////////////////////////////////////////
                    Visibility(
                      visible: b1_bill_of_lading,
                      //  visible: true,

                      child: ListTile(
                        title: Text(
                          'Bill of lading',
                          style: TextStyle(
                            fontSize: isTablet ? 31 : 17,
                          ),
                        ),
                        leading: Icon(
                          Icons.report,
                          size: isTablet ? 30 : 24,
                        ),
                        onTap: () {
                          // if (!b1ViewContacts) {
                          //   showToast('You do not have permissions.');
                          //   return;
                          // }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BillOfLading(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isTablet ? 11 : 0),
                    ////////////////////////////////////////
                    // Visibility(
                    //   //  visible: blShowSharedCAR,
                    //   child: ListTile(
                    //     title: const Text('Update Bill of lading'),
                    //     leading: const Icon(Icons.update),
                    //     onTap: () {
                    //       // if (!b1ViewContacts) {
                    //       //   showToast('You do not have permissions.');
                    //       //   return;
                    //       // }
                    //
                    //
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => SubmitReceivedStatusBillOfLadingScreen(billdata: null,),
                    //
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    // Visibility(
                    //   //  visible: blShowSharedCAR,
                    //   child: ListTile(
                    //     title: const Text('Dark Theme'),
                    //     leading: const Icon(Icons.dark_mode),
                    //     trailing: Switch.adaptive(
                    //       value: isDarkMode,
                    //       onChanged: (value) {
                    //         isDarkMode = !isDarkMode;
                    //       },
                    //     ),
                    //     onTap: () {
                    //       // if (!b1ViewContacts) {
                    //       //   showToast('You do not have permissions.');
                    //       //   return;
                    //       // }
                    //     },
                    //   ),
                    // ),
                    SizedBox(height: isTablet ? 11 : 0),
                    ValueListenableBuilder(
                      valueListenable: isDarkMode,
                      builder: (context, value, child) {
                        return ListTile(
                          title: Text(
                            'Dark Theme',
                            style: TextStyle(
                              fontSize: isTablet ? 31 : 17,
                            ),
                          ),
                          leading:
                              Icon(Icons.dark_mode, size: isTablet ? 30 : 24),
                          trailing: Switch.adaptive(
                            value: isDarkMode.value,
                            onChanged: (value) async {
                              //   AdaptiveTheme.of(context)
                              //     .toggleThemeMode(useSystem: false);
                              // AdaptiveTheme.of(context).setDark();
                              // AdaptiveTheme.of(context).toggleThemeMode(
                              //   useSystem: false,
                              // );

                              isDarkMode.value = !isDarkMode.value;

                              // if (AdaptiveTheme.of(context).theme.th==ThemeMode.dark) {

                              // }

                              final savedThemeMode =
                                  await AdaptiveTheme.getThemeMode();
                              if (savedThemeMode == AdaptiveThemeMode.dark) {
                                AdaptiveTheme.of(context).setLight();
                                isDarkMode.value = false;
                              } else {
                                AdaptiveTheme.of(context).setDark();
                                isDarkMode.value = true;
                              }

                              //    EasyDynamicTheme.of(context).themeMode =
                              //      ThemeMode.light;

                              // EasyDynamicTheme.of(context).changeTheme(
                              //     //    dynamic: true,
                              //     //   dark: true,
                              //     );

                              // print(EasyDynamicTheme.of(context)
                              //     .themeMode
                              //     .toString());

                              // if (EasyDynamicTheme.of(context).themeMode ==
                              //         ThemeMode.light ||
                              //     EasyDynamicTheme.of(context).themeMode ==
                              //         ThemeMode.system) {
                              //   isDarkMode.value = false;
                              //   //
                              //   if (EasyDynamicTheme.of(context).themeMode ==
                              //       ThemeMode.light) {
                              //     showToast('Theme changed to light mode');
                              //   }

                              //   if (EasyDynamicTheme.of(context).themeMode ==
                              //       ThemeMode.system) {
                              //     showToast('Theme changed to system mode');
                              //   }
                              // } else {
                              //   isDarkMode.value = true;
                              //   showToast('Theme Changed To Dark');
                              // }
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 17,
                  ),
                ),
                leading: Icon(Icons.logout, size: isTablet ? 30 : 24),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              'Logout Confirmation',
                              style: TextStyle(
                                fontSize: isTablet ? 30 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        content: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(fontSize: isTablet ? 24 : 16),
                            )),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: isTablet ? 26 : 15,
                                color: Colors.blue,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Logout',
                                style: TextStyle(
                                  fontSize: isTablet ? 26 : 15,
                                  color: Colors.red,
                                )),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              // Handle side drawer item 1 tap
                              saveBoolToSP(false, BL_USER_LOGGED_IN);
                              saveStringToSP("", BL_USER_TOKEN);

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );

                              final googleSignIn = GoogleSignIn();
                              await googleSignIn.signOut();
                              await FacebookAuth.instance.logOut();

                              /////
                              final sharedPrefs =
                                  await SharedPreferences.getInstance();
                              // await sharedPrefs.setString(BL_USER_GOOGLE_OR_FACEBOOK_IMAGE, widget.userCredentials!.user!.photoURL!);
                              await sharedPrefs
                                  .remove(BL_USER_GOOGLE_OR_FACEBOOK_IMAGE);
                              await sharedPrefs.clear();

                              print('photo url deleted locally');
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
          child: Row(
            children: [
              Text(
                '\u00a9',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 12,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '2023 SFM by A3 Assurance',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDashboardCard(BuildContext context, bool isTablet) {
  return GestureDetector(
    onTap: () {
      if (blShowInventory || b1ViewDashBoardWithGraphs) {
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
      height: isTablet ? 170 : 150.0, // previous was not 170 it was 130
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Icon(
                      Icons.dashboard,
                      color: Colors.white,
                      size: isTablet ? 45 : 24,
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: isTablet ? 40 : 25,
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
