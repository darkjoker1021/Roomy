import 'package:roomy/app/modules/login/controllers/login_controller.dart';
import 'package:roomy/core/widgets/button.dart';
import 'package:roomy/core/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    "assets/logos/logo.png",
                    width: Get.width * 0.4,
                    fit: BoxFit.contain,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  const Text(
                    "Benvenuto",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    "Accedi per continuare",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  CustomButton(
                    onPressed: () => controller.signInWithGoogle(context),
                    text: "Accedi con Google",
                    height: 56,
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.asset(
                        "assets/logos/google.png",
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onLoading: const Loading(),
    );
  }
}