import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/models/userModel.dart';
import 'package:collabDocs/screens/loginScreen/loginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingPannel extends ConsumerStatefulWidget {
  const SettingPannel({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingPannelState();
}

class _SettingPannelState extends ConsumerState<SettingPannel> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FutureBuilder<UserModel?>(
          future: AppApi().getUser(ref),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              UserModel userModel = snapshot.data!;
              return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 140,
                  backgroundColor: kPrimaryColor(),
                  title: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        userModel.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )
                    ],
                  ),
                ),
                body: Card(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Card(
                          child: ListTile(
                            title: Text("Email"),
                            subtitle: Text(userModel.email),
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                            ),
                            Container(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "More features are comming soon",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey, letterSpacing: 2),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        kLogoutButton(context),
                      ],
                    ),
                  ),
                ),
              );
            }
            return CircularProgressIndicator();
          },
        ));
  }

  Padding kLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Container(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Are you sure you want to log out?",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 22),
                        ),
                        Row(
                          children: [
                            Spacer(),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "no",
                                  style: TextStyle(fontSize: 18),
                                )),
                            TextButton(
                                onPressed: () {
                                  GoogleSignIn().signOut();
                                  SharedPrefData().clearToken();
                                  SharedPrefData().clearUid();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()));
                                },
                                child: Text(
                                  "yes",
                                  style: TextStyle(fontSize: 18),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                );
              });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
            ),
            IconButton(
                onPressed: () async {},
                icon: Icon(
                  Icons.logout,
                  color: Colors.red,
                )),
          ],
        ),
      ),
    );
  }
}
