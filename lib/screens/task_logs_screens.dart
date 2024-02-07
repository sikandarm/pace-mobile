import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pace_application_fb/utils/constants.dart';

import '../services/get_task_logs.dart';

class TaskLogsScreen extends StatefulWidget {
  const TaskLogsScreen({super.key, required this.taskId});
  final int taskId;

  @override
  State<TaskLogsScreen> createState() => _TaskLogsScreenState();
}

class _TaskLogsScreenState extends State<TaskLogsScreen> {
  @override
  void initState() {
    callApiMethods();
    super.initState();
  }

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

  List<TasklogModel> taskLogsListRemovedNullComment = [];
  List<TasklogModel> taskLogsList = [];
  bool isLoading = false;
  Future<void> callApiMethods() async {
    isLoading = true;
    taskLogsList = await getTaskLogs(taskId: widget.taskId);
    //  taskLogsListRemovedNullComment.add(Task)

    for (var taskLog in taskLogsList) {
      if (taskLog.comment != 'null' && taskLog.comment != null) {
        taskLogsListRemovedNullComment.add(taskLog);
      }
    }

    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
            // color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
            //     ? Colors.white
            //     : Colors.black,
            ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the last screen in the stack
            //   Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Task Logs",
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(right: 10.0),
              //   child: Stack(
              //     children: [
              //       InkWell(
              //         onTap: () {
              //           // if (_blShowNotificationsList) {
              //           //   Navigator.push(
              //           //     context,
              //           //     MaterialPageRoute(
              //           //         builder: (context) =>
              //           //             const NotificationsScreen()),
              //           //   );
              //           // } else {
              //           //   showToast(
              //           //       "You do not have permission to see notifications.");
              //           // }
              //         },
              //         child: Image.asset(
              //           "assets/images/ic_bell.png",
              //           width: 32,
              //           height: 32,
              //         ),
              //       ),
              //       Positioned(
              //         top: 5,
              //         right: 0,
              //         child: Container(
              //           padding: const EdgeInsets.all(5),
              //           decoration: BoxDecoration(
              //             color: Colors.red,
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () {
              //     // Navigator.push(
              //     //   context,
              //     //   MaterialPageRoute(
              //     //       builder: (context) => const ProfileScreen()),
              //     // );
              //   },
              //   child: const Padding(
              //     padding: EdgeInsets.only(right: 10.0, left: 5.0),
              //     child: CircleAvatar(
              //       backgroundImage: AssetImage('assets/images/ic_profile.png'),
              //       radius: 15,
              //     ),
              //   ),
              // ),
            ],
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   final list = await getTaskLogs(taskId: 165);
      //   print('Logs List: $list');

      //   print(list[0].breakEnd.toString());
      // }),

      body: isLoading
          ? Center(
              child: Column(
                children: [
                  SizedBox(height: isTablet ? 400 : 150),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : taskLogsListRemovedNullComment.isEmpty
              ? Center(
                  child: Text(
                  'No logs found!',
                  style: TextStyle(),
                ))
              : SingleChildScrollView(
                  child: Container(
                    //   width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        const SizedBox(height: 11),
                        SizedBox(height: isTablet ? 13 : 0),
                        Scrollbar(
                          scrollbarOrientation: ScrollbarOrientation.top,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              //  margin: EdgeInsets.symmetric(horizontal: 7),
                              //  width: MediaQuery.of(context).size.width,
                              child: DataTable(
                                headingRowColor: MaterialStatePropertyAll(
                                    Colors.grey.withOpacity(0.3)),
                                //    dataRowHeight: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                rows: [
                                  for (int i = 0;
                                      i < taskLogsListRemovedNullComment.length;
                                      i++) ...{
                                    DataRow(cells: [
                                      // DataCell(
                                      //   Text(
                                      //     taskLogsList[i].id.toString(),
                                      //     style: TextStyle(
                                      //       fontSize: 12,
                                      //     ),
                                      //     softWrap: true,
                                      //   ),
                                      // ),
                                      // DataCell(
                                      //   Text(
                                      //     taskLogsList[i].taskId.toString(),
                                      //     style: TextStyle(
                                      //       fontSize: 12,
                                      //     ),
                                      //     softWrap: true,
                                      //   ),
                                      // ),
                                      DataCell(
                                        Container(
                                          width: isTablet ? 250 : 120,
                                          child: Text(
                                            formatDateTime(
                                              DateTime.parse(
                                                taskLogsList[i].breakStart!,
                                              ),
                                            ),
                                            softWrap: true,
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Container(
                                        width: isTablet ? 250 : 120,
                                        child: Text(
                                          taskLogsListRemovedNullComment[i]
                                                      .breakEnd ==
                                                  null
                                              ? 'waiting for task end!'
                                              : formatDateTime(DateTime.parse(
                                                  taskLogsListRemovedNullComment[
                                                          i]
                                                      .breakEnd!)),
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                          softWrap: true,
                                        ),
                                      )),
                                      DataCell(
                                        Container(
                                          width: isTablet ? 290 : 120,
                                          // width: 250,
                                          // height: 1100,
                                          child: Text(
                                            taskLogsListRemovedNullComment[i]
                                                .comment
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                      // DataCell(
                                      //   Container(
                                      //     width: isTablet ? 200 : 120,
                                      //     // width: 250,
                                      //     // height: 1100,
                                      //     child: Text(
                                      //       taskLogsListRemovedNullComment[i]
                                      //           .iteration
                                      //           .toString(),
                                      //       style: TextStyle(
                                      //         fontSize: 12,
                                      //       ),
                                      //       softWrap: true,
                                      //     ),
                                      //   ),
                                      // ),
                                    ]),
                                  }
                                ],
                                columns: [
                                  // DataColumn(
                                  //   label: Text(
                                  //     'ID',
                                  //     style: TextStyle(
                                  //       fontWeight: FontWeight.bold,
                                  //       fontSize: 14,
                                  //     ),
                                  //   ),
                                  // ),
                                  // DataColumn(
                                  //   label: Text(
                                  //     'Task ID',
                                  //     style: TextStyle(
                                  //       fontWeight: FontWeight.bold,
                                  //       fontSize: 14,
                                  //     ),
                                  //   ),
                                  // ),
                                  DataColumn(
                                    label: Text(
                                      'Break Start',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Break End',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Comment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                  // DataColumn(
                                  //   label: Text(
                                  //     'Iteration',
                                  //     style: TextStyle(
                                  //       fontWeight: FontWeight.bold,
                                  //       fontSize: 14,
                                  //     ),
                                  //     softWrap: true,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    // Create a formatter with the desired format
    final formatter = DateFormat('dd/MM/yyyy h:mm a');

    // Format the DateTime object
    return formatter.format(dateTime);
  }
}
