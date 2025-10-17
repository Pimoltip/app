# 📱 Planner App

Flutter application for managing schedules, projects, and events with user authentication system.

## Features

- 🔐 User Authentication (Login/Register)
- 📅 Calendar and Event Management
- 📋 Project Management with Progress Tracking
- 📊 Dashboard with Statistics
- 💾 Local SQLite Database

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── event.dart
│   ├── user.dart
│   ├── project.dart
│   └── important_day.dart
├── pages/
│   ├── login_page.dart
│   ├── signup_page.dart
│   ├── dashboard_page.dart
│   ├── calendar_page.dart
│   ├── project_calendar.dart
│   ├── appoinment_page.dart
│   ├── add_event_page.dart
│   └── new_project_page.dart
├── services/
│   └── auth_service.dart
└── repo/
    ├── database_service.dart
    ├── user_repository.dart
    ├── event_repository.dart
    └── project_repository.dart
```

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK

### Installation
1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run`

## Usage

1. Register a new account or login
2. View dashboard for project overview
3. Create new projects
4. Manage events and appointments
5. Track project progress

## Technologies Used

- Flutter
- SQLite
- SharedPreferences
- Material Design

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

1. //  ส่วนกรอกเปอร์เซ็นต์ความคืบหน้า
TextField(
  controller: progressController,
  decoration: _filled("Progress (%)"),
  keyboardType: TextInputType.number,
  onChanged: (value) {
    // ตรวจสอบและจำกัดค่า 0-100
    int? newProgress = int.tryParse(value);
    if (newProgress != null && newProgress >= 0 && newProgress <= 100) {
      progress = newProgress;
      setState(() {});
    }
  },
),
const SizedBox(height: 6),
Text("Progress: $progress%"), // แสดงเปอร์เซ็นต์ความคืบหน้า

2. เพิ่ม Progress Controller
เพิ่มที่บรรทัด 48 (หลัง nameCtrl):
/// Controller สำหรับช่องกรอกชื่อโปรเจกต์
final nameCtrl = TextEditingController();

/// Controller สำหรับช่องกรอกเปอร์เซ็นต์ความคืบหน้า
final progressController = TextEditingController();
3. แก้ไขฟังก์ชัน recalc()แก้ไขที่บรรทัด 124-128:
void _recalc() {
  // ไม่ต้องคำนวณอัตโนมัติ เพราะผู้ใช้กรอกเอง
  // progress จะถูกอัปเดตใน onChanged ของ TextField
  setState(() {});
}
4. เพิ่มการตรวจสอบข้อมูลเพิ่มฟังก์ชันตรวจสอบที่บรรทัด 129:
   /// ตรวจสอบและจำกัดค่า progress ให้อยู่ในช่วง 0-100
void _validateProgress(String value) {
  int? newProgress = int.tryParse(value);
  if (newProgress != null) {
    if (newProgress < 0) {
      progress = 0;
      progressController.text = "0";
    } else if (newProgress > 100) {
      progress = 100;
      progressController.text = "100";
    } else {
      progress = newProgress;
    }
    setState(() {});
  }
}
5. โค้ดเต็มที่ต้องแก้ไข
// ส่วนกรอกเปอร์เซ็นต์ความคืบหน้า
TextField(
  controller: progressController,
  decoration: _filled("Progress (%)"),
  keyboardType: TextInputType.number,
  onChanged: _validateProgress,
),
const SizedBox(height: 6),
Text("Progress: $progress%"), // แสดงเปอร์เซ็นต์ความคืบหน้า
6. เพิ่มการตั้งค่าเริ่มต้นเพิ่มใน initState() (ถ้ามี):
@override
void initState() {
  super.initState();
  progressController.text = "0"; // เริ่มต้นที่ 0%
}

This project is licensed under the MIT License.
