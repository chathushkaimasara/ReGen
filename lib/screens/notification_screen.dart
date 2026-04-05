import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF5F5F5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'SFPro',
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        children: const [
          NotificationHeader(title: 'Today'),
          NotificationTile(isLike: true, text: 'You Got A New Like On Your Post', subtext: '@lol2456 Liked Your Post'),
          NotificationTile(isLike: false, text: 'Someone Commented On Your Post', subtext: '@user2302875478 Commented On Your Post'),
          
          SizedBox(height: 20),
          NotificationHeader(title: 'Yesterday'),
          NotificationTile(isLike: true, text: 'You Got A New Like On Your Post', subtext: '@r24724 Liked Your Post'),
          NotificationTile(isLike: true, text: 'You Got A New Like On Your Post', subtext: '@418547 Liked Your Post'),
          NotificationTile(isLike: true, text: 'You Got A New Like On Your Post', subtext: '@2348524 Liked Your Post'),

          SizedBox(height: 20),
          NotificationHeader(title: 'Dec 20, 2025'),
          NotificationTile(isLike: true, text: 'You Got A New Like On Your Post', subtext: '@helloworld55 Liked Your Post'),
        ],
      ),
    );
  }
}

class NotificationHeader extends StatelessWidget {
  final String title;
  const NotificationHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final bool isLike;
  final String text;
  final String subtext;

  const NotificationTile({
    super.key,
    required this.isLike,
    required this.text,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE0E0E0),
            ),
            child: Icon(
              isLike ? Icons.favorite : Icons.chat_bubble,
              color: Colors.black54,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  subtext,
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

