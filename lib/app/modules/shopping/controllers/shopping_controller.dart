import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:roomy/app/data/shopping_item.dart';

class ShoppingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String houseId = "";
  
  final RxList<ShoppingItem> shoppingItems = <ShoppingItem>[].obs;
  final RxList<ShoppingItem> filteredItems = <ShoppingItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'Tutte'.obs;
  final RxString selectedFilter = 'Tutte'.obs; // Tutte, Acquistate, Da comprare
  final RxString searchQuery = ''.obs;
  
  final List<String> categories = [
    'Tutte',
    'Alimentari',
    'Igiene',
    'Pulizia',
    'Bricolage',
    'Altro'
  ];

  @override
  void onInit() {
    super.onInit();
    loadShoppingItems();
    ever(selectedCategory, (_) => _applyFilters());
    ever(selectedFilter, (_) => _applyFilters());
    ever(searchQuery, (_) => _applyFilters());
  }

  void loadShoppingItems() {
    isLoading.value = true;
    
    _firestore
        .collection('houses')
        .doc(houseId)
        .collection('shopping')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      shoppingItems.value = querySnapshot.docs
          .map((doc) => ShoppingItem.fromFirestore(doc))
          .toList();
      _applyFilters();
      isLoading.value = false;
    });
  }

  void _applyFilters() {
    List<ShoppingItem> filtered = shoppingItems.toList();

    // Filter by category
    if (selectedCategory.value != 'Tutte') {
      filtered = filtered.where((item) => item.category == selectedCategory.value).toList();
    }

    // Filter by status
    if (selectedFilter.value == 'Acquistate') {
      filtered = filtered.where((item) => item.isPurchased).toList();
    } else if (selectedFilter.value == 'Da comprare') {
      filtered = filtered.where((item) => !item.isPurchased).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((item) => 
          item.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (item.notes?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
      ).toList();
    }

    filteredItems.value = filtered;
  }

  Future<void> addItem({
    required String name,
    int quantity = 1,
    String category = 'Altro',
    String? notes,
    required String addedBy,
  }) async {
    try {
      isLoading.value = true;
      
      final newItem = ShoppingItem(
        id: '',
        name: name,
        quantity: quantity,
        category: category,
        isPurchased: false,
        addedBy: addedBy,
        addedAt: DateTime.now(),
        notes: notes,
        houseId: houseId,
      );

      await _firestore
          .collection('houses')
          .doc(houseId)
          .collection('shopping')
          .add(newItem.toFirestore());

      Get.back();
      Get.snackbar('Successo', 'Articolo aggiunto alla lista!');
    } catch (e) {
      Get.snackbar('Errore', 'Errore nell\'aggiunta: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> togglePurchaseStatus(String itemId, bool isPurchased) async {
    try {
      await _firestore
          .collection('houses')
          .doc(houseId)
          .collection('shopping')
          .doc(itemId)
          .update({'isPurchased': isPurchased});
      
      Get.snackbar('Successo', isPurchased ? 'Articolo acquistato!' : 'Articolo da comprare');
    } catch (e) {
      Get.snackbar('Errore', 'Errore nell\'aggiornamento: $e');
    }
  }

  Future<void> updateItem(String id, {
    required String itemId,
    required String name,
    required int quantity,
    required String category,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      
      await _firestore
          .collection('houses')
          .doc(houseId)
          .collection('shopping')
          .doc(itemId)
          .update({
            'name': name,
            'quantity': quantity,
            'category': category,
            if (notes != null) 'notes': notes,
          });

      Get.back();
      Get.snackbar('Successo', 'Articolo aggiornato!');
    } catch (e) {
      Get.snackbar('Errore', 'Errore nell\'aggiornamento: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore
          .collection('houses')
          .doc(houseId)
          .collection('shopping')
          .doc(itemId)
          .delete();
      
      Get.snackbar('Successo', 'Articolo eliminato!');
    } catch (e) {
      Get.snackbar('Errore', 'Errore nell\'eliminazione: $e');
    }
  }
}