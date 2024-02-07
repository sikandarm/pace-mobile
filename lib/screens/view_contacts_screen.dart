import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/get_all_user_contacts.dart';
import '../utils/constants.dart';

class ViewContactsScreen extends StatefulWidget {
  const ViewContactsScreen({super.key});

  @override
  State<ViewContactsScreen> createState() => _ViewContactsScreenState();
}

class _ViewContactsScreenState extends State<ViewContactsScreen> {
  @override
  void initState() {
    callApiMethods();
    super.initState();
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

  UserContactList? contactApiData;
  bool isLoading = false;

  Future<void> callApiMethods() async {
    isLoading = true;
    contactApiData = await getAllUserContacts();
    // print('Contacts Api Data:' + contactApiData!.data.contacts.toString());

    // for (var i = 0; i < contactApiData!.data.contacts.length; i++) {
    //   print('Contacts:' + contactApiData!.data.toString());
    // }

    isLoading = false;
    setState(() {});
  }

  GlobalKey<ScaffoldState> viewContactsScreenScaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: viewContactsScreenScaffoldKey,
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

            //  if ( viewContactsScreenScaffoldKey.currentState != null && viewContactsScreenScaffoldKey.currentState!.isDrawerOpen) {
            //   Navigator.popUntil(context, (route) => route.isFirst);
            //   Navigator.pop(context);
            // } else {
            Navigator.pop(context);
            //  }
          },
        ),
        title: Text(
          "All Contacts",
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const Row(
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(right: 10.0),
              //   child: Stack(
              //     children: [
              //       InkWell(
              //         onTap: () {
              //           // if (_blShowNotificationsList) {
              //           //   Navigator.push(
              //           //     context,
              //           //     MaterialPageRoute(
              //           //         builder: (context) =>
              //           //             const NotificationsScreen()),
              //           //   );
              //           // } else {
              //           //   showToast(
              //           //       "You do not have permission to see notifications.");
              //           // }
              //         },
              //         child: Image.asset(
              //           "assets/images/ic_bell.png",
              //           width: 32,
              //           height: 32,
              //         ),
              //       ),
              //       Positioned(
              //         top: 5,
              //         right: 0,
              //         child: Container(
              //           padding: const EdgeInsets.all(5),
              //           decoration: BoxDecoration(
              //             color: Colors.red,
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () {
              //     // Navigator.push(
              //     //   context,
              //     //   MaterialPageRoute(
              //     //       builder: (context) => const ProfileScreen()),
              //     // );
              //   },
              //   child: const Padding(
              //     padding: EdgeInsets.only(right: 10.0, left: 5.0),
              //     child: CircleAvatar(
              //       backgroundImage: AssetImage('assets/images/ic_profile.png'),
              //       radius: 15,
              //     ),
              //   ),
              // ),
            ],
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   await getAllContacts();
      // }),

      body: Padding(
        padding: const EdgeInsets.all(11.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    if (contactApiData!.data!.users != null) ...{
                      for (int i = 0;
                          i < contactApiData!.data!.users!.length;
                          i++) ...{
                        Container(
                          height: isTablet ? 310 : 210,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(21.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'First Name: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 27 : 14,
                                        ),
                                      ),
                                      Text(
                                        contactApiData!
                                            .data!.users![i].firstName!,
                                        style: TextStyle(
                                          fontSize: isTablet ? 27 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Last Name: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 27 : 14,
                                        ),
                                      ),
                                      Text(
                                        contactApiData!
                                            .data!.users![i].lastName!,
                                        style: TextStyle(
                                          fontSize: isTablet ? 27 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Email: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 27 : 14,
                                        ),
                                      ),
                                      Text(
                                        contactApiData!.data!.users![i].email!,
                                        style: TextStyle(
                                          fontSize: isTablet ? 27 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Contact No: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 27 : 14,
                                        ),
                                      ),
                                      Text(
                                        contactApiData!.data!.users![i].phone
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: isTablet ? 27 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  Container(
                                    // width: double.infinity,
                                    width: MediaQuery.of(context).size.width *
                                        0.95,

                                    height: isTablet ? 70 : 45,

                                    child: ElevatedButton.icon(
                                        style: const ButtonStyle(
                                          shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)))),
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.blue),
                                          foregroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.white),
                                        ),
                                        onPressed: () async {
                                          await launchDialer(contactApiData!
                                              .data!.users![i].phone!);
                                        },
                                        icon: Icon(
                                          Icons.call,
                                          size: isTablet ? 30 : 18,
                                        ),
                                        label: Text(
                                          'Call',
                                          style: TextStyle(
                                            fontSize: isTablet ? 27 : 14,
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      }
                    }
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> launchDialer(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    //if (await canLaunch(url)) {
    await launchUrl(Uri.parse(url));
    // }
    //  else {
    //  throw 'Could not launch $url';
  }
}
