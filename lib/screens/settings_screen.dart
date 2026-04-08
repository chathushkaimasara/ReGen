import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'auth_gate.dart';
import '../providers/theme_provider.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _notificationsEnabled = true;

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (route) => false,
      );
    }
  }

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
            
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            TextEditingController nameController = TextEditingController(text: userData['name'] ?? '');
            TextEditingController bioController = TextEditingController(text: userData['bio'] ?? '');

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(height: 5, width: 50, decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Display Name', filled: true, fillColor: Theme.of(context).colorScheme.secondary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: bioController,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: 'Bio', filled: true, fillColor: Theme.of(context).colorScheme.secondary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await DatabaseService().updateProfileDetails(currentUserId, nameController.text.trim(), bioController.text.trim());
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text('Save Changes', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          _buildSettingsTile(icon: Icons.person_outline, title: 'Edit Profile', onTap: _showEditProfileSheet),
          
          const SizedBox(height: 30),
          const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.dark_mode_outlined, color: Theme.of(context).iconTheme.color),
            ),
            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            value: isDarkMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.notifications_active_outlined, color: Theme.of(context).iconTheme.color),
            ),
            title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            value: _notificationsEnabled,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          
          const SizedBox(height: 30),
          const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          _buildSettingsTile(icon: Icons.info_outline, title: 'About ReGen', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
          }),
          _buildSettingsTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
          }),
          _buildSettingsTile(icon: Icons.description_outlined, title: 'Licenses & 3rd Party', onTap: () {
            showLicensePage(
              context: context,
              applicationName: 'ReGen',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2026 ReGen AI Platform',
            );
          }),
          
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Theme.of(context).iconTheme.color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('About ReGen', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, size: 60, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            const Text('ReGen', style: TextStyle(fontFamily: 'SFPro', fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('Version 1.0.0', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))),
            const SizedBox(height: 30),
            const Text(
              'ReGen is a next-generation social platform dedicated to showcasing AI-generated art and videos. '
              'Connect with creators, share your prompts, and explore the limitless possibilities of artificial intelligence.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const Spacer(),
            Text('© 2026 ReGen Development Team', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildFaqItem(context, 'How do I upload a video?', 'Tap the + icon on your profile or home screen, select the video option, and ensure you have a Cloudinary account linked in your environment variables.'),
          _buildFaqItem(context, 'Are my prompts public?', 'Yes, ReGen is designed to be a collaborative platform. Your prompts are displayed alongside your generations so others can learn from your techniques.'),
          _buildFaqItem(context, 'How do I change my profile banner?', 'Navigate to your Profile screen and simply tap on the top background area above your avatar.'),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          const Text('Contact Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email_outlined),
            title: const Text('support@regen.ai'),
            subtitle: const Text('We typically respond within 24 hours.'),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      childrenPadding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      children: [
        Text(answer, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), height: 1.4)),
      ],
    );
  }
}
