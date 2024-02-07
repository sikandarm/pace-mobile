import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../screens/task_list.dart';
import '../utils/constants.dart';

class JobList extends StatefulWidget {
  final int jobId;
  final String status;
  final int totalTasks;
  final int completedTasks;
  final DateTime startDate;
  final String jobName;

  const JobList({
    Key? key,
    required this.jobId,
    required this.status,
    required this.totalTasks,
    required this.completedTasks,
    required this.startDate,
    required this.jobName,
  }) : super(key: key);

  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> {
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
    Color progressDoneColor =
        Color(int.parse(getProgressColorHex(widget.status)));

    return GestureDetector(
      onTap: () {
        // Navigator.pushReplacementNamed(context, '/tasks',
        // arguments: jobId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskList(jobId: widget.jobId),
          ),
        );
      },
      child: Container(
        height: isTablet ? 145 : 100,
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
                    // Text(
                    //   "#${widget.jobId}" + "   ${widget.jobName}",
                    //   style: TextStyle(
                    //     color: Color(0xFF1E2022),
                    //     fontWeight: FontWeight.w600,
                    //     fontSize: isTablet ? 22 : 14.0,
                    //   ),
                    // ),

                    Text(
                      "${widget.jobName}",
                      style: TextStyle(
                        color: Color(0xFF1E2022),
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 22 : 14.0,
                      ),
                    ),
                    Text(
                      DateFormat(US_DATE_FORMAT).format(widget.startDate),
                      style: TextStyle(
                        // fontSize: 11.0,
                        fontSize: isTablet ? 18 : 11.0,
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
                      widget.status[0].toUpperCase() +
                          widget.status.substring(1),
                      style: TextStyle(
                        color: widget.status[0].toUpperCase() +
                                    widget.status.substring(1) ==
                                'In_process'
                            ? Color(0xFFF4BE4F)
                            : widget.status[0].toUpperCase() +
                                        widget.status.substring(1) ==
                                    'Completed'
                                ? Color(0xFF63C556)
                                : getProgressColor(widget.status),
                        // fontSize: 12.0,
                        fontSize: isTablet ? 20 : 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // const Spacer(),
                    Text(
                      "${widget.completedTasks}/${widget.totalTasks}",
                      style: TextStyle(
                        //  fontSize: 12.0,
                        fontSize: isTablet ? 19 : 12.0,
                        fontWeight: FontWeight.w500,
                        color: EasyDynamicTheme.of(context).themeMode ==
                                ThemeMode.dark
                            ? Colors.black
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 20 : 8.0),
                LinearProgressIndicator(
                  minHeight: isTablet ? 7 : 3.5,
                  value: calculatePercentage(
                      widget.completedTasks, widget.totalTasks),
                  //  backgroundColor: const Color(0xFFF5F5F5),
                  backgroundColor: widget.status[0].toUpperCase() +
                              widget.status.substring(1) ==
                          'In_process'
                      ? Color(0xFFF4BE4F)
                      : widget.status[0].toUpperCase() +
                                  widget.status.substring(1) ==
                              'Completed'
                          ? Color(0xFF63C556)
                          : getProgressColor(widget.status),

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
