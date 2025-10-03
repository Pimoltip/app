import 'package:flutter/material.dart';
import 'event_card.dart';
//Widget สำหรับแสดง ไทม์ไลน์ของแต่ละกิจกรรม
class TimeLine extends StatelessWidget {
  const TimeLine({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      EventData(
        time: '10:00 - 11:00',
        code: '01371111-67',
        detail: 'LH4-305 | Sec 800',
      ),
      EventData(
        time: '013:00 - 014:00',
        code: '01418212-65',
        detail: 'SC Programming | Sec 800',
      ),
    ];

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
            ...matches.map((e) => EventCard(data: e)).toList(),
          ],
        );
      },
    );
  }
}
