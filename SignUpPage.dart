import 'package:flutter/material.dart';

class Signuppage extends StatelessWidget { // แก้จาก extends ตัวเอง
  const Signuppage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
              const SizedBox(height: 10),
              Container(
                width: 230,
                height: 30,
                color: const Color(0xffb2bb1f),
              ),
              const SizedBox(height: 10),
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
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50), // ขอบมน
                  ),
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
            const SizedBox(height: 24),
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
              TextField(
                obscureText: true, // ซ่อนรหัส
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50), // ขอบมน
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff006866),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // ขอบมน
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 150, vertical: 14),
                ),
                child: const Text(
                  "SIGN UP",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {Navigator.pushNamed(context, '/login');},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // ขอบมน
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 150, vertical: 14),
                ),
                child: const Text(
                  "SIGN IN",
                  style: TextStyle(fontSize: 15, color: Color(0xff006866)),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
