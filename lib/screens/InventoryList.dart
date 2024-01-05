import 'dart:convert';
import 'dart:math';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/inventory_list_service.dart';
import '../utils/AppColors.dart';
import '../utils/constants.dart';
import 'Dashboard.dart';
import 'InventoryDetailScreen.dart';
import 'ProfileScreen.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:http/http.dart' as http;

import 'notification.dart';

bool _blShowInventory = false;
bool _blShowInventoryDetail = false;
bool _blShowNotifications = false;

List<Color> get availableColors => const <Color>[
      AppColors.contentColorBlue,
      AppColors.contentColorGrey,
    ];

final Color barBackgroundColor = AppColors.contentColorWhite.withOpacity(0.3);
const Color barColor = AppColors.contentColorWhite;
const Color touchedBarColor = AppColors.contentColorGreen;

int _selectedSegment = 1;

// Color leftBarColor = AppColors.contentColorYellow;
// Color rightBarColor = AppColors.contentColorRed;
// Color avgColor = AppColors.contentColorOrange;

const double barwidth = 7;
late List<BarChartGroupData> rawBarGroups;
late List<BarChartGroupData> showingBarGroups;
int touchedGroupIndex = -1;

class InventoryList extends StatefulWidget {
  const InventoryList({Key? key}) : super(key: key);

