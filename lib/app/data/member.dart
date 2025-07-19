import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String id;
  final String name;
  final String email;

  Member({
    required this.id,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": id,
      "name": name,
      "email": email,
    };
  }

  Member.fromJson(Map<String, dynamic> json)
      : id = json['uid'] ?? '',
        name = json['name'] ?? '',
        email = json['email'] ?? '';
}

class MemberHelper {
  Stream<Member?> getUser(String id) {
    final userStream = FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .snapshots();

    return userStream.asyncMap((userDoc) async {
      if (!userDoc.exists) return null;
      final userData = userDoc.data();
      if (userData == null) return null;

      return Member.fromJson(userData);
    });
  }
}