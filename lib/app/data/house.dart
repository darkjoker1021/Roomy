import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  final String id;
  final String name;
  final String description;
  final String address;
  final String adminId;
  final String inviteCode;
  final List<String> members;
  final DateTime createdAt;
  final int maxMembers;

  House({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.adminId,
    required this.inviteCode,
    required this.members,
    required this.createdAt,
    required this.maxMembers,
  });

  factory House.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return House(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      adminId: data['adminId'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      maxMembers: data['maxMembers'] ?? 10,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'adminId': adminId,
      'inviteCode': inviteCode,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
      'maxMembers': maxMembers,
    };
  }
}