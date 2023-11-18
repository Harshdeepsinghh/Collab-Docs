import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/models/userModel.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:collabDocs/screens/password/changePassScreen.dart';
import 'package:collabDocs/screens/loginScreen/loginScreen.dart';
import 'package:collabDocs/screens/password/setPassword.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class SettingPannel extends ConsumerStatefulWidget {
  const SettingPannel({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingPannelState();
}

class _SettingPannelState extends ConsumerState<SettingPannel> {
  @override
  Widget build(BuildContext context) {
    // MyProvider provider = context.read<MyProvider>();
    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FutureBuilder(
          future: AppApi().getUser(ref),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              UserModel userModel = snapshot.data!;
              Logger().w(userModel.password);
              return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 150,
                  backgroundColor: kPrimaryColor(),
                  title: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: ref.read(themeProvider)
                                  ? kWhiteColor()
                                  : kBlackColor(),
                              radius: 40,
                              child: userModel.profilePic == ""
                                  ? Icon(CupertinoIcons.person)
                                  : Image.network(userModel.profilePic),
                            ),
                            Positioned(
                              right: -12,
                              bottom: -10,
                              child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    CupertinoIcons.pencil_circle_fill,
                                    color: !ref.read(themeProvider)
                                        ? kWhiteColor()
                                        : kBlackColor(),
                                  )),
                            )
                          ],
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(
                        child: ListTile(
                          title: Row(
                            children: [
                              Icon(CupertinoIcons.mail_solid),
                              SizedBox(width: 10),
                              Text("Email"),
                            ],
                          ),
                          subtitle: Text(userModel.email),
                        ),
                      ),
                      userModel.password == ''
                          ? InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return SetPasswordScreen();
                                }));
                              },
                              child: Card(
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Icon(CupertinoIcons.lock_fill),
                                      SizedBox(width: 10),
                                      Text("Set Password"),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return ChangePassWordScreen();
                                }));
                              },
                              child: Card(
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Icon(CupertinoIcons.lock_fill),
                                      SizedBox(width: 10),
                                      Text("Change Password"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      Card(
                        child: ListTile(
                          title: Row(
                            children: [
                              Icon(CupertinoIcons.moon_circle_fill),
                              SizedBox(width: 10),
                              Text("Night Mode"),
                              Spacer(),
                              Switch(
                                  value: ref.read(themeProvider),
                                  onChanged: (val) {
                                    ref.read(newProv);
                                    ref
                                        .read(themeProvider.notifier)
                                        .update((state) => val);
                                    SharedTheme().saveTheme(val);
                                  })
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Container(
                                    height: 200,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Are you sure you want to log out?",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 22),
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
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                )),
                                            TextButton(
                                                onPressed: () {
                                                  GoogleSignIn().signOut();
                                                  SharedPrefData().clearToken();
                                                  SharedPrefData().clearUid();
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              LoginScreen()));
                                                },
                                                child: Text(
                                                  "yes",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Card(
                          child: ListTile(
                            title: Row(
                              children: [
                                Icon(Icons.exit_to_app_rounded),
                                SizedBox(width: 10),
                                Text("Log Out"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 180),
                    ],
                  ),
                ),
              );
            }
            return Center();
          },
        ));
  }
}
