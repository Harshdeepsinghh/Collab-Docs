import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/constants/appIcons.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:collabDocs/screens/bottomNav/bottomNav.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SettingsSkeleton extends ConsumerStatefulWidget {
  const SettingsSkeleton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingPannelState();
}

class _SettingPannelState extends ConsumerState<SettingsSkeleton> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BottomNavScreen()));
        ref.read(showNavBar.notifier).update((state) => true);
        return true;
      },
      child: Skeletonizer(
        enabled: true,
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
                                fontWeight: FontWeight.w900, fontSize: 22),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text("Manage Profile"),
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: kGreyColor(),
                          child: Icon(
                            Icons.person,
                            size: 80,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Sanskriti moolchandani",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Iconify(
                            kMailIcon(),
                            size: 15,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Sanskrati@gmail.com",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 60),
                      Row(
                        children: [
                          Iconify(kLockIcon()),
                          SizedBox(width: 20),
                          Text("Change password")
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Iconify(kNightTheme()),
                          SizedBox(width: 20),
                          Text("Night mode"),
                          Spacer(),
                          // Switch(value: false, onChanged: (val) {})
                        ],
                      ),
                      SizedBox(height: 200),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Iconify(kLogOutIcon()),
                          SizedBox(width: 10),
                          Text(
                            "Log Out",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
