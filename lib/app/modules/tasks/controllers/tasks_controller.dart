import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/data/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxString houseId = ''.obs;
  final RxList<Task> tasks = <Task>[].obs;
  final RxList<Task> filteredTasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'Tutte'.obs;
  final RxString selectedFilter = 'Tutte'.obs;

  final List<String> filters = ['Tutte', 'Da fare', 'Completate'];

  @override
  void onInit() {
    super.onInit();
    _initializeHouseId();
  }

  Future<void> _initializeHouseId() async {
    try {
      // Prova a ottenere l'houseId dalle preferenze
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedHouseId = prefs.getString("houseId");
      
      if (savedHouseId != null && savedHouseId.isNotEmpty) {
        houseId.value = savedHouseId;
        await Future.wait([
          loadTasks(),
          loadHouseMembers(), // Carica anche i membri
        ]);
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
            await Future.wait([
              loadTasks(),
              loadHouseMembers(), // Carica anche i membri
            ]);
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

  // Aggiungi queste proprietà alla tua classe TasksController
  final RxList<Map<String, dynamic>> houseMembers = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingMembers = false.obs;

  // Modifica il metodo getHouseMembers per essere reactive
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
          'name': (uid == FirebaseAuth.instance.currentUser?.uid ? "${userData['name']}" : userData['name']) ?? 'Membro',
        });
      }

      houseMembers.value = loadedMembers;
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


  // Metodo per ottenere tutti i membri incluso "Tutti"
  List<Map<String, dynamic>> getAllAssignableMembers() {
    return [
      {'name': 'Tutti', 'email': 'tutti@casa', 'isAll': true},
      ...houseMembers,
    ];
  }

  // Metodo per validare se un membro esiste
  bool isValidMember(String memberName) {
    if (memberName == 'Tutti') return true;
    return houseMembers.any((member) => 
      member['name'] == memberName || member['email'] == memberName
    );
  }

  Future<void> loadTasks() async {
    if (houseId.value.isEmpty) return;
    
    isLoading.value = true;
    
    _firestore
        .collection('houses')
        .doc(houseId.value)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (querySnapshot) {
        tasks.value = querySnapshot.docs
            .map((doc) => Task.fromFirestore(doc))
            .toList();
        _applyFilters();
        isLoading.value = false;
      },
      onError: (error) {
        Get.snackbar(
          'Errore',
          'Errore nel caricamento delle task: $error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
      },
    );
  }

  void _applyFilters() {
    List<Task> filtered = tasks.toList();

    // Filtro per categoria
    if (selectedCategory.value != 'Tutte') {
      filtered = filtered.where((task) => task.category == selectedCategory.value).toList();
    }

    // Filtro per stato
    if (selectedFilter.value == 'Completate') {
      filtered = filtered.where((task) => task.isCompleted).toList();
    } else if (selectedFilter.value == 'Da fare') {
      filtered = filtered.where((task) => !task.isCompleted).toList();
    }

    filteredTasks.value = filtered;
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  Future<void> addTask({
    required String title,
    required String description,
    required String category,
    required String assignedTo,
    DateTime? dueDate,
    int priority = 1,
  }) async {
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
      isLoading.value = true;
      
      final newTask = Task(
        id: '',
        title: title,
        description: description,
        category: category,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        isCompleted: false,
        assignedTo: assignedTo,
        createdBy: currentUser.displayName ?? currentUser.email ?? 'Utente',
        priority: priority,
      );

      await _firestore
          .collection('houses')
          .doc(houseId.value)
          .collection('tasks')
          .add(newTask.toFirestore());

      Get.back();
      Get.snackbar(
        'Successo',
        'Task aggiunta con successo!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Errore nell\'aggiunta della task: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    if (houseId.value.isEmpty) return;

    try {
      await _firestore
          .collection('houses')
          .doc(houseId.value)
          .collection('tasks')
          .doc(taskId)
          .update({
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
      });
      
      Get.snackbar(
        'Successo',
        isCompleted ? 'Task completata!' : 'Task riaperta!',
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

  Future<void> deleteTask(String taskId) async {
    if (houseId.value.isEmpty) return;

    try {
      await _firestore
          .collection('houses')
          .doc(houseId.value)
          .collection('tasks')
          .doc(taskId)
          .delete();
      
      Get.snackbar(
        'Successo',
        'Task eliminata!',
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

  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String category,
    required String assignedTo,
    DateTime? dueDate,
    int priority = 1,
  }) async {
    if (houseId.value.isEmpty) return;

    try {
      isLoading.value = true;
      
      await _firestore
          .collection('houses')
          .doc(houseId.value)
          .collection('tasks')
          .doc(taskId)
          .update({
        'title': title,
        'description': description,
        'category': category,
        'assignedTo': assignedTo,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
        'priority': priority,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.back();
      Get.snackbar(
        'Successo',
        'Task aggiornata con successo!',
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
    } finally {
      isLoading.value = false;
    }
  }

  // Ottieni lista membri della casa per assegnazione task
  Future<List<Map<String, dynamic>>> getHouseMembers() async {
    if (houseId.value.isEmpty) return [];

    try {
      QuerySnapshot membersSnapshot = await _firestore
          .collection('houses')
          .doc(houseId.value)
          .collection('members')
          .get();

      return membersSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Errore nel caricamento dei membri: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
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

  void refreshTasks() {
    loadTasks();
  }
}