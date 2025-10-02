import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // พื้นหลังเขียวอ่อน
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "KU",
                style: TextStyle(
                  fontSize: 170,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff006866),
                 
                  height: 0.9,
                ),
              ),
              Container(
              width: 230,           // กว้าง 100
              height: 30,           // สูง 50
              color: const Color(0xffb2bb1f), // สีเขียว
              ),

              const Text(
                "PLANER",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff006866),
                  
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: "Enter Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50), // ขอบมน
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true, // ซ่อนรหัส
                decoration: InputDecoration(
                  labelText: "Enter Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50), // ขอบมน
                  ),
                ),
              ),
              const SizedBox(height: 24),


              ElevatedButton( // 👉 ปุ่ม SIGN IN
                onPressed: () { // ไปหน้า calendar หลัง login
                  Navigator.pushReplacementNamed(context, '/calendar');
                },
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff006866),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // ขอบมน
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 150, vertical: 14),
                ),
                child: const Text(
                  "SIGN IN",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}