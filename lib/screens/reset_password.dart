import 'package:flutter/material.dart';

import '../services/forgot_password.dart';
import 'verify_otp_screen.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassword> {
  var emailText = TextEditingController();
  var passwordText = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var welcomeText = Text(
    //   'This is Login screen',
    //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    // );

    return Scaffold(
      body: Form(
        key: formKey,
        child: Column(
          children: [
            SafeArea(
                child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 35.0, horizontal: 25.0),
                child: GestureDetector(
                  onTap: () {
                    print('tapped');
                    Navigator.pushReplacementNamed(context, '/login');
                    //   Navigator.pushNamed(context, routeName)
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      'assets/images/ic_back.png',
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
                    child: Text("Reset Password",
                        style: TextStyle(
                          color: Colors.black,
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
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: TextFormField(
                      validator: (value) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        final RegExp emailRegExp = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (value!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter an email address.'),
                            ),
                          );
                          return;
                          //     return 'Please enter an email address.';
                        } else if (!emailRegExp.hasMatch(value)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Please enter a valid email address.'),
                            ),
                          );
                          return;
                          //   return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                      controller: emailText,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffF8F9FD),
                          hintText: "Email",
                          suffixIcon: const Icon(
                            Icons.email,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        )
                      ]),
                      child: ElevatedButton(
                        onPressed: () async {
                          //    Navigator.pushReplacementNamed(context, '/login');
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          final response = await forgotPasswordApi(
                              email: emailText.text.trim());
                          print(response.message);
                          if (response.success != true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response.message!)));

                            return;
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerifyOtpScreen(
                                    email: emailText.text.trim()),
                              ));
                        },
                        style: ButtonStyle(
                          fixedSize: MaterialStatePropertyAll(
                              Size(double.infinity, 50)),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        child: const Text("Reset",
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
      ),
    );
  }
}
