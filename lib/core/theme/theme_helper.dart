import 'package:roomy/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeHelper {
  void changeThemeMode(ThemeMode themeMode) async {
    Get.changeThemeMode(themeMode);

    bool isDarkMode = themeMode == ThemeMode.dark;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isDarkMode", isDarkMode);

    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      systemNavigationBarColor: isDarkMode 
          ? const Color(0xFF464646)
          : Palette.containerColor,
      statusBarColor: isDarkMode 
          ? const Color(0xFF343434) 
          : Palette.scaffoldBackgroundColor,
      statusBarBrightness: isDarkMode 
          ? Brightness.light 
          : Brightness.dark,
      systemNavigationBarIconBrightness: isDarkMode 
          ? Brightness.light 
          : Brightness.dark,
      statusBarIconBrightness: isDarkMode 
          ? Brightness.light 
          : Brightness.dark,
    );

    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  Future<ThemeMode> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool("isDarkMode") ?? false;

    if (isDarkMode) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }
}