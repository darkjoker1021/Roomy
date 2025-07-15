import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Icon? prefixIcon;
  final String? validator;
  final TextEditingController? password;
  
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.password
  });

  @override
  Widget build(BuildContext context) {
    RxBool showPassword = false.obs;

    return Obx(
      () => TextFormField(
        autofocus: false,
        controller: controller,
        validator: (value) {
          if (value.isBlank == true || value!.isEmpty || value == "") {
            return "Compilare questo campo";
          }

          if (validator == "email") {
            if (!GetUtils.isEmail(value)) {
              return "Email non valida";
            }
          }

          if (validator == "password") {
            if (value.length < 6) {
              return "La password deve avere almeno 6 caratteri";
            }
          }

          if (validator == "confirmPassword") {
            if (value != password?.value.text) {
              return "Le password non corrispondono";
            }
          }

          return null;
        },
        obscureText: showPassword.value ? false : obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide.none),
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          prefixIcon: prefixIcon,
          suffixIcon: obscureText ? IconButton(onPressed: () => showPassword.value = !showPassword.value, icon: Icon(showPassword.value ? FluentIcons.eye_16_filled : FluentIcons.eye_off_16_filled)) : null,
        ),
      ),
    );
  }
}