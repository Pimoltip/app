import 'package:flutter/material.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 31,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text('${index + 1}'),
        );
      },
    );
  }
}
