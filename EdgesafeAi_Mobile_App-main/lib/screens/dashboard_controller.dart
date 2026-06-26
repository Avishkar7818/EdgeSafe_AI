// lib/screens/dashboard_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../detection_model.dart';

class DashboardController extends GetxController {
  late IO.Socket socket;

  final RxString currentFrameBase64 = ''.obs;

  final Rx<DashboardStats> stats = DashboardStats(
    totalPeople: 0,
    fireCount: 0,
    weaponCount: 0,
    violenceCount: 0,
    peakPeople: 0,
    isSystemOnline: false,
    systemStatus: 'CONNECTING...',
  ).obs;

  final RxList<DetectionEvent> recentEvents = <DetectionEvent>[].obs;
  final RxList<DetectionEvent> logs = <DetectionEvent>[].obs;
  final RxBool isAlertActive = false.obs;
  final RxString activeAlertMessage = ''.obs;

  Timer? _alertTimer;
  Timer? _uptimeTimer;
  final RxInt uptimeSeconds = 0.obs;
  int _peakPeopleTracked = 0;

  @override
  void onInit() {
    super.onInit();
    _initWebSocket();
    _startUptime();
  }

  void _initWebSocket() {
    // 🔥 FIX: point at the actual deployed backend, not the old project.
    // No explicit :443 — https implies 443, and forcing it can confuse
    // the engine.io URL parser on some socket_io_client versions.
    socket = IO.io(
      'https://web-production-db655.up.railway.app',
      IO.OptionBuilder()
          .setTransports([
            'websocket',
            'polling',
          ]) // Allow polling if websocket is blocked
          .enableReconnection()
          .setReconnectionAttempts(9999)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(8000)
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      stats.update((val) {
        if (val != null) {
          stats.value = DashboardStats(
            totalPeople: val.totalPeople,
            fireCount: val.fireCount,
            weaponCount: val.weaponCount,
            violenceCount: val.violenceCount,
            peakPeople: val.peakPeople,
            isSystemOnline: true,
            systemStatus: 'SYSTEM ONLINE',
          );
        }
      });
      print('✅ Connected to EdgeSafe WebSocket Backend');
    });

    socket.onConnectError((err) {
      print('❌ WebSocket Connection Error: $err');
      stats.update((val) {
        if (val != null) {
          stats.value = DashboardStats(
            totalPeople: 0,
            fireCount: 0,
            weaponCount: 0,
            violenceCount: 0,
            peakPeople: val.peakPeople,
            isSystemOnline: false,
            systemStatus: 'ERROR: CONNECTION FAILED',
          );
        }
      });
    });

    socket.onError((err) {
      print('❌ WebSocket General Error: $err');
    });

    socket.onDisconnect((_) {
      stats.update((val) {
        if (val != null) {
          stats.value = DashboardStats(
            totalPeople: 0,
            fireCount: 0,
            weaponCount: 0,
            violenceCount: 0,
            peakPeople: val.peakPeople,
            isSystemOnline: false,
            systemStatus: 'OFFLINE',
          );
        }
      });
      print('❌ Disconnected from EdgeSafe WebSocket');
    });

    socket.on('live_detections', (data) {
      _handleLiveDetections(data);
    });

    socket.connect();
  }

  void _handleLiveDetections(dynamic data) {
    if (data == null) return;

    if (data['frame'] != null) {
      currentFrameBase64.value = data['frame'];
    }

    final counts = data['class_counts'] ?? {};
    int pCount = counts['persons'] ?? 0;
    int kCount = counts['knives'] ?? 0;
    int wCount = counts['weapons'] ?? 0;
    int fCount = counts['fire'] ?? 0;

    if (pCount > _peakPeopleTracked) {
      _peakPeopleTracked = pCount;
    }

    String threatLevel = data['threat_level'] ?? "CLEAR";
    String statusText = 'MONITORING';
    if (threatLevel == 'DANGER') statusText = 'CRITICAL ALERT';
    if (threatLevel == 'WARNING') statusText = 'WARNING';

    stats.value = DashboardStats(
      totalPeople: pCount,
      fireCount: fCount,
      weaponCount: kCount + wCount,
      violenceCount: (threatLevel == 'DANGER') ? 1 : 0,
      peakPeople: _peakPeopleTracked,
      isSystemOnline: true,
      systemStatus: statusText,
    );

    if (fCount > 0 || kCount > 0 || wCount > 0 || threatLevel != 'CLEAR') {
      _generateRealLog(data, threatLevel);
    }

    if (threatLevel == 'DANGER' && !isAlertActive.value) {
      String summary = data['summary'] ?? 'Threat detected by AI';
      _triggerAlert('⚠️ DANGER: $summary');
    }
  }

  void _generateRealLog(dynamic data, String threatLevel) {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();
    final counts = data['class_counts'] ?? {};

    DetectionType type = DetectionType.person;
    if (counts['fire'] != null && counts['fire'] > 0) {
      type = DetectionType.fire;
    } else if ((counts['weapons'] != null && counts['weapons'] > 0) ||
        (counts['knives'] != null && counts['knives'] > 0)) {
      type = DetectionType.weapon;
    } else if (threatLevel == 'DANGER') {
      type = DetectionType.violence;
    }

    final newEvent = DetectionEvent(
      id: id,
      type: type,
      timestamp: now,
      location: 'Web Camera Feed',
      confidence: 0.85,
      description: data['summary'] ?? 'Active detection event',
    );

    recentEvents.insert(0, newEvent);
    if (recentEvents.length > 5) recentEvents.removeLast();

    logs.insert(0, newEvent);
    if (logs.length > 100) logs.removeLast();
  }

  void _triggerAlert(String message) {
    isAlertActive.value = true;
    activeAlertMessage.value = message;
    _alertTimer?.cancel();
    _alertTimer = Timer(const Duration(seconds: 5), () {
      isAlertActive.value = false;
    });
  }

  void _startUptime() {
    _uptimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      uptimeSeconds.value++;
    });
  }

  String get formattedUptime {
    final h = (uptimeSeconds.value ~/ 3600).toString().padLeft(2, '0');
    final m = ((uptimeSeconds.value % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (uptimeSeconds.value % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void onClose() {
    socket.disconnect();
    socket.dispose();
    _alertTimer?.cancel();
    _uptimeTimer?.cancel();
    super.onClose();
  }
}
