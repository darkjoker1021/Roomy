import 'package:roomy/app/routes/app_pages.dart';
import 'package:roomy/core/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  
  // Variabili per gestire il flusso di creazione/join casa
  Map<String, dynamic>? houseData;
  bool fromJoinHouse = false;
  bool fromCreateHouse = false;

  @override
  void onInit() {
    super.onInit();
    change(null, status: RxStatus.success());
    
    // Controlla se arriva da join house o create house
    if (Get.arguments != null) {
      houseData = Get.arguments['houseData'];
      fromJoinHouse = Get.arguments['fromJoinHouse'] ?? false;
      fromCreateHouse = Get.arguments['fromCreateHouse'] ?? false;
    }
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
          await _saveUser(googleAccount);
        }

        // Gestisci il flusso dopo il login
        await _handlePostLogin(context, user);
        
      } else {
        _showErrorDialog("Errore durante l'accesso o la registrazione con Google");
      }
    } catch (e) {
      _showErrorDialog("Errore durante l'accesso o la registrazione con Google: $e");
    }
    
    change(null, status: RxStatus.success());
  }

  Future<void> _handlePostLogin(BuildContext context, User user) async {
    if (action == 'join' && houseData != null) {
      // Unisci l'utente alla casa
      await _joinHouse(context);
    } else if (action == 'create') {
      // Vai alla pagina di creazione casa
      Get.offAndToNamed(Routes.CREATE_HOUSE);
    } else {
      // Comportamento normale
      Get.offAndToNamed(Routes.MAIN);
    }
  }
  Future<void> _joinUserToHouse(User user, Map<String, dynamic> houseData) async {
    String houseId = houseData['id'];
    
    // Aggiungi l'utente alla collezione membri della casa
    await FirebaseFirestore.instance.collection('houses').doc(houseId).collection('members').doc(user.uid).set({
      'uid': user.uid,
      'role': 'member',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // Aggiorna il profilo utente con l'ID della casa
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'houseId': houseId,
      'role': 'member',
    });
  }
  Future<void> _saveUser(GoogleSignInAccount googleAccount) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Salva i dati dell'utente nel database Firestore
    await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
      'uid': currentUser.uid,
      'email': currentUser.email,
      'displayName': googleAccount.displayName,
      'photoUrl': googleAccount.photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text("Errore"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}