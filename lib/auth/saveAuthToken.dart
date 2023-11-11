import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefData {
  void saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("uid");
  }

  void saveUid(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("uid", token);
  }

  Future<String?> getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("uid");
  }

  Future clearUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("uid");
  }
}
