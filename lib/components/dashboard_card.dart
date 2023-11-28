import 'package:com_a3_pace/components/job_list_card.dart';
import 'package:com_a3_pace/utils/constants.dart';
import 'package:flutter/material.dart';

import '../screens/department_list.dart';

class DashboardCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == "Departments") {
          if (showList) {
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

        if (title == "Jobs") {
          if (showList) {
            //   saveStringToSP("Select Rejected Reason", BL_REJECTED_REASON);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobList(
                  jobId: 1,
                  status: 'priority',
                  totalTasks: 12,
                  completedTasks: 4,
                  startDate: DateTime.now(),
                ),
              ),
            );
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
            gradient: gradient,
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
                        icon,
                        width: 24,
                        height: 24,
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
                      title,
                      style: const TextStyle(
                        fontSize: 15,
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
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
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
