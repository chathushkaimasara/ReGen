import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? selectedPlatform;
  
  File? _selectedFile;
  bool _isVideo = false;
  bool _isPickingMedia = false;
  bool _isUploading = false;

  final List<String> _platforms = ['Sora', 'Runway Gen-2', 'Pika Labs', 'Midjourney', 'DALL-E 3', 'Other'];

  Future<void> _pickMedia(bool pickVideo) async {
    if (_isPickingMedia) return;
    setState(() => _isPickingMedia = true);

    try {
      final picker = ImagePicker();
      final pickedFile = pickVideo 
          ? await picker.pickVideo(source: ImageSource.gallery)
          : await picker.pickImage(source: ImageSource.gallery);
          
      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _isVideo = pickVideo;
        });
      }
    } catch (e) {
      debugPrint("Error picking media: $e");
    } finally {
      setState(() => _isPickingMedia = false);
    }
  }

  void _showPlatformPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              Container(height: 5, width: 50, decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(10))),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Select AI Platform', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ..._platforms.map((platform) => ListTile(
                title: Text(platform, style: const TextStyle(fontSize: 16)),
                trailing: selectedPlatform == platform ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  setState(() => selectedPlatform = platform);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  void _handleUpload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select media!')));
      return;
    }
    if (_titleController.text.isEmpty || selectedPlatform == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and AI Platform are required.')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      if (_isVideo) {
        String videoUrl = await StorageService().uploadVideo(_selectedFile!);
        await DatabaseService().createVideoPost(
          userId: userId, videoUrl: videoUrl, title: _titleController.text.trim(),
          prompt: _promptController.text.trim(), description: _descController.text.trim(), aiPlatform: selectedPlatform!,
        );
      } else {
        String imageUrl = await StorageService().uploadPostImage(_selectedFile!, userId);
        await DatabaseService().createPost(
          userId: userId, imageUrl: imageUrl, title: _titleController.text.trim(),
          prompt: _promptController.text.trim(), description: _descController.text.trim(), aiPlatform: selectedPlatform!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded Successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.secondary),
            child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
          ),
        ),
        title: const Text('Upload', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'SFPro')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 20, right: 20, top: MediaQuery.of(context).padding.top + kToolbarHeight + 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _pickMedia(false),
                  child: Container(
                    height: 120, width: 120,
                    decoration: BoxDecoration(
                      color: !_isVideo && _selectedFile != null ? Colors.transparent : Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(15),
                      image: !_isVideo && _selectedFile != null ? DecorationImage(image: FileImage(_selectedFile!), fit: BoxFit.cover) : null,
                    ),
                    child: !_isVideo && _selectedFile != null ? null : Icon(Icons.add_photo_alternate_outlined, size: 40, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () => _pickMedia(true),
                  child: Container(
                    height: 120, width: 120,
                    decoration: BoxDecoration(
                      color: _isVideo && _selectedFile != null ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(15),
                      border: _isVideo && _selectedFile != null ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
                    ),
                    child: _isVideo && _selectedFile != null ? Icon(Icons.video_file, size: 50, color: Theme.of(context).colorScheme.primary) : Icon(Icons.video_call_outlined, size: 40, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            _buildInputLabel('Title'),
            _buildCustomTextField('Add A Title Here...', _titleController, maxLines: 1),
            const SizedBox(height: 20),
            
            _buildInputLabel('Prompt'),
            _buildCustomTextField('Add The Prompt Here...', _promptController, maxLines: 3),
            const SizedBox(height: 20),
            
            _buildInputLabel('Description'),
            _buildCustomTextField('Add A Description Here...', _descController, maxLines: 3),
            const SizedBox(height: 20),
            
            _buildInputLabel('AI Platform'),
            GestureDetector(
              onTap: _showPlatformPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedPlatform ?? 'Select The Platform', style: TextStyle(color: selectedPlatform == null ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4) : Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)),
                    Icon(Icons.keyboard_arrow_down, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: _isUploading ? null : _handleUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isUploading 
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).scaffoldBackgroundColor))
                    : const Text('Upload', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
  }

  Widget _buildCustomTextField(String hintText, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller, maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4), fontSize: 14),
        filled: true, fillColor: Theme.of(context).colorScheme.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
