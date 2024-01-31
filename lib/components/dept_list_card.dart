import 'package:flutter/material.dart';

import '../screens/department_list.dart';

class DeptListCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color textColor;
  final LinearGradient gradient;

  const DeptListCard({
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.gradient,
    Key? key,
  }) : super(key: key);

  @override
  State<DeptListCard> createState() => _DeptListCardState();
}

class _DeptListCardState extends State<DeptListCard> {
  @override
  void didChangeDependencies() {
    checkTablet();
    super.didChangeDependencies();
  }

  bool isTablet = false;
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
        if (widget.title == "Departments") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeptList(),
            ),
          );
        }
      },
      child: Container(
        height: isTablet ? 130 : 90,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: widget.gradient,
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: isTablet ? 25 : 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '\$${widget.subtitle}',
                        style: TextStyle(
                          fontSize: isTablet ? 27 : 17,
                          fontWeight: FontWeight.bold,
                          color: widget.textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
