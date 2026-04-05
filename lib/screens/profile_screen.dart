import 'package:flutter/material.dart';
import 'upload_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ReGen',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 26),
            onPressed: () {
              
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            
            SizedBox(
              height: 190,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  
                  Container(
                    height: 130,
                    width: double.infinity,
                    color: const Color(0xFFE0E0E0),
                  ),
                  
                  Positioned(
                    top: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4), 
                      ),
                      child: const CircleAvatar(
                        radius: 56,
                        backgroundColor: Color(0xFFD9D9D9), 
                        
                        
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
           
            const Text(
              'Jake Lol',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            const Text(
              '@lol8723',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            const Text(
              'This is My Bio.....',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 30),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(), 
                shrinkWrap: true, 
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, 
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}