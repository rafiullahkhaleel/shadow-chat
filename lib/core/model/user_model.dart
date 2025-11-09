import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String imageUrl;
  final String about;
  final String? fcmToken;
  final DateTime? lastActive;
  final DateTime? createdAt;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.about,
    required this.fcmToken,
    required this.lastActive,
    required this.createdAt,
    required this.isOnline,
  });

  /// ✅ Create safely from Firestore map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'Unknown',
      email: map['email'] ?? '',
      imageUrl: map['image'] ?? '',
      about: map['about'] ?? "Hey there! I'm using this app.",
      fcmToken: map['fcmToken'],
      lastActive:
          map['lastActive'] != null
              ? (map['lastActive'] as Timestamp).toDate()
              : null,
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : null,
      isOnline: map['isOnline'] ?? false,
    );
  }
}


// class UserModel {
//   final String id;
//   final String name;
//   final String email;
//   final String image;
//   final String about;
//   final String pushToken;
//   final String lastActive;
//   final String createdAt;
//   final bool isOnline;
//
//   UserModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.image,
//     required this.about,
//     required this.pushToken,
//     required this.lastActive,
//     required this.createdAt,
//     required this.isOnline,
//   });
//
//   factory UserModel.fromMap(Map<String, dynamic>? map) {
//     if (map == null) {
//       return UserModel(
//         id: '',
//         name: 'Unknown',
//         email: '',
//         image: '',
//         about: "Hey there! I'm using this app.",
//         pushToken: '',
//         lastActive: '',
//         createdAt: '',
//         isOnline: false,
//       );
//     }
//
//     return UserModel(
//       id: map['id'] ?? '',
//       name: map['name'] ?? 'Unknown',
//       email: map['email'] ?? '',
//       image: map['image'] ?? '',
//       about: map['about'] ?? "Hey there! I'm using this app.",
//       pushToken: map['pushToken'] ?? '',
//       lastActive: map['lastActive'] ?? '',
//       createdAt: map['createdAt'] ?? '',
//       isOnline: map['isOnline'] ?? false,
//     );
//   }
//
//   /// CopyWith method for local updates
//   UserModel copyWith({
//     String? id,
//     String? name,
//     String? email,
//     String? image,
//     String? about,
//     String? pushToken,
//     String? lastActive,
//     String? createdAt,
//     bool? isOnline,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       email: email ?? this.email,
//       image: image ?? this.image,
//       about: about ?? this.about,
//       pushToken: pushToken ?? this.pushToken,
//       lastActive: lastActive ?? this.lastActive,
//       createdAt: createdAt ?? this.createdAt,
//       isOnline: isOnline ?? this.isOnline,
//     );
//   }
// }
