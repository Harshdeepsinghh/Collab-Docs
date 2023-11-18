import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  final String name;
  final String email;
  final String profilePic;
  final String uid;
  final String token;
  final String password;
  UserModel({
    required this.name,
    required this.email,
    required this.profilePic,
    required this.uid,
    required this.token,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'profilePic': profilePic,
      '_id': uid,
      'token': token,
      'password': password
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      email: map['email'] as String,
      profilePic: map['profilePic'] as String,
      uid: map['_id'] as String,
      token: map['token'] ?? '',
      password: map['password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  UserModel copyWith(
      {String? name,
      String? email,
      String? profilePic,
      String? uid,
      String? token,
      String? password}) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
      token: token ?? this.token,
      password: password ?? this.password,
    );
  }
}
