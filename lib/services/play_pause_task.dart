import 'dart:convert';

import 'package:com_a3_pace/utils/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class PlayAndPauseTask {
  PlayAndPauseTask({
    required this.id,
    required this.taskId,
    required this.breakStart,
    this.breakEnd,
    required this.comment,
    // required this.createdBy,
    // required this.updatedAt,
    // required this.createdAt,
  });

  late final int? id;
  late final String? taskId;
  late final String? breakStart;
  late final String? breakEnd;
  late final String? comment;
  // late final int? createdBy;
  // late final String? updatedAt;
  // late final String? createdAt;

  PlayAndPauseTask.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taskId = json['task_id'];
    breakStart = json['break_start'];
    breakEnd = null;
    comment = json['comment'];
    // createdBy = json['createdBy'];
    // updatedAt = json['updatedAt'];
    // createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['task_id'] = taskId;
    _data['break_start'] = breakStart;
    _data['break_end'] = breakEnd;
    _data['comment'] = comment;
    // _data['createdBy'] = createdBy;
    // _data['updatedAt'] = updatedAt;
    // _data['createdAt'] = createdAt;
    return _data;
  }
}

Future<PlayAndPauseTask> playAndPauseTaskApi({
  required String taskId,
  required String? break_start_as_DateTime,
  required String? break_end_as_DateTime,
  required String comment,
}) async {
  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');
  PlayAndPauseTask playAndPauseTaskInstance = PlayAndPauseTask(
    id: null,
    taskId: null,
    breakEnd: null,
    breakStart: null,
    comment: null,
    // createdBy: null,
    // updatedAt: null,
    // createdAt: null,
  );

  final response = await http.post(
    Uri.parse('$BASE_URL/break-task/set-task-break'),
    headers: {
      'Authorization': 'Bearer $token',
    },
    body: break_end_as_DateTime == null
        ? {
            "break_start": break_start_as_DateTime,
            // "break_end": "2023-09-16 06:45",
            "comment": comment,
            "taskid": taskId,
          }
        : break_start_as_DateTime == null
            ? {
                //  "break_start": "2023-09-16 06:45",
                "break_end": break_end_as_DateTime,
                "comment": comment,
                "taskid": taskId,
              }
            : {},
  );
  final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

  // print('decoded Response: ' + decodedResponse.toString());

  if (response.statusCode == 200 &&
      decodedResponse['message'] != 'Not End Break First Start Break' &&
      decodedResponse['message'] != 'Break Already Start') {
    playAndPauseTaskInstance =
        PlayAndPauseTask.fromJson(decodedResponse['data']);
  } else {
    //  print('Something went wrong');
    // throw 'Something went wrong';
    playAndPauseTaskInstance = PlayAndPauseTask(
      id: null,
      taskId: null,
      breakEnd: null,
      breakStart: null,
      comment: null,
      // createdBy: null,
      // updatedAt: null,
      // createdAt: null,
    );
  }

  return playAndPauseTaskInstance;
}
