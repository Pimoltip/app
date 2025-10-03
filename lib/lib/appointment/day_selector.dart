import 'package:flutter/material.dart';
//Widget สำหรับ เลือกวัน
class DaySelector extends StatelessWidget {
  const DaySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final days = [
      '5 Sun',
      '6 Mon',
      '7 Tue',
      '8 Wed',
      '9 Thu',
      '10 Fri',
      '11 Sat',
    ];
    final selectedIndex = 3;

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final isSelected = i == selectedIndex;
          return Container(
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
          );
        },
      ),
    );
  }
}
