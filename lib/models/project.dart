class Project {
  final int? id;
  final String name;
  final String tag; // Recently/Today/Upcoming/Later
  final int progress; // 0-100
  final List<String> members; // รายชื่อสมาชิก
  final String? deadline; // รูปแบบ YYYY-MM-DD
  final DateTime createdAt;

  Project({
    this.id,
    required this.name,
    required this.tag,
    required this.progress,
    required this.members,
    this.deadline,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ✅ For SQLite database
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'tag': tag,
    'progress': progress,
    'members': members.join(','), // เก็บเป็น string คั่นด้วย comma
    'deadline': deadline,
    'created_at': createdAt.toIso8601String(),
  };

  factory Project.fromMap(Map<String, dynamic> map) => Project(
    id: map['id'],
    name: map['name'],
    tag: map['tag'],
    progress: map['progress'],
    members: (map['members'] as String)
        .split(',')
        .where((e) => e.isNotEmpty)
        .toList(),
    deadline: map['deadline'],
    createdAt: DateTime.parse(map['created_at']),
  );

  // ✅ For JSON (backward compatibility)
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'] as String,
      tag: json['tag'] as String,
      progress: (json['progress'] as num).toInt(),
      members: (json['members'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      deadline: json['deadline'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tag': tag,
      'progress': progress,
      'members': members,
      if (deadline != null) 'deadline': deadline,
    };
  }

  /// ✅ Create a copy of this project with updated fields
  Project copyWith({
    int? id,
    String? name,
    String? tag,
    int? progress,
    List<String>? members,
    String? deadline,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      progress: progress ?? this.progress,
      members: members ?? this.members,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
/*Models

models/project.dart

เก็บโครงสร้างข้อมูลของ Project (มี name, tag, progress, members)

ใช้เป็น Data Model หลัก ของระบบ

ไฟล์ที่เรียกใช้งาน:

repo/in_memory_project_repo.dart (จัดการ data collection)

widgets/project_card.dart (แสดง UI)

pages/dashboard_page.dart และ pages/new_project_page.dart (รับค่า/สร้าง project ใหม่)*/