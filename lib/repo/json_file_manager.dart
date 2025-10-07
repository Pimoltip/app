import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// ✅ ตัวจัดการอ่าน/เขียนไฟล์ JSON ภายใน Application Documents Directory
class JsonFileManager {
  final String fileName;

  JsonFileManager(this.fileName);

  /// ✅ path เต็มของไฟล์ใน local storage
  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  /// ✅ อ่านข้อมูล JSON (คืนค่าเป็น List)
  Future<List<dynamic>> readJson() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) return json.decode(content);
      }
    } catch (e) {
      print('❌ readJson($fileName) error: $e');
    }
    return [];
  }

  /// ✅ เขียนทับไฟล์ทั้งหมด
  Future<void> writeJson(List<dynamic> data) async {
    try {
      final file = await _getLocalFile();
      await file.writeAsString(json.encode(data), flush: true);
      print('✅ writeJson($fileName) saved successfully');
    } catch (e) {
      print('❌ writeJson($fileName) error: $e');
    }
  }

  /// ✅ เพิ่มข้อมูลใหม่เข้าไฟล์
  Future<void> addItem(Map<String, dynamic> newItem) async {
    final data = await readJson();
    data.add(newItem);
    await writeJson(data);
  }

  /// ✅ ลบไฟล์ JSON
  Future<void> deleteFile() async {
    final file = await _getLocalFile();
    if (await file.exists()) {
      await file.delete();
      print('🗑️ Deleted $fileName');
    }
  }

  /// ✅ คัดลอกจาก assets → local (ใช้ตอนเริ่มแอป)
  Future<void> copyFromAsset(String assetPath) async {
    final file = await _getLocalFile();
    if (!await file.exists()) {
      final data = await rootBundle.loadString(assetPath);
      await file.writeAsString(data, flush: true);
      print('📥 Copied $assetPath → ${file.path}');
    }
  }
}
