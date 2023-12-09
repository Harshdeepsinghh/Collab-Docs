import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

StateProvider<bool> themeProvider = StateProvider((ref) => false);
final newProv = StateProvider((ref) => "hello");
StateProvider<bool> showNavBar = StateProvider((ref) => true);
StateProvider<bool> showSkeleton = StateProvider((ref) => false);
StateProvider<bool> refreshApi = StateProvider((ref) => false);
StateProvider<dynamic> membersData = StateProvider((ref) => null);

class SharedTheme {
  saveTheme(bool theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("theme", theme);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getBool("theme") ?? false;
  }
}
