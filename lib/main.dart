import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:collabDocs/screens/bottomNav/bottomNav.dart';
import 'package:collabDocs/screens/loginScreen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
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
    } else {}
  }

  checkTheme() async {
    await SharedTheme()
        .getTheme()
        .then((value) => ref.watch(themeProvider.notifier).update((state) {
              return value;
            }));
    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    super.initState();
    checkToken();
    checkTheme();
  }

  @override
  Widget build(BuildContext context) {
    // MyProvider provider = context.watch<MyProvider>();
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final themeBool = ref.watch(themeProvider);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Collab Docs',
          themeMode: themeBool ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            dialogBackgroundColor: kPrimaryWhiteColor(),
            scaffoldBackgroundColor: kPrimaryWhiteColor(),
            fontFamily: "Lufga",
            colorScheme: ColorScheme.light(
              // background: kPrimaryColor(),
              primary: kPrimaryColor(),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            fontFamily: "Lufga",
            dialogBackgroundColor: kBlackColor(),
            primaryColor: kPrimaryColor(),
            colorScheme: ColorScheme.dark(
              // background: kBlackColor(),
              primary: kPrimaryColor(),
            ),
            useMaterial3: true,
          ),
          home: isLoggedIn ? BottomNavScreen() : LoginScreen(),
        );
      },
    );
  }
}

final routes = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => BottomNavScreen(),
  )
]);
