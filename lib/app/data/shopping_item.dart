import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final String id;
  final String name;
  final int quantity;
  final String category;
  final bool isPurchased;
  final String addedBy;
  final DateTime addedAt;
  final String? notes;
  final String? houseId;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.category = 'Altro',
    this.isPurchased = false,
    required this.addedBy,
    required this.addedAt,
    this.notes,
    this.houseId,
  });

  factory ShoppingItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItem(
      id: doc.id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 1,
      category: data['category'] ?? 'Altro',
      isPurchased: data['isPurchased'] ?? false,
      addedBy: data['addedBy'] ?? '',
      addedAt: (data['addedAt'] as Timestamp).toDate(),
      notes: data['notes'],
      houseId: data['houseId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'category': category,
      'isPurchased': isPurchased,
      'addedBy': addedBy,
      'addedAt': Timestamp.fromDate(addedAt),
      if (notes != null) 'notes': notes,
      if (houseId != null) 'houseId': houseId,
    };
  }
}