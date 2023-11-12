import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mydocsy/auth/saveAuthToken.dart';
import 'package:mydocsy/clients/myScoket.dart';
import 'package:mydocsy/models/userModel.dart';

class AppApi {
  // static String kBaseUrl = "http://192.168.1.12:3001";

  static String kBaseUrl = "https://mydocsy-server.onrender.com";
  static Map<String, String> userHeader = {
    "Content-type": "application/json",
    "Accept": "application/json"
  };

  Future userSignIn(Object? body) async {
    Uri url = Uri.parse("$kBaseUrl/api/signup");
    http.Response response =
        await http.post(url, body: body, headers: userHeader);
    Logger().e(response.body);
    if (response.statusCode == 200) {
      Logger().d(response.body);
      return jsonDecode(response.body);
    }
    print("something went wrong ${response.statusCode} ${response.body}");
  }

  Future<UserModel?> getUser(ref) async {
    String? token = await SharedPrefData().getToken();
    Uri url = Uri.parse("$kBaseUrl/api/user");
    try {
      http.Response response = await http.get(url, headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "token": token!
      });
      if (response.statusCode == 200) {
        Logger().d(response.body);
        final userData = jsonDecode(response.body)["user"];
        return UserModel.fromJson(jsonEncode(userData)).copyWith(token: token);
      } else {
        SharedPrefData().clearToken();
        GoogleSignIn().signOut();
      }
    } catch (e) {
      Logger().e(e);
    }
    return null;
  }

  Future userLoginManually(Object body) async {
    Uri url = Uri.parse("$kBaseUrl/api/loginmanually");
    try {
      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: userHeader);
      Logger().f(response.statusCode);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logger().f(data);
        return data;
      }
    } catch (e) {
      Logger().f(e);
    }
  }

  Future getAllDocs() async {
    String? token = await SharedPrefData().getToken();

    try {
      Uri url = Uri.parse("$kBaseUrl/api/allDocs");
      http.Response response = await http.get(url, headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "token": token!
      });
      if (response.statusCode == 200) {
        Logger().e(response.body);

        var data = jsonDecode(response.body)["data"];
        return data;
      }
    } catch (e) {
      Logger().e(e);
    }
    return null;
  }

  Future getDocById({required String id}) async {
    String? token = await SharedPrefData().getToken();
    try {
      Uri url = Uri.parse("$kBaseUrl/api/doc/$id");
      Logger().f(url);
      http.Response response = await http.get(url, headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "token": token!
      });
      Logger().f(response.body);
      if (response.statusCode == 200) {
        Logger().e(response.body);

        var data = jsonDecode(response.body)["data"];
        return data;
      }
    } catch (e) {
      Logger().e(e);
    }
    return null;
  }

  Future deleteDocById({required String id}) async {
    String? token = await SharedPrefData().getToken();
    try {
      Uri url = Uri.parse("$kBaseUrl/api/doc/$id");
      http.Response response = await http.delete(url, headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "token": token!
      });
      Logger().f(response.body);
      if (response.statusCode == 200) {
        Logger().f(response.body);

        var data = jsonDecode(response.body)["data"];
        return data;
      }
    } catch (e) {
      Logger().e(e);
    }
    return null;
  }

  Future createNewDoc() async {
    String? token = await SharedPrefData().getToken();

    Uri url = Uri.parse("$kBaseUrl/api/newDoc");

    http.Response response = await http.post(url, headers: {
      "Content-type": "application/json",
      "Accept": "application/json",
      "token": token!
    });
    if (response.statusCode == 200) {
      Logger().e(response.body);

      final data = jsonDecode(response.body)["data"];
      MySocket().makingChanges(response.body);
      // SocketRepo().makingChanges(response.body);
      return data;
    }
  }

  Future patchDocTitle({
    required String id,
    required String title,
  }) async {
    String? token = await SharedPrefData().getToken();

    Uri url = Uri.parse("$kBaseUrl/api/doc");

    http.Response response = await http.patch(url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          "token": token!
        },
        body: jsonEncode({"id": id, "title": title}));
    if (response.statusCode == 200) {
      Logger().e(response.body);

      final data = jsonDecode(response.body)["data"];

      return data;
    }
  }

  Future patchDocContent({
    required String id,
    required content,
  }) async {
    String? token = await SharedPrefData().getToken();

    Uri url = Uri.parse("$kBaseUrl/api/doc");

    http.Response response = await http.patch(url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          "token": token!
        },
        body: jsonEncode({"id": id, "content": content}));
    Logger().f(response.body);
    if (response.statusCode == 200) {
      Logger().e(response.body);

      final data = jsonDecode(response.body)["data"];

      return data;
    }
  }
}
