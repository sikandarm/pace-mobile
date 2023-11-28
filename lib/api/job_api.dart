import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchJobTask() async {
  // const String apiUrl = 'http://localhost:3500/api/job';
  // const String apiUrl = 'http://192.168.1.8/api/job';
  const String apiUrl = 'http://206.81.5.26/api/job';
  // const String apiUrl = 'http://206.81.5.26/login';

  final response = await http.get(Uri.parse(apiUrl));
  // final timestamp = DateTime.now().millisecondsSinceEpoch;
  // final response = await http
  //     .get(Uri.parse('http://localhost:3500/api/job?timestamp=$timestamp'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final jobs = data['data']['jobs'];
    return jobs;
  } else {
    throw Exception('Failed to load data from API');
  }
}
