// lib/services/mock_data_service.dart
import 'dart:async';
import 'dart:math';
import '../detection_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final _random = Random();

  // Stream controllers for real-time feel
  final _statsController = StreamController<DashboardStats>.broadcast();
  final _eventsController = StreamController<DetectionEvent>.broadcast();

  Stream<DashboardStats> get statsStream => _statsController.stream;
  Stream<DetectionEvent> get eventsStream => _eventsController.stream;

  Timer? _statsTimer;
  Timer? _eventTimer;

  int _people = 8;
  int _fire = 0;
  int _weapon = 1;
  int _violence = 2;
  int _peak = 14;

  void startSimulation() {
    // Update stats every 2 seconds
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _people = (_people + _random.nextInt(3) - 1).clamp(0, 30);
      if (_people > _peak) _peak = _people;
      if (_random.nextDouble() < 0.05) _fire++;
      if (_random.nextDouble() < 0.03) _weapon++;
      if (_random.nextDouble() < 0.08) _violence++;

      _statsController.add(
        DashboardStats(
          totalPeople: _people,
          fireCount: _fire,
          weaponCount: _weapon,
          violenceCount: _violence,
          peakPeople: _peak,
          isSystemOnline: true,
          systemStatus: _people > 20 ? 'HIGH CROWD DENSITY' : 'MONITORING',
        ),
      );
    });

    // Random detection events every 5-15 seconds
    _eventTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      final events = _generateRandomEvent();
      if (events != null) _eventsController.add(events);
    });
  }

  void stopSimulation() {
    _statsTimer?.cancel();
    _eventTimer?.cancel();
  }

  DetectionEvent? _generateRandomEvent() {
    final roll = _random.nextDouble();
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    if (roll < 0.4) {
      return DetectionEvent(
        id: id,
        type: DetectionType.person,
        timestamp: now,
        location: 'Zone ${_random.nextInt(4) + 1}',
        confidence: 0.85 + _random.nextDouble() * 0.14,
        description: '${_people} individuals detected in monitoring zone',
      );
    } else if (roll < 0.55) {
      return DetectionEvent(
        id: id,
        type: DetectionType.violence,
        timestamp: now,
        location: 'Zone ${_random.nextInt(4) + 1}',
        confidence: 0.72 + _random.nextDouble() * 0.2,
        description: 'Suspicious movement pattern detected',
      );
    } else if (roll < 0.65) {
      return DetectionEvent(
        id: id,
        type: DetectionType.weapon,
        timestamp: now,
        location: 'Entrance A',
        confidence: 0.78 + _random.nextDouble() * 0.18,
        description: 'Possible weapon-like object identified',
      );
    } else if (roll < 0.72) {
      return DetectionEvent(
        id: id,
        type: DetectionType.fire,
        timestamp: now,
        location: 'Zone 2 - Storage',
        confidence: 0.91 + _random.nextDouble() * 0.08,
        description: 'Thermal anomaly consistent with fire detected',
      );
    }
    return null;
  }

  DashboardStats getCurrentStats() {
    return DashboardStats(
      totalPeople: _people,
      fireCount: _fire,
      weaponCount: _weapon,
      violenceCount: _violence,
      peakPeople: _peak,
      isSystemOnline: true,
      systemStatus: 'MONITORING',
    );
  }

  List<DetectionEvent> getRecentLogs() {
    final now = DateTime.now();
    return [
      DetectionEvent(
        id: '1',
        type: DetectionType.fire,
        timestamp: now.subtract(const Duration(minutes: 5)),
        location: 'Zone 2',
        confidence: 0.94,
        description: 'Fire detected near storage unit. Alert dispatched.',
      ),
      DetectionEvent(
        id: '2',
        type: DetectionType.weapon,
        timestamp: now.subtract(const Duration(minutes: 18)),
        location: 'Entrance A',
        confidence: 0.87,
        description: 'Potential weapon detected on subject entering premises.',
      ),
      DetectionEvent(
        id: '3',
        type: DetectionType.person,
        timestamp: now.subtract(const Duration(minutes: 22)),
        location: 'Zone 3',
        confidence: 0.99,
        description: 'Peak crowd density: 14 people in restricted zone.',
      ),
      DetectionEvent(
        id: '4',
        type: DetectionType.violence,
        timestamp: now.subtract(const Duration(minutes: 45)),
        location: 'Zone 1',
        confidence: 0.76,
        description:
            'Aggressive behavior pattern detected between 2 individuals.',
      ),
      DetectionEvent(
        id: '5',
        type: DetectionType.person,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 10)),
        location: 'Perimeter',
        confidence: 0.98,
        description: 'Unauthorized perimeter crossing detected.',
      ),
      DetectionEvent(
        id: '6',
        type: DetectionType.weapon,
        timestamp: now.subtract(const Duration(hours: 2)),
        location: 'Zone 4',
        confidence: 0.82,
        description: 'Knife-like object detected in restricted area.',
      ),
      DetectionEvent(
        id: '7',
        type: DetectionType.safe,
        timestamp: now.subtract(const Duration(hours: 3)),
        location: 'All Zones',
        confidence: 1.0,
        description: 'Scheduled system check passed. All zones clear.',
      ),
      DetectionEvent(
        id: '8',
        type: DetectionType.fire,
        timestamp: now.subtract(const Duration(hours: 4, minutes: 30)),
        location: 'Zone 1 - Kitchen',
        confidence: 0.96,
        description: 'Minor fire incident - suppressed automatically.',
      ),
    ];
  }

  List<HourlyData> getHourlyData() {
    return List.generate(24, (i) {
      return HourlyData(
        hour: i,
        peopleCount: i >= 8 && i <= 20
            ? _random.nextInt(12) + 2
            : _random.nextInt(4),
        threatCount: _random.nextDouble() < 0.2 ? _random.nextInt(3) : 0,
      );
    });
  }

  // AI Chatbot mock responses
  String getChatbotResponse(String input) {
    final lowerInput = input.toLowerCase();
    if (lowerInput.contains('fire')) {
      return '🔥 Last fire event detected at ${_formatTime(DateTime.now().subtract(const Duration(minutes: 5)))} in Zone 2. Confidence: 94%. Alert was dispatched to emergency contacts. System auto-suppression was triggered.';
    } else if (lowerInput.contains('weapon') ||
        lowerInput.contains('knife') ||
        lowerInput.contains('gun')) {
      return '⚠️ Weapon detection log: A potential weapon was detected at Entrance A at ${_formatTime(DateTime.now().subtract(const Duration(minutes: 18)))} with 87% confidence. Security personnel were notified immediately.';
    } else if (lowerInput.contains('people') ||
        lowerInput.contains('crowd') ||
        lowerInput.contains('person')) {
      return '👥 Current crowd density: $_people individuals detected across all zones. Peak today: $_peak at 14:30. Zone 3 has the highest concentration. Recommend monitoring Zone 3.';
    } else if (lowerInput.contains('status') || lowerInput.contains('system')) {
      return '✅ EdgeSafe AI is fully operational. Camera feed: Active. AI Model: Running at 98.7% accuracy. Raspberry Pi: Offline (Demo Mode). Last full scan: ${_formatTime(DateTime.now().subtract(const Duration(seconds: 30)))}';
    } else if (lowerInput.contains('alert') || lowerInput.contains('threat')) {
      return '🚨 Active threat summary:\n• Fire incidents today: $_fire\n• Weapon detections: $_weapon\n• Suspicious activity: $_violence\n\nAll events logged and notifications sent. Recommend reviewing Zone 2.';
    } else if (lowerInput.contains('raspberry') ||
        lowerInput.contains('pi') ||
        lowerInput.contains('device')) {
      return '📡 Raspberry Pi status: NOT CONNECTED (Demo Mode active). The edge device integration will be enabled upon physical deployment. Currently running on simulated data streams.';
    } else if (lowerInput.contains('hello') ||
        lowerInput.contains('hi') ||
        lowerInput.contains('hey')) {
      return '👋 Hello! I\'m EdgeSafe AI Assistant. I can help you with:\n• Live detection status\n• Threat analysis\n• System diagnostics\n• Historical event logs\n\nWhat would you like to know?';
    } else if (lowerInput.contains('violence') ||
        lowerInput.contains('suspicious')) {
      return '⚠️ Suspicious activity detected $_violence time(s) today. Last event: Zone 1 at ${_formatTime(DateTime.now().subtract(const Duration(minutes: 45)))}. Behavioral pattern analysis suggests elevated tension. Recommend increased patrol in Zone 1.';
    } else {
      return '🤖 Processing your query... Based on current sensor data, the system is actively monitoring all zones. I detected "$input" — for specific analytics, try asking about: people, fire, weapons, threats, or system status.';
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void dispose() {
    stopSimulation();
    _statsController.close();
    _eventsController.close();
  }
}
