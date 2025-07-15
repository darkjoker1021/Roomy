import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/data/task.dart';

class TasksController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String houseId = ""; // Dovrebbe essere passato dal sistema di autenticazione
  
  final RxList<Task> tasks = <Task>[].obs;
  final RxList<Task> filteredTasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'Tutte'.obs;
  final RxString selectedFilter = 'Tutte'.obs; // Tutte, Completate, Da fare
  
  final List<String> categories = [
    'Tutte',
    'Pulizie',
    'Cucina',
    'Bagno',
    'Spesa',
    'Manutenzione',
    'Giardino',
    'Altro'
  ];

  final List<String> filters = ['Tutte', 'Da fare', 'Completate'];

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  // Carica tutte le tasks da Firestore
  void loadTasks() {
    isLoading.value = true;
    
    _firestore
        .collection('houses')
        .doc(houseId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      tasks.value = querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      _applyFilters();
      isLoading.value = false;
    });
  }

  // Applica i filtri alle tasks
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

  // Cambia categoria selezionata
  void changeCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  // Cambia filtro selezionato
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  // Aggiungi nuova task
  Future<void> addTask({
    required String title,
    required String description,
    required String category,
    required String assignedTo,
    required String createdBy,
    DateTime? dueDate,
    int priority = 1,
  }) async {
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
        createdBy: createdBy,
        priority: priority,
      );

      await _firestore
          .collection('houses')
          .doc(houseId)
          .collection('tasks')
          .add(newTask.toFirestore());

      Get.back();
      Get.snackbar('Successo', 'Task aggiunta con successo!');
    } catch (e) {
      Get.snackbar('Errore', 'Errore nell\'aggiunta della task: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Aggiorna stato completamento task
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _firestore
          .collection('houses')
          .doc(houseId)
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': isCompleted});
      
      Get.snackbar('Successo', isCompleted ? 'Task completata!' : 'Task riaperta!');
    } catch (e) {
      Get.snackbar('Errore', 'Errore nell\'aggiornamento: $e');
    }
  }

  // Elimina task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore
          .collection('houses')
          .doc(houseId)
          .collection('tasks')
          .doc(taskId)
          .delete();
      
      Get.snackbar('Successo', 'Task eliminata!');
    } catch (e) {
      Get.snackbar('Errore', 'Errore nell\'eliminazione: $e');
    }
  }

  // Modifica task
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String category,
    required String assignedTo,
    DateTime? dueDate,
    int priority = 1,
  }) async {
    try {
      isLoading.value = true;
      
      await _firestore
          .collection('houses')
          .doc(houseId)
          .collection('tasks')
          .doc(taskId)
          .update({
        'title': title,
        'description': description,
        'category': category,
        'assignedTo': assignedTo,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
        'priority': priority,
      });

      Get.back();
      Get.snackbar('Successo', 'Task aggiornata con successo!');
    } catch (e) {
      Get.snackbar('Errore', 'Errore nell\'aggiornamento: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Ottieni colore per priorità
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

  // Ottieni testo per priorità
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