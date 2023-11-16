import 'dart:io';

import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/models/userModel.dart';
import 'package:collabDocs/screens/loginScreen/loginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/clients/myScoket.dart';
import 'package:collabDocs/constants/appConsts.dart';
import 'package:collabDocs/models/docsModel.dart';
import 'package:collabDocs/screens/mainDocScreen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String uid;
  const HomeScreen(this.uid, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final String serverUrl = AppApi.kBaseUrl;

  void initState() {
    super.initState();
    MySocket.socket.on("changes", (data) {
      Logger().f("------------->received data : $data");
      setState(() {});
    });
  }

  PackageInfo _packageInfo = PackageInfo();

  Future<void> getPackageData() async {
    _packageInfo = await PackageManager.getPackageInfo();
    setState(() {});

    /// Android
    if (Platform.isAndroid) {
      InAppUpdateManager manager = InAppUpdateManager();
      AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();
      if (appUpdateInfo == null) return;
      if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        //If an in-app update is already running, resume the update.
        String? message =
            await manager.startAnUpdate(type: AppUpdateType.immediate);
        debugPrint(message ?? '');
      } else if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        ///Update available
        if (appUpdateInfo.immediateAllowed) {
          String? message =
              await manager.startAnUpdate(type: AppUpdateType.immediate);
          debugPrint(message ?? '');
        } else if (appUpdateInfo.flexibleAllowed) {
          String? message =
              await manager.startAnUpdate(type: AppUpdateType.flexible);
          debugPrint(message ?? '');
        } else {
          debugPrint(
              'Update available. Immediate & Flexible Update Flow not allow');
        }
      }
    } else if (Platform.isIOS) {
      VersionInfo? _versionInfo = await UpgradeVersion.getiOSStoreVersion(
          packageInfo: _packageInfo, regionCode: "US");
      debugPrint(_versionInfo.toJson().toString());
    }
  }

  int i = 0;
  void refresh() {
    setState(() {
      i++;
    });
  }

  onGoBack(value) {
    refresh();
  }

  ZoomDrawerController zoomDrawerController = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
          flexibleSpace: Row(
            children: [
              IconButton(
                  icon: Icon(CupertinoIcons.settings),
                  onPressed: () {
                    zoomDrawerController.toggle?.call();
                    setState(() {});
                  }),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainDocumnetScreen(
                                documentModel: null,
                                addingNew: true,
                              ))).then((value) => setState(() {
                        onGoBack(value);
                      }));
                },
                child: Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.8, color: kPrimaryColor()),
                  ),
                  child: Row(
                    children: [
                      Text("Add new"),
                      Icon(CupertinoIcons.doc_append),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: ZoomDrawer(
          controller: zoomDrawerController,
          style: DrawerStyle.defaultStyle,
          menuScreen: SettingPannel(),
          mainScreen: Body(),
          borderRadius: 24.0,
          showShadow: true,
          angle: -1.0,
          slideWidth: MediaQuery.of(context).size.width * .85,
          openCurve: Curves.fastOutSlowIn,
          closeCurve: Curves.bounceIn,
        ),
      ),
    ));
  }

  Future<bool> showExitPopup(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Do you want to exit?"),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print('yes selected');
                            SystemNavigator.pop();
                          },
                          child: Text("Yes"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          print('no selected');
                          Navigator.of(context).pop();
                        },
                        child:
                            Text("No", style: TextStyle(color: kWhiteColor())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}

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

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int i = 0;
  void refresh() {
    setState(() {
      i++;
    });
  }

  onGoBack(value) {
    refresh();
  }

  bool showDelIcon = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          FutureBuilder(
            future: AppApi().getAllDocs(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                List<dynamic> docList = snapshot.data;
                return docList.isEmpty
                    ? Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                          ),
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "Click on add new to create a new document",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey, letterSpacing: 2),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: docList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final data = docList[index];
                          return InkWell(
                            onLongPress: () {
                              setState(() {
                                showDelIcon = true;
                              });
                            },
                            onTap: () {
                              DocumentModel documentModel =
                                  DocumentModel.fromMap(docList[index]);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainDocumnetScreen(
                                            addingNew: false,
                                            documentModel: documentModel,
                                          ))).then((value) => onGoBack(value));
                            },
                            child: Card(
                              color: kPrimaryColor(),
                              child: ListTile(
                                title: Text(data["title"]),
                                subtitle: Text(AppConstants.DateFormatter(
                                    data["createdAt"])),
                                trailing: Visibility(
                                  // visible: showDelIcon,
                                  child: IconButton(
                                      onPressed: () async {
                                        // docList.removeWhere((element) =>
                                        //     element["_id"] == data["_id"]);

                                        AppApi()
                                            .deleteDocById(id: data["_id"])
                                            .then((value) => setState(() {}));
                                        MySocket().makingChanges(
                                            "deleting ${data["title"]}");
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: kPrimaryWhiteColor(),
                                      )),
                                ),
                              ),
                            ),
                          );
                        },
                      );
              }
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                  ),
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
