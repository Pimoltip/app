import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../repo/event_repository.dart';
import '../models/event.dart';

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
  bool _isLoading = false;

  final EventRepository repo = EventRepository();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    titleCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// ✅ Time Picker แบบเลื่อน (CupertinoDatePicker)
  Future<void> _showCupertinoTimePicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: Colors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            ),
            use24hFormat: true,
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                selectedTime = TimeOfDay(
                  hour: newDateTime.hour,
                  minute: newDateTime.minute,
                );
              });
            },
          ),
        );
      },
    );
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
                    const Text(
                      'Date & Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // 🗓 Date
                        Text(
                          "${selectedDate.year} y / ${selectedDate.month} m / ${selectedDate.day} d",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _pickDate,
                          child: const Text("Pick Date"),
                        ),

                        const SizedBox(width: 20),

                        // ⏰ Time (Cupertino scroll)
                        Text(
                          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} น.",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _showCupertinoTimePicker,
                          child: const Text("Pick Time"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FilledField(controller: titleCtrl, hint: 'What the title'),

                    const SizedBox(height: 20),
                    const Text(
                      'Event',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FilledField(
                      controller: noteCtrl,
                      hint: 'Write your important event',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 28),
                    Center(
                      child: ElevatedButton(
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
                        onPressed: _isLoading
                            ? null
                            : () async {
                                // ✅ ตรวจสอบข้อมูลที่จำเป็น
                                if (titleCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("กรุณากรอก Title ก่อนครับ"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                // ✅ เก็บ context references ก่อน async operation
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                final navigator = Navigator.of(context);

                                try {
                                  // ✅ รวม date + time เข้าด้วยกัน
                                  final fullDateTime = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime.hour,
                                    selectedTime.minute,
                                  );

                                  final newEvent = Event(
                                    date: fullDateTime, // ใช้ทั้งวัน+เวลา
                                    title: titleCtrl.text.trim(),
                                    description: noteCtrl.text.trim(),
                                  );

                                  // ✅ บันทึกข้อมูลลง SQLite
                                  await repo.addEvent(newEvent);

                                  // ✅ แสดงข้อความสำเร็จ
                                  if (mounted) {
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "บันทึก Event สำเร็จแล้ว! 🎉",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    navigator.pop();
                                  }
                                } catch (e) {
                                  // ✅ แสดงข้อความ error
                                  if (mounted) {
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Text("เกิดข้อผิดพลาด: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                        child: _isLoading
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('กำลังบันทึก...'),
                                ],
                              )
                            : const Text('Save'),
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
