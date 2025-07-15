import 'package:roomy/app/data/app_user.dart';
import 'package:roomy/app/routes/app_pages.dart';
import 'package:roomy/core/theme/theme_helper.dart';
import 'package:roomy/core/widgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountController extends GetxController with StateMixin {
  var user = AppUser(
    id: "",
    name: "",
    surname: "",
    email: "",
    points: 0,
  ).obs;
  var isDarkMode = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    _getUserData();
    isDarkMode.value = Get.isDarkMode;
  }

  void _getUserData() {
    change(null, status: RxStatus.loading());
    UserHelper().getUser(FirebaseAuth.instance.currentUser?.uid ?? "").listen((appUser) {
      user.value = appUser!;
    });

    change(null, status: RxStatus.success());
  }

  Future<void> verifyAccount(BuildContext context) async {
    String message;
    Color color;

    await FirebaseAuth.instance.currentUser?.reload();
    
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      message = "Email di verifica inviata";
      color = Colors.green;
    } else {
      message = "Account giù verificato!";
      color = Colors.red;
    }

    if (context.mounted) {
      CustomSnackbar.showSnackbar(
        context,
        message,
        color,
        null
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (await GoogleSignIn().isSignedIn()) {
      await GoogleSignIn().signOut();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    Get.offAllNamed(Routes.LOGIN);
    
    if (context.mounted) {
      CustomSnackbar.showSuccessSnackbar(
        context,
        "Uscita effettuato",
      );
    }
  }

  void deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text("Elimina account"),
          content: const Text("Sei sicuro di voler eliminare il tuo account?\nQuesto operazione è irreversibile."),
          actions: <Widget>[
            TextButton(
              child: const Text("Annulla"),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: const Text("Conferma l'eliminazione", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.delete();
                await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).delete();
                Get.offAllNamed(Routes.LOGIN);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addGoogleAuthentication(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    
    try {
      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);

      if (context.mounted) {
        CustomSnackbar.showSuccessSnackbar(
          context,
          "Accesso con Google aggiunto",
        );
      }
    } on FirebaseAuthException {
      if (context.mounted) {
        CustomSnackbar.showErrorSnackbar(
          context,
          "Errore nell'aggiunta dell'accesso con Google",
        );
      }
    }
  }

  Future<void> changeTheme() async {
    ThemeMode themeMode = await ThemeHelper().getThemeMode();

    if (themeMode == ThemeMode.dark) {
      ThemeHelper().changeThemeMode(ThemeMode.light);
    }

    if (themeMode == ThemeMode.light) {
      ThemeHelper().changeThemeMode(ThemeMode.dark);
    }

    isDarkMode.value = !isDarkMode.value;
  }
}