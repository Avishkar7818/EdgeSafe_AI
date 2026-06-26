// lib/screens/monitoring/monitoring_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../screens/dashboard_controller.dart';
import '../../app_theme.dart';
import '../../screens/camera_feed_widget.dart';
import '../../screens/glass_card.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Monitoring'),
        backgroundColor: AppTheme.bgDark,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.circle, color: AppTheme.dangerRed, size: 10),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: AppTheme.dangerRed,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              // Main camera feed - large
              SizedBox(
                height: 260,
                child: const CameraFeedWidget(),
              ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: 16),

              // Multi-camera grid (additional mock feeds)
              const Text(
                'ALL CAMERAS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: [
                  _buildMiniCamera(
                    'CAM-01',
                    'Main Entrance',
                    true,
                    AppTheme.accentGreen,
                  ),
                  _buildMiniCamera(
                    'CAM-02',
                    'Zone 2 - Storage',
                    false,
                    AppTheme.warningAmber,
                  ),
                  _buildMiniCamera(
                    'CAM-03',
                    'Zone 3 - Lobby',
                    true,
                    AppTheme.accentGreen,
                  ),
                  _buildMiniCamera(
                    'CAM-04',
                    'Perimeter',
                    false,
                    AppTheme.textSecondary,
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 20),

              // Detection overlay stats
              const Text(
                'DETECTION PARAMETERS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _buildDetectionParams(ctrl),
              const SizedBox(height: 20),

              // Zone activity map
              _buildZoneMap(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCamera(
    String id,
    String location,
    bool isActive,
    Color statusColor,
  ) {
    return GlassCard(
      backgroundColor: AppTheme.bgCard,
      borderColor: statusColor.withOpacity(0.3),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              color: const Color(0xFF060D1A),
              child: CustomPaint(painter: _MiniScenePainter()),
            ),
            if (isActive)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.primaryCyan.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              left: 8,
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? statusColor : AppTheme.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    id,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 6,
              left: 8,
              right: 8,
              child: Text(
                isActive ? location : 'OFFLINE',
                style: TextStyle(
                  color: isActive ? Colors.white70 : AppTheme.textSecondary,
                  fontSize: 9,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionParams(DashboardController ctrl) {
    return Obx(() {
      final stats = ctrl.stats.value;
      return GlassCard(
        backgroundColor: AppTheme.bgCard,
        child: Column(
          children: [
            _paramRow('Model Accuracy', '98.7%', AppTheme.accentGreen),
            const Divider(color: AppTheme.glassBorder, height: 16),
            _paramRow('Frame Rate', '30 FPS', AppTheme.primaryCyan),
            const Divider(color: AppTheme.glassBorder, height: 16),
            _paramRow(
              'Active Detections',
              '${stats.totalPeople + stats.totalThreats}',
              AppTheme.warningAmber,
            ),
            const Divider(color: AppTheme.glassBorder, height: 16),
            _paramRow('Inference Time', '12ms', AppTheme.primaryCyan),
            const Divider(color: AppTheme.glassBorder, height: 16),
            _paramRow('Detection Confidence', '>75%', AppTheme.accentGreen),
          ],
        ),
      );
    });
  }

  Widget _paramRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildZoneMap() {
    return GlassCard(
      backgroundColor: AppTheme.bgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ZONE ACTIVITY MAP',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF050A14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: CustomPaint(painter: _ZoneMapPainter()),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(AppTheme.accentGreen, 'Clear'),
              const SizedBox(width: 16),
              _legend(AppTheme.warningAmber, 'Activity'),
              const SizedBox(width: 16),
              _legend(AppTheme.dangerRed, 'Alert'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _MiniScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF0A1628);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      p,
    );
    final b = Paint()..color = const Color(0xFF0D1F35);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.2,
        size.width * 0.2,
        size.height * 0.4,
      ),
      b,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.7,
        size.height * 0.1,
        size.width * 0.2,
        size.height * 0.5,
      ),
      b,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ZoneMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF050A14);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.08)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Zones
    final zones = [
      (
        Rect.fromLTWH(10, 10, size.width * 0.4, size.height * 0.45),
        AppTheme.warningAmber,
        'ZONE 1',
      ),
      (
        Rect.fromLTWH(
          size.width * 0.45,
          10,
          size.width * 0.5,
          size.height * 0.45,
        ),
        AppTheme.dangerRed,
        'ZONE 2',
      ),
      (
        Rect.fromLTWH(
          10,
          size.height * 0.55,
          size.width * 0.4,
          size.height * 0.4,
        ),
        AppTheme.accentGreen,
        'ZONE 3',
      ),
      (
        Rect.fromLTWH(
          size.width * 0.45,
          size.height * 0.55,
          size.width * 0.5,
          size.height * 0.4,
        ),
        AppTheme.accentGreen,
        'ZONE 4',
      ),
    ];

    for (final zone in zones) {
      final fillPaint = Paint()..color = zone.$2.withOpacity(0.1);
      final strokePaint = Paint()
        ..color = zone.$2.withOpacity(0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawRect(zone.$1, fillPaint);
      canvas.drawRect(zone.$1, strokePaint);

      final tp = TextPainter(
        text: TextSpan(
          text: zone.$3,
          style: TextStyle(
            color: zone.$2,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, zone.$1.topLeft.translate(6, 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
