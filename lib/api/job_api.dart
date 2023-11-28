import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchJobTask() async {
 
  const String apiUrl = 'http://localhost:3500/api/job';
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

