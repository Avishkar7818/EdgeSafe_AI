import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../detection_model.dart';
import 'dashboard_controller.dart'; // Import the real engine

class ChatController extends GetxController {
  final DashboardController _dashCtrl = Get.find<DashboardController>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    messages.add(
      ChatMessage(
        id: '0',
        content:
            '👋 Welcome to EdgeSafe AI. I am linked to the live Railway backend. Ask me about current threats, people count, or system status.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    isTyping.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    final response = _generateRealResponse(text);
    isTyping.value = false;

    messages.add(
      ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}r',
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  String _generateRealResponse(String input) {
    final lowerInput = input.toLowerCase();
    final stats = _dashCtrl.stats.value; // GET REAL DATA!

    if (lowerInput.contains('status') || lowerInput.contains('system')) {
      return '✅ Live Status: ${stats.systemStatus}\nUptime: ${_dashCtrl.formattedUptime}\nConnection: ${stats.isSystemOnline ? "Stable" : "Offline"}';
    } else if (lowerInput.contains('people') ||
        lowerInput.contains('crowd') ||
        lowerInput.contains('person')) {
      return '👥 Current crowd density: ${stats.totalPeople} individuals detected right now. The peak today was ${stats.peakPeople}.';
    } else if (lowerInput.contains('alert') ||
        lowerInput.contains('threat') ||
        lowerInput.contains('fire') ||
        lowerInput.contains('weapon')) {
      if (stats.isSafe) {
        return '✅ The environment is currently CLEAR. No active weapons, fire, or violence detected in the live feed.';
      } else {
        return '🚨 ACTIVE THREATS:\n• Fire Detections: ${stats.fireCount}\n• Weapon Detections: ${stats.weaponCount}\n• Suspicious/Violence: ${stats.violenceCount}\nImmediate action recommended.';
      }
    } else {
      return '🤖 I am analyzing the live feed. Currently seeing ${stats.totalPeople} people. Are you looking for a specific threat report?';
    }
  }
}
