import 'package:flutter/material.dart';

class AddEventPage extends StatefulWidget {
  static const routeName = '/add-event';
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final titleCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.green.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Add Event',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and Time Picker mockup
                    const Text(
                      'Date and Time',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        PickerColumn(label: 'Day', items: ['13', '14', '15']),
                        PickerColumn(label: 'Month', items: ['09', '10']),
                        PickerColumn(label: 'Hour', items: ['7', '8', '9']),
                        PickerColumn(label: 'Minute', items: ['29', '30', '31']),
                        PickerColumn(label: 'AM/PM', items: ['AM', 'PM']),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text('Title',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    FilledField(
                        controller: titleCtrl, hint: 'What the title'),

                    const SizedBox(height: 20),
                    const Text('Event',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    FilledField(
                      controller: noteCtrl,
                      hint: 'Write your important event',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Text('Color',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 12),
                            ColorDot(color: Colors.orange),
                            ColorDot(color: Colors.lime),
                            ColorDot(color: Color(0xFF80CBC4)), // teal.200
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Alarm',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Switch(
                              value: alarmOn,
                              onChanged: (v) =>
                                  setState(() => alarmOn = v),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // ส่งค่ากลับให้ CalendarPage
                          Navigator.pop(context, {
                            'title': titleCtrl.text,
                            'note': noteCtrl.text,
                            'alarm': alarmOn,
                          });
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

/// Column picker mock widget
class PickerColumn extends StatelessWidget {
  final String label;
  final List<String> items;
  const PickerColumn({super.key, required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...items.map(
          (e) => Text(
            e,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

/// Filled text field
class FilledField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  const FilledField({
    super.key,
    required this.controller,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// Color circle dot
class ColorDot extends StatelessWidget {
  final Color color;
  const ColorDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
