// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class SequenceModel {
  final int? id;
  final String? sequenceName;
  final String? job;

  SequenceModel({
    this.id,
    this.sequenceName,
    this.job,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sequence_name': sequenceName,
      'Job': job,
    };
  }

  factory SequenceModel.fromMap(Map<String, dynamic> map) {
    return SequenceModel(
      id: map['id'] != null ? map['id'] as int : null,
      sequenceName:
          map['sequence_name'] != null ? map['sequence_name'] as String : null,
      job: map['Job'] != null ? map['Job'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SequenceModel.fromJson(String source) =>
      SequenceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

Future<List<SequenceModel>> getAllSequncesByJobId({required int jobId}) async {
  List<SequenceModel> sequencesList = [];

  final tokenBox = await Hive.openBox('tokenBox');
  final token = tokenBox.get('token');
  // print('token in api:' + token);
  final response = await http.get(
      // body: {'status': 'Recieved'},
      Uri.parse("http://192.168.1.2:3500/api/sequences/getsequence/$jobId"),
      headers: {
        'Authorization': 'Bearer $token',
      });

  // print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> decodedResponse = jsonDecode(response.body);

    final sequencesData = decodedResponse['data']['sequence'];
    // print(sequencesData);

    if (sequencesData != null && sequencesData != [] && sequencesData is List) {
      sequencesList =
          sequencesData.map((e) => SequenceModel.fromMap(e)).toList();
    } else {
      sequencesList = [];
    }
  }

  // print('sequnceList:' + sequencesList.toList().toString());
  return sequencesList;
}
