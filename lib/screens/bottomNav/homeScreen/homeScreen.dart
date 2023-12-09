import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/clients/myScoket.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/constants/appConsts.dart';
import 'package:collabDocs/constants/appIcons.dart';
import 'package:collabDocs/models/docsModel.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:collabDocs/screens/mainDocScreen.dart';
import 'package:collabDocs/screens/skeletons/CommonSkeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int i = 0;
  void refresh() {
    setState(() {
      i++;
    });
  }

  onGoBack(value) {
    refresh();
  }

  String uid = '';
  getUserId() async {
    uid = await SharedPrefData().getUid() ?? '';
    setState(() {});
  }

  List<String> selectedDocsId = [];
  bool isSelecting = false;
  @override
  void initState() {
    super.initState();
    MySocket.socket.on("changes", (data) {
      Logger().f("------------->received data : $data");
      setState(() {});
    });
    getUserId();
  }

  void selectingAfterActions() {
    isSelecting = false;
    setState(() {});
    ref.read(showNavBar.notifier).update((state) => true);
    selectedDocsId.clear();
    _shareEmailController.clear();
  }

  bool isSearching = false;
  TextEditingController _shareEmailController = TextEditingController();
  bool showDelIcon = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isSelecting ? false : true,
      onPopInvoked: (didPop) {
        if (isSelecting) {
          selectingAfterActions();
        }
      },
      child: Scaffold(
          bottomSheet: isSelecting ? kBottomSheet(context) : null,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: !isSearching,
                      child: Text(
                        "All Documents",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 22),
                      ),
                    ),
                    Visibility(
                        visible: isSearching,
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: TextFormField(
                              onChanged: (value) => setState(() {
                                search = value;
                              }),
                              decoration: InputDecoration(
                                hintText: 'Search',
                              ),
                            ))),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isSearching = !isSearching;
                          search = '';
                        });
                      },
                      child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: !ref.read(themeProvider)
                                  ? kWhiteColor()
                                  : kBlackColor(),
                              border:
                                  Border.all(color: kGreyColor(), width: 0.5)),
                          child: Visibility(
                            visible: !isSearching,
                            replacement: Icon(
                              Icons.cancel_outlined,
                              color: ref.read(themeProvider)
                                  ? kWhiteColor()
                                  : kGreyColor(),
                            ),
                            child: Icon(
                              Icons.search,
                              color: ref.read(themeProvider)
                                  ? kWhiteColor()
                                  : kGreyColor(),
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
          body: ref.read(showSkeleton)
              ? CommonSkeleton()
              : SingleChildScrollView(
                  physics: BouncingScrollPhysics(), child: kMyDocuments())),
    );
  }

  Container kBottomSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
          color: !ref.read(themeProvider) ? kWhiteColor() : kBlackColor(),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("${selectedDocsId.length.toString()} Selected"),
              Spacer(),
              IconButton(
                  onPressed: () {
                    selectingAfterActions();
                  },
                  icon: Iconify(kCrossIcon()))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  selectedDocsId.length == 0
                      ? null
                      : showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              surfaceTintColor: ref.read(themeProvider)
                                  ? kBlackColor()
                                  : kWhiteColor(),
                              backgroundColor: ref.read(themeProvider)
                                  ? kBlackColor()
                                  : kWhiteColor(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    "Share To",
                                    textAlign: TextAlign.center,
                                  ),
                                  Spacer(),
                                  IconButton(
                                      onPressed: () {
                                        selectingAfterActions();
                                        Navigator.pop(context);
                                      },
                                      icon: Iconify(
                                        kCrossIcon(),
                                        color: ref.read(themeProvider)
                                            ? kOffWhite()
                                            : null,
                                      ))
                                ],
                              ),
                              content: Container(
                                height: 60,
                                child: Column(
                                  children: [
                                    Container(
                                      color: ref.read(themeProvider)
                                          ? kBlackColor()
                                          : kWhiteColor(),
                                      child: kTextField(
                                        controller: _shareEmailController,
                                        validator: (val) {
                                          return null;
                                        },
                                        hint: "Email id",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                GestureDetector(
                                  onTap: () async {
                                    ref
                                        .read(showSkeleton.notifier)
                                        .update((state) => true);
                                    setState(() {});
                                    AppApi()
                                        .shareDocsArray(context,
                                            email: _shareEmailController.text,
                                            docIds: selectedDocsId)
                                        .then((value) {
                                      selectingAfterActions();
                                      Navigator.pop(context);
                                      ref
                                          .read(showSkeleton.notifier)
                                          .update((state) => false);
                                      onGoBack(value);
                                    });
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 50,
                                    color: kPrimaryColor(),
                                    child: Center(
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(color: kWhiteColor()),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        );
                },
                child: Column(
                  children: [
                    Iconify(
                      kShareIcon(),
                      color: ref.read(themeProvider) ? kOffWhite() : null,
                    ),
                    Text(
                      "Share",
                      style: kNormalTextStyle(),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  selectedDocsId.length == 0 ? null : kDelDocument(context);
                },
                child: Column(
                  children: [
                    Iconify(kDeleteIcon()),
                    Text(
                      "Delete doc",
                      style: TextStyle(color: kRedColor()),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future updateScreen() async {
    ref.read(showSkeleton.notifier).update((state) => true);
    setState(() {});
    await AppApi().getAllDocs(search: search);
    setState(() {});
    ref.read(showSkeleton.notifier).update((state) => false);
  }

  Future<dynamic> kDelDocument(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor:
              ref.read(themeProvider) ? kBlackColor() : kWhiteColor(),
          backgroundColor:
              ref.read(themeProvider) ? kBlackColor() : kWhiteColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          title: Row(
            children: [
              Spacer(),
              IconButton(
                  onPressed: () {
                    selectingAfterActions();
                    Navigator.pop(context);
                  },
                  icon: Iconify(
                    kCrossIcon(),
                    color: ref.read(themeProvider) ? kOffWhite() : null,
                  ))
            ],
          ),
          content: Text(
            "Are you sure you want delete this doc \npermanently?",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            GestureDetector(
              onTap: () async {
                ref.read(showSkeleton.notifier).update((state) => true);
                setState(() {});
                AppApi()
                    .deleteDocsArray(context, docIds: selectedDocsId)
                    .then((value) {
                  selectingAfterActions();
                  Navigator.pop(context);
                  ref.read(showSkeleton.notifier).update((state) => false);
                  onGoBack(value);
                });
              },
              child: Container(
                width: 100,
                height: 50,
                color: kPrimaryColor(),
                child: Center(
                  child: Text(
                    "Yes",
                    style: TextStyle(color: kWhiteColor()),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  String search = '';
  Column kMyDocuments() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FutureBuilder(
          future: AppApi().getAllDocs(search: search),
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
                            "Click on add Icon to create a new document",
                            style:
                                TextStyle(color: Colors.grey, letterSpacing: 2),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: docList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final data = docList[index];
                        return InkWell(
                          onLongPress: () {
                            ref
                                .read(showNavBar.notifier)
                                .update((state) => false);
                            setState(() {
                              isSelecting = true;
                            });
                          },
                          onTap: isSelecting
                              ? () {}
                              : () {
                                  DocumentModel documentModel =
                                      DocumentModel.fromMap(docList[index]);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MainDocumentScreen(
                                                addingNew: false,
                                                documentModel: documentModel,
                                              ))).then((value) {
                                    updateScreen();
                                  });
                                },
                          child: isSelecting
                              ? kSelectingDocumentCard(data, context)
                              : kDocumentCard(data, context),
                        );
                      },
                    );
            }
            return CommonSkeleton();
          })
    ]);
  }

  dynamic membersSavedData = {};
  Stack kDocumentCard(data, BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          color: !ref.read(themeProvider) ? kWhiteColor() : kBlackColor(),
          child: ListTile(
            title: Row(
              children: [
                Container(
                    width: 220,
                    child: Text(
                      data["title"],
                      overflow: TextOverflow.ellipsis,
                    )),
                Spacer(),
              ],
            ),
            subtitleTextStyle: TextStyle(color: kGreyColor()),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Members:",
                      style: kNormalTextStyle(),
                    ),
                    FutureBuilder(
                      future: AppApi().getUsersByIds(context, data["sharedTo"]),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> membersSnap) {
                        if (membersSnap.hasData) {
                          membersSavedData = membersSnap.data;
                          return Row(
                              children: List.generate(data["sharedTo"].length,
                                  (membersIndex) {
                            final membersData = membersSnap.data[membersIndex];
                            return CircleAvatar(
                              backgroundColor: ref.read(themeProvider)
                                  ? kOffWhite()
                                  : kBlackColor(),
                              radius: 10,
                              foregroundImage: membersData["profilePic"] != ''
                                  ? NetworkImage(membersData["profilePic"])
                                  : null,
                              child: Text(membersData["name"]
                                  .split("")[0]
                                  .toUpperCase()),
                            );
                          }));
                        }
                        return Center();
                      },
                    )
                  ],
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          "last edited: ",
                          style: kNormalTextStyle(),
                        ),
                        Text(
                          AppConstants.DateFormatter(data["updatedAt"]),
                          style: kNormalTextStyle(),
                        ),
                      ],
                    ),
                    Spacer(),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Owner: ",
                      style: kNormalTextStyle(),
                    ),
                    Text(
                      toBeginningOfSentenceCase(data["owner"])!,
                      style: kNormalTextStyle(),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
            top: 15,
            right: 30,
            child: StatefulBuilder(
              builder: (BuildContext context, setState) {
                return InkWell(
                  onTap: () async {
                    setState(() {
                      data["bookmarks"].contains(uid)
                          ? data["bookmarks"].remove(uid)
                          : data["bookmarks"].add(uid);
                    });
                    AppApi().manageBookmark(context, docId: data["_id"]);
                  },
                  child: data["bookmarks"].contains(uid)
                      ? Image.asset("assets/images/bookmarked.png")
                      : Image.asset("assets/images/notbookmarked.png"),
                );
              },
            )),
      ],
    );
  }

  TextStyle kNormalTextStyle() {
    return TextStyle(color: ref.read(themeProvider) ? kOffWhite() : null);
  }

  kSelectingDocumentCard(data, BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () {
                  selectedDocsId.contains(data["_id"])
                      ? selectedDocsId.remove(data["_id"])
                      : selectedDocsId.add(data["_id"]);
                  setState(() {});
                },
                icon: selectedDocsId.contains(data["_id"])
                    ? Iconify(
                        kCheckedIcon(),
                        color: kPrimaryColor(),
                      )
                    : Iconify(
                        kUncheckedIcon(),
                        color: kPrimaryColor(),
                      )),
            Container(
              width: MediaQuery.of(context).size.width * 0.82,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: ref.read(themeProvider) ? kBlackColor() : kWhiteColor(),
              child: ListTile(
                title: Row(
                  children: [
                    Container(
                        width: 220,
                        child: Text(
                          data["title"],
                          style: kNormalTextStyle(),
                          overflow: TextOverflow.ellipsis,
                        )),
                    Spacer(),
                  ],
                ),
                subtitleTextStyle: TextStyle(color: kGreyColor()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Members:",
                          style: kNormalTextStyle(),
                        ),
                        FutureBuilder(
                          future:
                              AppApi().getUsersByIds(context, data["sharedTo"]),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> membersSnap) {
                            if (membersSnap.hasData) {
                              membersSavedData = membersSnap.data;
                              return Row(
                                  children: List.generate(
                                      data["sharedTo"].length, (membersIndex) {
                                final membersData =
                                    membersSnap.data[membersIndex];
                                return CircleAvatar(
                                  backgroundColor: ref.read(themeProvider)
                                      ? kWhiteColor()
                                      : kBlackColor(),
                                  radius: 10,
                                  foregroundImage: membersData["profilePic"] !=
                                          ''
                                      ? NetworkImage(membersData["profilePic"])
                                      : null,
                                  child: Text(membersData["name"]
                                      .split("")[0]
                                      .toUpperCase()),
                                );
                              }));
                            }
                            return SizedBox(height: 0);
                          },
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              "last edited: ",
                              style: kNormalTextStyle(),
                            ),
                            Text(
                              AppConstants.DateFormatter(data["updatedAt"]),
                              style: kNormalTextStyle(),
                            ),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Owner: ",
                          style: kNormalTextStyle(),
                        ),
                        Text(
                          toBeginningOfSentenceCase(data["owner"])!,
                          style: kNormalTextStyle(),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
            top: 15,
            right: 30,
            child: StatefulBuilder(
              builder: (BuildContext context, setState) {
                return InkWell(
                  onTap: () async {
                    setState(() {
                      data["bookmarks"].contains(uid)
                          ? data["bookmarks"].remove(uid)
                          : data["bookmarks"].add(uid);
                    });
                    AppApi().manageBookmark(context, docId: data["_id"]);
                  },
                  child: data["bookmarks"].contains(uid)
                      ? Image.asset("assets/images/bookmarked.png")
                      : Image.asset("assets/images/notbookmarked.png"),
                );
              },
            )),
      ],
    );
  }

  kTextField(
          {required TextEditingController controller,
          required String? Function(String?)? validator,
          required String hint}) =>
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.all(10),
            isDense: true,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: kGreyColor(), width: 0.5)),
          ),
        ),
      );
}
