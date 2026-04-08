import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StorageService {
  final String _imgbbApiKey = dotenv.env['IMGBB_API_KEY'] ?? '';
  final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  final String _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  Future<String> uploadPostImage(File imageFile, String userId) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      Uri url = Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbApiKey');
      var response = await http.post(url, body: {'image': base64Image});

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['display_url'];
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  Future<String> uploadVideo(File videoFile) async {
    try {
      if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
        throw Exception("Cloudinary credentials missing in .env file");
      }

      Uri url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/video/upload');

      var request = http.MultipartRequest('POST', url);

      request.fields['upload_preset'] = _uploadPreset;

      request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['secure_url']; 
      } else {
        throw Exception("Cloudinary Upload Failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to upload video: $e");
    }
  }
}
