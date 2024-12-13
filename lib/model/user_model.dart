import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? name;
  final String? email;
  final String? password;

  UserModel({
    this.name,
    this.email,
    this.password,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    return UserModel(
      name: doc['name'],
      email: doc['email'],
      password: doc['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }
}