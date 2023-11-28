import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassword> {
  var emailText = TextEditingController();
  var passwordText = TextEditingController();

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
      body: Column(
        children: [
          SafeArea(
              child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: GestureDetector(
                onTap: () =>
                    {Navigator.pushReplacementNamed(context, '/login')},
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
                  child: TextField(
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
                        offset: const Offset(0, 3), // changes position of shadow
                      )
                    ]),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
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
    );
  }
}
