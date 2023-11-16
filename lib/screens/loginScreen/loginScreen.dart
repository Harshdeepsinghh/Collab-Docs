import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/constants/appConsts.dart';
import 'package:collabDocs/screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collabDocs/repo/auth_repo.dart';
import 'package:collabDocs/screens/loginScreen/signupScreen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Form(
          key: formKey,
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
                    "Login",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Divider(
                    indent: MediaQuery.of(context).size.width * 0.4,
                    endIndent: MediaQuery.of(context).size.width * 0.4,
                  ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/googleicon.png"),
                      TextButton(
                          onPressed: () async {
                            await ref
                                .watch(authRepoProvider)
                                .signInWithGoogle(ref, context);
                          },
                          child: Text(
                            "Sign in with google account",
                            style:
                                TextStyle(fontSize: 16, color: kBlackColor()),
                          )),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account?",
                      ),
                      TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpScreen()));
                          },
                          child: Text(
                            "Sign up",
                            style:
                                TextStyle(fontSize: 16, color: kPrimaryColor()),
                          )),
                    ],
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ));
  }

  GestureDetector kRepeatedLoginButton() {
    return GestureDetector(
      onTap: () async {
        if (formKey.currentState!.validate()) {
          Object body = {
            "email": _emailController.text,
            "password": _passwordController.text
          };
          AppApi().userLoginManually(body, context).then((value) {
            SharedPrefData().saveToken(value["token"]);
            SharedPrefData().saveUid(value["data"]["_id"]);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomeScreen(value["data"]["_id"])));
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
            "Login",
            style: TextStyle(
              color: kWhiteColor(),
            ),
          ),
        ),
      ),
    );
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
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
}

   //  Scaffold(
        //   body: Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         ElevatedButton.icon(
        //             style: ElevatedButton.styleFrom(maximumSize: Size(250, 80)),
        //             onPressed: () async {
        //               await ref
        //                   .watch(authRepoProvider)
        //                   .signInWithGoogle(ref, context);
        //             },
        //             icon: Image.asset(
        //               "assets/images/googleIcon.jpeg",
        //               height: 30,
        //             ),
        //             label: Text(
        //               'Sign in with Google',
        //               style: TextStyle(fontWeight: FontWeight.w800),
        //             )),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Text("or"),
        //         ),
        //         ElevatedButton(
        //             style: ElevatedButton.styleFrom(maximumSize: Size(250, 80)),
        //             onPressed: () async {
        //               Navigator.push(context,
        //                   MaterialPageRoute(builder: (context) => LoginScreen()));
        //             },
        //             child: Text(
        //               'Login',
        //               style: TextStyle(fontWeight: FontWeight.w800),
        //             )),
        //         SizedBox(height: 10),
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Text("Don't have an account?"),
        //             TextButton(
        //                 onPressed: () {
        //                   Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                           builder: (context) => SignUpScreen()));
        //                 },
        //                 child: Text('Sign up'))
        //           ],
        //         )
        //       ],
        //     ),
        //   ),
        // ),
