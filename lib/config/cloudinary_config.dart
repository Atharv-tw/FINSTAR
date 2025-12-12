/// Cloudinary Configuration
///
/// Free tier limits:
/// - 25 GB storage
/// - 25 GB bandwidth/month
/// - 25,000 images
///
/// Get your credentials from: https://console.cloudinary.com/
class CloudinaryConfig {
  // TODO: Replace with your actual Cloudinary credentials
  // Get these from: https://console.cloudinary.com/console
  static const String cloudName = 'dmjwpjyxm'; // e.g., 'dk1abc2def'
  static const String uploadPreset = 'finstar_profile_pics'; // Create this in Cloudinary dashboard

  // Optional: For signed uploads (more secure)
  static const String apiKey = 'YOUR_API_KEY'; // e.g., '123456789012345'

  // Upload URL (do not change)
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  // Folder structure
  static const String avatarFolder = 'finstar/avatars';
  static const String gameAssetsFolder = 'finstar/game-assets';

  // Image transformation presets
  static String getAvatarUrl(String publicId, {int size = 200}) {
    return 'https://res.cloudinary.com/$cloudName/image/upload/'
        'c_fill,w_$size,h_$size,g_face,q_auto,f_auto/$publicId';
  }

  static String getThumbnailUrl(String publicId, {int size = 100}) {
    return 'https://res.cloudinary.com/$cloudName/image/upload/'
        'c_thumb,w_$size,h_$size,g_face,q_auto,f_auto/$publicId';
  }
}
