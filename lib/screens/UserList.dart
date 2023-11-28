import 'dart:convert';

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

    print(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context, scaffoldKey, widget.carId),
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

Widget _buildAppBar(context, GlobalKey<ScaffoldState> scaffoldKey, int carId) {
  return AppBar(
    backgroundColor: Colors.white,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
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
          return const Text(
            "User List",
            style: TextStyle(
              color: Color(0xff1E2022),
              fontWeight: FontWeight.bold,
              fontSize: 25,
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
          child: const Text(
            "Send",
            style: TextStyle(
              fontSize: 16,
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
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
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
                  radius: 25,
                  backgroundColor: widget.backgroundColor,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.firstName![0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.firstName!} ${widget.lastName!}",
                    style: const TextStyle(
                      color: Color(0xFF1E2022),
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                  Text(
                    widget.email!,
                    style: const TextStyle(
                      fontSize: 13.0,
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
