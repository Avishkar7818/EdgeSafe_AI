// lib/controllers/settings_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxBool soundAlertsEnabled = true.obs;
  final RxBool motionDetectionEnabled = true.obs;
  final RxBool nightModeEnabled = false.obs;
  final RxBool autoRecordEnabled = true.obs;
  final RxString cameraStatus = 'Connected (Demo)'.obs;
  final RxString piStatus = 'Not Connected'.obs;
  final RxString aiModelStatus = 'Running (Simulation)'.obs;
  final RxDouble detectionSensitivity = 0.75.obs;
  final RxInt alertThreshold = 3.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled.value = prefs.getBool('notifications') ?? true;
    soundAlertsEnabled.value = prefs.getBool('sound_alerts') ?? true;
    motionDetectionEnabled.value = prefs.getBool('motion_detection') ?? true;
    autoRecordEnabled.value = prefs.getBool('auto_record') ?? true;
    detectionSensitivity.value = prefs.getDouble('sensitivity') ?? 0.75;
    alertThreshold.value = prefs.getInt('alert_threshold') ?? 3;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', notificationsEnabled.value);
    await prefs.setBool('sound_alerts', soundAlertsEnabled.value);
    await prefs.setBool('motion_detection', motionDetectionEnabled.value);
    await prefs.setBool('auto_record', autoRecordEnabled.value);
    await prefs.setDouble('sensitivity', detectionSensitivity.value);
    await prefs.setInt('alert_threshold', alertThreshold.value);
    Get.snackbar(
      'Settings Saved',
      'Your preferences have been updated.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void reconnectPi() async {
    piStatus.value = 'Connecting...';
    await Future.delayed(const Duration(seconds: 2));
    piStatus.value = 'Not Connected (Demo Mode)';
    Get.snackbar(
      'Connection Failed',
      'Raspberry Pi not found. Running in simulation mode.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
