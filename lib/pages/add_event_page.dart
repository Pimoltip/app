// 📦 Import libraries ที่จำเป็นสำหรับการทำงาน
import 'package:flutter/cupertino.dart'; // สำหรับ CupertinoDatePicker (time picker แบบ iOS)
import 'package:flutter/material.dart'; // Flutter UI framework หลัก
import '../repo/event_repository.dart'; // Repository สำหรับจัดการข้อมูลกิจกรรม
import '../models/event.dart'; // Model ข้อมูลกิจกรรม
import '../services/auth_service.dart'; // Service สำหรับจัดการการเข้าสู่ระบบ

/// 📝 หน้าเพิ่มกิจกรรมใหม่
///
/// StatefulWidget สำหรับเพิ่มกิจกรรมใหม่ในปฏิทิน
/// - เลือกวันที่และเวลาสำหรับกิจกรรม
/// - กรอกชื่อและรายละเอียดกิจกรรม
/// - บันทึกข้อมูลลงฐานข้อมูล SQLite
/// - แสดง loading indicator ขณะบันทึก
class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

/// 🏗️ State class สำหรับจัดการข้อมูลและ UI ของหน้าเพิ่มกิจกรรม
class _AddEventPageState extends State<AddEventPage> {
  // 📝 Controllers สำหรับจัดการข้อมูลในช่องกรอก
  final titleCtrl = TextEditingController(); // ควบคุมช่องกรอกชื่อกิจกรรม
  final noteCtrl = TextEditingController(); // ควบคุมช่องกรอกรายละเอียดกิจกรรม

  // ⏳ สถานะการโหลด (แสดง loading indicator ขณะบันทึกข้อมูล)
  bool _isLoading = false;

  // 🗄️ Repository สำหรับจัดการข้อมูลในฐานข้อมูล SQLite
  final EventRepository repo = EventRepository();

  // 🔐 AuthService สำหรับดึงข้อมูลผู้ใช้ปัจจุบัน
  final AuthService _authService = AuthService();

  // 📅 วันที่และเวลาที่ผู้ใช้เลือก
  DateTime selectedDate = DateTime.now(); // วันที่ที่เลือก (เริ่มต้นเป็นวันนี้)
  TimeOfDay selectedTime =
      TimeOfDay.now(); // เวลาที่เลือก (เริ่มต้นเป็นเวลาปัจจุบัน)

  /// 🧹 ฟังก์ชันที่เรียกเมื่อ widget ถูกทำลาย
  ///
  /// ใช้สำหรับทำความสะอาด resources เพื่อป้องกัน memory leak
  /// ต้อง dispose TextEditingController ทุกตัวที่สร้างขึ้น
  @override
  void dispose() {
    titleCtrl.dispose(); // ทำความสะอาด controller ของช่องกรอกชื่อ
    noteCtrl.dispose(); // ทำความสะอาด controller ของช่องกรอกรายละเอียด
    super.dispose(); // เรียก dispose ของ parent class
  }

  /// 📅 ฟังก์ชันสำหรับเลือกวันที่
  ///
  /// แสดงปฏิทินให้ผู้ใช้เลือกวันที่สำหรับกิจกรรม
  /// จำกัดช่วงวันที่ที่เลือกได้ระหว่างปี 2020-2035
  Future<void> _pickDate() async {
    // แสดงปฏิทินเลือกวันที่
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // วันที่เริ่มต้น (วันที่ที่เลือกอยู่)
      firstDate: DateTime(2020), // วันที่แรกที่เลือกได้
      lastDate: DateTime(2035), // วันที่สุดท้ายที่เลือกได้
    );

