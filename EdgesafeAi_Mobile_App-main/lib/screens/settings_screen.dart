// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../auth_controller.dart';
import '../../screens/settings_controller.dart';
import '../../app_theme.dart';
import '../../screens/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SettingsController());
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.bgDark,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070D1A), AppTheme.bgDark],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConnectionStatus(ctrl).animate().fadeIn(delay: 50.ms),
              const SizedBox(height: 16),
              _buildNotificationSettings(ctrl).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 16),
              _buildDetectionSettings(ctrl).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 16),
              _buildSystemInfo().animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 16),
              _buildSaveButton(ctrl).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 12),
              _buildLogoutButton(authCtrl).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryCyan, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(SettingsController ctrl) {
    return GlassCard(
      backgroundColor: AppTheme.bgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CONNECTION STATUS', Icons.wifi),
          Obx(
            () => _statusRow(
              'Camera Feed',
              ctrl.cameraStatus.value,
              Icons.videocam,
              AppTheme.accentGreen,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => _statusRow(
              'Raspberry Pi',
              ctrl.piStatus.value,
              Icons.developer_board,
              ctrl.piStatus.value.contains('Not')
                  ? AppTheme.dangerRed
                  : AppTheme.accentGreen,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => _statusRow(
              'AI Model',
              ctrl.aiModelStatus.value,
              Icons.model_training,
              AppTheme.warningAmber,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: ctrl.reconnectPi,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reconnect Raspberry Pi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryCyan,
                side: const BorderSide(color: AppTheme.primaryCyan),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(String label, String status, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(SettingsController ctrl) {
    return GlassCard(
      backgroundColor: AppTheme.bgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('NOTIFICATIONS', Icons.notifications_outlined),
          Obx(
            () => _toggleRow(
              'Push Notifications',
              'Receive alert notifications',
              ctrl.notificationsEnabled,
              (v) => ctrl.notificationsEnabled.value = v,
            ),
          ),
          _divider(),
          Obx(
            () => _toggleRow(
              'Sound Alerts',
              'Audio alerts for threats',
              ctrl.soundAlertsEnabled,
              (v) => ctrl.soundAlertsEnabled.value = v,
            ),
          ),
          _divider(),
          Obx(
            () => _toggleRow(
              'Auto-Record Events',
              'Save detection clips',
              ctrl.autoRecordEnabled,
              (v) => ctrl.autoRecordEnabled.value = v,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionSettings(SettingsController ctrl) {
    return GlassCard(
      backgroundColor: AppTheme.bgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('DETECTION SETTINGS', Icons.track_changes),
          Obx(
            () => _toggleRow(
              'Motion Detection',
              'Enable motion-based triggers',
              ctrl.motionDetectionEnabled,
              (v) => ctrl.motionDetectionEnabled.value = v,
            ),
          ),
          _divider(),
          Obx(
            () => _toggleRow(
              'Night Mode',
              'Enhanced IR detection',
              ctrl.nightModeEnabled,
              (v) => ctrl.nightModeEnabled.value = v,
            ),
          ),
          _divider(),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detection Sensitivity',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${(ctrl.detectionSensitivity.value * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppTheme.primaryCyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: ctrl.detectionSensitivity.value,
                  onChanged: (v) => ctrl.detectionSensitivity.value = v,
                  activeColor: AppTheme.primaryCyan,
                  inactiveColor: AppTheme.bgSurface,
                ),
              ],
            ),
          ),
          _divider(),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alert Threshold (people)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${ctrl.alertThreshold.value}',
                      style: const TextStyle(
                        color: AppTheme.primaryCyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: ctrl.alertThreshold.value.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  onChanged: (v) => ctrl.alertThreshold.value = v.toInt(),
                  activeColor: AppTheme.primaryCyan,
                  inactiveColor: AppTheme.bgSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfo() {
    return GlassCard(
      backgroundColor: AppTheme.bgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('SYSTEM INFO', Icons.info_outline),
          _infoRow('App Version', '1.0.0'),
          _divider(),
          _infoRow('Build', 'Demo / Showcase'),
          _divider(),
          _infoRow('AI Model', 'YOLOv8 (Simulated)'),
          _divider(),
          _infoRow('Platform', 'Flutter (Mobile)'),
          _divider(),
          _infoRow('Edge Device', 'Raspberry Pi 4 (Planned)'),
          _divider(),
          _infoRow('Tagline', 'Intelligence at the Edge.'),
        ],
      ),
    );
  }

  Widget _infoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(
    String label,
    String subtitle,
    RxBool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value.value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryCyan,
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.bgSurface,
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: AppTheme.glassBorder, height: 8);

  Widget _buildSaveButton(SettingsController ctrl) {
    return ElevatedButton.icon(
      onPressed: ctrl.saveSettings,
      icon: const Icon(Icons.save_outlined, size: 18),
      label: const Text(
        'SAVE SETTINGS',
        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryCyan,
        foregroundColor: AppTheme.bgDark,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLogoutButton(AuthController ctrl) {
    return OutlinedButton.icon(
      onPressed: ctrl.logout,
      icon: const Icon(Icons.logout, size: 18),
      label: const Text(
        'SIGN OUT',
        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.dangerRed,
        side: const BorderSide(color: AppTheme.dangerRed),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