  @override
  State<InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<InventoryListModel>> _futureInventory = Future.value([]);

  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;
  bool isPlaying = false;
  bool isShowingMainData = true;

  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      hasNewNotifiaction = true;
      setState(() {});
    });

    super.initState();

    _tooltipBehavior = TooltipBehavior(enable: true);
    isShowingMainData = true;
    _futureInventory = fetchInventoryList();

    final barGroup1 = makeBarGroupData(0, 5, 12);
    final barGroup2 = makeBarGroupData(1, 16, 12);
    final barGroup3 = makeBarGroupData(2, 18, 5);
    final barGroup4 = makeBarGroupData(3, 20, 16);
    final barGroup5 = makeBarGroupData(4, 17, 6);
    final barGroup6 = makeBarGroupData(5, 19, 1.5);
    final barGroup7 = makeBarGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;

    checkPermissionAndUpdateBool("view_inventory", (localBool) {
      _blShowInventory = localBool;
    });

    checkPermissionAndUpdateBool("view_inventory_detail", (localBool) {
      _blShowInventoryDetail = localBool;
    });

    checkPermissionAndUpdateBool("view_notifications", (localBool) {
      _blShowNotifications = localBool;
    });
  }

  List<ChartSampleData> getChartData(Map data) {
    List<ChartSampleData> graphData = <ChartSampleData>[];
    print(data["months"]);
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 1, 1), 0,
        data["months"]["01"] == null ? 0 : double.parse(data["months"]["01"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 2, 1), 0,
        data["months"]["02"] == null ? 0 : double.parse(data["months"]["02"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 3, 1), 0,
        data["months"]["03"] == null ? 0 : double.parse(data["months"]["03"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 4, 1), 0,
        data["months"]["04"] == null ? 0 : double.parse(data["months"]["04"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 5, 1), 0,
        data["months"]["05"] == null ? 0 : double.parse(data["months"]["05"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 6, 1), 0,
        data["months"]["06"] == null ? 0 : double.parse(data["months"]["06"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 7, 1), 0,
        data["months"]["07"] == null ? 0 : double.parse(data["months"]["07"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 8, 1), 0,
        data["months"]["08"] == null ? 0 : double.parse(data["months"]["08"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 9, 1), 0,
        data["months"]["09"] == null ? 0 : double.parse(data["months"]["09"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 10, 1), 0,
        data["months"]["10"] == null ? 0 : double.parse(data["months"]["10"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 11, 1), 0,
        data["months"]["11"] == null ? 0 : double.parse(data["months"]["11"])));
    graphData.add(ChartSampleData(DateTime(DateTime.now().year, 12, 1), 0,
        data["months"]["12"] == null ? 0 : double.parse(data["months"]["12"])));
    // data["months"].forEach((key, value) {
    //   graphData.add(ChartSampleData(
    //       DateTime(DateTime.now().year, int.tryParse(key)!, 1),
    //       0,
    //       double.tryParse(value)!));
    // });
    return graphData;
  }

  void checkPermissionAndUpdateBool(
      String permValue, Function(bool) boolUpdater) async {
    var localBool = await hasPermission(permValue);

    setState(() {
      boolUpdater(localBool);
    });
  }

  final List<ChartData> chartData = <ChartData>[];

  final List<SyncLineChartData> lineChartData = <SyncLineChartData>[];

  Future fetchGraphData() async {
    const String apiUrl = '$BASE_URL/task/rejected-task-by-month-year';
    final response = await http.get(Uri.parse(apiUrl));
    // final timestamp = DateTime.now().millisecondsSinceEpoch;
    // final response = await http
    //     .get(Uri.parse('http://localhost:3500/api/job?timestamp=$timestamp'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final jobs = data['data']['analytics'];

      jobs["reasons"].forEach((key, value) {
        print(double.tryParse(value)!.toInt());
        chartData.add(
          ChartData(key, double.tryParse(value)!.toInt(), 0, 0, 0),
        );
      });

      lineChartData.add(SyncLineChartData(2020, 0));
      lineChartData.add(SyncLineChartData(2021, 0));
      lineChartData.add(SyncLineChartData(2022, 0));
      jobs["years"].forEach((key, value) {
        lineChartData.add(
            SyncLineChartData(int.tryParse(key)!, double.tryParse(value)!));
      });
      lineChartData.add(SyncLineChartData(2024, 0));
      lineChartData.add(SyncLineChartData(2025, 0));
      lineChartData.add(SyncLineChartData(2026, 0));
      // return graphData;
      return jobs;
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context, scaffoldKey),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            child: CustomSlidingSegmentedControl<int>(
              isStretch: true,
              initialValue: 1,
              children: const {
                1: Text('Month'),
                2: Text('Process'),
                3: Text('YOY'),
              },
              decoration: BoxDecoration(
                color: CupertinoColors.lightBackgroundGray,
                borderRadius: BorderRadius.circular(8),
              ),
              thumbDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.3),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(
                      0.0,
                      2.0,
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInToLinear,
              onValueChanged: (v) {
                print(v);
                setState(() {
                  _selectedSegment = v;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: FutureBuilder(
              future: fetchGraphData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Data is available, fill the TextField
                  return Column(
                    children: [
                      Visibility(
                        visible: _selectedSegment == 1,
                        child: SizedBox(
                          height: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                //Initialize the chart widget
                                SfCartesianChart(
                                  legend: Legend(isVisible: false),
                                  tooltipBehavior: _tooltipBehavior,
                                  series: <RangeColumnSeries>[
                                    RangeColumnSeries<ChartSampleData,
                                            DateTime>(
                                        dataSource: getChartData(snapshot.data),
                                        // enableTooltip: false,
                                        name: 'Month',
                                        xValueMapper:
                                            (ChartSampleData data, _) => data.x,
                                        highValueMapper:
                                            (ChartSampleData data, _) =>
                                                data.high,
                                        lowValueMapper:
                                            (ChartSampleData data, _) =>
                                                data.low,
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                                isVisible: false),
                                        width: 0.5,
                                        borderRadius: BorderRadius.circular(10),
                                        spacing: 0.5),
                                  ],
                                  plotAreaBorderWidth: 0.0,
                                  primaryXAxis: DateTimeAxis(
                                    majorTickLines:
                                        const MajorTickLines(width: 0),
                                    majorGridLines:
                                        const MajorGridLines(width: 0),
                                    dateFormat: DateFormat.MMM(),
                                    intervalType: DateTimeIntervalType.months,
                                    rangePadding: ChartRangePadding.normal,
                                    axisLine: const AxisLine(width: 0),
                                  ),
                                  primaryYAxis: NumericAxis(
                                      borderWidth: 0.0,
                                      labelFormat: '\${value}',
                                      axisLine: const AxisLine(width: 0),
                                      majorTickLines:
                                          const MajorTickLines(width: 0),
                                      axisBorderType:
                                          AxisBorderType.withoutTopAndBottom),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _selectedSegment == 2,
                        child: SizedBox(
                          height: 300,
                          child: Container(
                            child: SfCartesianChart(
                              plotAreaBorderWidth: 0.0,
                              primaryXAxis: CategoryAxis(
                                  labelRotation: -90,
                                  borderWidth: 0.0,
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  axisBorderType:
                                      AxisBorderType.withoutTopAndBottom,
                                  axisLine: const AxisLine(width: 0),
                                  majorTickLines:
                                      const MajorTickLines(width: 0)),
                              primaryYAxis: NumericAxis(
                                  borderWidth: 0.0,
                                  labelFormat: '\${value}',
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  axisLine: const AxisLine(width: 0),
                                  majorTickLines:
                                      const MajorTickLines(width: 0),
                                  axisBorderType:
                                      AxisBorderType.withoutTopAndBottom),
                              series: <ChartSeries>[
                                StackedColumnSeries<ChartData, String>(
                                    dataSource: chartData,
                                    width: 0.2,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) =>
                                        data.y1),
                                StackedColumnSeries<ChartData, String>(
                                    dataSource: chartData,
                                    width: 0.2,
                                    color: Colors.grey.shade300,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) =>
                                        data.y4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _selectedSegment == 3,
                        child: SizedBox(
                          height: 300,
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: SfCartesianChart(
                                  plotAreaBorderWidth: 0.0,
                                  primaryXAxis: NumericAxis(
                                    majorTickLines:
                                        const MajorTickLines(width: 0),
                                    majorGridLines:
                                        const MajorGridLines(width: 0),
                                  ),
                                  primaryYAxis: NumericAxis(
                                      borderWidth: 0.0,
                                      labelFormat: '\${value}',
                                      axisLine: const AxisLine(width: 0),
                                      majorTickLines:
                                          const MajorTickLines(width: 0),
                                      axisBorderType:
                                          AxisBorderType.withoutTopAndBottom),
                                  series: <ChartSeries>[
                                    SplineAreaSeries<SyncLineChartData, int>(
                                        dataSource: lineChartData,
                                        splineType: SplineType.cardinal,
                                        cardinalSplineTension: 0.9,
                                        xValueMapper:
                                            (SyncLineChartData data, _) =>
                                                data.x,
                                        yValueMapper:
                                            (SyncLineChartData data, _) =>
                                                data.y)
                                  ])),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  // Error occurred while fetching data
                  return Text("Error: ${snapshot.error}");
                }
                // Data is still loading
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: _blShowInventory,
            child: Expanded(
              child: FutureBuilder<List<InventoryListModel>>(
                future: _futureInventory,
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
                      child: Text(NO_REC_FOUND),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];

                        return InventoryListItemWidget(
                          id: item.id,
                          ediStdNomenclature: item.ediStdNomenclature,
                          shape: item.shape!,
                          createdAt: item.createdAt,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildAppBar(context, GlobalKey<ScaffoldState> scaffoldKey) {
  return AppBar(
    backgroundColor: Colors.white,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      },
    ),
    title: FutureBuilder<String?>(
      future: getStringFromSF(BL_USER_FULL_NAME),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          // String? title = snapshot.data;
          return const Text(
            "Inventory",
            style: TextStyle(
              color: Color(0xff1E2022),
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          );
        } else if (snapshot.hasError) {
          // Handle the error case
          return Text('Error: ${snapshot.error}');
        } else {
          // Display a loading indicator while waiting for the data
          return const CircularProgressIndicator();
        }
      },
    ),
    actions: [
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    hasNewNotifiaction = false;

                    if (_blShowNotifications) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationsScreen()),
                      );
                    } else {
                      showToast(
                          "You do not have permission to see notifications.");
                    }
                  },
                  child: Image.asset(
                    "assets/images/ic_bell.png",
                    width: 32,
                    height: 32,
                  ),
                ),
                !hasNewNotifiaction
                    ? SizedBox()
                    : Positioned(
                        top: 5,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10.0, left: 5.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/ic_profile.png'),
                radius: 15,
              ),
            ),
          ),
        ],
      )
    ],
  );
}

class InventoryListItemWidget extends StatelessWidget {
  final int? id;
  final String? ediStdNomenclature;
  final String? shape;
  final DateTime? createdAt;

  const InventoryListItemWidget({
    super.key,
    this.id,
    this.ediStdNomenclature,
    this.shape,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    // Color progressDoneColor = Color(int.parse(getProgressColorHex(status)));

    return GestureDetector(
      onTap: () {
        if (_blShowInventoryDetail) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InventoryDetailScreen(itemId: id),
            ),
          );
        } else {
          showSnackbar(context, "You do not have permission");
        }
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
                  Text(
                    "#$id",
                    style: const TextStyle(
                      color: Color(0xFF1E2022),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    DateFormat(US_DATE_FORMAT).format(createdAt!),
                    style: const TextStyle(
                      fontSize: 11.0,
                      color: Color(0xFF77838F),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ediStdNomenclature![0].toUpperCase() +
                        ediStdNomenclature!.substring(1),
                    style: const TextStyle(
                      // color: getProgressColor(status),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // const Spacer(),
                  Text(
                    "Shape:$shape",
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 8.0),
              // Container(
              //   width: double.infinity,
              //   height: 6,
              //   decoration: BoxDecoration(
              //       color: Colors.grey.shade300,
              //       borderRadius: BorderRadius.circular(12)),
              //   child: Row(
              //     children: [
              //       Container(
              //         width: MediaQuery.of(context).size.width * 0.5,
              //         decoration: BoxDecoration(
              //             color: const Color(0xFFF4BE4F),
              //             borderRadius: BorderRadius.circular(12)),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bar Chart Functions
BarChartData randomData() {
  return BarChartData(
    barTouchData: BarTouchData(
      enabled: false,
    ),
    titlesData: FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: getTitles,
          reservedSize: 38,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),
    ),
    borderData: FlBorderData(
      show: false,
    ),
    barGroups: List.generate(7, (i) {
      switch (i) {
        case 0:
          return makeGroupData(
            0,
            Random().nextInt(15).toDouble() + 6,
            barColor: availableColors[Random().nextInt(availableColors.length)],
          );
        case 1:
          return makeGroupData(
            1,
            Random().nextInt(15).toDouble() + 6,
            barColor: availableColors[Random().nextInt(availableColors.length)],
          );
        case 2:
          return makeGroupData(
            2,
            Random().nextInt(15).toDouble() + 6,
            barColor: availableColors[Random().nextInt(availableColors.length)],
          );
        case 3:
          return makeGroupData(
            3,
            Random().nextInt(15).toDouble() + 6,
            barColor: availableColors[Random().nextInt(availableColors.length)],
          );
        case 4:
          return makeGroupData(
            4,
            Random().nextInt(15).toDouble() + 6,
            barColor: availableColors[Random().nextInt(availableColors.length)],
          );
        case 5:
          return makeGroupData(
            5,
            Random().nextInt(15).toDouble() + 6,
            barColor: availableColors[Random().nextInt(availableColors.length)],
          );
        case 6:
          return makeGroupData(
            6,
            Random().nextInt(15).toDouble() + 6,
            barColor: availableColors[Random().nextInt(availableColors.length)],
          );
        default:
          return throw Error();
      }
    }),
    gridData: FlGridData(show: false),
  );
}

BarChartGroupData makeGroupData(
  int x,
  double y, {
  bool isTouched = false,
  Color? barColor,
  double width = 22,
  List<int> showTooltips = const [],
}) {
  barColor ??= barColor;
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: isTouched ? y + 1 : y,
        color: isTouched ? touchedBarColor : barColor,
        width: width,
        borderSide: isTouched
            ? const BorderSide(color: touchedBarColor)
            : const BorderSide(color: Colors.white, width: 0),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: 20,
          color: barBackgroundColor,
        ),
      ),
    ],
    showingTooltipIndicators: showTooltips,
  );
}

Widget getTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  Widget text;
  switch (value.toInt()) {
    case 0:
      text = const Text('Jan', style: style);
      break;
    case 1:
      text = const Text('Feb', style: style);
      break;
    case 2:
      text = const Text('Mar', style: style);
      break;
    case 3:
      text = const Text('Apr', style: style);
      break;
    case 4:
      text = const Text('May', style: style);
      break;
    case 5:
      text = const Text('Jun', style: style);
      break;
    case 6:
      text = const Text('Jul', style: style);
      break;
    default:
      text = const Text('', style: style);
      break;
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 16,
    child: text,
  );
}

/// Line Chart Functions
List<Color> gradientColors = [
  AppColors.contentColorCyan,
  AppColors.contentColorBlue,
];

bool showAvg = false;

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  Widget text;
  switch (value.toInt()) {
    case 1:
      text = const Text('2015', style: style);
      break;
    case 2:
      text = const Text('2016', style: style);
      break;
    case 3:
      text = const Text('2017', style: style);
      break;
    case 4:
      text = const Text('2018', style: style);
      break;
    case 5:
      text = const Text('2019', style: style);
      break;
    case 6:
      text = const Text('2020', style: style);
      break;
    default:
      text = const Text('', style: style);
      break;
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: text,
  );
}

Widget leftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );
  String text;
  switch (value.toInt()) {
    case 1:
      text = '10K';
      break;
    case 3:
      text = '30k';
      break;
    case 5:
      text = '50k';
      break;
    default:
      return Container();
  }

  return Text(text, style: style, textAlign: TextAlign.left);
}

LineChartData mainData() {
  return LineChartData(
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 1,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppColors.mainGridLineColor,
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: AppColors.mainGridLineColor,
          strokeWidth: 1,
        );
      },
    ),
    titlesData: FlTitlesData(
      show: true,
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 2,
          getTitlesWidget: bottomTitleWidgets,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: leftTitleWidgets,
          reservedSize: 42,
        ),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: const Color(0xff37434d)),
    ),
    minX: 0,
    maxX: 11,
    minY: 0,
    maxY: 6,
    lineBarsData: [
      LineChartBarData(
        spots: const [
          FlSpot(0, 3),
          FlSpot(2.6, 2),
          FlSpot(4.9, 5),
          FlSpot(6.8, 3.1),
          FlSpot(8, 4),
          FlSpot(9.5, 3),
          FlSpot(11, 4),
        ],
        isCurved: true,
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ),
    ],
  );
}

