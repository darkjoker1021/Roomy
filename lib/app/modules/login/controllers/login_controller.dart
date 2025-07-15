import 'package:roomy/app/routes/app_pages.dart';
import 'package:roomy/core/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController with StateMixin {
  final loginFormKey = GlobalKey<FormState>();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var keepMeLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    change(null, status: RxStatus.success());
  }

  void setKeepMeLoggedIn(bool value) {
    keepMeLoggedIn.value = value;
  }
  
  Future<void> signInWithEmailPassword(BuildContext context) async {
    change(null, status: RxStatus.loading());

    if (loginFormKey.currentState!.validate() == false) {
      change(null, status: RxStatus.success());
      return;
    }

    try {
      String email = emailController.text.trim();
      String password = passwordController.text;

      UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = authResult.user;

      if (user != null) {
        if (!user.emailVerified) {
          _showErrorDialog("Devi prima verificare il tuo indirizzo email.\nControlla la tua casella di posta per verificare il tuo indirizzo email.");
          _auth.signOut();
          change(null, status: RxStatus.success());
          return;
        }

        if (keepMeLoggedIn.value) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool("isLoggedIn", true);
        }
        
        Get.offAndToNamed(Routes.MAIN);
        change(null, status: RxStatus.success());

        if (context.mounted) {
          CustomSnackbar.showSuccessSnackbar(
            context,
            "Accesso effettuato con successo!",
          );
        }
      } else {
        _showErrorDialog("Credenziali non valide");
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog("Errore: ${e.code}");
      change(null, status: RxStatus.success());
    } catch (e) {
      _showErrorDialog("Si è verificato un errore: ${e.toString()}");
      change(null, status: RxStatus.success());
    }

    change(null, status: RxStatus.success());
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    change(null, status: RxStatus.loading());

    try {
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential? authResult = await _auth.signInWithCredential(credential);
      User? user = authResult.user;

      if (user != null) {
        bool isNewUser = authResult.additionalUserInfo!.isNewUser;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);

        if (isNewUser) {
          _saveUser(googleAccount);
        }

        Get.offAndToNamed(Routes.MAIN);
        
        if (context.mounted) {
          CustomSnackbar.showSuccessSnackbar(
            context,
            "Accesso effettuato con successo!",
          );
        }
      } else {
        _showErrorDialog("Errore durante l'accesso o la registrazione con Google");
      }
    } catch (e) {
      _showErrorDialog("Errore durante l'accesso o la registrazione con Google: $e");
    }
    
    change(null, status: RxStatus.success());
  }

  Future<void> _saveUser(GoogleSignInAccount account) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (!userDoc.exists) {
      DateTime? creationDate = _auth.currentUser!.metadata.creationTime;
      DateFormat("dd/MM/yyyy").format(creationDate!);
      var userNameSurname = account.displayName!.split(" ");
      if (userNameSurname.length < 2) {
        userNameSurname.add("");
      }
      FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "name": userNameSurname[0],
        "surname": userNameSurname[1],
        "email": account.email,
        "image": account.photoUrl,
      });
    }
  }

    Future<void> forgotPassword() async {
    try {
      String email = emailController.text;

      await _auth.sendPasswordResetEmail(email: email);

      _showSuccessDialog("Email di reset della password inviata con successo. Controlla la tua casella di posta.");
    } catch (e) {
      _showErrorDialog("Errore durante l'invio dell'email di reset della password: $e");
    }
  }

    void _showSuccessDialog(String message) {
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: const Text("Successo"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () => Get.back(),
            ),
          ],
        )
      );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text("Errore"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () => Get.back(),
          ),
        ],
      )
    );
  }
}