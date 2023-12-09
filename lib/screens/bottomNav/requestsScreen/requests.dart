import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/clients/myScoket.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:collabDocs/screens/skeletons/CommonSkeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
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
  @override
  void initState() {
    super.initState();
    MySocket.socket.on("changes", (data) async {
      Logger().f("------------->received data : $data");
      await AppApi().getRequestPendingDocs();
      setState(() {});
    });
  }

  TextStyle kNormalTextStyle() {
    return TextStyle(color: ref.read(themeProvider) ? kOffWhite() : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Requests Pending",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                  ),
                  Spacer(),
                  // Container(
                  //     padding: EdgeInsets.all(3),
                  //     decoration: BoxDecoration(
                  //         color: kWhiteColor(),
                  //         border: Border.all(color: kGreyColor(), width: 0.5)),
                  //     child: Icon(
                  //       Icons.search,
                  //       color: kGreyColor(),
                  //     ))
                ],
              ),
            ),
          ),
        ),
        body: ref.read(showSkeleton)
            ? CommonSkeleton()
            : SingleChildScrollView(child: kMyDocuments()));
  }

  Column kMyDocuments() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FutureBuilder(
          future: AppApi().getRequestPendingDocs(),
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
                            "No pending requests",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.grey, letterSpacing: 2),
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
                        return Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              color: ref.read(themeProvider)
                                  ? kBlackColor()
                                  : kWhiteColor(),
                              child: ListTile(
                                title: Text(data["title"]),
                                subtitleTextStyle:
                                    TextStyle(color: kGreyColor()),
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
                                          future: AppApi().getUsersByIds(
                                              context, data["sharedTo"]),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<dynamic>
                                                  membersSnap) {
                                            if (membersSnap.hasData) {
                                              return Row(
                                                  children: List.generate(
                                                      data["sharedTo"].length,
                                                      (membersIndex) {
                                                final membersData = membersSnap
                                                    .data[membersIndex];
                                                return CircleAvatar(
                                                  backgroundColor:
                                                      ref.read(themeProvider)
                                                          ? kOffWhite()
                                                          : kBlackColor(),
                                                  radius: 10,
                                                  foregroundImage: membersData[
                                                              "profilePic"] !=
                                                          ''
                                                      ? NetworkImage(
                                                          membersData[
                                                              "profilePic"])
                                                      : null,
                                                  child: Text(
                                                    membersData["name"]
                                                        .split("")[0]
                                                        .toUpperCase(),
                                                  ),
                                                );
                                              }));
                                            }
                                            return SizedBox(height: 0);
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Requested By: ",
                                          style: kNormalTextStyle(),
                                        ),
                                        Text(
                                          toBeginningOfSentenceCase(
                                              data["owner"])!,
                                          style: kNormalTextStyle(),
                                        )
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Text("Requested on: "),
                                    //     Text(toBeginningOfSentenceCase('')!)
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                                top: 10,
                                right: 20,
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        ref
                                            .read(showSkeleton.notifier)
                                            .update((state) => true);
                                        setState(() {});
                                        AppApi()
                                            .manageDocRequest(
                                                decision: "decline",
                                                docId: data["_id"])
                                            .then((value) {
                                          ref
                                              .read(showSkeleton.notifier)
                                              .update((state) => false);

                                          onGoBack(value);
                                        });
                                      },
                                      child: Image.asset(
                                          "assets/images/declineIcon.png"),
                                    ),
                                    SizedBox(width: 10),
                                    InkWell(
                                        onTap: () async {
                                          ref
                                              .read(showSkeleton.notifier)
                                              .update((state) => true);
                                          setState(() {});
                                          AppApi()
                                              .manageDocRequest(
                                                  decision: "accept",
                                                  docId: data["_id"])
                                              .then((value) {
                                            ref
                                                .read(showSkeleton.notifier)
                                                .update((state) => false);
                                            onGoBack(value);
                                          });
                                        },
                                        child: Image.asset(
                                            "assets/images/acceptIcon.png"))
                                  ],
                                ))
                          ],
                        );
                      },
                    );
            }
            return CommonSkeleton();
          })
    ]);
  }
}
