//import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../screens/task_detail.dart';
import '../utils/constants.dart';

class TaskCard extends StatefulWidget {
  final int id;
  final String taskName;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final Color statusColor;
  final ValueChanged<int> onSelected;
  void Function()? onPressedDelete;
  bool showDeleteIcon;
  bool? hasPermissionToGoToTaskDetailScreen;

  TaskCard({
    Key? key,
    required this.id,
    required this.taskName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.statusColor,
    required this.onSelected,
    this.onPressedDelete,
    this.showDeleteIcon = false,
    this.hasPermissionToGoToTaskDetailScreen = false,
  }) : super(key: key);

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isChecked = false;
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   // widget.onSelected(widget.index);
      // },
      // onLongPressStart: (details) {
      //   if (!_isDragging) {
      //     setState(() {
      //       _isChecked = true;
      //       _dragOffset = details.localPosition.dx.clamp(0, 40);
      //       _isDragging = true;
      //     });
      //   }
      // },

      // onLongPressMoveUpdate: (details) {
      //   if (_isDragging) {
      //     setState(() {
      //       _dragOffset = details.localPosition.dx.clamp(0, 40);
      //     });
      //   }
      // },
      // onLongPressEnd: (_) {
      //   setState(() {
      //     _isDragging = false;
      //   });
      // },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Card(
          elevation: 0,
          child: Stack(
            children: [
              Transform.translate(
                offset: Offset(_dragOffset, 0),
                child: ClipPath(
                  clipper: _TaskCardClipper(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: TaskWidget(
                    hasPermissionToGoToTaskDetailScreen:
                        widget.hasPermissionToGoToTaskDetailScreen,
                    showDeleteIcon2: widget.showDeleteIcon,
                    onPressedDelete2: widget.onPressedDelete,
                    taskId: widget.id,
                    taskName: widget.taskName,
                    description: widget.description,
                    status: widget.status,
                    statusColor: widget.statusColor,
                    startDate: widget.startDate,
                  ),
                ),
              ),
              if (_isChecked)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 40,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Checkbox(
                        value: true,
                        onChanged: null,
                        fillColor: MaterialStateProperty.all(Colors.blue),
                        shape: const CircleBorder(),
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
}

class _TaskCardClipper extends CustomClipper<Path> {
  final ShapeBorder shape;

  _TaskCardClipper({required this.shape});

  @override
  Path getClip(Size size) {
    final path = shape.getOuterPath(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    final leftEdge = Rect.fromLTWH(0, 0, 40, size.height);
    path.addRRect(RRect.fromRectAndCorners(
      leftEdge,
      topLeft: const Radius.circular(10),
      bottomLeft: const Radius.circular(10),
    ));
    return path;
  }

  @override
  bool shouldReclip(_TaskCardClipper oldClipper) => true;
}

class TaskWidget extends StatefulWidget {
  final int taskId;
  final String taskName;
  final String description;
  final String status;
  final Color statusColor;
  final DateTime? startDate;
  void Function()? onPressedDelete2;
  bool? showDeleteIcon2;
  bool? hasPermissionToGoToTaskDetailScreen;

  TaskWidget({
    Key? key,
    required this.taskId,
    required this.taskName,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.startDate,
    this.onPressedDelete2,
    this.showDeleteIcon2,
    this.hasPermissionToGoToTaskDetailScreen,
  }) : super(key: key);

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
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
    // final borderColor = statusColor.withOpacity(0.5);
    // final bgColor = statusColor.withOpacity(0.1);
    return GestureDetector(
      onTap: widget.hasPermissionToGoToTaskDetailScreen == true
          ? () {
              print('start date in task_list_card: ' +
                  widget.startDate.toString());

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetail(taskId: widget.taskId),
                ),
              );
            }
          : () async {
              //   await Fluttertoast.cancel();
              //  showToast('You do not have permissions');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetail(taskId: widget.taskId),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: setCardColor(widget.status),
          border: Border(
            left:
                BorderSide(color: setCardBorderColor(widget.status), width: 8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pmk# ${widget.taskName}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 25 : 14.0,
                            // color: EasyDynamicTheme.of(context).themeMode ==
                            //         ThemeMode.dark
                            //     ? Colors.black
                            //     : Colors.black,
                            color: Colors.black),
                      ),
                      Text(
                        widget.startDate == null
                            ? "N/A"
                            : DateFormat(US_DATE_FORMAT)
                                .format(widget.startDate!),
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 11.0,
                          color: Color(0xFF77838F),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: isTablet ? 27 : 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    //  mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        setStatusText(widget.status),
                        style: TextStyle(
                          color: setCardBorderColor(widget.status),
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 23 : 14.0,
                        ),
                      ),
                      widget.showDeleteIcon2 == false
                          ? SizedBox()
                          : IconButton(
                              //  splashRadius: 2,
                              iconSize: 21,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              onPressed: widget.onPressedDelete2,
                              icon: Icon(
                                Icons.delete,
                              ),
                              color: AdaptiveTheme.of(context).mode.isDark
                                  ? Colors.redAccent
                                  : Colors.red,
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
