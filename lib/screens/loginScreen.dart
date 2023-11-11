import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mydocsy/repo/auth_repo.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(maximumSize: Size(250, 80)),
            onPressed: () async {
              await ref.watch(authRepoProvider).signInWithGoogle(ref, context);
            },
            icon: Image.asset(
              "assets/images/googleIcon.jpeg",
              height: 30,
            ),
            label: Text(
              'Sign in with Google',
              style: TextStyle(fontWeight: FontWeight.w800),
            )),
      ),
    );
  }
}
