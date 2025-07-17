import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final String id;
  final String name;
  final String? brand;
  final String category;
  final String? notes;
  final int quantity;
  final String? unit;
  final bool isPerishable;
  final DateTime? expiryDate;
  final bool isPurchased;
  final String addedBy;
  final DateTime addedAt;
  final DateTime? purchasedAt;
  final String? purchasedBy;

  ShoppingItem({
    required this.id,
    required this.name,
    this.brand,
    this.quantity = 1,
    this.category = 'Altro',
    this.unit,
    this.isPerishable = false,
    this.expiryDate,
    this.isPurchased = false,
    required this.addedBy,
    required this.addedAt,
    this.purchasedAt,
    this.purchasedBy,
    this.notes,
  });

  factory ShoppingItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItem(
      id: doc.id,
      name: data['name'] ?? '',
      brand: data['brand'],
      quantity: data['quantity'] ?? 1,
      category: data['category'] ?? 'Altro',
      unit: data['unit'],
      isPerishable: data['isPerishable'] ?? false,
      expiryDate: data['expiryDate'] != null ? (data['expiryDate'] as Timestamp).toDate() : null,
      isPurchased: data['isPurchased'] ?? false,
      addedBy: data['addedBy'] ?? '',
      addedAt: (data['addedAt'] as Timestamp).toDate(),
      purchasedAt: data['purchasedAt'] != null ? (data['purchasedAt'] as Timestamp).toDate() : null,
      purchasedBy: data['purchasedBy'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'brand': brand,
      'quantity': quantity,
      'category': category,
      'unit': unit,
      'isPerishable': isPerishable,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isPurchased': isPurchased,
      'addedBy': addedBy,
      'addedAt': Timestamp.fromDate(addedAt),
      if (purchasedAt != null) 'purchasedAt': Timestamp.fromDate(purchasedAt!),
      if (purchasedBy != null) 'purchasedBy': purchasedBy,
      if (notes != null) 'notes': notes,
    };
  }
}