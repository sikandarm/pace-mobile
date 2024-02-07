import 'dart:convert';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pace_application_fb/screens/Dashboard.dart';
import 'package:pace_application_fb/screens/welcome_screen.dart';
import 'package:pace_application_fb/services/check_user_phone.dart';
import 'package:pace_application_fb/services/check_user_role.dart';
import 'package:pace_application_fb/services/facbook_api_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/getAllRoles.dart';
import '../utils/constants.dart';

class GoogleSignInScreen extends StatefulWidget {
  GoogleSignInScreen({
    super.key,
    // required this.facebookLoginModel
    required this.userCredentials,
  });

  // final String fbID;

  final UserCredential? userCredentials;

  // final String name;
  //final FacebookLoginModel facebookLoginModel;

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  var phone = TextEditingController();

  // final Stirng fcmToken;
  // final emailController = TextEditingController();

  // final nameController = TextEditingController();

  int _selectedRoleIndex = 0;
  String _selectedRoleName = "";
  int _selectedRoleId = 1;
  late Future<List<allRolesModel>> _futureRoles = Future.value([]);
  late List<String> _lsRoles; // List to store role names

  @override
  void initState() {
    checkUserPhoneByApi(widget.userCredentials!.user!.email!);
    checkUserRoleByApi(widget.userCredentials!.user!.email!);
    _futureRoles = fetchAllRoles();
    _lsRoles = [];
    saveProfileImageToSharedPrefs();
    print('widget.userCredentials!.user!.email!: ' +
        widget.userCredentials!.user!.email!);

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

  Future<void> saveProfileImageToSharedPrefs() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString(BL_USER_GOOGLE_OR_FACEBOOK_IMAGE,
        widget.userCredentials!.user!.photoURL!);
    print('photo url saved locally');
  }

  CheckUserPhoneModel? checkUserPhoneModel = CheckUserPhoneModel(
    success: false,
  );

  Future<void> checkUserPhoneByApi(String email) async {
    checkUserPhoneModel = await checkUserPhone(email: email);
    phone.value = TextEditingValue(text: checkUserPhoneModel!.data!);
    setState(() {});
  }

  CheckUserRoleModel? checkUserRoleModel;

