import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

import '../utils/constants.dart';

enum TaskStatus {
  inProcess,
  priority,
  completed,
}

class Task {
  final int id;
  final int totalTask;
  final int completedTask;
  final DateTime taskDate;
  final TaskStatus status;

  Task(
      {required this.id,
      required this.totalTask,
      required this.completedTask,
      required this.taskDate,
      required this.status});

  String get formattedDate => DateFormat(US_DATE_FORMAT).format(taskDate);

  String get statusValue {
    switch (status) {
      case TaskStatus.inProcess:
        return 'In Process';
      case TaskStatus.priority:
        return 'Priority';
      case TaskStatus.completed:
        return 'Completed';
      default:
        return '';
    }
  }
}

Future<List<Task>> fetchTasks() async {
  await Future.delayed(const Duration(seconds: 2));

  List<Task> tasks = List.generate(
    10,
    (index) {
      const totalTask = 20;
      final completedTask = Random().nextInt(totalTask + 1);
      final taskDate = DateTime.now().add(Duration(days: index));
      final status = _taskStatus(totalTask, completedTask, taskDate);
      return Task(
        id: 3000,
        totalTask: totalTask,
        completedTask: completedTask,
        taskDate: taskDate,
        status: status,
      );
    },
  );

  return tasks;
}

TaskStatus _taskStatus(int totalTask, int completedTask, DateTime taskDate) {
  final completedPercentage = (completedTask / totalTask) * 100;
  if (completedPercentage <= 10) {
    return TaskStatus.priority;
  } else if (completedPercentage == 100) {
    return TaskStatus.completed;
  } else {
    return TaskStatus.inProcess;
  }
}
