// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import '../auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      userName.value = await _authService.getUserName();
      Get.offAllNamed('/dashboard');
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _authService.login(email, password);
      if (result['success']) {
        userName.value = result['name'];
        Get.offAllNamed('/dashboard');
      } else {
        errorMessage.value = result['message'];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _authService.signup(name, email, password);
      if (result['success']) {
        userName.value = result['name'];
        Get.offAllNamed('/dashboard');
      } else {
        errorMessage.value = result['message'];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed('/login');
  }
}