  Future<void> checkUserRoleByApi(String email) async {
    checkUserRoleModel = await checkUserRole(email: email);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            // color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
            //     ? Colors.white.withOpacity(0.92)
            //     : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          'Google Sign In',
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
            // color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
            //     ? Colors.white
            //     : Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(27.0),
        child: Column(
          children: [
            SizedBox(
              height: 11,
            ),
            CircleAvatar(
                radius: isTablet ? 70 : 45,
                backgroundImage:
                    NetworkImage(widget.userCredentials!.user!.photoURL!)),
            SizedBox(
              height: 33,
            ),
            TextField(
              style: TextStyle(
                fontSize: isTablet ? 24 : 15,
                //   color: Colors.black.withOpacity(0.65),
                fontWeight: FontWeight.w500,
              ),
              //   controller: nameController,
              keyboardType: TextInputType.emailAddress,
              decoration: textFieldDecoration(
                widget.userCredentials!.user!.displayName!,
                false,
                enabled: false,
                isTablet: isTablet,
                context: context,
              ),
            ),
            SizedBox(
              height: 11,
            ),
            TextField(
              style: TextStyle(
                fontSize: isTablet ? 24 : 15,
                //   color: Colors.black.withOpacity(0.65),
                fontWeight: FontWeight.w500,
              ),
              //   controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: textFieldDecoration(
                widget.userCredentials!.user!.email!,
                false,
                enabled: false,
                isTablet: isTablet,
                context: context,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 100,
              child: TextField(
                style: TextStyle(
                  fontSize: isTablet ? 24 : 15,
                  // color: Colors.black.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                ),
                textAlignVertical: TextAlignVertical.center,
                controller: phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(12),
                  // Limit input to 12 characters (including mask characters)
                  PhoneNumberFormatter(),
                  // Only allow digits
                ],
                decoration: textFieldDecoration(
                  checkUserPhoneModel!.data == null
                      ? "Phone"
                      : checkUserPhoneModel!.data.toString(),
                  false,
                  enabled: checkUserPhoneModel!.data == null ? true : false,
                  isTablet: isTablet,
                  context: context,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<allRolesModel>>(
              future: _futureRoles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while fetching data
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  _lsRoles = snapshot.data!.map((role) => role.name!).toList();

                  return Visibility(
                    visible: !checkUserRoleModel!.data!,
                    child: SizedBox(
                      height: 100,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: _selectedRoleIndex),
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedRoleIndex = index;
                            _selectedRoleName = _lsRoles[index];
                            _selectedRoleId = snapshot.data![index].id!;
                            print("$_selectedRoleName-$_selectedRoleId");
                          });

                          print(_selectedRoleName);
                        },
                        children: _lsRoles.map((String role) {
                          return Center(
                            child: Text(role),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                } else {
                  return Text('No data available.');
                }
              },
            ),
            SizedBox(
              height: 50,
            ),
            SizedBox(
              // width: double.infinity,
              // height: 50.0,
              width: MediaQuery.of(context).size.width * 0.95,

              //  height: 50.0,
              height: MediaQuery.of(context).size.height * 0.066,
              child: Container(
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
                    if (phone.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please provide a phone number!')));
                      return;
                    }
                    // _validateFields();
                    // if (nameController.text.trim().isEmpty) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(content: Text('Please provide a name!')));
                    //   return;
                    //  } else
                    // if (emailController.text.trim().isEmpty) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(content: Text('Please provide an email!')));
                    //   return;
                    // } else if (!EmailValidator.validate(
                    //     emailController.text.trim())) {
                    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //       content: Text('Please provide a valid email!')));
                    // }

                    var _fcmToken = '';
                    final fcmTokenBox = await Hive.openBox('fcmToken');

                    if (fcmTokenBox.get('fcmToken') == null) {
                      _fcmToken =
                          (await FirebaseMessaging.instance.getToken())!;
                      await fcmTokenBox.put('fcmToken', _fcmToken);
                    } else {
                      _fcmToken = await fcmTokenBox.get('fcmToken');
                    }

                    print('dahi wala token:' + _fcmToken.toString());
                    print('roleid:' + _selectedRoleId.toString());
                    final apiResponse = await http
                        .post(Uri.parse('$BASE_URL/auth/socialLogin'), body: {
                      'email': widget.userCredentials!.user!.email!,
                      'Uid': widget.userCredentials!.user!.uid!,
                      'name': widget.userCredentials!.user!.displayName!,
                      'roleId': _selectedRoleId.toString(),
                      'phone': phone.text,
                      'fcm_token': _fcmToken,
                    });
                    // final tokenBox = await Hive.openBox('tokenBox');
                    // final token = tokenBox.get('token');

                    print('api res google: ' + apiResponse.body.toString());
                    final decodedResponse = jsonDecode(apiResponse.body);
                    print(
                        'socialLogin response: ' + decodedResponse.toString());

                    if (decodedResponse['success'] == false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(decodedResponse['message'])));
                    }

                    if (decodedResponse['success'] == true) {
                      print('myy token: ' + decodedResponse['data']['token']);
                      Map<String, dynamic>? decodedToken =
                          JwtDecoder.decode(decodedResponse['data']['token']);

                      final tokenBox = await Hive.openBox('tokenBox');
                      await tokenBox.put(
                          'token', decodedResponse['data']['token']);

                      print(
                          'MYYYYYY DECODED TOKEN: ' + decodedToken.toString());

                      saveBoolToSP(true, BL_USER_LOGGED_IN);

                      saveStringToSP(
                          decodedResponse['data']['token'], BL_USER_TOKEN);
                      // saveStringToSP(
                      //   decodedToken.toString(), BL_USER_TOKEN); error ara hy ismai
                      saveIntToSP(decodedToken['id'], BL_USER_ID);
                      print('decodedToken["id"]: ' + BL_USER_ID.toString());
                      saveStringToSP(
                          decodedToken['firstName'], BL_USER_FULL_NAME);

                      String lsUserRoles = json.encode(decodedToken['roles']);
                      print(decodedToken['roles']);
                      print("permissions");
                      print(decodedToken['permissions']);
                      String lsUserPermissions =
                          json.encode(decodedToken['permissions']);

                      saveStringToSP(lsUserRoles, BL_USER_ROLES);
                      saveStringToSP(lsUserPermissions, BL_USER_PERMISSIONS);

                      // Navigator.pushReplacement(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => DashboardScreen()));

                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => DashboardScreen()),
                      //     (route) => false);   it is exactly correct

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomeScreen()),
                          (route) => false);
                    }

                    //   String uEmail = emailText.text;
                    //  String uPassword = passwordText.text;

                    if (true) {
                      //    mockProgressBar();
                      //    callLoginApi(uEmail, uPassword);
                    } else {
                      showSnackbar(context, "Please input valid data.");
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
                  child: Text("Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 30 : 15.5,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.length <= 3) {
      return TextEditingValue(
          text: text, selection: TextSelection.collapsed(offset: text.length));
    } else if (text.length <= 6) {
      return TextEditingValue(
        text: '${text.substring(0, 3)}-${text.substring(3)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    } else {
      return TextEditingValue(
        text:
            '${text.substring(0, 3)}-${text.substring(3, 6)}-${text.substring(6)}',
        selection: TextSelection.collapsed(offset: text.length + 2),
      );
    }
  }
}
