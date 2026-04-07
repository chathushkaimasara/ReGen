import 'dart:ui';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'SFPro',
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        // Added top padding so the list scrolls neatly under the frosted glass app bar
        padding: EdgeInsets.only(
          left: 20.0, 
          right: 20.0, 
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 20, 
          bottom: 20.0
        ),
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
        color: Theme.of(context).colorScheme.secondary, // Adapts to Dark Mode
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor, // Uses the main background color for contrast
            ),
            child: Icon(
              isLike ? Icons.favorite : Icons.chat_bubble,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.6), // Fades the icon slightly
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
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), // Fades the subtext
                    fontSize: 11
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
