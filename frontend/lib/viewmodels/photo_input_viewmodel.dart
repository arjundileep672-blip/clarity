import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';

class PhotoInputViewModel extends ChangeNotifier {
  final PermissionService _permissionService = PermissionService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  String? _imageFilePath;
  final String _persistenceKey;

  String? get imageFilePath => _imageFilePath;

  PhotoInputViewModel(this._persistenceKey) {
    _loadPersistedImage();
  }

  Future<void> _loadPersistedImage() async {
    final path = await _storageService.getString(_persistenceKey);
    if (path != null) {
      _imageFilePath = path;
      notifyListeners();
    }
  }

  Future<void> pickImageFromGallery() async {
    if (await _permissionService.requestPhotosPermission()) {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          _imageFilePath = image.path;
          await _storageService.saveString(_persistenceKey, image.path);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error picking image: $e');
      }
    }
  }

  Future<void> takePhoto() async {
    if (await _permissionService.requestCameraPermission()) {
      try {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
        );
        if (photo != null) {
          _imageFilePath = photo.path;
          await _storageService.saveString(_persistenceKey, photo.path);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error taking photo: $e');
      }
    }
  }

  Future<void> clearImage() async {
    _imageFilePath = null;
    await _storageService.clear(_persistenceKey);
    notifyListeners();
  }
}
