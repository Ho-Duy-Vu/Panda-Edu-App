import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  Future<bool> isMicrophonePermanentlyDenied() async {
    final status = await Permission.microphone.status;
    return status.isPermanentlyDenied;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}
