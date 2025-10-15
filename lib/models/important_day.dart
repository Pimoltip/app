/// 📅 IMPORTANT DAY MODEL - โครงสร้างข้อมูลวันสำคัญ บัตรบันทึก
/// Data class ที่เก็บข้อมูลวันสำคัญในระบบ
/// หน้าที่หลัก:
/// 1. เก็บข้อมูลวันสำคัญ (วันหยุด, วันครบรอบ, วันพิเศษ)
/// 2. รองรับการแสดงผลในปฏิทินด้วยสีต่างๆ
/// 3. จัดการข้อมูลจากไฟล์ JSON (assets)
/// 4. รองรับการแปลงข้อมูลระหว่างรูปแบบต่างๆ
/// 
/// ฟีเจอร์หลัก:
/// - Important Day Data Storage
/// - Color-coded Display
/// - JSON Integration
/// - Asset Data Management
/// - Calendar Integration
/// - Visual Indicators
/// 
/// การทำงาน:
/// - ใช้เป็น Model สำหรับเก็บข้อมูลวันสำคัญจากไฟล์ JSON
/// - รองรับการแสดงผลในปฏิทินด้วยสีที่กำหนด
/// - จัดการข้อมูลวันหยุด, วันครบรอบ, วันพิเศษ
/// - รองรับการแปลงข้อมูลเป็น JSON และจาก JSON
/// 
/// ข้อมูลที่เก็บ:
/// - ชื่อวันสำคัญ
/// - วันที่ (ในรูปแบบ string)
/// - คำอธิบายวันสำคัญ
/// - สีสำหรับแสดงผล (hex color code)

// การประกาศ class ImportantDayเป็นModel(แม่แบบข้อมูล)ใช้สำหรับจัดเก็บข้อมูลของกิจกรรม/วันสำคัญ 
class ImportantDay {
  
  // 📊 ข้อมูลวันสำคัญ
  final String title; /// ชื่อหรือหัวข้อของวัน
  final String date; /// วันที่ของวันสำคัญ (ในรูปแบบ string) ใช้สำหรับ เปรียบเทียบและกรอง
  final String description; /// คำอธิบายหรือรายละเอียดของวันสำคัญ
  final String color; /// สีสำหรับแสดงผลวันสำคัญ (hex color code)
//----------------------------------------------------------------------------------
  
  // 🔧 Constructor - ฟังก์ชันสร้าง ImportantDay Object
  /// Constructor สำหรับสร้าง ImportantDay object
  /// @param title ชื่อหรือหัวข้อของวันสำคัญ (จำเป็น)
  /// @param date วันที่ของวันสำคัญ (จำเป็น)
  /// @param description คำอธิบายของวันสำคัญ (จำเป็น)
  /// @param color สีสำหรับแสดงผล (จำเป็น)
  /// การใช้งาน: - สร้างวันสำคัญใหม่: ImportantDay(title: "วันหยุด", date: "2024-01-01", ...) - สร้างจาก JSON: ImportantDay.fromJson(jsonData)
  /// ข้อควรระวัง: - ข้อมูลทั้งหมดเป็น required (จำเป็นต้องส่งมา) - date ควรเป็น string format ที่สม่ำเสมอ - color ควรเป็น hex color code ที่ถูกต้อง
  ImportantDay({
    required this.title,
    required this.date,
    required this.description,
    required this.color,
  }); //----------------------------------------------------------------------------
  
  // 📄 JSON Methods - ฟังก์ชันจัดการ JSON
  /// สร้าง ImportantDay object จาก JSON
  /// @param json Map ที่ได้จาก JSON data
  /// @return ImportantDay object ที่สร้างจากข้อมูล JSON
  /// ขั้นตอนการทำงาน: 1. อ่านข้อมูลจาก JSON map 2. ตั้งค่า default values สำหรับข้อมูลที่ขาดหาย 3. สร้าง ImportantDay object ด้วยข้อมูลที่แปลงแล้ว
  /// การใช้งาน: - อ่านข้อมูลจากไฟล์ JSON assets - รับข้อมูลจาก API หรือ network - Import ข้อมูลวันสำคัญจาก external sources - Load ข้อมูลวันหยุดราชการหรือวันสำคัญ
  /// ข้อควรระวัง: - ต้องตรวจสอบว่า JSON มีข้อมูลครบถ้วน - ใช้ default values สำหรับข้อมูลที่ขาดหาย - title จะใช้ค่า default = "No Title" หากไม่ระบุ - date จะใช้ค่า default = "" หากไม่ระบุ
  /// - description จะใช้ค่า default = "" หากไม่ระบุ - color จะใช้ค่า default = "#FF0000" (สีแดง) หากไม่ระบุ
  // 📄 การทำงานของ Factory Constructor
  factory ImportantDay.fromJson(Map<String, dynamic> json) { //รับข้อมูลดิบในรูปแบบ Map (เหมือน Dictionary) ที่ได้จากการแปลงข้อมูล JSON
    return ImportantDay( //สั่งให้สร้าง Object ใหม่โดยเรียกใช้ Constructor หลักของคลาส ImportantDay
      title: json['title'] ?? 'No Title', // หาก JSON ไม่มี title หรือเป็น null จะใช้ 'No Title' แทน
      date: json['date'] ?? '', // ''(ว่างเปล่า)ป้องกันปัญหาถ้าไม่มีคำอธิบาย
      description: json['description'] ?? '', // ''(ว่างเปล่า) ป้องกันปัญหาถ้าไม่มีการระบุวันที่
      color: json['color'] ?? '#FF0000', // ใช้สีแดงเป็นค่า default หากไม่มีสี จะใช้สีแดงเป็นค่าเริ่มต้น
    );
  }//--------------------------------------------------------------------------

  /// เมธอด toJson() แปลง ImportantDay object เป็น JSON รูปแบบ Map บันทึกข้อมูล
  /// @return Map<String, dynamic> ข้อมูลในรูปแบบ JSON
  /// ขั้นตอนการทำงาน: 1. สร้าง Map จาก properties ทั้งหมด 2. เก็บข้อมูลทั้งหมดในรูปแบบ JSON 3. รองรับการส่งผ่าน network หรือบันทึกลงไฟล์
  /// การใช้งาน: - ส่งข้อมูลผ่าน API หรือ network - บันทึกข้อมูลลงไฟล์ JSON
  /// - แชร์ข้อมูลวันสำคัญระหว่างแอปพลิเคชัน - Backup ข้อมูลวันสำคัญ- Export ข้อมูลวันสำคัญ 
  /// ข้อควรระวัง: - ข้อมูลทั้งหมดจะถูกแปลงเป็น JSON - รองรับการทำงานกับ external systems - ควรตรวจสอบ JSON format ก่อนใช้งาน
  Map<String, dynamic> toJson() { //ทำหน้าที่ตรงกันข้ามกับ ImportantDay.fromJson():
    return {
      'title': title, // ชื่อวันสำคัญ
      'date': date, // วันที่
      'description': description, // คำอธิบาย
      'color': color, // สีสำหรับแสดงผล
    };
  }
}
