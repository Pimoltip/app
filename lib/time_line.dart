import 'package:flutter/material.dart';
import 'event_card.dart';

class TimeLine extends StatelessWidget {
  final int selectedDay;
  const TimeLine({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    // ✅ แสดงกิจกรรมเฉพาะวันพุธ (index = 3)
    final events = selectedDay == 3
        ? [
            EventData(
              time: '10:00 - 11:00',
              code: '01371111-67',
              detail: 'LH4-305 | Sec 800',
            ),
            EventData(
              time: '13:00 - 14:00',
              code: '01418212-65',
              detail: 'SC Programming | Sec 800',
            ),
          ]
        : [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 24,
      itemBuilder: (context, i) {
        final hour = 00 + i;
        final label =
            '${hour.toString().padLeft(2, '0')} ${hour <= 12 ? 'AM' : 'PM'}';

        final matches = events.where(
          (e) => e.time.startsWith('${hour.toString().padLeft(2, '0')}:'),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const Divider(height: 20, color: Colors.black12),
            // ✅ ถ้ามี event จะแสดง EventCard
            ...matches.map((e) => EventCard(data: e)).toList(),
          ],
        );
      },
    );
  }
}
