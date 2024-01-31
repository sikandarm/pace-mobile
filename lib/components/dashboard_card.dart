import 'package:flutter/material.dart';

import '../screens/department_list.dart';
import '../screens/view_all_jobs_screen.dart';
import '../utils/constants.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final bool showList;
  final String subtitle;
  final String icon;
  final LinearGradient gradient;

  const DashboardCard({
    required this.title,
    required this.showList,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
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
    return GestureDetector(
      onTap: () {
        if (widget.title == "Departments") {
          if (widget.showList) {
            saveStringToSP("Select Rejected Reason", BL_REJECTED_REASON);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DeptList(),
              ),
            );
          } else {
            showToast("You do not have permission to see department list.");
          }
        }

        if (widget.title == "Jobs") {
          if (widget.showList) {
            //   saveStringToSP("Select Rejected Reason", BL_REJECTED_REASON);

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => JobList(
            //       jobId: 1,
            //       status: 'priority',
            //       totalTasks: 12,
            //       completedTasks: 4,
            //       startDate: DateTime.now(),
            //     ),
            //   ),
            // );

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewAllJobsScreen(),
                ));
          } else {
            showToast("You do not have permission to see job list.");
          }
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: widget.gradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Column(
              children: [
                SizedBox(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        widget.icon,
                        width: isTablet ? 40 : 24,
                        height: isTablet ? 40 : 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: isTablet ? 35 : 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