    // ถ้าผู้ใช้เลือกวันที่แล้ว (ไม่กด cancel)
    if (picked != null) {
      setState(() {
        selectedDate = picked; // อัปเดตวันที่ที่เลือก
      });
    }
  }

  /// ⏰ ฟังก์ชันสำหรับเลือกเวลา (CupertinoDatePicker)
  /// แสดง time picker แบบเลื่อน (iOS style) ให้ผู้ใช้เลือกเวลา
  /// ใช้รูปแบบ 24 ชั่วโมง และแสดงใน modal bottom sheet
  Future<void> _showCupertinoTimePicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250, // ความสูงของ modal
          color: Colors.white, // สีพื้นหลัง
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time, // แสดงเฉพาะเวลา
            // กำหนดเวลาเริ่มต้นจากวันที่และเวลาที่เลือกอยู่
            initialDateTime: DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            ),
            use24hFormat: true, // ใช้รูปแบบ 24 ชั่วโมง (00:00-23:59)
            // ฟังก์ชันที่เรียกเมื่อผู้ใช้เปลี่ยนเวลา
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                // อัปเดตเวลาที่เลือก
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

  /// 🎨 สร้าง UI ของหน้าเพิ่มกิจกรรม
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 📱 Header Section - แถบหัวข้อหน้า
            Container(
              padding: const EdgeInsets.all(16), // ระยะห่างภายใน 16 pixels
              width: double.infinity, // กว้างเต็มหน้าจอ
              color: Colors.green.shade200, // สีพื้นหลังเขียวอ่อน
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // กระจายพื้นที่
                children: [
                  // ปุ่มปิดหน้า (X)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        Navigator.pop(context), // กลับไปหน้าก่อนหน้า
                  ),
                  // หัวข้อหน้า
                  const Text(
                    'Add Event',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // กล่องว่างเพื่อให้ layout สมดุล (balance)
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // 📋 Form Section - ส่วนฟอร์มกรอกข้อมูล
            Expanded(
              child: SingleChildScrollView(
                // ใช้เลื่อนได้เมื่อเนื้อหายาว
                padding: const EdgeInsets.all(16), // ระยะห่างจากขอบ 16 pixels
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // จัดชิดซ้าย
                  children: [
                    // 📅 ส่วนเลือกวันที่และเวลา
                    const Text(
                      'Date & Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8), // ระยะห่าง 8 pixels
                    Row(
                      children: [
                        // 🗓️ แสดงวันที่ที่เลือก
                        Text(
                          "${selectedDate.year} y / ${selectedDate.month} m / ${selectedDate.day} d",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        // ปุ่มเลือกวันที่
                        ElevatedButton(
                          onPressed: _pickDate,
                          child: const Text("Pick Date"),
                        ),

                        const SizedBox(
                          width: 20,
                        ), // ระยะห่างระหว่างส่วนวันที่และเวลา
                        // ⏰ แสดงเวลาที่เลือก (รูปแบบ 24 ชั่วโมง)
                        Text(
                          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} น.",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        // ปุ่มเลือกเวลา
                        ElevatedButton(
                          onPressed: _showCupertinoTimePicker,
                          child: const Text("Pick Time"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20), // ระยะห่างก่อนส่วนถัดไป
                    // 📝 ส่วนกรอกชื่อกิจกรรม
                    const Text(
                      'Title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FilledField(controller: titleCtrl, hint: 'What the title'),

                    const SizedBox(height: 20), // ระยะห่างก่อนส่วนถัดไป
                    // 📄 ส่วนกรอกรายละเอียดกิจกรรม
                    const Text(
                      'Event',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FilledField(
                      controller: noteCtrl,
                      hint: 'Write your important event',
                      maxLines: 3, // อนุญาตให้กรอกได้ 3 บรรทัด
                    ),

                    const SizedBox(height: 28), // ระยะห่างก่อนปุ่มบันทึก
                    // 💾 ปุ่มบันทึกข้อมูล - จัดกึ่งกลาง
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // สีพื้นหลังส้ม
                          foregroundColor: Colors.white, // สีข้อความขาว
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40, // ระยะห่างซ้าย-ขวา 40 pixels
                            vertical: 14, // ระยะห่างบน-ล่าง 14 pixels
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // มุมโค้งมน 12 pixels
                          ),
                        ),
                        // ถ้ากำลังโหลด ปุ่มจะกดไม่ได้
                        onPressed: _isLoading
                            ? null
                            : () async {
                                // 🔍 ตรวจสอบข้อมูลที่จำเป็นก่อนบันทึก
                                if (titleCtrl.text.trim().isEmpty) {
                                  // แสดงข้อความแจ้งเตือนถ้าไม่ได้กรอกชื่อกิจกรรม
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("กรุณากรอก Title ก่อนครับ"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return; // หยุดการทำงาน
                                }

                                // ⏳ เริ่มแสดง loading indicator
                                setState(() {
                                  _isLoading = true;
                                });

                                // 📱 เก็บ context references ก่อน async operation
                                // เพื่อป้องกันปัญหา context หมดอายุระหว่าง async operation
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                final navigator = Navigator.of(context);

                                try {
                                  // 📅 รวมวันที่และเวลาเข้าด้วยกันเป็น DateTime object
                                  final fullDateTime = DateTime(
                                    selectedDate.year, // ปี
                                    selectedDate.month, // เดือน
                                    selectedDate.day, // วัน
                                    selectedTime.hour, // ชั่วโมง
                                    selectedTime.minute, // นาที
                                  );

                                  // 🔐 ดึงข้อมูลผู้ใช้ปัจจุบัน
                                  final currentUser = await _authService
                                      .getCurrentUser();
                                  if (currentUser == null) {
                                    // ถ้าไม่มีผู้ใช้เข้าสู่ระบบ แสดงข้อความแจ้งเตือน
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text("กรุณาเข้าสู่ระบบก่อน"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  // 🆕 สร้าง Event object ใหม่จากข้อมูลที่กรอก
                                  final newEvent = Event(
                                    date: fullDateTime, // วันที่และเวลาที่เลือก
                                    title: titleCtrl.text
                                        .trim(), // ชื่อกิจกรรม (ลบช่องว่าง)
                                    description: noteCtrl.text
                                        .trim(), // รายละเอียด (ลบช่องว่าง)
                                    userId:
                                        currentUser.id!, // ID ของผู้ใช้ปัจจุบัน
                                  );

                                  // 💾 บันทึกข้อมูลลงฐานข้อมูล SQLite
                                  await repo.addEvent(newEvent);

                                  // ✅ แสดงข้อความสำเร็จและปิดหน้า
                                  if (mounted) {
                                    // ตรวจสอบว่า widget ยังอยู่ในหน้าจอ
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "บันทึก Event สำเร็จแล้ว! 🎉",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    navigator.pop(); // กลับไปหน้าก่อนหน้า
                                  }
                                } catch (e) {
                                  // ❌ จัดการ error ที่อาจเกิดขึ้นขณะบันทึก
                                  if (mounted) {
                                    // ตรวจสอบว่า widget ยังอยู่ในหน้าจอ
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Text("เกิดข้อผิดพลาด: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  // 🔄 ซ่อน loading indicator เสมอ (ไม่ว่าจะสำเร็จหรือผิดพลาด)
                                  if (mounted) {
                                    // ตรวจสอบว่า widget ยังอยู่ในหน้าจอ
                                    setState(() {
                                      _isLoading =
                                          false; // หยุดแสดง loading indicator
                                    });
                                  }
                                }
                              },
                        // แสดงข้อความในปุ่มตามสถานะ loading
                        child: _isLoading
                            ? // 🔄 แสดง loading indicator ขณะบันทึก
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth:
                                          2, // ความหนาของวงกลม 2 pixels
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white, // สีขาว
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ), // ระยะห่างระหว่างไอคอนและข้อความ
                                  Text('กำลังบันทึก...'),
                                ],
                              )
                            : // 💾 แสดงข้อความปกติเมื่อไม่กำลังโหลด
                              const Text('Save'),
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

/// 🎨 Custom Widget: FilledField
///
/// TextField ที่มีสไตล์เฉพาะสำหรับใช้ในฟอร์ม
/// - มีสีพื้นหลังเทาอ่อน
/// - ไม่มีขอบ (borderless)
/// - มุมโค้งมน
/// - รองรับหลายบรรทัด
class FilledField extends StatelessWidget {
  final TextEditingController controller; // ตัวควบคุมข้อมูลในช่องกรอก
  final String? hint; // ข้อความแนะนำ (placeholder)
  final int maxLines; // จำนวนบรรทัดสูงสุดที่กรอกได้

  const FilledField({
    super.key,
    required this.controller, // จำเป็นต้องส่ง controller มา
    this.hint, // ข้อความแนะนำ (optional)
    this.maxLines = 1, // ค่าเริ่มต้น 1 บรรทัด
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // ใช้ controller ที่ส่งมา
      maxLines: maxLines, // จำนวนบรรทัดที่อนุญาตให้กรอก
      decoration: InputDecoration(
        hintText: hint, // ข้อความแนะนำ
        filled: true, // เติมสีพื้นหลัง
        fillColor: Colors.grey.shade200, // สีพื้นหลังเทาอ่อน
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // มุมโค้งมน 12 pixels
          borderSide: BorderSide.none, // ไม่แสดงขอบ
        ),
      ),
    );
  }
}
