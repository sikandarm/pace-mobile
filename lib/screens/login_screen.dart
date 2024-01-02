import 'dart:async';
import 'dart:convert';

import 'package:com_a3_pace/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../api/firebase_api.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // var emailText = TextEditingController(text: 'noman@yahoo.com');
  // var passwordText = TextEditingController(text: '12345');
  bool _passwordVisible = false;

  var emailText = TextEditingController(text: '');
  var passwordText = TextEditingController(text: '');

  String emailError = "";
  String passwordError = "";
  var _fcmToken = "";

  bool _isLoading = false;

  void mockProgressBar() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void showMsgBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  callLoginApi(String uEmail, String uPass) async {
    try {
      _fcmToken = await getStringFromSF(BL_FCM_TOKEN);

      var loginRes = await http.post(Uri.parse("$BASE_URL/auth/login"), body: {
        "email": uEmail,
        "password": uPass,
        "fcm_token": _fcmToken,
      });

      print(loginRes.body);
      Map<String, dynamic> jsonMap = jsonDecode(loginRes.body);

      if (loginRes.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonMap['message'])));

        Map<String, dynamic>? decodedToken =
            JwtDecoder.decode(jsonMap['data']['token']);

        saveBoolToSP(true, BL_USER_LOGGED_IN);
        saveStringToSP(jsonMap['data']['token'], BL_USER_TOKEN);
        saveIntToSP(decodedToken['id'], BL_USER_ID);
        saveStringToSP(decodedToken['firstName'], BL_USER_FULL_NAME);

        String lsUserRoles = json.encode(decodedToken['roles']);
        print(decodedToken['roles']);
        print("permissions");
        print(decodedToken['permissions']);
        String lsUserPermissions = json.encode(decodedToken['permissions']);

        saveStringToSP(lsUserRoles, BL_USER_ROLES);
        saveStringToSP(lsUserPermissions, BL_USER_PERMISSIONS);

        // print("USER NAME-->" + decodedToken['firstName']);
        // print("USER ID-->${decodedToken['id']}");
        print(jsonMap['data']['token']);
        // print(jsonRoles);

        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/welcomeScreen');
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(jsonMap['message'])));
      }
    } catch (e) {
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
                  onTap: () => {
                    Navigator.pushReplacementNamed(context, '/midwayscreen')
                  },
                  child: Image.asset(
                    'assets/images/ic_back.png',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            )),
            Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: double.infinity,
                      child: Text("Login",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                          )),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: emailText,
                      keyboardType: TextInputType.emailAddress,
                      decoration: textFieldDecoration("Email", false),
                    ),
                    const SizedBox(height: 10),
                    // TextField(
                    //     controller: passwordText,
                    //     obscureText: true,
                    //     obscuringCharacter: "*",
                    //     decoration: textFieldDecoration("Password", true)),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextField(
                            controller: passwordText,
                            textAlignVertical: TextAlignVertical.center,
                            obscureText: !_passwordVisible,
                            obscuringCharacter: '*',
                            keyboardType: TextInputType.visiblePassword,
                            decoration: textFieldDecoration("Password", true),
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
                    SizedBox(
                      width: double.maxFinite,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/resetpassword');
                          },
                          child: const Text("Forgot Password",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              )),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          )
                        ]),
                        child: ElevatedButton(
                          onPressed: () {
                            // _validateFields();

                            String uEmail = emailText.text;
                            String uPassword = passwordText.text;

                            if (uEmail.isNotEmpty && uPassword.isNotEmpty) {
                              mockProgressBar();
                              callLoginApi(uEmail, uPassword);
                            } else {
                              showSnackbar(context, "Please input valid data.");
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          child: const Text("Login",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.pushReplacementNamed(context, '/signup')
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            text: 'Dont have an account?',
                            style: TextStyle(color: Colors.grey),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' Register',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      width: double.maxFinite,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Text("OR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            )),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildSocialIcon(
                            context, 'assets/images/google.png', true),
                        _buildSocialIcon(
                            context, 'assets/images/apple.png', false),
                        _buildSocialIcon(
                            context, 'assets/images/facebook.png', false),
                      ],
                    ),
                    const SizedBox(height: 50),
                    if (_isLoading)
                      const CircularProgressIndicator(
                        color: Colors.blueAccent,
                        backgroundColor: Colors.grey,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSocialIcon(
    BuildContext context, String imagePath, bool isForGoogle) {
  return Expanded(
    child: InkWell(
      onTap: () async {
        // Button pressed action
        if (isForGoogle) {
          User? user = await FirebaseApi().signInWithGoogle();
          if (user != null) {
            // Handle successful sign-in, e.g., navigate to another screen.
            // print("User-->" + user.email.toString());
            // print("User-->" + user.displayName.toString());

            List<String> nameParts = user.displayName.toString().split(" ");
            String firstName = nameParts[0];
            String lastName = nameParts[1];

            saveStringToSP(user.email.toString(), BL_USER_EMAIL);
            saveStringToSP(firstName, BL_USER_FNAME);
            saveStringToSP(lastName, BL_USER_LNAME);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUpScreen(),
              ),
            );

          } else {
            // Handle sign-in failure.
            print("User auth FAIL");
          }
        } else {
          // await FirebaseApi().signInWithFacebook();
        }
      },
      child: Image.asset(
        imagePath,
        width: 40,
        height: 40,
      ),
    ),
  );
}
