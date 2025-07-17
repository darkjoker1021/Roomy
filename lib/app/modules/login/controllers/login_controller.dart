import 'package:roomy/app/routes/app_pages.dart';
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
  String? action; // 'join' o 'create'
  bool fromJoinHouse = false;
  bool fromCreateHouse = false;

  @override
  void onInit() {
    super.onInit();
    change(null, status: RxStatus.success());
    
    // Controlla se arriva da join house o create house
    if (Get.arguments != null) {
      houseData = Get.arguments['houseData'];
      action = Get.arguments['action']; // 'join' o 'create'
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    change(null, status: RxStatus.loading());

    try {
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
      
      if (googleAccount == null) {
        change(null, status: RxStatus.success());
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;

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
        await prefs.setString("userId", user.uid);

        if (isNewUser) {
          await _saveUser(googleAccount);
        }

        // Gestisci il flusso dopo il login
        if (context.mounted) {
          await _handlePostLogin(context, user);
        }
      } else {
        _showErrorDialog("Errore durante l'accesso o la registrazione con Google");
      }
    } catch (e) {
      _showErrorDialog("Errore durante l'accesso o la registrazione con Google: $e");
    }
    
    change(null, status: RxStatus.success());
  }

  Future<void> _handlePostLogin(BuildContext context, User user) async {
    try {
      // Controlla se l'utente è già in una casa
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? existingHouseId = userData['houseId'];

        if (existingHouseId != null && existingHouseId.isNotEmpty) {
          // L'utente è già in una casa, vai alla main
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("houseId", existingHouseId);
          Get.offAndToNamed(Routes.MAIN);
          return;
        }
      }

      // Gestisci il flusso basato sull'azione
      if (action == 'join' && houseData != null) {
        // Unisci l'utente alla casa
        await _joinUserToHouse(user, houseData!);
        Get.offAndToNamed(Routes.MAIN);
      } else if (action == 'create') {
        // Vai alla pagina di creazione casa
        Get.offAndToNamed(Routes.CREATE_HOUSE);
      } else {
        // Comportamento normale - controlla se l'utente deve scegliere tra join/create
        Get.offAndToNamed(Routes.HOUSE);
      }
    } catch (e) {
      _showErrorDialog("Errore nella gestione post-login: $e");
    }
  }

  Future<void> _joinUserToHouse(User user, Map<String, dynamic> houseData) async {
    try {
      String houseId = houseData['id'];
      
      // Verifica che la casa esista
      DocumentSnapshot houseDoc = await FirebaseFirestore.instance
          .collection('houses')
          .doc(houseId)
          .get();

      if (!houseDoc.exists) {
        throw Exception("La casa non esiste più");
      }

      // Aggiungi l'utente alla collezione membri della casa
      await FirebaseFirestore.instance
          .collection('houses')
          .doc(houseId)
          .collection('members')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Aggiorna il profilo utente con l'ID della casa
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'houseId': houseId,
        'email': user.email,
        'name': user.displayName,
        'uid': user.uid,
      });

      // Salva l'ID della casa nelle preferenze
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("houseId", houseId);

      // Incrementa il numero di membri nella casa
      await FirebaseFirestore.instance
          .collection('houses')
          .doc(houseId)
          .update({
        'memberCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Successo', 
        'Ti sei unito alla casa "${houseData['name']}" con successo!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      throw Exception("Errore nell'unirsi alla casa: $e");
    }
  }

  Future<void> _saveUser(GoogleSignInAccount googleAccount) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Salva i dati dell'utente nel database Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        'uid': currentUser.uid,
        'email': currentUser.email,
        'displayName': googleAccount.displayName,
        'photoUrl': googleAccount.photoUrl,
        'houseId': null, // Inizialmente non è in nessuna casa
        'role': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Errore nel salvare l'utente: $e");
    }
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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}