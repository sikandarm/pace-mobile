import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/get_all_car.dart';
import '../utils/AppColors.dart';
import '../utils/constants.dart';
import 'CAR_Detail.dart';
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

  bool isTablet = false;

  @override
  void didChangeDependencies() {
    checkTablet();
    getAllPendingCarReports();
    super.didChangeDependencies();
  }

  List<CAReportModel> allPendingCarReports = [];

  Future<void> getAllPendingCarReports() async {
    allPendingCarReports = await fetchAllCARList();
    setState(() {});
  }

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
              ? Colors.white
              : Colors.black,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const DashboardScreen(),
            //   ),
            //);
            ////////////////////////
            Navigator.pop(context);
            ///////////////////////
            // Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
          },
        ),
        title: Text(
          "CAR List",
          style: TextStyle(
            fontSize: isTablet ? appBarTiltleSizeTablet : appBarTiltleSize,
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

class CARListItemWidget extends StatefulWidget {
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
  State<CARListItemWidget> createState() => _CARListItemWidgetState();
}

class _CARListItemWidgetState extends State<CARListItemWidget> {
  bool isTablet = false;

  @override
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CARDetail(carId: widget.id!),
          ),
        );
      },
      child: Container(
        // height: 200,
        height: isTablet ? 135 : 80,
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          //  color: Colors.white,
          color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
              ? Colors.white.withOpacity(0.92)
              : Colors.white,
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
                        "#${widget.id}",
                        style: TextStyle(
                          color: Color(0xFF1E2022),
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 26 : 16.0,
                        ),
                      ),
                      Text(
                        widget.caReportDate != null
                            ? DateFormat(US_DATE_FORMAT)
                                .format(widget.caReportDate!)
                            : 'N/A',
                        style: TextStyle(
                          fontSize: isTablet ? 21 : 11.0,
                          color: Color(0xFF77838F),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.status!.substring(0, 1).toUpperCase() +
                        widget.status!.substring(1),
                    style: TextStyle(
                      color: AppColors.contentColorYellow,
                      fontSize: isTablet ? 26 : 16.0,
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
