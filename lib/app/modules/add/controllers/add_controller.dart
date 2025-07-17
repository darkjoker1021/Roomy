import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomy/app/data/shopping_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roomy/app/data/task.dart';

enum AddType { task, product }

class AddController extends GetxController with StateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Tipo di elemento da aggiungere
  final Rx<AddType> addType = AddType.task.obs;
  
  // Controllers per i form
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final brandController = TextEditingController();
  final quantityController = TextEditingController();
  final notesController = TextEditingController();
  
  // Variabili per task
  final RxString selectedCategory = 'Pulizie'.obs;
  final RxInt selectedPriority = 1.obs;
  final Rx<DateTime?> selectedDueDate = Rx<DateTime?>(null);
  final RxString selectedMember = ''.obs;
  
  // Variabili per prodotti alimentari
  final RxString selectedProductCategory = 'Alimentari'.obs;
  final Rx<DateTime?> selectedExpiryDate = Rx<DateTime?>(null);
  final RxString selectedUnit = 'Pz'.obs;
  final RxBool isPerishable = false.obs;
  
  // Dati comuni
  final RxString houseId = ''.obs;
  final RxList<Map<String, dynamic>> houseMembers = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingMembers = false.obs;

  // Task/ShoppingItem esistente per modifica
  Task? editingTask;
  ShoppingItem? editingShoppingItem;

  @override
  void onInit() {
    super.onInit();
    change(null, status: RxStatus.success());

    _initializeData();

    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      if (args['task'] != null) {
        editingTask = args['task'];
        initializeForTaskEdit(editingTask!);
      } else if (args['shopping'] != null) {
        editingShoppingItem = args['shopping'];
        initializeForShoppingEdit(editingShoppingItem!);
      }
    }

  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    brandController.dispose();
    quantityController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> _initializeData() async {
    await _initializeHouseId();
    if (houseId.value.isNotEmpty) {
      await loadHouseMembers();
    }
  }

  Future<void> _initializeHouseId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedHouseId = prefs.getString("houseId");
      
      if (savedHouseId != null && savedHouseId.isNotEmpty) {
        houseId.value = savedHouseId;
        return;
      }

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

  Future<void> loadHouseMembers() async {
    if (houseId.value.isEmpty) return;

    try {
      isLoadingMembers.value = true;

      final membersSnapshot = await _firestore
          .collection('houses')
          .doc(houseId.value)
          .collection('members')
          .get();

      List<Map<String, dynamic>> loadedMembers = [];

      for (var doc in membersSnapshot.docs) {
        final uid = doc.id;
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final userData = userDoc.data() ?? {};

        loadedMembers.add({
          'uid': uid,
          'name': userData['name'] ?? 'Membro',
        });
      }

      houseMembers.value = loadedMembers;
      
      // Imposta il primo membro come selezionato di default
      if (houseMembers.isNotEmpty) {
        selectedMember.value = houseMembers.first['name'];
      }
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Errore nel caricamento dei membri: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingMembers.value = false;
    }
  }

  void changeAddType(AddType type) {
    addType.value = type;
    _clearForm();
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    brandController.clear();
    quantityController.clear();
    notesController.clear();
    
    selectedCategory.value = 'Pulizie';
    selectedPriority.value = 1;
    selectedDueDate.value = null;
    selectedProductCategory.value = 'Alimentari';
    selectedExpiryDate.value = null;
    selectedUnit.value = 'Pz';
    isPerishable.value = false;
    
    if (houseMembers.isNotEmpty) {
      selectedMember.value = houseMembers.first['name'];
    }
  }

  void initializeForTaskEdit(Task task) {
    editingTask = task;
    addType.value = AddType.task;
    
    titleController.text = task.title;
    descriptionController.text = task.description;
    selectedCategory.value = task.category;
    selectedPriority.value = task.priority;
    selectedDueDate.value = task.dueDate;
    selectedMember.value = task.assignedTo;
  }

  void initializeForShoppingEdit(ShoppingItem item) {
    editingShoppingItem = item;
    addType.value = AddType.product;
    
    titleController.text = item.name;
    brandController.text = item.brand!;
    quantityController.text = item.quantity.toString();
    selectedProductCategory.value = item.category;
    selectedExpiryDate.value = item.expiryDate;
    selectedUnit.value = item.unit!;
    isPerishable.value = item.isPerishable;
    notesController.text = item.notes!;
  }

  Future<void> saveItem() async {
    if (addType.value == AddType.task) {
      await _saveTask();
    } else {
      await _saveProduct();
    }
    _clearForm();
  }

  Future<void> _saveTask() async {
    if (titleController.text.isEmpty || selectedMember.value.isEmpty) {
      Get.snackbar(
        'Errore',
        'Compila tutti i campi obbligatori',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (houseId.value.isEmpty) {
      Get.snackbar('Errore', 'ID casa non trovato');
      return;
    }

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.snackbar('Errore', 'Utente non autenticato');
      return;
    }

    try {
      change(null, status: RxStatus.loading());
      
      if (editingTask != null) {
        // Modifica task esistente
        await _firestore
            .collection('houses')
            .doc(houseId.value)
            .collection('tasks')
            .doc(editingTask!.id)
            .update({
          'title': titleController.text,
          'description': descriptionController.text,
          'category': selectedCategory.value,
          'assignedTo': selectedMember.value,
          'dueDate': selectedDueDate.value != null ? Timestamp.fromDate(selectedDueDate.value!) : null,
          'priority': selectedPriority.value,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        Get.snackbar(
          'Successo',
          'Task aggiornata con successo!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Nuova task
        final newTask = Task(
          id: '',
          title: titleController.text,
          description: descriptionController.text,
          category: selectedCategory.value,
          createdAt: DateTime.now(),
          dueDate: selectedDueDate.value,
          isCompleted: false,
          assignedTo: selectedMember.value,
          createdBy: currentUser.displayName ?? currentUser.email ?? 'Utente',
          priority: selectedPriority.value,
        );

        await _firestore
            .collection('houses')
            .doc(houseId.value)
            .collection('tasks')
            .add(newTask.toFirestore());

        Get.snackbar(
          'Successo',
          'Task aggiunta con successo!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Errore nel salvataggio: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      change(null, status: RxStatus.success());
    }
  }

  Future<void> _saveProduct() async {
    if (titleController.text.isEmpty || quantityController.text.isEmpty) {
      Get.snackbar(
        'Errore',
        'Compila tutti i campi obbligatori',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (houseId.value.isEmpty) {
      Get.snackbar('Errore', 'ID casa non trovato');
      return;
    }

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.snackbar('Errore', 'Utente non autenticato');
      return;
    }

    try {
      change(null, status: RxStatus.loading());

      final shoppingItem = ShoppingItem(
        id: '',
        name: titleController.text,
        brand: brandController.text,
        category: selectedProductCategory.value,
        quantity: quantityController.text.isNotEmpty ? int.parse(quantityController.text) : 1,
        unit: selectedUnit.value,
        isPerishable: isPerishable.value,
        expiryDate: selectedExpiryDate.value,
        notes: notesController.text,
        addedBy: currentUser.displayName ?? currentUser.email ?? 'Utente',
        addedAt: DateTime.now(),
        isPurchased: false,
        purchasedAt: null,
        purchasedBy: null,
      );

      await _firestore
          .collection('houses')
          .doc(houseId.value)
          .collection('shopping')
          .add(shoppingItem.toFirestore());

      Get.snackbar(
        'Successo',
        'Prodotto aggiunto con successo!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Errore nell\'aggiunta del prodotto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      change(null, status: RxStatus.success());
    }
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Bassa';
      case 2:
        return 'Media';
      case 3:
        return 'Alta';
      default:
        return 'Normale';
    }
  }
}