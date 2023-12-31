import 'package:flutter/material.dart';

class MidwayScreen extends StatefulWidget {
  const MidwayScreen({super.key});

  @override
  State<MidwayScreen> createState() => _MidwayScreenScreenState();
}

class _MidwayScreenScreenState extends State<MidwayScreen> {
  @override
  void initState() {
    super.initState();
  }

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
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/images/bg_bottom_curve.png'),
                        fit: BoxFit.fill,
                      )),
                    ),
                    SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 2,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            'assets/images/chain.png',
                          ),
                        )),
                    SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 2,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            'assets/images/people.png',
                          ),
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 170,
              child: Image.asset(
                'assets/images/text.png',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 340,
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
                    Navigator.pushReplacementNamed(
                        context, '/login'); // move to login screen
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
                  child: const Text("Login",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 340,
              height: 50.0,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // rounded corners
                    border: Border.all(
                        color: const Color(0xff06A3F6), width: 1), // border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      )
                    ]),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, '/signup'); // move to login screen
                  },
                  style: ButtonStyle(
                    // backgroundColor:
                    //     MaterialStateProperty.all<Color>(Colors.blue),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: const Text("Register",
                      style: TextStyle(
                        color: Colors.blue,
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
