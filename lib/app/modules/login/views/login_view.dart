import 'package:roomy/app/modules/login/controllers/login_controller.dart';
import 'package:roomy/app/routes/app_pages.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/button.dart';
import 'package:roomy/core/widgets/loading.dart';
import 'package:roomy/core/widgets/text_field.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx((state) => 
      Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: controller.loginFormKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Benvenuto su", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),

                      const SizedBox(height: 10),

                      Image.asset(
                        "assets/logos/logo_name.png",
                        width: Get.width * 0.5,
                        fit: BoxFit.contain,
                      ),
                            
                      const SizedBox(height: 40),
                            
                      CustomTextField(
                        controller: controller.emailController,
                        hintText: "Email",
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(FluentIcons.mail_12_filled),
                      ),
                            
                      const SizedBox(height: 10),
                            
                      CustomTextField(
                        controller: controller.passwordController,
                        hintText: "Password",
                        obscureText: true,
                        prefixIcon: const Icon(FluentIcons.password_16_filled),
                      ),
                  
                      const SizedBox(height: 10),
                        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Obx(() =>
                              Checkbox(
                                value: controller.keepMeLoggedIn.value,
                                onChanged: (value) => controller.setKeepMeLoggedIn(value!))
                              ),
                              GestureDetector(
                                onTap: () => controller.setKeepMeLoggedIn(!controller.keepMeLoggedIn.value),
                                child: const Text("Mantieni accesso", style: TextStyle(color: Palette.labelColor))
                              ),
                            ],
                          ),
                          TextButton(onPressed: () => controller.forgotPassword(), child: const Text("Password dimenticata?", style: TextStyle(color: Palette.labelColor))),
                        ],
                      ),
                            
                      const SizedBox(height: 10),
                            
                      CustomButton(onPressed: () => controller.signInWithEmailPassword(context), text: "Accedi", height: 50),
                        
                      const SizedBox(height: 20),
                            
                      const Row(
                        children: [
                          Expanded(child: Divider(height: 20)),
                          SizedBox(width: 10),
                          Text("Oppure", style: TextStyle(color: Palette.labelColor)),
                          SizedBox(width: 10),
                          Expanded(child: Divider(height: 20)),
                        ],
                      ),
                        
                      const SizedBox(height: 20),
                            
                      CustomButton(
                        onPressed: () => controller.signInWithGoogle(context),
                        text: "Continua con Google",
                        height: 50,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        borderColor: Theme.of(context).colorScheme.secondary,
                        textColor: Palette.primaryColor,
                        icon: Image.asset("assets/logos/google.png", height: 20, fit: BoxFit.cover),
                      ),
                        
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      onLoading: const Loading()
    );
  }
}