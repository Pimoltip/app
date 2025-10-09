import 'package:flutter/material.dart';
import '../repo/project_repository.dart'; // ✅ import ProjectRepository
import '../models/project.dart'; // ✅ import Project model

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key});
  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  final nameCtrl = TextEditingController();
  String tag = "Recently";
  String process = "Plan";
  int progress = 10;
  final members = <String>[];
  final friendBook = const ["Alice", "Bob", "Charlie", "Diana", "Eve"];
  DateTime? selectedDeadline;
  bool _isLoading = false;

  // ✅ ProjectRepository สำหรับจัดการ SQLite
  final ProjectRepository _projectRepo = ProjectRepository();

  void _recalc() {
    progress =
        {"Plan": 10, "Doing": 50, "Review": 80, "Done": 100}[process] ?? 0;
    setState(() {});
  }

  /// ✅ เลือกวันที่ deadline
  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDeadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB7E5A2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("New Project", style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF3D6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: _filled("Enter Project Name"),
            ),
            const SizedBox(height: 16),
            const Text(
              "Deadline",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      selectedDeadline != null
                          ? "${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}"
                          : "เลือกวันที่ deadline",
                      style: TextStyle(
                        color: selectedDeadline != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    if (selectedDeadline != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () =>
                            setState(() => selectedDeadline = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: process,
              decoration: _filled("Process List"),
              items: const [
                "Plan",
                "Doing",
                "Review",
                "Done",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                process = v ?? "Plan";
                _recalc();
              },
            ),
            const SizedBox(height: 6),
            Text("Progress: $progress%"),
            const SizedBox(height: 12),
            const Text("Member", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final m in members)
                  Chip(
                    label: Text(m),
                    onDeleted: () => setState(() => members.remove(m)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add),
                  label: const Text("Add"),
                  onPressed: () async {
                    final pick = await _pickFriend(context, friendBook);
                    if (pick != null && !members.contains(pick)) {
                      setState(() => members.add(pick));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC04D),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("กรอกชื่อโปรเจกต์ก่อนนะ"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        // ✅ เก็บ context references ก่อน async operation
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        try {
                          // ✅ สร้าง Project object
                          final project = Project(
                            name: nameCtrl.text.trim(),
                            tag: tag,
                            progress: progress,
                            members: members,
                            deadline: selectedDeadline != null
                                ? "${selectedDeadline!.year.toString().padLeft(4, '0')}-${selectedDeadline!.month.toString().padLeft(2, '0')}-${selectedDeadline!.day.toString().padLeft(2, '0')}"
                                : null,
                          );

                          // ✅ บันทึกลง SQLite
                          await _projectRepo.addProject(project);

                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text("สร้างโปรเจกต์สำเร็จแล้ว! 🎉"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            navigator.pop(
                              true,
                            ); // ส่ง true กลับไปเพื่อบอกว่าเพิ่มสำเร็จ
                          }
                        } catch (e) {
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
                                Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text("กำลังบันทึก..."),
                        ],
                      )
                    : const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _filled(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  Future<String?> _pickFriend(BuildContext context, List<String> list) {
    return showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("เลือกเพื่อน"),
        children: list
            .map(
              (f) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, f),
                child: Text(f),
              ),
            )
            .toList(),
      ),
    );
  }
}
