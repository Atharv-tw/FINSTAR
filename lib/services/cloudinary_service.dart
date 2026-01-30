import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/cloudinary_config.dart';
import 'package:flutter/foundation.dart';

/// Cloudinary Service for Image Uploads
///
/// Free tier alternative to Firebase Storage
/// - No billing required
/// - 25GB storage, 25GB bandwidth/month
class CloudinaryService {
  // Singleton pattern
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Upload image to Cloudinary
  ///
  /// Returns the public_id of the uploaded image or null if failed
  Future<String?> uploadImage(
    XFile imageFile, {
    String folder = CloudinaryConfig.avatarFolder,
    String? publicId,
  }) async {
    try {
      final url = Uri.parse(CloudinaryConfig.uploadUrl);

      final request = http.MultipartRequest('POST', url);

      // Add upload preset (unsigned upload)
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      request.fields['folder'] = folder;

      // Optional: specify public_id for consistent naming
      if (publicId != null) {
        request.fields['public_id'] = publicId;
      }

      // Add the image file
      final file = File(imageFile.path);
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
      );
      request.files.add(multipartFile);

      debugPrint('Uploading image to Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        final uploadedPublicId = jsonResponse['public_id'] as String;
        final secureUrl = jsonResponse['secure_url'] as String;

        debugPrint('Upload successful!');
        debugPrint('Public ID: $uploadedPublicId');
        debugPrint('URL: $secureUrl');

        return uploadedPublicId;
      } else {
        debugPrint('Upload failed: ${response.statusCode}');
        debugPrint('Response: $responseData');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Upload avatar and return the public_id
  Future<String?> uploadAvatar(XFile imageFile, String userId) async {
    return uploadImage(
      imageFile,
      folder: CloudinaryConfig.avatarFolder,
      publicId: 'user_$userId', // Consistent naming
    );
  }

  /// Get avatar URL with transformations
  String getAvatarUrl(String publicId, {int size = 200}) {
    return CloudinaryConfig.getAvatarUrl(publicId, size: size);
  }

  /// Get thumbnail URL
  String getThumbnailUrl(String publicId, {int size = 100}) {
    return CloudinaryConfig.getThumbnailUrl(publicId, size: size);
  }

  /// Delete image from Cloudinary (requires API secret - use backend for production)
  ///
  /// Note: For security, deletion should be done server-side with API secret
  /// For now, we'll just mark images as unused and clean them up manually
  Future<bool> deleteImage(String publicId) async {
    // TODO: Implement server-side deletion with API secret
    // For free tier without backend, you can manually delete from Cloudinary dashboard
    debugPrint('Note: Image deletion should be done via Cloudinary dashboard');
    return false;
  }
}