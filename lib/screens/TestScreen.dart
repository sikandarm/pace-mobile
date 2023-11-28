import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// import '../utils/CandlestickChart.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
// Mock data for the candlestick chart
  final List<Candle> mockData = [
    Candle(1, 100, 150, 80, 120),
    Candle(2, 120, 180, 90, 150),
    Candle(3, 150, 200, 130, 160),
    Candle(1, 100, 150, 80, 120),
    Candle(2, 120, 180, 90, 150),
    Candle(3, 150, 200, 130, 160),
    Candle(1, 100, 150, 80, 120),
    Candle(2, 120, 180, 90, 150),
    Candle(3, 150, 200, 130, 160),
    Candle(1, 100, 150, 80, 120),
    Candle(2, 120, 180, 90, 150),
    Candle(3, 150, 200, 130, 160),
    Candle(1, 100, 150, 80, 120),
    Candle(2, 120, 180, 90, 150),
    Candle(3, 150, 200, 130, 160),
    Candle(2, 120, 180, 90, 150),
    Candle(3, 150, 200, 130, 160),
    Candle(1, 100, 150, 80, 120),
    Candle(2, 120, 180, 90, 150),
    Candle(3, 150, 200, 130, 160),
    Candle(1, 100, 150, 80, 120),
    Candle(2, 120, 180, 90, 150),
    Candle(3, 150, 200, 130, 160),
    Candle(1, 100, 150, 80, 120),
    Candle(2, 120, 180, 90, 150),
    Candle(3, 150, 200, 130, 160),
    // Add more data as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candlestick Chart with Mock Data'),
      ),
      body: Center(
        child: SizedBox(
          width: 300,
          height: 200,
          child: CustomPaint(
            painter: CandlestickChartPainter(data: mockData),
          ),
        ),
      ),
    );
  }
}

class CandlestickChartPainter extends CustomPainter {
  final List<Candle> data;
  final double candleWidth = 10.0;
  final double spacing = 8.0;

  CandlestickChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    double maxPrice =
        data.map((candle) => candle.high).reduce((a, b) => a > b ? a : b);
    double minPrice =
        data.map((candle) => candle.low).reduce((a, b) => a < b ? a : b);

    double priceRange = maxPrice - minPrice;
    double height = size.height - 2.0;

    for (int i = 0; i < data.length; i++) {
      Candle candle = data[i];
      double x = (i * (candleWidth + spacing)) + spacing;
      double yHigh = height - ((candle.high - minPrice) / priceRange) * height;
      double yLow = height - ((candle.low - minPrice) / priceRange) * height;
      double yOpen = height - ((candle.open - minPrice) / priceRange) * height;
      double yClose =
          height - ((candle.close - minPrice) / priceRange) * height;

      double candleX = x + (candleWidth / 2);

      // Draw the candlestick body (rectangle)
      canvas.drawRect(
        Rect.fromLTRB(x, yOpen, x + candleWidth, yClose),
        paint..color = candle.open > candle.close ? Colors.red : Colors.green,
      );

      // Draw the high-to-low line (wick)
      canvas.drawLine(Offset(candleX, yHigh), Offset(candleX, yLow), paint);

      // Draw the open-to-close line (body)
      canvas.drawLine(Offset(x + (candleWidth / 2), yOpen),
          Offset(x + (candleWidth / 2), yClose), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class Candle {
  final int x;
  final double open;
  final double high;
  final double low;
  final double close;

  Candle(this.x, this.open, this.high, this.low, this.close);
}
