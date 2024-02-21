// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';

// class VerifyOtpScreen extends StatelessWidget {
//   const VerifyOtpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 56,
//       textStyle: TextStyle(
//           fontSize: 20,
//           color: Color.fromRGBO(30, 60, 87, 1),
//           fontWeight: FontWeight.w600),
//       decoration: BoxDecoration(
//         border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
//         borderRadius: BorderRadius.circular(20),
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyDecorationWith(
//       border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
//       borderRadius: BorderRadius.circular(8),
//     );

//     final submittedPinTheme = defaultPinTheme.copyWith(
//       decoration: defaultPinTheme.decoration!.copyWith(
//         color: Color.fromRGBO(234, 239, 243, 1),
//       ),
//     );

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(33.0),
//         child: Column(
//           children: [
//             SafeArea(
//                 child: Align(
//               alignment: Alignment.topLeft,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                     vertical: 30.0, horizontal: 20.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     print('tapped');
//                     Navigator.pushReplacementNamed(context, '/login');
//                     //   Navigator.pushNamed(context, routeName)
//                   },
//                   child: Image.asset(
//                     'assets/images/ic_back.png',
//                     width: 20,
//                     height: 20,
//                   ),
//                 ),
//               ),
//             )),
//             const SizedBox(height: 20),
//             const SizedBox(
//               width: double.infinity,
//               child: Text("Reset Password",
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 25,
//                   )),
//             ),
//             const SizedBox(height: 10),
//             const SizedBox(
//               width: double.infinity,
//               child:
//                   Text("Please enter your email address to reset your account.",
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 13,
//                       )),
//             ),
//             Pinput(
//               defaultPinTheme: defaultPinTheme,
//               focusedPinTheme: focusedPinTheme,
//               submittedPinTheme: submittedPinTheme,
//               validator: (s) {
//                 return s == '2222' ? null : 'Pin is incorrect';
//               },
//               pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
//               showCursor: true,
//               onCompleted: (pin) => print(pin),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:pace_application_fb/utils/constants.dart';
import 'package:pinput/pinput.dart';

import '../services/verify_otp.dart';
import 'update_password_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  // var emailText = TextEditingController();
  // var passwordText = TextEditingController();
  // var formKey = GlobalKey<FormState>();

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // var welcomeText = Text(
    //   'This is Login screen',
    //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    // );
    final pinController = TextEditingController();
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
              child: Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () {
                print('tapped');
                //                  Navigator.pushReplacementNamed(context, '/login');
                // Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => ResetPassword(),
                //     ));
                Navigator.pop(context);
                //   Navigator.pushNamed(context, routeName)
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 35.0, horizontal: 25.0),
                child: Container(
                  //   color: Colors.red,
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    'assets/images/ic_back.png',
                    color: AdaptiveTheme.of(context).mode ==
                            AdaptiveThemeMode.light
                        ? Colors.black
                        : Colors.white,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          )),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Text("Verify OTP",
                      style: TextStyle(
                        //   color: Colors.black,
                        fontSize: 30,
                      )),
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                      "Please enter your email address to reset your account.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      )),
                ),
                const SizedBox(height: 30),
                Pinput(
                  controller: pinController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  //    validator: (s) {
                  //     // return s == '2222' ? null : 'Pin is incorrect';
                  //     return s?.length == 6 ? null : 'Enter 6 digit otp.';
                  //  },
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,

                  // onCompleted: (pin) {
                  //   if (pin.length != 6) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(content: Text('Enter 6 digit otp!')));
                  //     return;
                  //   }
                  // },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: Container(
                    decoration: BoxDecoration(boxShadow: [
                      // BoxShadow(
                      //   color: const Color.fromARGB(255, 218, 162, 162)
                      //       .withOpacity(0.5),
                      //   spreadRadius: 2,
                      //   blurRadius: 5,
                      //   offset:
                      //       const Offset(0, 3), // changes position of shadow
                      // )
                    ]),
                    child: ElevatedButton(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        if (pinController.text.length != 6) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(content: Text('Enter 6 digit otp!')));
                          showSnackbar(context, 'Enter 6 digit otp!');
                          return;
                        }

                        final response =
                            await verifyOtpApi(otp: pinController.text.trim());

                        if (response.success != true) {
                          //  ScaffoldMessenger.of(context).showSnackBar(
                          //      SnackBar(content: Text(response.message!)));
                          showSnackbar(context, response.message.toString());
                          return;
                        } else {
                          //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //         content: Text(response.message.toString())));

                          showSnackbar(context, (response.message.toString()));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UpdatePasswordScreen(email: widget.email),
                              ));
                        }

                        //    Navigator.pushReplacementNamed(context, '/login');

                        // final response = await forgotPasswordApi(
                        //     email: emailText.text.trim());
                        // print(response.message);
                        // if (response.success != true) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(content: Text(response.message!)));

                        //   return;
                        // }
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => VerifyOtpScreen(),
                        //     ));
                      },
                      style: ButtonStyle(
                        fixedSize:
                            MaterialStatePropertyAll(Size(double.infinity, 50)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      child: const Text("Verify",
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
