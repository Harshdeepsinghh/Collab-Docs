import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collabDocs/repo/auth_repo.dart';
import 'package:collabDocs/screens/loginScreen/loginScreen.dart';
import 'package:collabDocs/screens/loginScreen/signupScreen.dart';

class SelectLoginScreen extends ConsumerWidget {
  const SelectLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(maximumSize: Size(250, 80)),
                  onPressed: () async {
                    await ref
                        .watch(authRepoProvider)
                        .signInWithGoogle(ref, context);
                  },
                  icon: Image.asset(
                    "assets/images/googleIcon.jpeg",
                    height: 30,
                  ),
                  label: Text(
                    'Sign in with Google',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("or"),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(maximumSize: Size(250, 80)),
                  onPressed: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  )),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()));
                      },
                      child: Text('Sign up'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
