import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:roomy/core/theme/theme.dart';
import 'package:roomy/core/theme/theme_helper.dart';
import 'package:roomy/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _isLogged();
  await _getThemeMode();

  ThemeHelper().changeThemeMode(_themeMode);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

bool _isLoggedIn = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Roomy",
      locale: const Locale('it', 'IT'),
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: _isLoggedIn ? Routes.MAIN : Routes.HOUSE,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
    );
  }
}

Future<void> _isLogged() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
}

ThemeMode _themeMode = ThemeMode.system;

Future<void> _getThemeMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool("isDarkMode") ?? false;

  if (isDarkMode) {
    _themeMode = ThemeMode.dark;
  } else {
    _themeMode = ThemeMode.light;
  }
}