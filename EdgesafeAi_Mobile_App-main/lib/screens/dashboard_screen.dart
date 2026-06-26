import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../auth_controller.dart';
import 'dashboard_controller.dart';
import '../detection_model.dart';
import '../app_theme.dart';
import 'camera_feed_widget.dart';
import 'glass_card.dart';
import 'stat_card.dart';
import 'chatbot_screen.dart';

// --- ADD THESE IMPORTS SO THE TABS WORK ---
import 'monitoring_screen.dart';
import 'logs_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _ctrl = Get.find<DashboardController>();
  final AuthController _authCtrl = Get.find<AuthController>();

  // This tracks which tab is currently active
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all screens alive and simply switches between them
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardTab(), // Tab 0: The original dashboard content
          const MonitoringScreen(), // Tab 1
          const LogsScreen(), // Tab 2
          const SettingsScreen(), // Tab 3
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildChatFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Dashboard 'Stack' in its own widget method
  Widget _buildDashboardTab() {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF070D1A), AppTheme.bgDark],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAlertBanner(),
                      _buildSystemStatus(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('THREAT INTELLIGENCE'),
                      const SizedBox(height: 12),
                      _buildStatCards(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('LIVE CAMERA FEED'),
                      const SizedBox(height: 12),
                      _buildCameraSection(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('RECENT EVENTS'),
                      const SizedBox(height: 12),
                      _buildRecentEvents(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryCyan, AppTheme.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryCyan.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.security, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EDGESAFE AI',
                  style: TextStyle(
                    color: AppTheme.primaryCyan,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                Obx(
                  () => Text(
                    'Welcome, ${_authCtrl.userName.value}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Text(
              _ctrl.formattedUptime,
              style: const TextStyle(
                color: AppTheme.accentGreen,
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Get.find<AuthController>().logout(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Icon(
                Icons.logout,
                color: AppTheme.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Obx(() {
      if (!_ctrl.isAlertActive.value) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.dangerRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dangerRed.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.dangerRed),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _ctrl.activeAlertMessage.value,
                style: const TextStyle(
                  color: AppTheme.dangerRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.circle, color: AppTheme.dangerRed, size: 10)
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 500.ms)
                .then()
                .fadeOut(duration: 500.ms),
          ],
        ),
      ).animate().shake(duration: 300.ms).then().fadeIn();
    });
  }

  Widget _buildSystemStatus() {
    return Obx(() {
      final stats = _ctrl.stats.value;
      return GlassCard(
        backgroundColor: AppTheme.bgCard,
        borderColor: (stats.isSafe ? AppTheme.accentGreen : AppTheme.dangerRed)
            .withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
                  Icons.circle,
                  color: stats.isSafe
                      ? AppTheme.accentGreen
                      : AppTheme.dangerRed,
                  size: 10,
                )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 800.ms)
                .then()
                .fadeOut(duration: 800.ms),
            const SizedBox(width: 10),
            Text(
              stats.systemStatus,
              style: TextStyle(
                color: stats.isSafe ? AppTheme.accentGreen : AppTheme.dangerRed,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            const Icon(Icons.circle, color: AppTheme.accentGreen, size: 8),
            const SizedBox(width: 4),
            const Text(
              'CAM-01 LIVE',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.circle, color: AppTheme.warningAmber, size: 8),
            const SizedBox(width: 4),
            const Text(
              'PI OFFLINE',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.primaryCyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Obx(() {
      final stats = _ctrl.stats.value;
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // THE FIX: Lowered aspect ratio to give the StatCard more vertical space
        childAspectRatio: 0.85,
        children: [
          StatCard(
            title: 'People Detected',
            value: stats.totalPeople,
            icon: Icons.people_alt,
            color: AppTheme.primaryCyan,
            subtitle: 'Peak today: ${stats.peakPeople}',
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
          StatCard(
            title: 'Fire Alerts',
            value: stats.fireCount,
            icon: Icons.local_fire_department,
            color: AppTheme.dangerRed,
            subtitle: 'Requires immediate action',
            isDanger: stats.fireCount > 0,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
          StatCard(
            title: 'Weapon Detections',
            value: stats.weaponCount,
            icon: Icons.gpp_bad,
            color: AppTheme.warningAmber,
            subtitle: 'Security notified',
            isDanger: stats.weaponCount > 0,
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
          StatCard(
            title: 'Suspicious Activity',
            value: stats.violenceCount,
            icon: Icons.warning_rounded,
            color: const Color(0xFFFF6D00),
            subtitle: 'Under surveillance',
            isDanger: stats.violenceCount > 2,
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
        ],
      );
    });
  }

  Widget _buildCameraSection() {
    return SizedBox(
      height: 300,
      child: const CameraFeedWidget(),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildRecentEvents() {
    return Obx(() {
      final events = _ctrl.recentEvents.isEmpty
          ? _ctrl.logs.take(5).toList()
          : _ctrl.recentEvents.take(5).toList();

      if (events.isEmpty) {
        return const Center(
          child: Text(
            'No events yet...',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        );
      }

      return Column(
        children: events.asMap().entries.map((entry) {
          return _buildEventTile(
            entry.value,
          ).animate().fadeIn(delay: (entry.key * 100).ms).slideX(begin: -0.1);
        }).toList(),
      );
    });
  }

  Widget _buildEventTile(DetectionEvent event) {
    Color color;
    IconData icon;
    switch (event.type) {
      case DetectionType.fire:
        color = AppTheme.dangerRed;
        icon = Icons.local_fire_department;
        break;
      case DetectionType.weapon:
        color = AppTheme.warningAmber;
        icon = Icons.gpp_bad;
        break;
      case DetectionType.violence:
        color = const Color(0xFFFF6D00);
        icon = Icons.warning_rounded;
        break;
      case DetectionType.person:
        color = AppTheme.primaryCyan;
        icon = Icons.person;
        break;
      case DetectionType.safe:
        color = AppTheme.accentGreen;
        icon = Icons.verified_user;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        backgroundColor: color.withOpacity(0.05),
        borderColor: color.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        event.typeLabel,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('HH:mm').format(event.timestamp),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '📍 ${event.location}  •  ${(event.confidence * 100).toStringAsFixed(0)}% confidence',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          top: BorderSide(color: AppTheme.glassBorder, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        // Instead of pushing routes, update the selected tab index
        onTap: (i) {
          setState(() => _selectedIndex = i);
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: AppTheme.primaryCyan,
        unselectedItemColor: AppTheme.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 10, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Monitor'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildChatFAB() {
    return FloatingActionButton.extended(
      onPressed: () =>
          Get.to(() => const ChatbotScreen(), transition: Transition.downToUp),
      backgroundColor: AppTheme.primaryCyan,
      foregroundColor: AppTheme.bgDark,
      icon: const Icon(Icons.smart_toy),
      label: const Text(
        'AI Assistant',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
