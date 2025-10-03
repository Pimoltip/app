class Project {
  final String name;
  final String tag; // Recently/Today/Upcoming/Later
  final int progress; // 0-100
  final List<String> members; // รายชื่อสมาชิก

  const Project({
    required this.name,
    required this.tag,
    required this.progress,
    required this.members,
  });
}
/*Models

models/project.dart

เก็บโครงสร้างข้อมูลของ Project (มี name, tag, progress, members)

ใช้เป็น Data Model หลัก ของระบบ

ไฟล์ที่เรียกใช้งาน:

repo/in_memory_project_repo.dart (จัดการ data collection)

widgets/project_card.dart (แสดง UI)

pages/dashboard_page.dart และ pages/new_project_page.dart (รับค่า/สร้าง project ใหม่)*/