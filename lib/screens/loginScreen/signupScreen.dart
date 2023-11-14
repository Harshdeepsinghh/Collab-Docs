import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/screens/loginScreen/loginScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(em);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _globalKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign up here",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 30),
              kRepeatedTextForm(
                  validator: (String) {
                    if (String == '') {
                      return "Please write a name";
                    }
                    return null;
                  },
                  controller: _fullNameController,
                  hint: 'Full name'),
              kRepeatedTextForm(
                  validator: (String) {
                    if (String == '') {
                      return "Please write an email address";
                    } else if (!isEmail(String!)) {
                      return "Invalid email";
                    }
                    return null;
                  },
                  controller: _emailController,
                  hint: 'Email'),
              kRepeatedTextForm(
                  validator: (String) {
                    if (String == '') {
                      return "Please write a password";
                    }
                    return null;
                  },
                  controller: _passwordController,
                  hint: 'Password'),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_globalKey.currentState!.validate()) {
                          Object body = jsonEncode({
                            "name": _fullNameController.text,
                            "email": _emailController.text,
                            "password": _passwordController.text
                          });
                          await AppApi().userSignIn(body).then((value) {
                            if (value["msg"] == "user already exist!") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("user already exist")));
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            }
                          });
                        }
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 20),
                      )))
            ],
          ),
        ),
      ),
    );
  }

  Column kRepeatedTextForm({
    required String? Function(String?)? validator,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: EdgeInsets.all(10),
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ),
        SizedBox(height: 20)
      ],
    );
  }
}
