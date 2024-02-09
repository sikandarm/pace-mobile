import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import '../services/purchase_order_items_list.dart';

class MidwayScreen extends StatefulWidget {
  const MidwayScreen({super.key});

  @override
  State<MidwayScreen> createState() => _MidwayScreenScreenState();
}

class _MidwayScreenScreenState extends State<MidwayScreen> {
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
  }

  @override
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

  bool isTablet = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      // height: MediaQuery.of(context).size.height / 1.0,
                      //  height: MediaQuery.of(context).size.height,
                      height: MediaQuery.of(context).size.height * 0.95,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image:
                            AssetImage('assets/images/midway_screen_image.png'),
                        fit: BoxFit.cover,
                      )),
                    ),
                    // Container(
                    //   width: double.infinity,
                    //   height: MediaQuery.of(context).size.height / 2,
                    //   decoration: const BoxDecoration(
                    //       image: DecorationImage(
                    //     image: AssetImage('assets/images/bg_bottom_curve.png'),
                    //     fit: BoxFit.fill,
                    //   )),
                    // ),
                    // SizedBox(
                    //     width: double.infinity,
                    //     height: MediaQuery.of(context).size.height / 2,
                    //     child: Align(
                    //       alignment: Alignment.topLeft,
                    //       child: Image.asset(
                    //         'assets/images/chain.png',
                    //       ),
                    //     )),
                    // SizedBox(
                    //     width: double.infinity,
                    //     height: MediaQuery.of(context).size.height / 2,
                    //     child: Align(
                    //       alignment: Alignment.topLeft,
                    //       child: Image.asset(
                    //         'assets/images/people.png',
                    //       ),
                    //     )),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.75,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          SizedBox(
                            //   width: 340,
                            width: MediaQuery.of(context).size.width * 0.95,

                            //  height: 50.0,
                            height: MediaQuery.of(context).size.height * 0.07,
                            child: Container(
                              decoration: BoxDecoration(boxShadow: [
                                // BoxShadow(
                                //   color: Colors.grey.withOpacity(0.5),
                                //   spreadRadius: 2,
                                //   blurRadius: 5,
                                //   offset: const Offset(
                                //       0, 3), // changes position of shadow
                                // )
                              ]),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context,
                                      '/login'); // move to login screen
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                child: Text("Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 30 : 14,
                                    )),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            //   width: 340,
                            width: MediaQuery.of(context).size.width * 0.95,

                            //  height: 50.0,
                            height: MediaQuery.of(context).size.height * 0.07,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      10), // rounded corners
                                  border: Border.all(
                                      color: const Color(0xff06A3F6),
                                      width: 1), // border
                                  boxShadow: [
                                    // BoxShadow(
                                    //   color: Colors.grey.withOpacity(0.5),
                                    //   spreadRadius: 2,
                                    //   blurRadius: 5,
                                    //   offset: const Offset(
                                    //       0, 3), // changes position of shadow
                                    // )
                                  ]),
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.pushReplacementNamed(context,
                                      '/signup'); // move to login screen
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                child: Text("Register",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: isTablet ? 30 : 14,
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
            ),
            // SizedBox(
            //   width: double.infinity,
            //   height: 170,
            //   child: Image.asset(
            //     'assets/images/text.png',
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
