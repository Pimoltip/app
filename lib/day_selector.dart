import 'package:flutter/material.dart';

class DaySelector extends StatefulWidget {
  final Function(int) onDaySelected; // ✅ callback ส่ง index กลับไป

  const DaySelector({super.key, required this.onDaySelected});

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  final days = [
    '5 Sun',
    '6 Mon',
    '7 Tue',
    '8 Wed',
    '9 Thu',
    '10 Fri',
    '11 Sat',
  ];
  int selectedIndex = 3; // ค่าเริ่มต้น: วันพุธ

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final isSelected = i == selectedIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                selectedIndex = i;
              });
              widget.onDaySelected(i); // ✅ ส่งค่า index กลับไป SchedulePage
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                days[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
