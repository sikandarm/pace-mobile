import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../services/user_profile.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'notification.dart';

bool _blEditProfile = false;
bool _blShowNotificationsList = false;

// TextEditingController firstNameController = TextEditingController();
// TextEditingController lastNameController = TextEditingController();
// TextEditingController emailController = TextEditingController();
// TextEditingController phoneController = TextEditingController();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _futureProfile;

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      hasNewNotifiaction = true;
      setState(() {});
    });
    super.initState();
    _futureProfile = fetchUserProfile();

    checkPermissionAndUpdateBool("edit_profile", (localBool) {
      _blEditProfile = localBool;
    });

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
    checkTablet();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          "Profile",
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Visibility(
            visible: _blShowNotificationsList,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          hasNewNotifiaction = false;
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
                // const Padding(
                //   padding: EdgeInsets.only(right: 10.0, left: 5.0),
                //   child: CircleAvatar(
                //     backgroundImage: AssetImage('assets/images/ic_profile.png'),
                //     radius: 15,
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<UserProfile>(
              future: _futureProfile,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Data is available, fill the TextField
                  return userProfileWidget(
                    id: snapshot.data!.id,
                    firstName: snapshot.data!.firstName,
                    lastName: snapshot.data!.lastName,
                    email: snapshot.data!.email,
                    phone: snapshot.data!.phone,
                    ratePerHour: snapshot.data!.ratePerHour,
                  );
                } else if (snapshot.hasError) {
                  // Error occurred while fetching data
                  return Text("Error: ${snapshot.error}");
                }
                // Data is still loading
                return const Center(child: CircularProgressIndicator());
              },
            ),
          )
        ],
      ),
    );
  }
}

Future<void> callUpdateUser(BuildContext context, String fName, String lName,
    String email, String phone) async {
  try {
    int? userId = await getIntFromSF('UserId');

    // ignore: unnecessary_null_comparison
    if (userId != null) {
      var request =
          http.MultipartRequest('PUT', Uri.parse('$BASE_URL/user/$userId'));
      request.fields['firstName'] = fName;
      request.fields['lastName'] = lName;
      request.fields['email'] = email;
      request.fields['phone'] = phone;

      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      print(responseString);
      Map<String, dynamic> jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        saveStringToSP(fName, BL_USER_FULL_NAME);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonMap['message'])));

        // Navigate to TaskDetail screen
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
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

// ignore: camel_case_types
class userProfileWidget extends StatefulWidget {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final int? ratePerHour;

  // final List<Roles>? roles;
  // final List<Permissions>? permissions;

  const userProfileWidget({
    Key? key,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.ratePerHour,
    // required this.roles,
    // required this.permissions,
  }) : super(key: key);

  @override
  State<userProfileWidget> createState() => _userProfileWidgetState();
}

class _userProfileWidgetState extends State<userProfileWidget> {
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

  Future<List<Widget>> buildRoleChips() async {
    try {
      final String rolesJson = await getStringFromSF(BL_USER_ROLES);

      if (rolesJson.isNotEmpty) {
        List<String> savedRoles = List<String>.from(json.decode(rolesJson));

        return savedRoles.map((role) => buildStyledChip(role)).toList();
      } else {
        // Return an empty list of chips if roles are not available in shared preferences
        return [];
      }
    } catch (e) {
      // Handle any exceptions that may occur during JSON decoding or shared preferences retrieval
      print("Error: $e");
      return [];
    }
  }