LineChartData avgData() {
  return LineChartData(
    lineTouchData: LineTouchData(enabled: false),
    gridData: FlGridData(
      show: true,
      drawHorizontalLine: true,
      verticalInterval: 1,
      horizontalInterval: 1,
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: const Color(0xff37434d),
          strokeWidth: 1,
        );
      },
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: const Color(0xff37434d),
          strokeWidth: 1,
        );
      },
    ),
    titlesData: FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: bottomTitleWidgets,
          interval: 1,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: leftTitleWidgets,
          reservedSize: 42,
          interval: 1,
        ),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: const Color(0xff37434d)),
    ),
    minX: 0,
    maxX: 11,
    minY: 0,
    maxY: 6,
    lineBarsData: [
      LineChartBarData(
        spots: const [
          FlSpot(0, 3.44),
          FlSpot(2.6, 3.44),
          FlSpot(4.9, 3.44),
          FlSpot(6.8, 3.44),
          FlSpot(8, 3.44),
          FlSpot(9.5, 3.44),
          FlSpot(11, 3.44),
        ],
        isCurved: true,
        gradient: LinearGradient(
          colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2)!,
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2)!,
          ],
        ),
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!
                  .withOpacity(0.1),
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!
                  .withOpacity(0.1),
            ],
          ),
        ),
      ),
    ],
  );
}

