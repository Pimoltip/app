import 'package:flutter/material.dart';

class AddEventPage extends StatefulWidget {
  static const routeName = '/add-event';
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final titleCtrl = TextEditingController();
  final noteCtrl  = TextEditingController();
  bool alarmOn = true;

  @override
  void dispose() {
    titleCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Event")),
      body: SafeArea(
        child: Column(
          children: [
            // Header เขียวอ่อน
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.green.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
                  const Text('Add Event',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date and Time',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    // mock เลย์เอาต์แบบรูป (ถ้าจะเลือกจริงใช้ datetime picker ภายหลัง)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _PickerColumn(label: 'Day', items: ['13','14','15']),
                        _PickerColumn(label: 'Month', items: ['09','10']),
                        _PickerColumn(label: 'Hour', items: ['7','8','9']),
                        _PickerColumn(label: 'Minute', items: ['29','30','31']),
                        _PickerColumn(label: 'AM/PM', items: ['AM','PM']),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _filledField(controller: titleCtrl, hint: 'What the title'),

                    const SizedBox(height: 20),
                    const Text('Event', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _filledField(controller: noteCtrl,
                        hint: 'Write your important event', maxLines: 3),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          _colorDot(Colors.orange),
                          _colorDot(Colors.lime),
                          _colorDot(Colors.teal.shade200),
                        ]),
                        Row(children: [
                          const Text('Alarm', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Switch(value: alarmOn, onChanged: (v) => setState(() => alarmOn = v)),
                        ]),
                      ],
                    ),

                    const SizedBox(height: 28),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // ส่งค่ากลับให้หน้าปฏิทินในอนาคต (ตอนนี้ปิดอย่างเดียว)
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerColumn extends StatelessWidget {
  final String label;
  final List<String> items;
  const _PickerColumn({required this.label, required this.items, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...items.map((e) => Text(e, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}

Widget _filledField({required TextEditingController controller, String? hint, int maxLines = 1}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Widget _colorDot(Color c) => Container(
  margin: const EdgeInsets.symmetric(horizontal: 4),
  width: 24,
  height: 24,
  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
);