  Widget buildStyledChip(String role) {
    return Chip(
      label: Text(
        role,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 30 : 17,
        ),
      ),
      backgroundColor: Colors.blue,
      shape: const StadiumBorder(
        side: BorderSide.none, // Set the side property to none
      ),
    );
  }

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void didChangeDependencies() {
    firstNameController.text = widget.firstName!;
    lastNameController.text = widget.lastName!;
    emailController.text = widget.email!;
    phoneController.text = widget.phone!;
    checkTablet();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'First Name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 30 : 17,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextField(
              style: TextStyle(
                fontSize: isTablet ? 28 : 16.5,
              ),
              controller: firstNameController,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                // hintText: labelText,
                labelStyle: TextStyle(
                  fontSize: isTablet ? 40 : 24,
                ),
                hintStyle: TextStyle(fontSize: isTablet ? 24 : 15),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              // onChanged: onChanged,
            ),
          ),
          ////////////////////////////////////////////////////////////////////////////////////////////
          ///
          SizedBox(
            height: 7,
          ),
          Text(
            'Last Name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 30 : 17,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextField(
              style: TextStyle(
                fontSize: isTablet ? 28 : 16.5,
              ),
              controller: lastNameController,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                // hintText: labelText,
                labelStyle: TextStyle(
                  fontSize: isTablet ? 40 : 24,
                ),
                hintStyle: TextStyle(fontSize: isTablet ? 24 : 15),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              // onChanged: onChanged,
            ),
          ),
          /////////////////////////////////////////////////////////////////////////////////
          SizedBox(
            height: 7,
          ),
          Text(
            'Email',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 30 : 17,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextField(
              style: TextStyle(
                fontSize: isTablet ? 28 : 16.5,
              ),
              controller: emailController,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                // hintText: labelText,
                labelStyle: TextStyle(
                  fontSize: isTablet ? 40 : 24,
                ),
                hintStyle: TextStyle(fontSize: isTablet ? 24 : 15),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              // onChanged: onChanged,
            ),
          ),
          ////////////////////////////////////////////////////////////////////////////////
          ///
          SizedBox(
            height: 7,
          ),
          Text(
            'Phone',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 30 : 17,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextField(
              controller: phoneController,

              style: TextStyle(
                fontSize: isTablet ? 28 : 16.5,
              ),
              //    controller: controller,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                // hintText: labelText,
                labelStyle: TextStyle(
                  fontSize: isTablet ? 40 : 24,
                ),
                hintStyle: TextStyle(fontSize: isTablet ? 24 : 15),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                    14), // including spaces, '- and ()'
                PhoneNumberFormatter(),
              ],
              // onChanged: onChanged,
            ),
          ),
          ////////////////////////////////////////////////////////////////////////////////

          //    buildElements(
          //      "First Name", widget.firstName!, firstNameController, isTablet),
          //  buildElements(
          //      "Last Name", widget.lastName!, lastNameController, isTablet),
          //   buildElements("Email", widget.email!, emailController, isTablet),
          //   buildElements("Phone", widget.phone!, phoneController, isTablet),
          SizedBox(
            height: 7,
          ),
          Expanded(
            // SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Role(s)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 27 : 17,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  // height: 50,
                  child: FutureBuilder<List<Widget>>(
                    future:
                        buildRoleChips(), // Call the function to get the chips
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Show a loading indicator while waiting
                      }

                      final List<Widget> roleChips = snapshot.data ?? [];

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: roleChips,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          //   Spacer(),
          // ),
          Visibility(
            visible: _blEditProfile,
            child: SizedBox(
              width: double.infinity,
              // height: 50.0,
              child: Container(
                //   width: 340,
                width: MediaQuery.of(context).size.width * 0.95,

                //  height: 50.0,
                height: MediaQuery.of(context).size.height * 0.066,
                decoration: BoxDecoration(boxShadow: [
                  (EasyDynamicTheme.of(context).themeMode != ThemeMode.dark)
                      ? BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        )
                      : const BoxShadow(),
                ]),
                child: ElevatedButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    if (_blEditProfile) {
                      String fName = firstNameController.text;
                      String lName = lastNameController.text;
                      String email = emailController.text;
                      String phone = phoneController.text;

                      if (phoneController.text.length != 14) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Invalid phone number entered')));
                        return;
                      }

                      callUpdateUser(context, fName, lName, email, phone);
                    } else {
                      showSnackbar(context, "You do not have permission");
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Text(
                    "Update",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 30 : 15.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildElements(String labelText, String value,
      TextEditingController controller, bool isTablet) {
    controller.text = value; // Set the TextField value to the provided string

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: isTablet ? 35 : 0,
        ),
        Text(
          labelText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 30 : 17,
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextField(
            style: TextStyle(
              fontSize: isTablet ? 28 : 16.5,
            ),
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              hintText: labelText,
              labelStyle: TextStyle(
                fontSize: isTablet ? 40 : 24,
              ),
              hintStyle: TextStyle(fontSize: isTablet ? 24 : 15),
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(100),
            ],
            // onChanged: onChanged,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = _formatPhoneNumber(newValue.text);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String _formatPhoneNumber(String input) {
    // Remove non-numeric characters
    final digits = input.replaceAll(RegExp(r'\D'), '');

    // Apply phone number formatting (XXX) XXX-XXXX
    if (digits.length >= 6) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length >= 3) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    } else {
      return digits;
    }
  }
}
