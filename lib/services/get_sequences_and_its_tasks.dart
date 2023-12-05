// import 'dart:convert';

// import 'package:com_a3_pace/utils/constants.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:http/http.dart' as http;

// class SequenceModelNew {
//   int? sequenceId;
//   String? jobId;
//   String? sequenceName;
//   // List<TaskModel>? tasks;
//   List<TaskModel>? tasks;

//   SequenceModelNew(
//       {this.sequenceId, this.jobId, this.sequenceName, this.tasks});

//   SequenceModelNew.fromJson(Map<String, dynamic> json) {
//     sequenceId = json['SequenceId'];
//     jobId = json['JobId'];
//     sequenceName = json['sequenceName'];
//     if (json['tasks'] != null) {
//       tasks = <TaskModel>[];
//       json['tasks'].forEach((v) {
//         tasks!.add(TaskModel.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['SequenceId'] = this.sequenceId;
//     data['JobId'] = this.jobId;
//     data['sequenceName'] = this.sequenceName;
//     if (this.tasks != null) {
//       data['tasks'] = this.tasks!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class TaskModel {
//   int? id;
//   String? pmkNumber;
//   String? description;
//   String? status;
//   String? startedAt;
//   String? completedAt;

//   TaskModel(
//       {this.id,
//       this.pmkNumber,
//       this.description,
//       this.status,
//       this.startedAt,
//       this.completedAt});

//   TaskModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     pmkNumber = json['PmkNumber'];
//     description = json['description'];
//     status = json['status'];
//     startedAt = json['startedAt'];
//     completedAt = json['completedAt'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['id'] = this.id;
//     data['PmkNumber'] = this.pmkNumber;
//     data['description'] = this.description;
//     data['status'] = this.status;
//     data['startedAt'] = this.startedAt;
//     data['completedAt'] = this.completedAt;
//     return data;
//   }
// }

// Future<List<SequenceModelNew>> getAllSequencesWithItsTasks(
//     {required int jobID}) async {
// //   List<SequenceModelNew> sequencesList = [];

//   final tokenBox = await Hive.openBox('tokenBox');
//   final token = tokenBox.get('token');

// //   final response = await http.get(
// //       Uri.parse('$BASE_URL/sequencestask/getsequenceandtask/$jobID'),
// //       headers: {
// //         'Authorization': 'Bearer $token',
// //       });

// //   // print(response.body);

// //   Map<String, dynamic> decodedResponse = jsonDecode(response.body);

// //   // print('decodedResponse :' + decodedResponse.toString());

// //   if (decodedResponse['data'] is List && decodedResponse['data'] != []) {
// //     sequencesList = decodedResponse['data'] as List<SequenceModelNew>;
// //   }

// // //  print(
// // //    'sequencesList.toString():' +
// // //        sequencesList[0]['sequence']['tasks'].toString(),
// // //  );
// //   // if (decodedResponse['data'] != []) {
// //   //   print(decodedResponse['data'][0]);
// //   // }

// //   // print('sequencesList:' + sequencesList.toString());
// //   // print('sequencesList Length:' + sequencesList.length.toString());

// //   return sequencesList;
// //////////////////////////////////////////////////////////////////////////////
//   ///
//   ///

//   final response = await http.get(
//       Uri.parse('$BASE_URL/sequencestask/getsequenceandtask/$jobID'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       });

//   if (response.statusCode == 200) {
//     // If the server returns a 200 OK response, parse the JSON
//     List<dynamic> data = json.decode(response.body);
//     List<SequenceModelNew> sequences = [];

//     // for (var item in data) {
//     //   var sequenceJson = item['sequence'];
//     //   SequenceModelNew sequence = SequenceModelNew.fromJson(sequenceJson);
//     //   sequences.add(sequence);
//     // }
//     sequences = data.map((item) {
//       var sequenceJson = item['sequence'];
//       return SequenceModelNew.fromJson(sequenceJson);
//     }).toList();

