import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomy/app/routes/app_pages.dart';

class JoinHouseController extends GetxController with StateMixin {
  final joinHouseFormKey = GlobalKey<FormState>();
  final inviteCodeController = TextEditingController();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    change(null, status: RxStatus.success());
  }

  @override
  void onClose() {
    inviteCodeController.dispose();
    super.onClose();
  }

  Future<void> joinHouseWithCode(BuildContext context) async {
    if (!joinHouseFormKey.currentState!.validate()) return;

    change(null, status: RxStatus.loading());

    try {
      String inviteCode = inviteCodeController.text.trim().toUpperCase();
      
      // Verifica se il codice invito esiste
      QuerySnapshot houseQuery = await _firestore
          .collection('houses')
          .where('inviteCode', isEqualTo: inviteCode)
          .get();

      if (houseQuery.docs.isEmpty) {
        _showErrorDialog("Codice invito non valido");
        change(null, status: RxStatus.success());
        return;
      }

      // Salva il codice invito per usarlo dopo il login
      Get.toNamed(Routes.LOGIN, arguments: {
        'action': 'join',
        'inviteCode': inviteCode,
        'houseData': houseQuery.docs.first.data() as Map<String, dynamic>
      });

      change(null, status: RxStatus.success());

    } catch (e) {
      _showErrorDialog("Errore durante la verifica del codice: $e");
      change(null, status: RxStatus.success());
    }
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