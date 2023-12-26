// ignore_for_file: use_build_context_synchronously

import 'package:com_a3_pace/screens/login_screen.dart';
import 'package:com_a3_pace/screens/verify_otp_screen.dart';
import 'package:com_a3_pace/services/forgot_password.dart';
import 'package:com_a3_pace/services/update_password.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key, required this.email});
  final String email;

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  bool isPasswordVisible = true;
  bool isConfirmPasswordVisible = true;

  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    vertical: 30.0, horizontal: 20.0),
                child: GestureDetector(
                  onTap: () {
                    print('tapped');
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Image.asset(
                    'assets/images/ic_back.png',
                    width: 20,
                    height: 20,
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
                    child: Text("Update Password",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                        )),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                        "Please enter your new password and confirm password.",
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
                      obscureText: isPasswordVisible,
                      validator: (value) {
                        ScaffoldMessenger.of(context).clearSnackBars();

                        if (value!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter new password.'),
                            ),
                          );
                          return;
                        }
                        return null;
                      },
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffF8F9FD),
                          hintText: "Password",
                          suffixIcon: GestureDetector(
                            onTap: () {
                              isPasswordVisible = !isPasswordVisible;
                              setState(() {});
                            },
                            child: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                  ),
                  const SizedBox(height: 11),
                  /////////////////////////////////////////////////////////////////////////
                  ///
                  /////////////////////////////////////////////////////////////////////////
                  ///
                  /////////////////////////////////////////////////////////////////////////
                  ///
                  /////////////////////////////////////////////////////////////////////////
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: TextFormField(
                      obscureText: isConfirmPasswordVisible,
                      validator: (value) {
                        //    ScaffoldMessenger.of(context).clearSnackBars();

                        if (value!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter confirm password.'),
                            ),
                          );
                          return;
                        }

                        return null;
                      },
                      controller: confirmPasswordController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffF8F9FD),
                          hintText: "Confirm Password",
                          suffixIcon: GestureDetector(
                            onTap: () {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                              setState(() {});
                            },
                            child: Icon(
                              isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
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
                          offset: const Offset(0, 3),
                        )
                      ]),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          if (passwordController.text.trim() !=
                              confirmPasswordController.text.trim()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Password and confirm password do no match!')));
                            return;
                          }

                          final response = await updatePasswordApi(
                              email: widget.email,
                              newPassword: passwordController.text.trim());

                          if (response.success == false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response.message!)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response.message!)));
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false);
                          }
                        },
                        style: ButtonStyle(
                          fixedSize: const MaterialStatePropertyAll(
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
                        child: const Text("Update Password",
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
