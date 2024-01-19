import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../screens/task_list.dart';
import '../utils/constants.dart';

class JobList extends StatelessWidget {
  final int jobId;
  final String status;
  final int totalTasks;
  final int completedTasks;
  final DateTime startDate;

  const JobList(
      {Key? key,
      required this.jobId,
      required this.status,
      required this.totalTasks,
      required this.completedTasks,
      required this.startDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color progressDoneColor = Color(int.parse(getProgressColorHex(status)));

    return GestureDetector(
      onTap: () {
        // Navigator.pushReplacementNamed(context, '/tasks',
        // arguments: jobId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskList(jobId: jobId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          //   color: Colors.red,
          borderRadius: BorderRadius.circular(8.0),
          //  color: Colors.white,
          //   color: Colors.white.withOpacity(0.8),

          boxShadow: [
            // BoxShadow(
            //   color: Colors.grey.withOpacity(0.5),

            //   spreadRadius: 1,
            //   blurRadius: 3,
            //   offset: const Offset(0, 3),
            // ),
          ],
        ),
        child: Card(
          // color: Colors.white.withOpacity(0.92),

          color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
              ? Colors.white.withOpacity(0.92)
              : Colors.white,

          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "#$jobId",
                      style: const TextStyle(
                        color: Color(0xFF1E2022),
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      DateFormat(US_DATE_FORMAT).format(startDate),
                      style: const TextStyle(
                        fontSize: 11.0,
                        color: Color(0xFF77838F),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(
                        color: status[0].toUpperCase() + status.substring(1) ==
                                'In_process'
                            ? Color(0xFFF4BE4F)
                            : status[0].toUpperCase() + status.substring(1) ==
                                    'Completed'
                                ? Color(0xFF63C556)
                                : getProgressColor(status),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // const Spacer(),
                    Text(
                      "$completedTasks/$totalTasks",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: EasyDynamicTheme.of(context).themeMode ==
                                ThemeMode.dark
                            ? Colors.black
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: calculatePercentage(completedTasks, totalTasks),
                  //  backgroundColor: const Color(0xFFF5F5F5),
                  backgroundColor:
                      status[0].toUpperCase() + status.substring(1) ==
                              'In_process'
                          ? Color(0xFFF4BE4F)
                          : status[0].toUpperCase() + status.substring(1) ==
                                  'Completed'
                              ? Color(0xFF63C556)
                              : getProgressColor(status),

                  valueColor: AlwaysStoppedAnimation<Color>(progressDoneColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color getProgressColor(String value) {
  if (value == 'in-process') {
    return const Color(0xFFF4BE4F);
  } else if (value == 'priority') {
    return const Color(0xFFEC6B60);
  } else if (value == 'complete') {
    return const Color(0xFF63C556);
  } else {
    return const Color(0xFFF5F5F5);
  }
}

String getProgressColorHex(String value) {
  if (value == 'in-process') {
    return 0xFFF4BE4F.toString();
  } else if (value == 'priority') {
    return 0xFFEC6B60.toString();
  } else if (value == 'complete') {
    return 0xFF63C556.toString();
  } else {
    return 0xFFF5F5F5.toString();
  }
}
