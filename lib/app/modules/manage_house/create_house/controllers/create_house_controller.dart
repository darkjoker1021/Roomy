import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomy/app/routes/app_pages.dart';
import 'package:roomy/core/widgets/snackbar.dart';
import 'dart:math';

class CreateHouseController extends GetxController with StateMixin {
  final createHouseFormKey = GlobalKey<FormState>();
  final houseNameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    change(null, status: RxStatus.success());
  }

  @override
  void onClose() {
    houseNameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> createHouse(BuildContext context) async {
    if (!createHouseFormKey.currentState!.validate()) return;

    change(null, status: RxStatus.loading());

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        _showErrorDialog("Errore: utente non autenticato");
        change(null, status: RxStatus.success());
        return;
      }

      String inviteCode = _generateInviteCode();
      String houseId = _firestore.collection('houses').doc().id;

      // Crea la casa
      await _firestore.collection('houses').doc(houseId).set({
        'id': houseId,
        'name': houseNameController.text.trim(),
        'address': addressController.text.trim(),
        'description': descriptionController.text.trim(),
        'inviteCode': inviteCode,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'adminId': currentUser.uid,
        'memberIds': [currentUser.uid],
      });

      // Aggiunge l'utente come membro della casa
      await _firestore.collection('houses').doc(houseId).collection('members').doc(currentUser.uid).set({
        'uid': currentUser.uid,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Aggiorna il profilo utente con l'ID della casa
      await _firestore.collection('users').doc(currentUser.uid).update({
        'houseId': houseId,
      });

      change(null, status: RxStatus.success());

      Get.offAndToNamed(Routes.MAIN);

      if (context.mounted) {
        CustomSnackbar.showSuccessSnackbar(
          context,
          "Casa creata con successo! Codice invito: $inviteCode",
        );
      }

    } catch (e) {
      _showErrorDialog("Errore durante la creazione della casa: $e");
      change(null, status: RxStatus.success());
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
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
      ),
    );
  }
}