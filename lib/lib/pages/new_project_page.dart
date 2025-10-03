import 'package:flutter/material.dart';
import '../data/tab_tag.dart';

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key});
  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  final nameCtrl = TextEditingController();
  String tag = TabTag.values.first;
  String process = "Plan";
  int progress = 10;
  final members = <String>[];
  final friendBook = const ["Alice", "Bob", "Charlie", "Diana", "Eve"];
  final deadlines = const ["No deadline", "Today", "Tomorrow", "Next week"];
  String? deadline;

  void _recalc() {
    progress =
        {"Plan": 10, "Doing": 50, "Review": 80, "Done": 100}[process] ?? 0;
    setState(() {});
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
              "My Task",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TabTag.values
                  .map(
                    (t) => ChoiceChip(
                      label: Text(t),
                      selected: tag == t,
                      onSelected: (_) => setState(() => tag = t),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: deadline,
              decoration: _filled("Deadline"),
              items: deadlines
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => deadline = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: process,
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
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("กรอกชื่อโปรเจกต์ก่อนนะ")),
                    );
                    return;
                  }
                  Navigator.pop(context, {
                    "name": nameCtrl.text.trim(),
                    "tag": tag,
                    "progress": progress,
                    "members": members,
                  });
                },
                child: const Text("Save"),
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