import 'dart:io';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/screens/homeScreen/homeBody.dart';
import 'package:collabDocs/screens/homeScreen/settingsPannel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:logger/logger.dart';
import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/clients/myScoket.dart';
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
      checkUpdate();
      setState(() {});
    });
  }

  PackageInfo _packageInfo = PackageInfo();

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
          mainScreen: HomeBody(),
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

  Future<void> checkUpdate() async {
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
