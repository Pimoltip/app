import '../models/project.dart';

class InMemoryProjectRepo {
  final _items = <Project>[];

  List<Project> all() => List.unmodifiable(_items);
  List<Project> byTag(String tag) => _items.where((e) => e.tag == tag).toList();
  void add(Project p) => _items.add(p);
}
/*Repository

repo/in_memory_project_repo.dart

เป็น Repository ชั้นกลาง สำหรับจัดการ Project

เก็บ data แบบ in-memory (ยังไม่มี database จริง)

method: all(), byTag(), add()

ไฟล์ที่เรียกใช้งาน:

pages/dashboard_page.dart (โหลด project ตาม tag + เพิ่ม project ใหม่)*/