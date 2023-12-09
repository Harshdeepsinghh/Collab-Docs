import 'dart:convert';
import 'dart:io';

import 'package:collabDocs/constants/appConsts.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:collabDocs/screens/loginScreen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/clients/myScoket.dart';
import 'package:collabDocs/models/userModel.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

final riverUser = StateProvider((ref) {
  dynamic user = {};
  return user;
});

class AppApi {
  // static String kBaseUrl = "http://192.168.1.4:8777";

  // static String kBaseUrl = "http://122.175.203.223:8777";
  static String kBaseUrl = "https://collab-docs-server.onrender.com";
  static Map<String, String> userHeader = {
    "Content-type": "application/json",
    "Accept": "application/json"
  };

  Future userSignIn(Object? body) async {
    Uri url = Uri.parse("$kBaseUrl/api/signup");
    http.Response response =
        await http.post(url, body: body, headers: userHeader);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    print("something went wrong ${response.statusCode} ${response.body}");
  }

  Future getUser(ref, context) async {
    String? token = await SharedPrefData().getToken();
    Uri url = Uri.parse("$kBaseUrl/api/user");
    try {
      http.Response response = await http.get(url, headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "token": token!
      });
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body)["user"];

        if (userData == null) {
          GoogleSignIn().signOut();
          SharedPrefData().clearToken();
          SharedPrefData().clearUid();

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
        ref.read(riverUser.notifier).update((state) => userData);
        Logger().d(ref.read(riverUser));
        return UserModel.fromJson(jsonEncode(userData)).copyWith(token: token);
      } else {
        SharedPrefData().clearToken();
        GoogleSignIn().signOut();
      }
    } catch (e) {
      Logger().f(e);
    }
    return null;
  }

  Future manageDocRequest(
      {required String decision, required String docId}) async {
    String? token = await SharedPrefData().getToken();

    Uri url = Uri.parse("$kBaseUrl/api/manageRequest");
    http.Response response = await http.post(url,
        body: jsonEncode({
          "decision": decision,
          "docId": docId,
        }),
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          "token": token!
        });
    print(response.body);

    if (response.statusCode == 200) {
      return response.body;
    }
  }

  Future getUsersByIds(context, ids) async {
    Uri url = Uri.parse("$kBaseUrl/api/getUsersByIds");
    try {
      http.Response response = await http.post(url,
          headers: userHeader, body: jsonEncode({"ids": ids}));
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body)["data"];
        if (userData == null) {
          GoogleSignIn().signOut();
          SharedPrefData().clearToken();
          SharedPrefData().clearUid();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
        return userData;
      } else {
        SharedPrefData().clearToken();
        GoogleSignIn().signOut();
      }
    } catch (e) {
      Logger().f(e);
    }
    return null;
  }

  Future getDocsByIds(context, ids) async {
    Uri url = Uri.parse("$kBaseUrl/api/getDocsByIds");
    try {
      http.Response response = await http.post(url,
          headers: userHeader, body: jsonEncode({"ids": ids}));
      Logger().i(response.body);
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body)["data"];
        Logger().i(userData);
        if (userData == null) {
          GoogleSignIn().signOut();
          SharedPrefData().clearToken();
          SharedPrefData().clearUid();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
        return userData;
      } else {
        SharedPrefData().clearToken();
        GoogleSignIn().signOut();
      }
    } catch (e) {
      Logger().f(e);
    }
    return null;
  }

  Future userLoginManually(Object body, context) async {
    Uri url = Uri.parse("$kBaseUrl/api/loginmanually");
    try {
      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: userHeader);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            AppConstants.kSnackbarMsg(msg: jsonDecode(response.body)["msg"]));
      }
    } catch (e) {
      Logger().f(e);
    }
  }

  Future changePassword(context, ref,
      {required String oldPassword, required String newPassword}) async {
    String? token = await SharedPrefData().getToken();

    Uri url = Uri.parse("$kBaseUrl/api/passUpdate");
    try {
      http.Response response = await http.patch(url,
          body: jsonEncode(
              {"oldPassword": oldPassword, "newPassword": newPassword}),
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            "token": token!
          });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
            AppConstants.kSnackbarMsg(msg: jsonDecode(response.body)["msg"]));
        return data;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            AppConstants.kSnackbarMsg(msg: jsonDecode(response.body)["msg"]));
      }
    } catch (e) {
      Logger().f(e);
    }
  }

  Future updateView({required String docId, required String uid}) async {
    try {
      Uri url = Uri.parse("$kBaseUrl/api/doc/viewing");
      http.Response response = await http.patch(url,
          headers: userHeader, body: jsonEncode({"uid": uid, "docId": docId}));
      Logger().e(response.body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data;
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  Future getAllDocs({required String search}) async {
    String? token = await SharedPrefData().getToken();
    try {
      Uri url = Uri.parse("$kBaseUrl/api/allDocs");
      http.Response response =
          await http.post(url, body: jsonEncode({"search": search}), headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "token": token!
      });
      Logger().w("all docs called");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)["data"];
        return data;
      }
    } catch (e) {
      Logger().e(e);
    }
    return null;
  }

  Future getRequestPendingDocs() async {
    String? token = await SharedPrefData().getToken();

    try {
      Uri url = Uri.parse("$kBaseUrl/api/requestsPending");
      http.Response response = await http.get(url, headers: {
        "Content-type": "application/json",
        "Accept": "application/json",
        "token": token!
      });
      Logger().f(response.body);
      if (response.statusCode == 200) {
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

  Future deleteDocsArray(context, {required List<String> docIds}) async {
    String? token = await SharedPrefData().getToken();

    try {
      Uri url = Uri.parse("$kBaseUrl/api/doc/deletePermanantly");
      http.Response response = await http.post(url,
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            "token": token!
          },
          body: jsonEncode({"docIds": docIds}));
      var data = jsonDecode(response.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(AppConstants.kSnackbarMsg(msg: data["msg"]));
    } catch (e) {
      Logger().e(e);
    }

    return null;
  }

  Future shareDocsArray(context,
      {required List<String> docIds, required String email}) async {
    String? token = await SharedPrefData().getToken();

    try {
      Uri url = Uri.parse("$kBaseUrl/api/doc/shareMultiDocs");
      http.Response response = await http.post(url,
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            "token": token!
          },
          body: jsonEncode({"docIds": docIds, "email": email}));
      var data = jsonDecode(response.body);
      MySocket().makingChanges(response.body);

      ScaffoldMessenger.of(context)
          .showSnackBar(AppConstants.kSnackbarMsg(msg: data["msg"]));
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
    Logger().e(response.body);
    if (response.statusCode == 200) {
      Logger().e(response.body);

      final data = jsonDecode(response.body)["data"];
      MySocket().makingChanges(response.body);
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

  Future shareDocumentRequest(context,
      {required String email, required String docId}) async {
    Uri url = Uri.parse("$kBaseUrl/api/doc/share/$docId");
    try {
      http.Response response = await http.post(
        url,
        body: jsonEncode({"email": email}),
        headers: userHeader,
      );
      ScaffoldMessenger.of(context).showSnackBar(
          AppConstants.kSnackbarMsg(msg: jsonDecode(response.body)["msg"]));
      if (response.statusCode == 200) {
        Logger().e(response.body);
        final data = jsonDecode(response.body);

        return data;
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  Future getBookmarks() async {
    String? token = await SharedPrefData().getToken();

    Uri url = Uri.parse("$kBaseUrl/api/getBookmarkedDocs");
    try {
      http.Response response = await http.get(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          "token": token!
        },
      );
      if (response.statusCode == 200) {
        Logger().e(response.body);
        final data = jsonDecode(response.body)["data"];
        return data;
      }
    } catch (e) {}
  }

  Future manageBookmark(context, {required String docId}) async {
    Uri url = Uri.parse("$kBaseUrl/api/managebookmark");

    String? token = await SharedPrefData().getToken();
    try {
      http.Response response = await http.post(url,
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            "token": token!
          },
          body: jsonEncode({"docId": docId}));
      if (response.statusCode == 200) {
        MySocket.socket.emit("makingChanges", "bookmarks");
        Logger().e(response.body);
        final data = jsonDecode(response.body);

        return data;
      }
      ScaffoldMessenger.of(context).showSnackBar(
          AppConstants.kSnackbarMsg(msg: jsonDecode(response.body)["msg"]));
    } catch (e) {}
  }

  Future uploadImage(ref,
      {required File imageFile, required BuildContext context}) async {
    String? id = await SharedPrefData().getUid();
    String url = '$kBaseUrl/api/profileUpload/$id';
    Logger().f(url);
    var request = http.MultipartRequest('POST', Uri.parse(url));
    var stream = http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();
    var multipartFile = http.MultipartFile(
      'profile',
      stream,
      length,
      filename: basename(imageFile.path),
      contentType:
          MediaType('image', 'jpeg'), // Change the content type accordingly
    );

    request.files.add(multipartFile);
    var response = await request.send();
    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = await http.Response.fromStream(response)
            .then((value) => json.decode(value.body));
        String imageUrl = data['data']['profilePic'];
        Navigator.pop(context);
        return imageUrl;
      } else {
        print('Error uploading image: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }
}
