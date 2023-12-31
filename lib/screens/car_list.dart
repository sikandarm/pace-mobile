import 'package:com_a3_pace/screens/CAR_Detail.dart';
import 'package:com_a3_pace/services/get_all_car.dart';
import 'package:com_a3_pace/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';

class CARList extends StatefulWidget {
  const CARList({Key? key}) : super(key: key);

  @override
  State<CARList> createState() => _SharedListState();
}

class _SharedListState extends State<CARList> {
  Future<List<CAReportModel>> _futureList = Future.value([]);

  @override
  void initState() {
    super.initState();
    _futureList = fetchAllCARList();
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
            // Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
          },
        ),
        title: const Text(
          "CAR List",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const TaskListHeader(
          //   title: "Shared CA Reports",
          // ),
          Expanded(
            child: FutureBuilder<List<CAReportModel>>(
              future: _futureList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(
                    child: Text("Error : ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No record found"),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];

                      if (item.status == "pending") {
                        return CARListItemWidget(
                          id: item.id,
                          originatorName: item.originatorName,
                          description: item.description!,
                          caReportDate: item.caReportDate,
                          status: item.status,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                }
              },
            ),

            // chi
          ),
        ],
      ),
    );
  }
}

class TaskListHeader extends StatelessWidget {
  final String title;

  const TaskListHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CARListItemWidget extends StatelessWidget {
  final int? id;
  final String? originatorName;
  final String? description;
  final String? status;
  final DateTime? caReportDate;

  const CARListItemWidget({
    super.key,
    this.id,
    this.originatorName,
    this.description,
    this.status,
    required this.caReportDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CARDetail(carId: id!),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "#$id",
                        style: const TextStyle(
                          color: Color(0xFF1E2022),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        DateFormat(US_DATE_FORMAT).format(caReportDate!),
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Color(0xFF77838F),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    status!.substring(0, 1).toUpperCase() +
                        status!.substring(1),
                    style: const TextStyle(
                      color: AppColors.contentColorYellow,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
