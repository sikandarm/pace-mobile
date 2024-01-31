import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: Image.asset(
                  'assets/images/ic_tick.png',
                  width: isTablet ? 330 : 200,
                  height: isTablet ? 230 : 120,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              children: [
                Center(
                  child: Text("Welcome to SFM",
                      style: TextStyle(
                        color: Color(0xff2E2E2E),
                        fontSize: isTablet ? 45 : 30,
                      )),
                ),
                Center(
                  child: Text("Powered by A3 Insurance",
                      style: TextStyle(
                        color: Color(0xff6E80B0),
                        fontSize: isTablet ? 22 : 15,
                      )),
                ),
                SizedBox(height: 100),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Center(
                    child: Text("Your account has been created successfully",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff2E2E2E),
                          fontSize: isTablet ? 27 : 17,
                        )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 145),
          SizedBox(
            //  width: 333,
            //  height: 58.4,

            width: MediaQuery.of(context).size.width * 0.9,

            //  height: 50.0,
            height: MediaQuery.of(context).size.height * 0.07,
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
                  Navigator.pushReplacementNamed(context, '/dashboard');
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dashboard,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text("Goto Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 27 : 17,
                        )),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
