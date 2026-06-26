// lib/models/detection_model.dart

enum DetectionType { person, fire, weapon, violence, safe }

class DetectionEvent {
  final String id;
  final DetectionType type;
  final DateTime timestamp;
  final String location;
  final double confidence;
  final String description;

  DetectionEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.location,
    required this.confidence,
    required this.description,
  });

  String get typeLabel {
    switch (type) {
      case DetectionType.person:
        return 'Person Detected';
      case DetectionType.fire:
        return 'Fire Alert';
      case DetectionType.weapon:
        return 'Weapon Detected';
      case DetectionType.violence:
        return 'Suspicious Activity';
      case DetectionType.safe:
        return 'All Clear';
    }
  }
}

class DashboardStats {
  final int totalPeople;
  final int fireCount;
  final int weaponCount;
  final int violenceCount;
  final int peakPeople;
  final bool isSystemOnline;
  final String systemStatus;

  DashboardStats({
    required this.totalPeople,
    required this.fireCount,
    required this.weaponCount,
    required this.violenceCount,
    required this.peakPeople,
    required this.isSystemOnline,
    required this.systemStatus,
  });

  int get totalThreats => fireCount + weaponCount + violenceCount;
  bool get isSafe => totalThreats == 0;
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
  });
}

class HourlyData {
  final int hour;
  final int peopleCount;
  final int threatCount;

  HourlyData({
    required this.hour,
    required this.peopleCount,
    required this.threatCount,
  });
}
