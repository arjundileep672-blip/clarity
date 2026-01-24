import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestPhotosPermission() async {
    // For Android 13+ (SDK 33) use Permission.photos, older use Permission.storage
    // permission_handler handles SDK checks internally usually, keeping simple for now
    final status = await Permission.photos.request();
    if (status.isGranted) return true;

    // Fallback for older Android
    if (await Permission.storage.request().isGranted) return true;

    return false;
  }

  Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }
}
