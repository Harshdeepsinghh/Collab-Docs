import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/constants/appIcons.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:collabDocs/screens/bottomNav/bookmarksScreen/bookmarksScreen.dart';
import 'package:collabDocs/screens/bottomNav/homeScreen/homeScreen.dart';
import 'package:collabDocs/screens/bottomNav/requestsScreen/requests.dart';
import 'package:collabDocs/screens/bottomNav/settingsScreen/settingsScreen.dart';
import 'package:collabDocs/screens/mainDocScreen.dart';
import 'package:collabDocs/update/autoUpdate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:logger/logger.dart';

class BottomNavScreen extends ConsumerStatefulWidget {
  const BottomNavScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BottomNavScreenState();
}

class _BottomNavScreenState extends ConsumerState<BottomNavScreen> {
  var _bottomNavIndex = 0;
  List labelAndIcon = [
    {"icon": kDocIcon(), "label": "Docs"},
    {"icon": kBookmarkIcon(), "label": "Bookmark"},
    {"icon": kRequestsIcon(), "label": "Requests"},
    {"icon": kSettingsIcon(), "label": "Settings"},
  ];
  List body = [
    HomeScreen(),
    BookmarksScreen(),
    RequestsScreen(),
    SettingsScreen()
  ];
  int i = 0;
  void refresh() {
    setState(() {
      i++;
    });
  }

  onGoBack(value) {
    refresh();
    updateScreen();
  }

  TextStyle kNormalTextStyle() {
    return TextStyle(color: ref.read(themeProvider) ? kOffWhite() : null);
  }

  @override
  void initState() {
    super.initState();
    playUpdate();
  }

  void playUpdate() {
    AutoUpdate().getPackageData();
    setState(() {});
  }

  String search = '';

  updateScreen() async {
    setState(() {
      ref.read(showSkeleton.notifier).update((state) => true);
    });
    await AppApi().getAllDocs(search: search).then((value) {
      setState(() {});
      ref.read(showSkeleton.notifier).update((state) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, WidgetRef ref, __) {
        return Scaffold(
            body: body[_bottomNavIndex], //destination screen
            floatingActionButton: ref.read(showNavBar)
                ? InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MainDocumentScreen(
                          addingNew: true,
                          documentModel: null,
                        );
                      })).then((value) {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return BottomNavScreen();
                        }));
                      });
                    },
                    child: CircleAvatar(
                      child: Icon(
                        Icons.add,
                        color: ref.read(themeProvider) ? kOffWhite() : null,
                        size: 35,
                      ),
                      radius: 30,
                    ),
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: ref.watch(showNavBar)
                ? AnimatedBottomNavigationBar.builder(
                    backgroundColor: !ref.read(themeProvider)
                        ? kWhiteColor()
                        : kBlackColor(),
                    activeIndex: _bottomNavIndex,
                    gapLocation: GapLocation.center,
                    height: 70,
                    notchSmoothness: NotchSmoothness.sharpEdge,
                    leftCornerRadius: 10,
                    rightCornerRadius: 10,
                    onTap: (index) {
                      setState(() => _bottomNavIndex = index);
                      index == 3
                          ? ref
                              .read(showNavBar.notifier)
                              .update((state) => false)
                          : null;
                    },
                    itemCount: labelAndIcon.length,
                    tabBuilder: (int index, bool isActive) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Iconify(
                            labelAndIcon[index]["icon"],
                            size: 24,
                            color: isActive
                                ? kPrimaryColor()
                                : ref.read(themeProvider)
                                    ? kOffWhite()
                                    : kGreyColor(),
                          ),
                          Text(
                            labelAndIcon[index]["label"],
                            style: TextStyle(
                              color: isActive
                                  ? kPrimaryColor()
                                  : ref.read(themeProvider)
                                      ? kOffWhite()
                                      : kGreyColor(),
                            ),
                          )
                        ],
                      );
                    })
                : null);
      },
    );
  }
}
