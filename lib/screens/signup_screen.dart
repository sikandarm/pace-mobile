import 'dart:convert';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../services/getAllRoles.dart';
import '../utils/constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var emailText = TextEditingController();
  var passwordText = TextEditingController();
  var fName = TextEditingController();
  var lName = TextEditingController();
  var phone = TextEditingController();
  bool _passwordVisible = false;
  var _fcmToken = "";
  bool isTablet = false;

  late Future<List<allRolesModel>> _futureRoles = Future.value([]);

  int _selectedRoleIndex = 0;
  String _selectedRoleName = "";
  int _selectedRoleId = 1;
  late List<String> _lsRoles; // List to store role names

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
  void initState() {
    super.initState();
    _futureRoles = fetchAllRoles();
    _lsRoles = [];

    loadInitialData();
  }

  @override
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

  Future<List<allRolesModel>> fetchRoles() async {
    List<allRolesModel> roles =
        await _futureRoles; // Await the future to get the roles data
    return roles;
  }

  Future<void> loadInitialData() async {
    String? fNameValue = await getStringFromSF(BL_USER_FNAME);
    String? lNameValue = await getStringFromSF(BL_USER_LNAME);
    String? emailValue = await getStringFromSF(BL_USER_EMAIL);
    _fcmToken = await getStringFromSF(BL_FCM_TOKEN);

    setState(() {
      fName.text = fNameValue;
      lName.text = lNameValue;
      emailText.text = emailValue;
    });
  }

  bool validateEmail(String email) {
    return EmailValidator.validate(email);
  }

  callSignUpnApi(String fName, String lName, String emailText,
      String passwordText, String phone) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    try {
      print({
        "firstName": fName,
        "lastName": lName,
        "email": emailText,
        "password": passwordText,
        "fcm_token": _fcmToken,
        "phone": phone,
        "roleId": _selectedRoleId,
      });
      var response = await http.post(Uri.parse("$BASE_URL/user/signup"),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "firstName": fName,
            "lastName": lName,
            "email": emailText,
            "password": passwordText,
            "fcm_token": _fcmToken,
            "phone": phone,
            "roleId": _selectedRoleId,
          }));

      print(response.body);
      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonMap['message'])));

        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonMap['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));

      print("error");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
                child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 30.0, horizontal: 20.0),
                child: GestureDetector(
                  onTap: () =>
                      {Navigator.pushReplacementNamed(context, '/login')},
                  child: Image.asset(
                    'assets/images/ic_back.png',
                    width: 20,
                    height: 20,
                    color:
                        EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text("Sign Up",
                        style: TextStyle(
                          //    color: Colors.black,
                          color: EasyDynamicTheme.of(context).themeMode ==
                                  ThemeMode.dark
                              ? Colors.white
                              : Colors.black,

                          fontSize: isTablet ? 45 : 28,
                        )),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          // height: 55,
                          child: TextField(
                            style: TextStyle(
                              fontSize: isTablet ? 24 : 15,
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                            ),
                            controller: fName,
                            keyboardType: TextInputType.name,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: textFieldDecoration("First Name", false,
                                isTablet: isTablet),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          //  height: 55,
                          child: TextField(
                            style: TextStyle(
                              fontSize: isTablet ? 24 : 15,
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            controller: lName,
                            keyboardType: TextInputType.name,
                            decoration: textFieldDecoration("Last Name", false,
                                isTablet: isTablet),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    //   height: 50,
                    child: TextField(
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 15,
                        color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            12), // Limit input to 12 characters (including mask characters)
                        _PhoneNumberFormatter(), // Only allow digits
                      ],
                      decoration: textFieldDecoration("Phone", false,
                          isTablet: isTablet),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    //  height: 50,
                    child: TextField(
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 15,
                        color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      controller: emailText,
                      keyboardType: TextInputType.emailAddress,
                      decoration: textFieldDecoration("Email", false,
                          isTablet: isTablet),
                      onChanged: (value) {
                        validateEmail(value);
                        // Handle the validation result here
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        // height: 50,
                        child: TextField(
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 15,
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                          ),
                          controller: passwordText,
                          textAlignVertical: TextAlignVertical.center,
                          obscureText: !_passwordVisible,
                          obscuringCharacter: '*',
                          keyboardType: TextInputType.visiblePassword,
                          decoration: textFieldDecoration("Password", true,
                              isTablet: isTablet),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible =
                                !_passwordVisible; // Toggle the visibility state
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<allRolesModel>>(
                    future: _futureRoles,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show loading indicator while fetching data
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        _lsRoles =
                            snapshot.data!.map((role) => role.name!).toList();

                        return SizedBox(
                          height: 100,
                          //    height: isTablet ? 200 : 100,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: _selectedRoleIndex),
                            itemExtent: isTablet ? 65 : 32,
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
                                child: Text(
                                  role,
                                  style:
                                      TextStyle(fontSize: isTablet ? 33 : 22),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        return Text('No data available.');
                      }
                    },
                  ),
                  // SizedBox(
                  //   height: 100,
                  //   child: CupertinoPicker(
                  //     scrollController: FixedExtentScrollController(
                  //         initialItem: _selectedRoleIndex),
                  //     itemExtent: 40, // The height of each item in the picker
                  //     onSelectedItemChanged: (index) {
                  //       setState(() {
                  //         _selectedRoleIndex = index;
                  //         _selectedRoleName = _lsRoles[index];
                  //       });
                  //
                  //       print(_selectedRoleName);
                  //     },
                  //     children: _lsRoles.map((String role) {
                  //       return Center(
                  //         child: Text(role),
                  //       );
                  //     }).toList(),
                  //   ),
                  // ),
                  const SizedBox(height: 30),
                  SizedBox(
                    //    width: double.infinity,
                    //   height: 50.0,
                    //  width: MediaQuery.of(context).size.width * 0.95,

                    //  height: 50.0,
                    //  height: MediaQuery.of(context).size.height * 0.07,

                    width: MediaQuery.of(context).size.width * 0.95,

                    //  height: 50.0,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        (EasyDynamicTheme.of(context).themeMode !=
                                ThemeMode.dark)
                            ? BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              )
                            : const BoxShadow(),
                      ]),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigator.pushReplacementNamed(context, '/login');

                          String firstName = fName.text;
                          String lastName = lName.text;
                          String userEmail = emailText.text;
                          String userPass = passwordText.text;
                          String userPh = phone.text;

                          print("check email");
                          bool isValidEmail = validateEmail(userEmail);
                          print("checked");
                          if (firstName.isNotEmpty &&
                              lastName.isNotEmpty &&
                              userPass.isNotEmpty &&
                              userPh.isNotEmpty) {
                            if (isValidEmail) {
// mockProgressBar();
                              print("call");
                              callSignUpnApi(firstName, lastName, userEmail,
                                  userPass, userPh);
                            } else {
                              showSnackbar(
                                  context, "Please enter a valid email");
                            }
                          } else {
                            showSnackbar(context, "Please input valid data.");
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        child: Text("Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 33 : 17,
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () =>
                          {Navigator.pushReplacementNamed(context, '/login')},
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'You have an account?',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isTablet ? 25 : 14,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' Login',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: isTablet ? 25 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
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
