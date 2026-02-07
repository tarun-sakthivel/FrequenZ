import 'package:permission_handler/permission_handler.dart';

class MicPermission {
  static Future<bool> request() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
}