//     return sequences;
//   } else {
//     // If the server did not return a 200 OK response, throw an exception
//     throw Exception('Failed to load data');
//   }
// }

/////////////////
//  today's work api

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class SequenceModelNew {
  int SequenceId;
  String JobId;
  String sequenceName;
  List<dynamic> tasks;
  SequenceModelNew({
    required this.SequenceId,
    required this.JobId,
    required this.sequenceName,
    required this.tasks,
  });

  SequenceModelNew copyWith({
    int? SequenceId,
    String? JobId,
    String? sequenceName,
    List<TaskModel>? tasks,
  }) {
    return SequenceModelNew(
      SequenceId: SequenceId ?? this.SequenceId,
      JobId: JobId ?? this.JobId,
      sequenceName: sequenceName ?? this.sequenceName,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'SequenceId': SequenceId,
      'JobId': JobId,
      'sequenceName': sequenceName,
      'tasks': tasks.map((x) => x.toMap()).toList(),
    };
  }

  factory SequenceModelNew.fromMap(Map<String, dynamic> map) {
    return SequenceModelNew(
      SequenceId: map['SequenceId'] as int,
      JobId: map['JobId'] as String,
      sequenceName: map['sequenceName'] as String,
      tasks: List<TaskModel>.from(
        (map['tasks'] as List<int>).map<TaskModel>(
          (x) => TaskModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SequenceModelNew.fromJson(String source) =>
      SequenceModelNew.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Sequence(SequenceId: $SequenceId, JobId: $JobId, sequenceName: $sequenceName, tasks: $tasks)';
  }

  @override
  bool operator ==(covariant SequenceModelNew other) {
    if (identical(this, other)) return true;

    return other.SequenceId == SequenceId &&
        other.JobId == JobId &&
        other.sequenceName == sequenceName &&
        listEquals(other.tasks, tasks);
  }

  @override
  int get hashCode {
    return SequenceId.hashCode ^
        JobId.hashCode ^
        sequenceName.hashCode ^
        tasks.hashCode;
  }
}

class TaskModel {
  int id;
  String pmkNumber;
  String description;
  String status;
  DateTime? startedAt;
  DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.pmkNumber,
    required this.description,
    required this.status,
    required this.startedAt,
    required this.completedAt,
  });

  TaskModel copyWith({
    int? id,
    String? pmkNumber,
    String? description,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      pmkNumber: pmkNumber ?? this.pmkNumber,
      description: description ?? this.description,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'pmkNumber': pmkNumber,
      'description': description,
      'status': status,
      'startedAt': startedAt?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int,
      pmkNumber: map['pmkNumber'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      startedAt: map['startedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startedAt'] as int)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Task(id: $id, pmkNumber: $pmkNumber, description: $description, status: $status, startedAt: $startedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(covariant TaskModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.pmkNumber == pmkNumber &&
        other.description == description &&
        other.status == status &&
        other.startedAt == startedAt &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        pmkNumber.hashCode ^
        description.hashCode ^
        status.hashCode ^
        startedAt.hashCode ^
        completedAt.hashCode;
  }
}

// Future<List<Sequence>> getAllSequnces() async {
//   List<Sequence> allSeq = [];
//   final response = await http.get(
//     Uri.parse('http://192.168.100.4:3000/allSequencesWithTasks'),
//   );

//   if (response.statusCode == 200) {
//     // allSeq = jsonDecode(response.body);
//     final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
//     print(decodedResponse.runtimeType);
//     print(decodedResponse['data']);

//     print('1');
//     final list = decodedResponse['data'] as List;
//     print('2');
//     // allSeq = map.map((e) => Sequence.fromMap(e)).toList();
//     final myList = list.map((e) => Sequence.fromJson(e['sequence'])).toList();
//   }

//   return allSeq;
// }
Future<List<SequenceModelNew>> getSequences({required String jobID}) async {
  List<SequenceModelNew> list = [];
  // final response = await http
  //     .get(Uri.parse('http://192.168.100.4:3000/allSequencesWithTasks'));

  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');

  final response = await http.get(
      Uri.parse('$BASE_URL/sequencestask/getsequenceandtask/$jobID'),
      headers: {
        'Authorization': 'Bearer $token',
      });

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final data = body['data'] as List<dynamic>;

    //  print(data.toString());
    // print(data.runtimeType);

    // final list = data.map((e) => Sequence.fromJson(e['sequence']));

    // print(list.toString());
    print('=======================');
    for (var element in data) {
      // print('===============================================');
      // print(element['sequence']);
      // print('===============================================');
      // print('okokokok');
      list.add(
        SequenceModelNew(
          SequenceId: element['sequence']['SequenceId'],
          JobId: element['sequence']['JobId'],
          sequenceName: element['sequence']['sequenceName'],
          tasks: (element['sequence']['tasks'] as List),
        ),
      );
    }
    // for (var element in data) {
    //   print(element['sequence'].toString());
    //   print('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');
    //   list.add(
    //     Sequence(
    //       sequenceId: int.parse(element['SequenceId']),
    //       jobId: element['JobId'],
    //       sequenceName: element['sequenceName'],
    //       tasks: element['tasks'],
    //     ),
    //   );
    // }
    //   print(list);
    return list.toList();
  }

  return [];
}
///////////////////////////////////////////////////////////////

Future<List<SequenceModelNew>> getAllEmptySequences(
    {required String jobID}) async {
  List<SequenceModelNew> list = [];
  // final response = await http
  //     .get(Uri.parse('http://192.168.100.4:3000/allSequencesWithTasks'));

  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');

  final response = await http.get(
      Uri.parse('$BASE_URL/sequencestask/get-noassign-sequence/$jobID'),
      headers: {
        'Authorization': 'Bearer $token',
      });

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final data = body['data'] as Map<String, dynamic>;
    final myData = data['sequences'];
    print('data2: type: ' + myData.runtimeType.toString());

    //  print(data.toString());
    // print(data.runtimeType);

    // final list = data.map((e) => Sequence.fromJson(e['sequence']));

    // print(list.toString());
    print('===========22222222============');
    for (var element in myData) {
      // print('===============================================');
      // print(element['sequence']);
      // print('===============================================');
      // print('okokokok');
      list.add(
        SequenceModelNew(
          SequenceId: element['id'],
          JobId: element['job_id'].toString(),
          sequenceName: element['sequence_name'],
          tasks: [],
        ),
      );
    }
    // for (var element in data) {
    //   print(element['sequence'].toString());
    //   print('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');
    //   list.add(
    //     Sequence(
    //       sequenceId: int.parse(element['SequenceId']),
    //       jobId: element['JobId'],
    //       sequenceName: element['sequenceName'],
    //       tasks: element['tasks'],
    //     ),
    //   );
    // }
    //   print(list);
    return list.toList();
  }

  return [];
}




// Future<List<SequenceModel>> getAllSequncesByJobId({required int jobId}) async {
//   List<SequenceModel> sequencesList = [];

//   final tokenBox = await Hive.openBox('tokenBox');
//   final token = tokenBox.get('token');
//   // print('token in api:' + token);
//   final response = await http.get(

//       // body: {'status': 'Recieved'},
//       Uri.parse("$BASE_URL/sequences/getsequence/$jobId"),
//       headers: {
//         'Authorization': 'Bearer $token',
//       });

//   // print(response.body);
//   if (response.statusCode == 200) {
//     Map<String, dynamic> decodedResponse = jsonDecode(response.body);

//     print(response.body);

//     final sequencesData = decodedResponse['data']['sequence'];
//     // print(sequencesData);

//     if (sequencesData != null && sequencesData != [] && sequencesData is List) {
//       sequencesList =
//           sequencesData.map((e) => SequenceModel.fromMap(e)).toList();
//     } else {
//       sequencesList = [];
//     }
//   }

//   // print('sequnceList:' + sequencesList.toList().toString());
//   return sequencesList;
// }

