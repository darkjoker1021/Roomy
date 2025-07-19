import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final String category;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final String assignedTo;
  final String createdBy;
  final int priority; // 1 = bassa, 2 = media, 3 = alta

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.dueDate,
    required this.isCompleted,
    required this.assignedTo,
    required this.createdBy,
    required this.priority,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
      isCompleted: data['isCompleted'] ?? false,
      assignedTo: data['assignedTo'] ?? '',
      createdBy: data['createdBy'] ?? '',
      priority: data['priority'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isCompleted': isCompleted,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'priority': priority,
    };
  }
}