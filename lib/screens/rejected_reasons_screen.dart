import 'package:com_a3_pace/utils/constants.dart';
import 'package:flutter/material.dart';

import '../services/rejection_reason.dart';
import 'ProfileScreen.dart';
import 'department_list.dart';

List<ReasonCategory> rejectionReasonCategories = [];

class RejectedReasonsScreen extends StatefulWidget {
  const RejectedReasonsScreen({Key? key}) : super(key: key);

  @override
  State<RejectedReasonsScreen> createState() => _RejectedReasonsListState();
}

class _RejectedReasonsListState extends State<RejectedReasonsScreen> {
  @override
  void initState() {
    super.initState();
    fetchReasonCategories();
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
        iconTheme: const IconThemeData(color: Colors.black),
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
        title: const Text(
          "Rejected Reasons",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/ic_profile.png'),
                radius: 15,
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
                    padding: const EdgeInsets.only(left: 5.0, top: 10.0),
                    child: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
