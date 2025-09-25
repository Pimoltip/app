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
