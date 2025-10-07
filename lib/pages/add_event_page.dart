import 'package:flutter/material.dart';
import '../repo/json_file_manager.dart'; // ✅ import ตัวจัดการไฟล์

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
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final eventFile = JsonFileManager('addevent.json'); // ✅ ใช้ตัวจัดการไฟล์

  @override
  void dispose() {
    titleCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  // ✅ เลือกวันที่
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // ✅ เลือกเวลา
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  // ✅ บันทึกลง local storage ผ่าน JsonFileManager
  Future<void> _saveEvent() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final dateStr =
        "${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    final newEvent = {
      'title': titleCtrl.text.trim().isEmpty
          ? 'Untitled Event'
          : titleCtrl.text.trim(),
      'note': noteCtrl.text,
      'date': dateStr,
      'time':
          '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
      'alarm': alarmOn,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await eventFile.addItem(newEvent);
    debugPrint('✅ Saved event: $newEvent');

    // ส่งค่ากลับไป CalendarPage เพื่อรีเฟรช
    Navigator.pop(context, newEvent);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? 'Select Date'
        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
    final timeText = selectedTime == null
        ? 'Select Time'
        : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
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

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date and Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(dateText),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade400,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(timeText),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade400,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FilledField(
                      controller: titleCtrl,
                      hint: 'Enter event title',
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FilledField(
                      controller: noteCtrl,
                      hint: 'Write event details...',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Alarm',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: alarmOn,
                          onChanged: (v) => setState(() => alarmOn = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

/// ✅ TextField สำหรับกรอกข้อมูล
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
