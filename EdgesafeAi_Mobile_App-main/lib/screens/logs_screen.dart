import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../screens/dashboard_controller.dart';
import '../../detection_model.dart';
import '../../app_theme.dart';
import '../screens/glass_card.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen>
    with SingleTickerProviderStateMixin {
  final DashboardController _ctrl = Get.find<DashboardController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs & Analytics'),
        backgroundColor: AppTheme.bgDark,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryCyan,
          labelColor: AppTheme.primaryCyan,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'REAL EVENTS'),
            Tab(text: 'CHARTS'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070D1A), AppTheme.bgDark],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [_buildOverviewTab(), _buildEventsTab(), _buildChartsTab()],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final stats = _ctrl.stats.value;
        return Column(
          children: [
            _buildSummaryCard(
              title: 'Live Session Overview',
              child: Column(
                children: [
                  _summaryRow(
                    'Current People Detected',
                    stats.totalPeople.toString(),
                    AppTheme.primaryCyan,
                  ),
                  _divider(),
                  _summaryRow(
                    'Peak Crowd Count',
                    stats.peakPeople.toString(),
                    AppTheme.primaryCyan,
                  ),
                  _divider(),
                  _summaryRow(
                    'Fire Incidents',
                    stats.fireCount.toString(),
                    AppTheme.dangerRed,
                  ),
                  _divider(),
                  _summaryRow(
                    'Weapon Detections',
                    stats.weaponCount.toString(),
                    AppTheme.warningAmber,
                  ),
                  _divider(),
                  _summaryRow(
                    'Total Threats Currently',
                    stats.totalThreats.toString(),
                    stats.totalThreats > 0
                        ? AppTheme.dangerRed
                        : AppTheme.accentGreen,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),
            _buildSummaryCard(
              title: 'System Performance',
              child: Column(
                children: [
                  _summaryRow(
                    'Uptime',
                    _ctrl.formattedUptime,
                    AppTheme.accentGreen,
                  ),
                  _divider(),
                  _summaryRow(
                    'Connection Status',
                    stats.isSystemOnline
                        ? 'Connected via WebSockets'
                        : 'Offline',
                    stats.isSystemOnline
                        ? AppTheme.accentGreen
                        : AppTheme.dangerRed,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard({required String title, required Widget child}) {
    return GlassCard(
      backgroundColor: AppTheme.bgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: AppTheme.glassBorder, height: 1);

  Widget _buildEventsTab() {
    return Obx(() {
      final logs = _ctrl.logs; // REAL LOGS FROM BACKEND!
      if (logs.isEmpty) {
        return const Center(
          child: Text(
            'No real threats detected yet in this session. Send a frame with a knife or fire to generate a log.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (ctx, i) => _buildDetailedEventTile(
          logs[i],
          i,
        ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: -0.05),
      );
    });
  }

  Widget _buildDetailedEventTile(DetectionEvent event, int index) {
    Color color = AppTheme.primaryCyan;
    IconData icon = Icons.person;
    if (event.type == DetectionType.fire) {
      color = AppTheme.dangerRed;
      icon = Icons.local_fire_department;
    } else if (event.type == DetectionType.weapon) {
      color = AppTheme.warningAmber;
      icon = Icons.gpp_bad;
    } else if (event.type == DetectionType.violence) {
      color = const Color(0xFFFF6D00);
      icon = Icons.warning_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        backgroundColor: color.withOpacity(0.05),
        borderColor: color.withOpacity(0.25),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 8),
          iconColor: color,
          collapsedIconColor: AppTheme.textSecondary,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          title: Text(
            event.typeLabel,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            DateFormat('HH:mm:ss').format(event.timestamp),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: AppTheme.glassBorder),
                _detailRow('Description', event.description),
                _detailRow('Location', 'Live Railway Feed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              key,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          "Live Historical Charts require a Database.\n\nCurrently, EdgeSafe runs fully stateless at the edge for privacy. Live data is processed instantly and discarded.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}
