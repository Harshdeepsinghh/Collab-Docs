import 'dart:convert';

import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/constants/appConsts.dart';
import 'package:collabDocs/screens/loginScreen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:collabDocs/api/appApi.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: globalKey,
        child: Scaffold(
          backgroundColor: kPrimaryWhiteColor(),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                Image.asset("assets/images/heading.png"),
                SizedBox(height: 80),
                Text(
                  "Signup",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Divider(
                  indent: MediaQuery.of(context).size.width * 0.4,
                  endIndent: MediaQuery.of(context).size.width * 0.4,
                ),
                kRepeatedTextFieldAndHead(context,
                    label: "Full name",
                    controller: _fullNameController, validator: (String) {
                  if (String == '') {
                    return "Please input a name";
                  }
                  return null;
                }),
                kRepeatedTextFieldAndHead(
                  context,
                  label: "Email",
                  controller: _emailController,
                  validator: (String) {
                    if (AppConstants.kIsEmail(String!) == false) {
                      return "Invalid email";
                    }
                    return null;
                  },
                ),
                kRepeatedTextFieldAndHead(context,
                    label: "Password",
                    controller: _passwordController, validator: (String) {
                  if (String == '') {
                    return "Please input a password";
                  } else if (String!.split("").length < 6) {
                    return "Please input at least 6 digit password";
                  }
                  return null;
                }),
                kRepeatedLoginButton(),
                Text("or"),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                    ),
                    TextButton(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: Text(
                          "Login",
                          style:
                              TextStyle(fontSize: 16, color: kPrimaryColor()),
                        )),
                  ],
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ));
  }

  Column kRepeatedTextFieldAndHead(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: kGreyColor()),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: TextFormField(
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              isDense: true,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: kGreyColor(), width: 0.5)),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  GestureDetector kRepeatedLoginButton() {
    return GestureDetector(
      onTap: () async {
        if (globalKey.currentState!.validate()) {
          Object body = jsonEncode({
            "name": _fullNameController.text,
            "email": _emailController.text,
            "password": _passwordController.text
          });
          await AppApi().userSignIn(body).then((value) {
            if (value["msg"] == "user already exist") {
              ScaffoldMessenger.of(context).showSnackBar(
                  AppConstants.kSnackbarMsg(msg: "user already exist!"));
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            }
          });
        }
      },
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(12),
        color: kPrimaryColor(),
        width: 250,
        child: Center(
          child: Text(
            "Signup",
            style: TextStyle(
              color: kWhiteColor(),
            ),
          ),
        ),
      ),
    );
  }
}
