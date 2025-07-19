import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/data/shopping_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingController extends GetxController with StateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxString houseId = ''.obs;
  final RxList<ShoppingItem> shoppingItems = <ShoppingItem>[].obs;
  final RxList<ShoppingItem> filteredItems = <ShoppingItem>[].obs;
  final RxnString selectedCategory = RxnString(null);
  final RxnString selectedFilter = RxnString(null);

  final List<String> filters = ['Da comprare', 'Acquistate'];

  @override
  void onInit() {
    super.onInit();
    _initializeHouseId();
    
    // Listener per i filtri
    ever(selectedCategory, (_) => _applyFilters());
    ever(selectedFilter, (_) => _applyFilters());
  }

  Future<void> _initializeHouseId() async {
    try {
      // Prova a ottenere l'houseId dalle preferenze
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedHouseId = prefs.getString("houseId");
      
      if (savedHouseId != null && savedHouseId.isNotEmpty) {
        houseId.value = savedHouseId;
        loadShoppingItems();
        return;
      }

      // Se non è presente nelle preferenze, prova a ottenerlo dal database
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
            loadShoppingItems();
          } else {
            // L'utente non è in nessuna casa
            Get.snackbar(
              'Attenzione',
              'Devi prima unirti a una casa',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Errore nel caricamento dei dati: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void loadShoppingItems() {
    if (houseId.value.isEmpty) return;
    
    change(null, status: RxStatus.loading());
    
    _firestore
        .collection('houses')
        .doc(houseId.value)
        .collection('shopping')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .listen(
      (querySnapshot) {
        shoppingItems.value = querySnapshot.docs
            .map((doc) => ShoppingItem.fromFirestore(doc))
            .toList();
        _applyFilters();
        change(null, status: RxStatus.success());
      },
      onError: (error) {
        Get.snackbar(
          'Errore',
          'Errore nel caricamento della lista: $error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        change(null, status: RxStatus.success());
      },
    );
  }

  void _applyFilters() {
    List<ShoppingItem> filtered = shoppingItems.toList();

    final noCategory = selectedCategory.value == null || selectedCategory.value!.isEmpty;
    final noFilter = selectedFilter.value == null || selectedFilter.value!.isEmpty;

    // Se nessun filtro attivo → mostra tutto
    if (noCategory && noFilter) {
      filteredItems.value = filtered;
      return;
    }

    // Filtro per categoria
    if (!noCategory) {
      filtered = filtered.where((item) => item.category == selectedCategory.value).toList();
    }

    // Filtro per stato
    if (!noFilter) {
      if (selectedFilter.value == 'Acquistate') {
        filtered = filtered.where((item) => item.isPurchased).toList();
      } else if (selectedFilter.value == 'Da comprare') {
        filtered = filtered.where((item) => !item.isPurchased).toList();
      }
    }

    filteredItems.value = filtered;
  }

  void changeCategory(String? category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void changeFilter(String? filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  void resetFilters() {
    selectedCategory.value = null;
    selectedFilter.value = null;
    _applyFilters();
  }

  Future<void> togglePurchaseStatus(String itemId, bool isPurchased) async {
    if (houseId.value.isEmpty) return;

    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      Map<String, dynamic> updateData = {
        'isPurchased': isPurchased,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isPurchased) {
        updateData['purchasedBy'] = currentUser.displayName ?? currentUser.email ?? 'Utente';
        updateData['purchasedAt'] = FieldValue.serverTimestamp();
      } else {
        updateData['purchasedBy'] = null;
        updateData['purchasedAt'] = null;
      }

      await _firestore
          .collection('houses')
          .doc(houseId.value)
          .collection('shopping')
          .doc(itemId)
          .update(updateData);
      
      Get.snackbar(
        'Successo',
        isPurchased ? 'Articolo acquistato!' : 'Articolo da comprare',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Errore nell\'aggiornamento: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteItem(String itemId) async {
    if (houseId.value.isEmpty) return;

    try {
      await _firestore
          .collection('houses')
          .doc(houseId.value)
          .collection('shopping')
          .doc(itemId)
          .delete();
      
      Get.snackbar(
        'Successo',
        'Articolo eliminato!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Errore nell\'eliminazione: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}