import 'package:flutter/material.dart';
import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/screens/homeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.navigate_before,
              size: 38,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 30),
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
                          Object body = {
                            "email": _emailController.text,
                            "password": _passwordController.text
                          };
                          AppApi().userLoginManually(body).then((value) {
                            SharedPrefData().saveToken(value["token"]);
                            SharedPrefData().saveUid(value["data"]["_id"]);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomeScreen(value["data"]["_id"])));
                          });
                        }
                      },
                      child: Text(
                        "Login",
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
