import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/constants/appConsts.dart';
import 'package:collabDocs/constants/appIcons.dart';
import 'package:collabDocs/models/userModel.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:collabDocs/screens/bottomNav/bottomNav.dart';
import 'package:collabDocs/screens/loginScreen/loginScreen.dart';
import 'package:collabDocs/screens/skeletons/settingsSkeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingPannelState();
}

class _SettingPannelState extends ConsumerState<SettingsScreen> {
  int i = 0;
  void refresh() {
    setState(() {
      i++;
    });
  }

  onGoBack(value) {
    refresh();
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showOldPasswordField = false;
  bool showNewPasswordsField = false;
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _repeatPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BottomNavScreen()));
        ref.read(showNavBar.notifier).update((state) => true);
        return true;
      },
      child: FutureBuilder(
          future: AppApi().getUser(ref, context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserModel userModel = snapshot.data!;
              return ref.read(showSkeleton)
                  ? SettingsScreen()
                  : Form(
                      key: _formKey,
                      child: Scaffold(
                        body: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          BottomNavScreen()));
                                              ref
                                                  .read(showNavBar.notifier)
                                                  .update((state) => true);
                                            },
                                            icon: Iconify(kBackIcon())),
                                        SizedBox(width: 10),
                                        Text(
                                          "Settings",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 22),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Text("Manage Profile"),
                                    Center(
                                      child: Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 60,
                                            backgroundColor: kGreyColor(),
                                            foregroundImage:
                                                userModel.profilePic != ''
                                                    ? NetworkImage(
                                                        userModel.profilePic)
                                                    : null,
                                            child: Icon(
                                              Icons.person,
                                              size: 80,
                                            ),
                                          ),
                                          Positioned(
                                              bottom: -12,
                                              right: -10,
                                              child: IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder:
                                                          (context) =>
                                                              AlertDialog(
                                                                surfaceTintColor: ref
                                                                        .read(
                                                                            themeProvider)
                                                                    ? kBlackColor()
                                                                    : kWhiteColor(),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            0)),
                                                                title: Text(
                                                                  "Edit Profile Pic",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                content: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        AppConstants.ImagePick(
                                                                            ref,
                                                                            ImageSource.camera,
                                                                            context,
                                                                            onGoBack("update"));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        margin:
                                                                            EdgeInsets.all(8),
                                                                        padding:
                                                                            EdgeInsets.all(8),
                                                                        color: kPrimaryColor()
                                                                            .withAlpha(60),
                                                                        child:
                                                                            Iconify(
                                                                          kCameraIcon(),
                                                                          color: !ref.read(themeProvider)
                                                                              ? kBlackColor()
                                                                              : kWhiteColor(),
                                                                          size:
                                                                              60,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            15),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        await AppConstants.ImagePick(
                                                                            ref,
                                                                            ImageSource.gallery,
                                                                            context,
                                                                            onGoBack("update"));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        margin:
                                                                            EdgeInsets.all(8),
                                                                        padding:
                                                                            EdgeInsets.all(8),
                                                                        color: kPrimaryColor()
                                                                            .withAlpha(60),
                                                                        child:
                                                                            Iconify(
                                                                          kGalleryIcon(),
                                                                          color: !ref.read(themeProvider)
                                                                              ? kBlackColor()
                                                                              : kWhiteColor(),
                                                                          size:
                                                                              60,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                },
                                                icon: Iconify(
                                                  kEditIcon(),
                                                  size: 40,
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Center(
                                      child: Text(
                                        userModel.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Iconify(
                                          kMailIcon(),
                                          size: 15,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          userModel.email,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 60),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showOldPasswordField =
                                              !showOldPasswordField;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Iconify(kLockIcon()),
                                          SizedBox(width: 20),
                                          Text("Change password")
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Visibility(
                                      visible: showOldPasswordField,
                                      child: Center(
                                        child: kRepeatedTextFieldAndHead(
                                            context,
                                            label: "Old password",
                                            controller: _oldPasswordController,
                                            validator: (val) {
                                          if (val!.split("").length < 6) {
                                            return "Please write a valid password";
                                          }
                                          return null;
                                        }, isPassword: false),
                                      ),
                                    ),
                                    Visibility(
                                      visible: showOldPasswordField,
                                      child: Row(
                                        children: [
                                          Spacer(),
                                          InkWell(
                                            onTap: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                setState(() {
                                                  showOldPasswordField = false;
                                                  showNewPasswordsField = true;
                                                });
                                              }
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(5),
                                              color: kPrimaryColor(),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30, vertical: 15),
                                              child: Text(
                                                "Next",
                                                style: TextStyle(
                                                    color: kWhiteColor()),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: showNewPasswordsField,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            kRepeatedTextFieldAndHead(context,
                                                label: "New password",
                                                controller:
                                                    _newPasswordController,
                                                validator: (val) {
                                              if (val!.split("").length < 6) {
                                                return "Please write a valid password";
                                              } else if (val ==
                                                  _oldPasswordController.text) {
                                                return "New password cannot be the same as old password";
                                              }
                                              return null;
                                            }, isPassword: true),
                                            kRepeatedTextFieldAndHead(context,
                                                label: "Repeat new password",
                                                controller:
                                                    _repeatPasswordController,
                                                validator: (val) {
                                              if (val == '') {
                                                return "Please write a valid password";
                                              } else if (val !=
                                                  _newPasswordController.text) {
                                                return "Password does not match";
                                              }
                                              return null;
                                            }, isPassword: false),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: showNewPasswordsField,
                                      child: Row(
                                        children: [
                                          Spacer(),
                                          InkWell(
                                            onTap: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                showNewPasswordsField = false;
                                                showOldPasswordField = false;
                                                ref
                                                    .read(showSkeleton.notifier)
                                                    .update((state) => true);
                                                setState(() {});
                                                await AppApi().changePassword(
                                                    context, ref,
                                                    oldPassword:
                                                        _oldPasswordController
                                                            .text,
                                                    newPassword:
                                                        _newPasswordController
                                                            .text);
                                                ref
                                                    .read(showSkeleton.notifier)
                                                    .update((state) => false);
                                                _oldPasswordController.clear();
                                                _newPasswordController.clear();
                                                setState(() {});
                                              }
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(5),
                                              color: kPrimaryColor(),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30, vertical: 15),
                                              child: Text(
                                                "Confirm",
                                                style: TextStyle(
                                                    color: kWhiteColor()),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Iconify(kNightTheme()),
                                        SizedBox(width: 20),
                                        Text("Night mode"),
                                        Spacer(),
                                        Switch(
                                            value: ref.read(themeProvider),
                                            onChanged: (val) {
                                              setState(() {});
                                              ref.read(newProv);
                                              ref
                                                  .read(themeProvider.notifier)
                                                  .update((state) => val);
                                              SharedTheme().saveTheme(val);
                                            })
                                      ],
                                    ),
                                    SizedBox(height: 200),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              surfaceTintColor:
                                                  ref.read(themeProvider)
                                                      ? kBlackColor()
                                                      : kWhiteColor(),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                              title: Row(
                                                children: [
                                                  Spacer(),
                                                  IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      icon:
                                                          Iconify(kCrossIcon()))
                                                ],
                                              ),
                                              content: Text(
                                                "Are you sure you want to \nLog Out?",
                                                textAlign: TextAlign.center,
                                              ),
                                              actionsAlignment:
                                                  MainAxisAlignment.center,
                                              actions: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    ref
                                                        .read(
                                                            showNavBar.notifier)
                                                        .update(
                                                            (state) => true);
                                                    GoogleSignIn().signOut();
                                                    SharedPrefData()
                                                        .clearToken();
                                                    SharedPrefData().clearUid();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                LoginScreen()));
                                                  },
                                                  child: Container(
                                                    width: 100,
                                                    height: 50,
                                                    color: kPrimaryColor(),
                                                    child: Center(
                                                      child: Text(
                                                        "Yes",
                                                        style: TextStyle(
                                                            color:
                                                                kWhiteColor()),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Iconify(kLogOutIcon()),
                                          SizedBox(width: 10),
                                          Text(
                                            "Log Out",
                                            style: TextStyle(fontSize: 18),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                    );
            }
            return SettingsSkeleton();
          }),
    );

    // ClipRRect(
    //     borderRadius: BorderRadius.circular(20),
    //     child: FutureBuilder(
    //       future: AppApi().getUser(ref, context),
    //       builder: (BuildContext context, AsyncSnapshot snapshot) {
    //         if (snapshot.hasData) {
    //           UserModel userModel = snapshot.data!;
    //           Logger().w(userModel.password);
    //           return Scaffold(
    //             appBar: AppBar(
    //               automaticallyImplyLeading: false,
    //               toolbarHeight: 150,
    //               backgroundColor: kPrimaryColor(),
    //               title: Column(
    //                 children: [
    //                   Center(
    //                     child: Stack(
    //                       children: [
    //                         CircleAvatar(
    //                           backgroundColor: ref.read(themeProvider)
    //                               ? kWhiteColor()
    //                               : kBlackColor(),
    //                           radius: 40,
    //                           child: userModel.profilePic == ""
    //                               ? Icon(CupertinoIcons.person)
    //                               : ClipRRect(
    //                                   borderRadius: BorderRadius.circular(50),
    //                                   child:
    //                                       Image.network(userModel.profilePic)),
    //                         ),
    //                         Positioned(
    //                           right: -12,
    //                           bottom: -10,
    //                           child: IconButton(
    //                               onPressed: () {},
    //                               icon: Icon(
    //                                 CupertinoIcons.pencil_circle_fill,
    //                                 color: !ref.read(themeProvider)
    //                                     ? kWhiteColor()
    //                                     : kBlackColor(),
    //                               )),
    //                         )
    //                       ],
    //                     ),
    //                   ),
    //                   SizedBox(height: 20),
    //                   Text(
    //                     userModel.name,
    //                     overflow: TextOverflow.ellipsis,
    //                     maxLines: 1,
    //                   )
    //                 ],
    //               ),
    //             ),
    //             body: Card(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                 children: [
    //                   Card(
    //                     child: ListTile(
    //                       title: Row(
    //                         children: [
    //                           Icon(CupertinoIcons.mail_solid),
    //                           SizedBox(width: 10),
    //                           Text("Email"),
    //                         ],
    //                       ),
    //                       subtitle: Text(userModel.email),
    //                     ),
    //                   ),
    //                   userModel.password == ''
    //                       ? InkWell(
    //                           onTap: () {
    //                             Navigator.push(context, MaterialPageRoute(
    //                                 builder: (BuildContext context) {
    //                               return SetPasswordScreen();
    //                             }));
    //                           },
    //                           child: Card(
    //                             child: ListTile(
    //                               title: Row(
    //                                 children: [
    //                                   Icon(CupertinoIcons.lock_fill),
    //                                   SizedBox(width: 10),
    //                                   Text("Set Password"),
    //                                 ],
    //                               ),
    //                             ),
    //                           ),
    //                         )
    //                       : InkWell(
    //                           onTap: () {
    //                             Navigator.push(context, MaterialPageRoute(
    //                                 builder: (BuildContext context) {
    //                               return ChangePassWordScreen();
    //                             }));
    //                           },
    //                           child: Card(
    //                             child: ListTile(
    //                               title: Row(
    //                                 children: [
    //                                   Icon(CupertinoIcons.lock_fill),
    //                                   SizedBox(width: 10),
    //                                   Text("Change Password"),
    //                                 ],
    //                               ),
    //                             ),
    //                           ),
    //                         ),
    //                   Card(
    //                     child: ListTile(
    //                       title: Row(
    //                         children: [
    //                           Icon(CupertinoIcons.moon_circle_fill),
    //                           SizedBox(width: 10),
    //                           Text("Night Mode"),
    //                           Spacer(),
    //                           Switch(
    //                               value: ref.read(themeProvider),
    //                               onChanged: (val) {
    //                                 ref.read(newProv);
    //                                 ref
    //                                     .read(themeProvider.notifier)
    //                                     .update((state) => val);
    //                                 SharedTheme().saveTheme(val);
    //                               })
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                   InkWell(
    //                     onTap: () {
    //                       showDialog(
    //                           context: context,
    //                           builder: (context) {
    //                             return AlertDialog(
    //                               content: Container(
    //                                 height: 200,
    //                                 child: Column(
    //                                   mainAxisAlignment:
    //                                       MainAxisAlignment.spaceEvenly,
    //                                   children: [
    //                                     Text(
    //                                       "Are you sure you want to log out?",
    //                                       style: TextStyle(
    //                                           fontWeight: FontWeight.w800,
    //                                           fontSize: 22),
    //                                     ),
    //                                     Row(
    //                                       children: [
    //                                         Spacer(),
    //                                         TextButton(
    //                                             onPressed: () {
    //                                               Navigator.pop(context);
    //                                             },
    //                                             child: Text(
    //                                               "no",
    //                                               style:
    //                                                   TextStyle(fontSize: 18),
    //                                             )),
    //                                         TextButton(
    //                                             onPressed: () {
    //                                               GoogleSignIn().signOut();
    //                                               SharedPrefData().clearToken();
    //                                               SharedPrefData().clearUid();
    //                                               Navigator.push(
    //                                                   context,
    //                                                   MaterialPageRoute(
    //                                                       builder: (context) =>
    //                                                           LoginScreen()));
    //                                             },
    //                                             child: Text(
    //                                               "yes",
    //                                               style:
    //                                                   TextStyle(fontSize: 18),
    //                                             ))
    //                                       ],
    //                                     )
    //                                   ],
    //                                 ),
    //                               ),
    //                             );
    //                           });
    //                     },
    //                     child: Card(
    //                       child: ListTile(
    //                         title: Row(
    //                           children: [
    //                             Icon(Icons.exit_to_app_rounded),
    //                             SizedBox(width: 10),
    //                             Text("Log Out"),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(height: 180),
    //                 ],
    //               ),
    //             ),
    //           );
    //         }
    //         return Center();
    //       },
    //     ));
  }

  Column kRepeatedTextFieldAndHead(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required bool isPassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: ref.read(themeProvider) ? kWhiteColor() : kGreyColor()),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: TextFormField(
            obscureText: isPassword,
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
