import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/rejection_reason.dart';
import '../utils/constants.dart';
import 'ProfileScreen.dart';
import 'department_list.dart';

List<ReasonCategory> rejectionReasonCategories = [];

class RejectedReasonsScreen extends StatefulWidget {
  const RejectedReasonsScreen({Key? key}) : super(key: key);

  @override
  State<RejectedReasonsScreen> createState() => _RejectedReasonsListState();
}

class _RejectedReasonsListState extends State<RejectedReasonsScreen> {
  bool blShowProfile = false;

  void checkPermissionAndUpdateBool(
      String permValue, Function(bool) boolUpdater) async {
    var localBool = await hasPermission(permValue);

    setState(() {
      boolUpdater(localBool);
    });
  }

  @override
  void initState() {
    checkPermissionAndUpdateBool("view_profile", (localBool) {
      blShowProfile = localBool;
    });

    getProfileImageToSharedPrefs();
    super.initState();
    fetchReasonCategories();
  }

  String? userProfileImage;

  Future<void> getProfileImageToSharedPrefs() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    userProfileImage =
        await sharedPrefs.getString(BL_USER_GOOGLE_OR_FACEBOOK_IMAGE);
    print('user profile image: ' + userProfileImage.toString());
    setState(() {});
  }

  Future<void> fetchReasonCategories() async {
    try {
      final categories = await fetchRejectionReasons();
      setState(() {
        rejectionReasonCategories = categories;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
              ? Colors.white
              : Colors.black,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DeptList(),
              ),
            );
            // Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
          },
        ),
        title: Text(
          "Rejected Reasons",
          style: TextStyle(
            fontSize: appBarTiltleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Visibility(
            visible: blShowProfile,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: CircleAvatar(
                  backgroundImage: userProfileImage == null
                      ? AssetImage('assets/images/ic_profile.png')
                      : NetworkImage(userProfileImage!) as ImageProvider,
                  radius: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: rejectionReasonCategories.length,
          itemBuilder: (context, index) {
            var category = rejectionReasonCategories[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  // onTap: () {
                  //   print(category.name);
                  //   // Navigate to the next screen using Navigator
                  //   // Pass the selected category to the next screen
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const DeptList(),
                  //     ),
                  //   );
                  // },
                  child: Padding(
                    // padding: const EdgeInsets.only(left: 5.0, top: 10.0), // old one
                    padding: const EdgeInsets.only(left: 5.0, top: 13.0),
                    child: Center(
                      child: Text(
                        category.name.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: category.children.map((reason) {
                    return InkWell(
                      onTap: () {
                        print(reason.name);
                        saveStringToSP(reason.name, BL_REJECTED_REASON);
                        // Navigate to the next screen using Navigator
                        // Pass the selected category and reason to the next screen
                        Navigator.pop(context);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const DeptList(),
                        //   ),
                        // );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(reason.name,
                            style: const TextStyle(fontSize: 14)),
                      ),
                    );
                  }).toList(),
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
