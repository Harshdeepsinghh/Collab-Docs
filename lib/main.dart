import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:mydocsy/auth/saveAuthToken.dart';
import 'package:mydocsy/screens/homeScreen.dart';
import 'package:mydocsy/screens/loginScreen.dart';

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
  String? uid;
  Future checkToken() async {
    String? token = await SharedPrefData().getToken();
    uid = await SharedPrefData().getUid();
    setState(() {});
    Logger().e(token);
    if (token == null && uid == null) {
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
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn ? HomeScreen(uid!) : LoginScreen(),
    );
  }
}