/// Bar Chart Functions
Widget leftTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Color(0xff7589a2),
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  String text;
  if (value == 0) {
    text = '1K';
  } else if (value == 10) {
    text = '5K';
  } else if (value == 19) {
    text = '10K';
  } else {
    return Container();
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 0,
    child: Text(text, style: style),
  );
}

Widget bottomTitles(double value, TitleMeta meta) {
  final titles = <String>['VC', 'Det', 'Ft', 'Wl', 'Co', '', ''];

  final Widget text = Text(
    titles[value.toInt()],
    style: const TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  );

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 16, //margin top
    child: text,
  );
}

BarChartGroupData makeBarGroupData(int x, double y1, double y2) {
  return BarChartGroupData(
    barsSpace: 4,
    x: x,
    barRods: [
      BarChartRodData(
        //   y: y1,
        color: Colors.blue,
        width: barwidth, toY: y1,
        //  y: 0.0,
      ),
      BarChartRodData(
        // y: y2,
        toY: y2,
        color: Colors.grey,
        width: barwidth,
        //  y: 0.0,
      ),
    ],
  );
}

Widget makeTransactionsIcon() {
  const width = 4.5;
  const space = 3.5;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Container(
        width: width,
        height: 10,
        color: Colors.white.withOpacity(0.4),
      ),
      const SizedBox(
        width: space,
      ),
      Container(
        width: width,
        height: 28,
        color: Colors.white.withOpacity(0.8),
      ),
      const SizedBox(
        width: space,
      ),
      Container(
        width: width,
        height: 42,
        color: Colors.white.withOpacity(1),
      ),
      const SizedBox(
        width: space,
      ),
      Container(
        width: width,
        height: 28,
        color: Colors.white.withOpacity(0.8),
      ),
      const SizedBox(
        width: space,
      ),
      Container(
        width: width,
        height: 10,
        color: Colors.white.withOpacity(0.4),
      ),
    ],
  );
}

class ChartSampleData {
  ChartSampleData(this.x, this.high, this.low);
  final DateTime x;
  final double high;
  final double low;
}

class ChartData {
  ChartData(this.x, this.y1, this.y2, this.y3, this.y4);
  final String x;
  final int y1;
  final int y2;
  final int y3;
  final int y4;
}

class SyncLineChartData {
  SyncLineChartData(
    this.x,
    this.y,
  );
  final int x;
  final double y;
}
