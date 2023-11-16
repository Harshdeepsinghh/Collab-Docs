import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/screens/homeScreen.dart';
import 'package:collabDocs/screens/loginScreen/loginScreen.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = true;
  String uid = '';
  Future checkToken() async {
    String? token = await SharedPrefData().getToken();
    uid = await SharedPrefData().getUid() ?? '';
    setState(() {});
    Logger().e(token);
    if (token == null) {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "Lufga",
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff01D8D8)),
        useMaterial3: true,
      ),
      home: isLoggedIn ? HomeScreen(uid) : LoginScreen(),
    );
  }
}
