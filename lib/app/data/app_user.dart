import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String surname;
  final String email;
  final int points;

  AppUser({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.points,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": id,
      "name": name,
      "surname": surname,
      "email": email,
      "points": points,
    };
  }

  AppUser.fromJson(Map<String, dynamic> json)
      : id = json['uid'] ?? '',
        name = json['name'] ?? '',
        surname = json['surname'] ?? '',
        email = json['email'] ?? '',
        points = json['points'] ?? 0;
}

class UserHelper {
  Stream<AppUser?> getUser(String id) {
    final userStream = FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .snapshots();

    return userStream.asyncMap((userDoc) async {
      if (!userDoc.exists) return null;
      final userData = userDoc.data();
      if (userData == null) return null;

      return AppUser.fromJson(userData);
    });
  }
}