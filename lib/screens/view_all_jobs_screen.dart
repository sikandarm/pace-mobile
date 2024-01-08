import 'package:flutter/material.dart';

import '../components/job_list_card.dart';
import '../services/job_service.dart';
import '../utils/constants.dart';

class ViewAllJobsScreen extends StatefulWidget {
  const ViewAllJobsScreen({super.key});

  @override
  State<ViewAllJobsScreen> createState() => _ViewAllJobsScreenState();
}

class _ViewAllJobsScreenState extends State<ViewAllJobsScreen> {
  Future<List<Job>> _futureJob = Future.value([]);
  String jobCount = '';
  void updateJobCount(int count) {
    setState(() {
      jobCount = count.toString();
    });
  }

  Future<void> _refreshData() async {
    List<Job> refreshedJobs = await fetchJobs();

    setState(() {
      _futureJob = Future.value(refreshedJobs);
      updateJobCount(refreshedJobs.length);
    });
  }

  @override
  void initState() {
    _futureJob = fetchJobs();
    _futureJob.then((jobs) {
      updateJobCount(jobs.length);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: Text(
          "All Jobs",
          style: TextStyle(
            fontSize: appBarTiltleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [],
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Visibility(
            //  visible: blShowJobList,
            child: Expanded(
              child: FutureBuilder<List<Job>>(
                future: _futureJob,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: Text("No Data"),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final task = snapshot.data![index];

                        return JobList(
                          jobId: task.id,
                          totalTasks: task.totalTasks,
                          completedTasks: task.completedTasks,
                          status: task.status,
                          startDate: task.startDate,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
