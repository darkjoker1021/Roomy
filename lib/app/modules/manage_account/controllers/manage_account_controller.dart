import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:roomy/app/data/member.dart';
import 'package:roomy/core/widgets/snackbar.dart';

class ManageAccountController extends GetxController with StateMixin {
  var user = Get.arguments as Member;
  var nameController = TextEditingController();
  var surnameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    change(null, status: RxStatus.success());
    nameController.text = user.name;
  }

  Future<void> updateAccount(BuildContext context) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? userAuth = auth.currentUser;
      String uid = userAuth?.uid ?? "";

      if (userAuth == null || uid.isEmpty) {
        throw Exception("Utente non autenticato");
      }

      FirebaseFirestore instance = FirebaseFirestore.instance;

      if (nameController.text != user.name) {
        await instance.collection("users").doc(uid).update({
          "name": nameController.text,
          "surname": surnameController.text
        });
        
        user = Member(
          id: uid,
          name: nameController.text,
          email: user.email,
        );

        if (context.mounted) {
          CustomSnackbar.showSuccessSnackbar(
            context,
            "Informazioni aggiornate con successo!",
          );
        }

        Get.back();
      } else {
        if (context.mounted) {
          CustomSnackbar.showErrorSnackbar(
            context,
            "Inserisci almeno un campo!",
          );
        }
      }
    } catch (e) {
      return;
    }
  }
}