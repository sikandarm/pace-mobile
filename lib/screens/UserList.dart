import 'dart:convert';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';

import '../services/user_list_service.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

import 'department_list.dart';

List<int> pickedIds = [];

class UserList extends StatefulWidget {
  final int carId;
  const UserList({Key? key, required this.carId}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

callShareCAR(BuildContext context, int reportId, List<int> userId) async {
  try {
    print(jsonEncode(userId));

    var response =
        await http.post(Uri.parse("$BASE_URL/CA-report/shared"), body: {
      "reportId": reportId.toString(),
      "userId": userId.map((id) => id.toString()).toList().join(","),
    });

    print('Car share response api: ' + response.body);
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    // print(jsonMap);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(jsonMap['message'])));

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DeptList(),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(jsonMap['message'])));
    }
  } catch (e) {
    print(e);
  }
}

class _UserListState extends State<UserList> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<UserListModel>> _futureInventory = Future.value([]);
  List<Color> backgroundColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.cyan,
    Colors.purple,
    Colors.grey,
    Colors.orange
  ];

  @override
  void initState() {
    super.initState();
    pickedIds.clear();
    _futureInventory = fetchUserList();
  }

  bool isTablet = false;

  @override
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

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
      key: scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context, scaffoldKey, widget.carId, isTablet),
          Expanded(
            child: FutureBuilder<List<UserListModel>>(
              future: _futureInventory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error : ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(NO_REC_FOUND),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      Color backgroundColor =
                          backgroundColors[index % backgroundColors.length];

                      return UserListItemWidget(
                        id: item.id,
                        firstName: item.firstName,
                        lastName: item.lastName!,
                        email: item.email,
                        backgroundColor: backgroundColor,
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildAppBar(
    context, GlobalKey<ScaffoldState> scaffoldKey, int carId, bool isTablet) {
  return AppBar(
    //   backgroundColor: Colors.white,
    backgroundColor: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
        ? Color.fromARGB(255, 7, 21, 32)
        : Colors.black,

    leading: IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
            ? Colors.white
            : Colors.black,
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DeptList(),
          ),
        );
      },
    ),
    title: FutureBuilder<String?>(
      future: getStringFromSF(BL_USER_FULL_NAME),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          // String? title = snapshot.data;
          return Text(
            "User List",
            style: TextStyle(
              //   color: Color(0xff1E2022),
              color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: appBarTiltleSize,
            ),
          );
        } else if (snapshot.hasError) {
          // Handle the error case
          return Text('Error: ${snapshot.error}');
        } else {
          // Display a loading indicator while waiting for the data
          return const CircularProgressIndicator();
        }
      },
    ),
    actions: [
      GestureDetector(
        onTap: () {
          if (pickedIds.isNotEmpty) {
            callShareCAR(context, carId, pickedIds);
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Please select a user to share CAR.")));
          }
        },
        child: Container(
          margin:
              const EdgeInsets.only(right: 20.0), // Adjust the value as needed
          child: Text(
            "Send",
            style: TextStyle(
              fontSize: isTablet ? 26 : 16,
              color: Color(0xff06A3F6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )
    ],
  );
}

class UserListItemWidget extends StatefulWidget {
  const UserListItemWidget({
    Key? key,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.backgroundColor,
  }) : super(key: key);

  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final Color backgroundColor;

  @override
  _UserListItemWidgetState createState() => _UserListItemWidgetState();
}

class _UserListItemWidgetState extends State<UserListItemWidget> {
  bool isLongPressed = false;

  int getPickedUsersCount() {
    return pickedIds.length;
  }

  bool isTablet = false;

  @override
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

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
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const DeptList(),
        //   ),
        // );
      },
      onLongPress: () {
        setState(() {
          isLongPressed = !isLongPressed;
          if (isLongPressed) {
            if (!pickedIds.contains(widget.id)) {
              pickedIds.add(widget.id!);
            }
          } else {
            pickedIds.remove(widget.id);
          }
        });
      },
      child: Container(
        height: isTablet ? MediaQuery.of(context).size.height * 0.12 : 90,
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          //   color: Colors.white,
          color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
              ? Colors.white.withOpacity(0.92)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0, left: 5.0),
                child: CircleAvatar(
                  radius: isTablet ? 40 : 25,
                  backgroundColor: widget.backgroundColor,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.firstName![0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isTablet ? 27 : 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.firstName!} ${widget.lastName!}",
                    style: TextStyle(
                      color: Color(0xFF1E2022),
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 27 : 17.0,
                    ),
                  ),
                  Text(
                    widget.email!,
                    style: TextStyle(
                      fontSize: isTablet ? 23 : 13.0,
                      color: Color(0xFF77838F),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isLongPressed)
                const Icon(
                  Icons.check,
                  color: Colors.green,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
