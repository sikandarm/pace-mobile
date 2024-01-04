// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pace_application_fb/screens/facebook_email_screen.dart';
import 'package:pace_application_fb/screens/google_sign_in_screen.dart';
import 'package:pace_application_fb/services/facbook_api_model.dart';

import '../api/firebase_api.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'signup_screen.dart';

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
  tryAutoLogin();
    super.initState();
  }

  Future<void> tryAutoLogin()async{
    final autologinBool=await     getBoolFromSF(BL_USER_LOGGED_IN);
    if(autologinBool){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
      return;
    }
  }

  void showMsgBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  callLoginApi(String uEmail, String uPass) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    String errorMsg = '';
    try {
      final fcmTokenBox = await Hive.openBox('fcmToken');

      if (fcmTokenBox.get('fcmToken') == null) {
        _fcmToken = (await FirebaseMessaging.instance.getToken())!;
        await fcmTokenBox.put('fcmToken', _fcmToken);
      } else {
        _fcmToken = await fcmTokenBox.get('fcmToken');
      }

      // initiall _fcmToken="";
      //  _fcmToken = (await FirebaseMessaging.instance.getToken())!;
      // _fcmToken = await getStringFromSF(BL_FCM_TOKEN);

      var loginRes = await http.post(Uri.parse("$BASE_URL/auth/login"), body: {
        "email": uEmail,
        "password": uPass,
        "fcm_token": _fcmToken,
      });

      // print('LOGIN RESPONSE=========================================');
      // print(loginRes.body);

      // print('JSON MAP LOGIN API:' + loginRes.body);

      Map<String, dynamic> jsonMap = jsonDecode(loginRes.body);

      // print('JSON MAP LOGIN API:' + jsonMap['message'].toString());
      // print('login token:' + jsonMap['data']['token']);

      print(loginRes.statusCode);
      print(loginRes.body);

      if (loginRes.statusCode != 200) {
        errorMsg = jsonDecode(loginRes.body)['message'];
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMsg)));
        return;
      }

      final tokenBox = await Hive.openBox('tokenBox');
      await tokenBox.put('token', jsonMap['data']['token']);

      print('today login response:'+ jsonMap.toString());
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
      } else if (loginRes.statusCode != 200) {
        errorMsg = jsonDecode(loginRes.body)['message'];
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      print('login api:$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async {
        print('button pressed');

        await loginApiFB();
        //  await FacebookAuth.instance.login();
        return;

        final a = FacebookLogin(
          debug: false,
        );
        final result = await a.logIn(permissions: [
          FacebookPermission.publicProfile,
          // FacebookPermission.email,
          // FacebookPermission.email,
        ]);

        final ok = await a.getUserProfile();
        final image = await a.getProfileImageUrl(width: 200);
        print('status ok:${ok!.firstName}image:$image');

        final AuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final fbUser =
            await FirebaseAuth.instance.signInWithCredential(credential);
        print('fb User:${fbUser.additionalUserInfo!.profile}');
      }),
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
                            context, 'assets/images/google.png', true, false),
                        _buildSocialIcon(
                            context, 'assets/images/apple.png', false, false),
                        _buildSocialIcon(
                            context, 'assets/images/facebook.png', false, true),
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

Widget _buildSocialIcon(BuildContext context, String imagePath,
    bool isForGoogle, bool isForFacebook) {
  return Expanded(
    child: InkWell(
      onTap: () async {
        print('button pressed');
        // Button pressed action
        if (isForGoogle) {
          // await loginWithGoogle();
        //  final user = await signInWithGoogleFirebase();
         // print('G Email: $user');
         final userCredentials= await signInWithGoogle();
         print('userCredentials: ' + userCredentials.toString());
         if(userCredentials!=null){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>GoogleSignInScreen(userCredentials: userCredentials,)));
         }
          return;

          // print('google button code');
          // //    User? user = await FirebaseApi().signInWithGoogle();
          // if (user != null) {
          //   // Handle successful sign-in, e.g., navigate to another screen.
          //   // print("User-->" + user.email.toString());
          //   // print("User-->" + user.displayName.toString());
          //
          //   List<String> nameParts = user.displayName.toString().split(" ");
          //   String firstName = nameParts[0];
          //   String lastName = nameParts[1];
          //
          //   saveStringToSP(user.email.toString(), BL_USER_EMAIL);
          //   saveStringToSP(firstName, BL_USER_FNAME);
          //   saveStringToSP(lastName, BL_USER_LNAME);
          //
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => const SignUpScreen(),
          //     ),
          //   );
          // } else {
          //   // Handle sign-in failure.
          //   print("User auth FAIL");
          // }
        } else if (isForFacebook) {
          print('facebook button code');
          await loginWithFacebook(context);
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

Future<LoginResult> loginWithFacebook(BuildContext context) async {
  final LoginResult result = await FacebookAuth.instance.login(
      loginBehavior: LoginBehavior.webOnly, permissions: ['public_profile',]);
  print(result.message);
  if (result.status == LoginStatus.success) {
    // Logged in successfully
    final accessToken = result.accessToken;


    print('fb access token:${accessToken!.token}');

    final profile = await FacebookAuth.instance.getUserData();
    print('==================================');
    print('fb profile data: $profile');

    //  final fbID=profile.
  final fbLoginResponse=  await facebookLoginResponse(profile);
  print('my response:'+fbLoginResponse.id.toString());
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FacebookEmailScreen(
           facebookLoginModel: fbLoginResponse,
                accessToken: result.accessToken,



          ),
        ));

    // Use the access token to get user data from Facebook
  } else {
    // Login failed
  }

  return result;
}

Future<void> loginWithGoogle() async {
  final googleSignInAccount = await GoogleSignIn().signIn();
  if (googleSignInAccount != null) {
    print('account not null');
  }
}

Future<User?> signInWithGoogleFirebase() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount == null) {
      // User canceled the sign-in process
      return null;
    }

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential authResult = await _auth.signInWithCredential(credential);
    User? user = authResult.user;

    return user;
  } catch (e) {
    print("Error during Google sign-in: $e");
    return null;
  }
}


Future<void> loginApiFB() async {
  final response = await http.post(Uri.parse('$BASE_URL/user/facebook'));
  print(response.body);
}

Future<UserCredential?> signInWithGoogle() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  try {
    // Trigger the Google Sign In process
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    // Check if the sign-in was canceled
    if (googleSignInAccount == null) return null;

    // Obtain the GoogleSignInAuthentication object
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    // Create a new credential using the GoogleSignInAuthentication object
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
// print('google sign in credentials:'+ credential.toString());
    // Sign in to Firebase with the Google Auth credentials
    return await _auth.signInWithCredential(credential);
  } catch (e) {
    print("Error during Google sign in: $e");
    return null;
  }
}