// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:mydocsy/api/appApi.dart';
import 'package:mydocsy/auth/saveAuthToken.dart';
import 'package:mydocsy/models/userModel.dart';
import 'package:mydocsy/screens/homeScreen.dart';

final authRepoProvider =
    Provider((ref) => AuthRepo(googleSignIn: GoogleSignIn()));
final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepo {
  final GoogleSignIn _googleSignIn;
  AuthRepo({
    required GoogleSignIn googleSignIn,
  }) : _googleSignIn = googleSignIn;

  Future signInWithGoogle(ref, context) async {
    try {
      final navigator = Navigator.of(context);

      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userData = UserModel(
            name: user.displayName ?? '',
            email: user.email,
            profilePic: user.photoUrl ?? '',
            uid: '',
            token: '');

        AppApi().userSignIn(userData.toJson()).then((value) {
          final newUser = userData.copyWith(
              uid: value["data"]["_id"], token: value["token"]);
          ref.read(userProvider.notifier).update((state) => newUser);
          SharedPrefData().saveToken(value["token"]);
          SharedPrefData().saveUid(value["data"]["_id"]);
          navigator.pushReplacement(MaterialPageRoute(
              builder: (context) => HomeScreen(value["data"]["_id"])));
          Logger().d(newUser.toJson());
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
