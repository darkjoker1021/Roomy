import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/data/member.dart';
import 'package:roomy/app/data/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksController extends GetxController with StateMixin{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxString houseId = ''.obs;
  final RxList<Task> tasks = <Task>[].obs;
  final RxList<Task> filteredTasks = <Task>[].obs;
  final RxnString selectedCategory = RxnString(null);
  final RxnString selectedFilter = RxnString(null);
  final RxnString selectedPriority = RxnString(null);
  final RxnString selectedAssignedTo = RxnString(null);

  final List<String> filters = ['Da fare', 'Completate'];
  final RxList<Member> houseMembers = <Member>[].obs;
  final RxBool isLoadingMembers = false.obs;

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
          loadHouseMembers(),
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
              loadHouseMembers(),
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

  Future<void> loadHouseMembers() async {
    if (houseId.value.isEmpty) return;

    try {
      isLoadingMembers.value = true;

      final membersSnapshot = await _firestore
          .collection('houses')
          .doc(houseId.value)
          .collection('members')
          .get();

      List<Member> loadedMembers = [];

      for (var doc in membersSnapshot.docs) {
        final uid = doc.id;
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final userData = userDoc.data() ?? {};

        loadedMembers.add(
          Member.fromJson(userData)
        );
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

  List<Member> getAllAssignableMembers() {
    return houseMembers.toList();
  }

  bool isValidMember(String memberName) {
    if (memberName == 'Assegnata a') return true;
    return houseMembers.any((member) => 
      member.name == memberName
    );
  }

  Future<void> loadTasks() async {
    if (houseId.value.isEmpty) return;
    
    change(null, status: RxStatus.loading());
    
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
        change(null, status: RxStatus.success());
      },
      onError: (error) {
        Get.snackbar(
          'Errore',
          'Errore nel caricamento delle task: $error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        change(null, status: RxStatus.success());
      },
    );
  }

  void _applyFilters() {
    List<Task> filtered = tasks.toList();

    // Se tutti i filtri sono nulli o vuoti, mostra tutte le task
    final noCategory = selectedCategory.value == null || selectedCategory.value!.isEmpty;
    final noFilter = selectedFilter.value == null || selectedFilter.value!.isEmpty;
    final noPriority = selectedPriority.value == null || selectedPriority.value!.isEmpty;
    final noAssignedTo = selectedAssignedTo.value == null || selectedAssignedTo.value!.isEmpty;

    if (noCategory && noFilter && noPriority && noAssignedTo) {
      filteredTasks.value = filtered;
      return;
    }

    // Filtro per categoria
    if (!noCategory) {
      filtered = filtered.where((task) => task.category == selectedCategory.value).toList();
    }

    // Filtro per stato
    if (!noFilter) {
      if (selectedFilter.value == 'Completate') {
        filtered = filtered.where((task) => task.isCompleted).toList();
      } else if (selectedFilter.value == 'Da fare') {
        filtered = filtered.where((task) => !task.isCompleted).toList();
      }
    }

    // Filtro per priorità
    if (!noPriority) {
      final priorityText = selectedPriority.value!;
      int priorityNumber;
      switch (priorityText) {
        case 'Alta':
          priorityNumber = 3;
          break;
        case 'Media':
          priorityNumber = 2;
          break;
        case 'Bassa':
          priorityNumber = 1;
          break;
        default:
          priorityNumber = -1;
      }

      if (priorityNumber > 0) {
        filtered = filtered.where((task) => task.priority == priorityNumber).toList();
      }
    }

    // Filtro per assegnazione
    if (!noAssignedTo) {
      filtered = filtered.where((task) => task.assignedTo == selectedAssignedTo.value).toList();
    }

    filteredTasks.value = filtered;
  }


  void changeCategory(String? category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void changeFilter(String? filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  void changePriority(String? priority) {
    selectedPriority.value = priority;
    _applyFilters();
  }

  void changeAssignedTo(String? assignedTo) {
    selectedAssignedTo.value = assignedTo;
    _applyFilters();
  }

  void resetFilters() {
    selectedCategory.value = null;
    selectedFilter.value = null;
    selectedPriority.value = null;
    selectedAssignedTo.value = null;
    _applyFilters();
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

  int getPriorityNumber(String priorityText) {
    switch (priorityText) {
      case 'Alta':
        return 3;
      case 'Media':
        return 2;
      case 'Bassa':
        return 1;
      default:
        return 1;
    }
  }

  void refreshTasks() {
    loadTasks();
  }
}