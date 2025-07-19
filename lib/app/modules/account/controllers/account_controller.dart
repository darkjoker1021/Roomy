import 'package:roomy/app/data/member.dart';
import 'package:roomy/app/routes/app_pages.dart';
import 'package:roomy/core/theme/theme_helper.dart';
import 'package:roomy/core/widgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountController extends GetxController with StateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var user = Member(
    id: "",
    name: "",
    email: "",
  ).obs;
  var isDarkMode = false.obs;
  
  // Variabili per la gestione della casa
  final RxString houseId = ''.obs;
  final RxString houseName = ''.obs;
  final RxString houseInviteCode = ''.obs;
  final RxBool isHouseAdmin = false.obs;
  final RxList<Member> houseMembers = <Member>[].obs;
  final RxBool isLoadingHouse = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _getUserData();
    _loadHouseData();
    isDarkMode.value = Get.isDarkMode;
  }

  void _getUserData() {
    change(null, status: RxStatus.loading());
    MemberHelper().getUser(FirebaseAuth.instance.currentUser?.uid ?? "").listen((appUser) {
      user.value = appUser!;
    });
    change(null, status: RxStatus.success());
  }

  Future<void> _loadHouseData() async {
    try {
      isLoadingHouse.value = true;
      
      // Ottieni l'houseId dalle preferenze
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedHouseId = prefs.getString("houseId");
      
      if (savedHouseId != null && savedHouseId.isNotEmpty) {
        houseId.value = savedHouseId;
        await _loadHouseInfo();
        await _loadHouseMembers();
      } else {
        // Prova a ottenerlo dal database utente
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            String? userHouseId = userData['houseId'];
            
            if (userHouseId != null && userHouseId.isNotEmpty) {
              houseId.value = userHouseId;
              await prefs.setString("houseId", userHouseId);
              await _loadHouseInfo();
              await _loadHouseMembers();
            }
          }
        }
      }
    } finally {
      isLoadingHouse.value = false;
    }
  }

  Future<void> _loadHouseInfo() async {
    if (houseId.value.isEmpty) return;
    
    try {
      DocumentSnapshot houseDoc = await _firestore
          .collection('houses')
          .doc(houseId.value)
          .get();

      if (houseDoc.exists) {
        Map<String, dynamic> houseData = houseDoc.data() as Map<String, dynamic>;
        houseName.value = houseData['name'] ?? '';
        houseInviteCode.value = houseData['inviteCode'] ?? '';
        
        // Controlla se l'utente corrente è l'amministratore
        String? adminId = houseData['adminId'];
        isHouseAdmin.value = adminId == _auth.currentUser?.uid;
      }
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Impossibile caricare le informazioni della casa',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _loadHouseMembers() async {
    if (houseId.value.isEmpty) return;
    
    try {
      QuerySnapshot membersQuery = await _firestore
          .collection('users')
          .where('houseId', isEqualTo: houseId.value)
          .get();

      List<Member> members = [];
      for (var doc in membersQuery.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        members.add(Member(
          id: doc.id,
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
        ));
      }
      
      houseMembers.value = members;
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Impossibile caricare i membri della casa',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> copyInviteCode(BuildContext context) async {
    if (houseInviteCode.value.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: houseInviteCode.value));
      
      if (context.mounted) {
        CustomSnackbar.showSuccessSnackbar(
          context,
          "Codice invito copiato negli appunti",
        );
      }
    }
  }

  Future<void> regenerateInviteCode(BuildContext context) async {
    if (!isHouseAdmin.value) {
      if (context.mounted) {
        CustomSnackbar.showErrorSnackbar(
          context,
          "Solo l'amministratore può rigenerare il codice",
        );
      }
      return;
    }

    try {
      // Genera un nuovo codice invito
      String newCode = _generateInviteCode();
      
      await _firestore
          .collection('houses')
          .doc(houseId.value)
          .update({'inviteCode': newCode});

      houseInviteCode.value = newCode;
      
      if (context.mounted) {
        CustomSnackbar.showSuccessSnackbar(
          context,
          "Codice invito rigenerato",
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showErrorSnackbar(
          context,
          "Errore nella rigenerazione del codice",
        );
      }
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }

  Future<void> leaveHouse(BuildContext context) async {
    if (houseId.value.isEmpty) return;

    // Mostra dialog di conferma
    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Esci dalla Casa'),
        content: const Text('Sei sicuro di voler uscire dalla casa? Perderai accesso a tutte le funzionalità condivise.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Esci', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          // Rimuovi l'houseId dall'utente
          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .update({'houseId': FieldValue.delete()});

          // Rimuovi dalle preferenze
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove("houseId");

          // Reset delle variabili
          houseId.value = '';
          houseName.value = '';
          houseInviteCode.value = '';
          isHouseAdmin.value = false;
          houseMembers.clear();

          if (context.mounted) {
            CustomSnackbar.showSuccessSnackbar(
              context,
              "Hai lasciato la casa",
            );
          }
        }

        Get.offAllNamed(Routes.HOUSE);
      } catch (e) {
        if (context.mounted) {
          CustomSnackbar.showErrorSnackbar(
            context,
            "Errore nell'uscita dalla casa",
          );
        }
      }
    }
  }

  Future<void> kickMember(BuildContext context, Member member) async {
    if (!isHouseAdmin.value) {
      if (context.mounted) {
        CustomSnackbar.showErrorSnackbar(
          context,
          "Solo l'amministratore può espellere i membri",
        );
      }
      return;
    }

    if (member.id == _auth.currentUser?.uid) {
      if (context.mounted) {
        CustomSnackbar.showErrorSnackbar(
          context,
          "Non puoi espellere te stesso",
        );
      }
      return;
    }

    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Espelli Membro'),
        content: Text('Sei sicuro di voler espellere ${member.name} dalla casa?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Espelli', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore
            .collection('users')
            .doc(member.id)
            .update({'houseId': FieldValue.delete()});

        await _loadHouseMembers();

        if (context.mounted) {
          CustomSnackbar.showSuccessSnackbar(
            context,
            "${member.name} è stato espulso dalla casa",
          );
        }
      } catch (e) {
        if (context.mounted) {
          CustomSnackbar.showErrorSnackbar(
            context,
            "Errore nell'espulsione del membro",
          );
        }
      }
    }
  }

  Future<void> deleteHouse(BuildContext context) async {
    if (!isHouseAdmin.value) {
      if (context.mounted) {
        CustomSnackbar.showErrorSnackbar(
          context,
          "Solo l'amministratore può eliminare la casa",
        );
      }
      return;
    }

    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Elimina Casa'),
        content: const Text('Sei sicuro di voler eliminare la casa? Questa azione è irreversibile e rimuoverà tutti i dati condivisi.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Rimuovi l'houseId da tutti i membri
        for (Member member in houseMembers) {
          await _firestore
              .collection('users')
              .doc(member.id)
              .update({'houseId': FieldValue.delete()});
        }

        // Elimina la casa
        await _firestore
            .collection('houses')
            .doc(houseId.value)
            .delete();

        // Rimuovi dalle preferenze
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove("houseId");

        // Reset delle variabili
        houseId.value = '';
        houseName.value = '';
        houseInviteCode.value = '';
        isHouseAdmin.value = false;
        houseMembers.clear();

        if (context.mounted) {
          CustomSnackbar.showSuccessSnackbar(
            context,
            "Casa eliminata con successo",
          );
        }

        Get.offAllNamed(Routes.HOUSE);
      } catch (e) {
        if (context.mounted) {
          CustomSnackbar.showErrorSnackbar(
            context,
            "Errore nell'eliminazione della casa",
          );
        }
      }
    }
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
      message = "Account già verificato!";
      color = Colors.red;
    }

    if (context.mounted) {
      CustomSnackbar.showSnackbar(context, message, color, null);
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (await GoogleSignIn().isSignedIn()) {
      await GoogleSignIn().signOut();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    Get.offAllNamed(Routes.HOUSE);
    
    if (context.mounted) {
      CustomSnackbar.showSuccessSnackbar(context, "Uscita effettuata");
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
                Get.offAllNamed(Routes.HOUSE);
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