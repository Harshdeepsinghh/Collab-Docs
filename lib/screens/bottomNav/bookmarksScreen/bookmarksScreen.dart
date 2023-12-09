import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/constants/appConsts.dart';
import 'package:collabDocs/constants/appIcons.dart';
import 'package:collabDocs/models/docsModel.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:collabDocs/screens/mainDocScreen.dart';
import 'package:collabDocs/screens/skeletons/CommonSkeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:intl/intl.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
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

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  TextEditingController _shareEmailController = TextEditingController();
  bool showDelIcon = false;
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
                    " Bookmarks",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                  ),
                  Spacer(),
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
          future: AppApi().getBookmarks(),
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
                            "No saved bookmarks",
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
                        return InkWell(
                          onTap: () {
                            DocumentModel documentModel =
                                DocumentModel.fromMap(docList[index]);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainDocumentScreen(
                                          addingNew: false,
                                          documentModel: documentModel,
                                        ))).then((value) => onGoBack(value));
                          },
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                color: ref.read(themeProvider)
                                    ? kBlackColor()
                                    : kWhiteColor(),
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
                                  subtitleTextStyle:
                                      TextStyle(color: kGreyColor()),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  final membersData =
                                                      membersSnap
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
                                                AppConstants.DateFormatter(
                                                    data["updatedAt"]),
                                                style: kNormalTextStyle(),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          GestureDetector(
                                              onTap: () {
                                                kShareDoc(context, data);
                                              },
                                              child: Iconify(
                                                kShareIcon(),
                                                color: ref.read(themeProvider)
                                                    ? kOffWhite()
                                                    : null,
                                                size: 18,
                                              ))
                                          // Icon(CupertinoIcons.info)
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Owner: ",
                                            style: kNormalTextStyle(),
                                          ),
                                          Text(
                                            toBeginningOfSentenceCase(
                                                data["owner"])!,
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
                                  child: InkWell(
                                    onTap: () async {
                                      ref
                                          .read(showSkeleton.notifier)
                                          .update((state) => true);
                                      setState(() {});
                                      await AppApi().manageBookmark(context,
                                          docId: data["_id"]);
                                      ref
                                          .read(showSkeleton.notifier)
                                          .update((state) => false);
                                      setState(() {});
                                    },
                                    child: Image.asset(
                                        "assets/images/bookmarked.png"),
                                  )),
                            ],
                          ),
                        );
                      },
                    );
            }
            return CommonSkeleton();
          })
    ]);
  }

  Future<dynamic> kShareDoc(BuildContext context, data) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          surfaceTintColor: kWhiteColor(),
          backgroundColor: kWhiteColor(),
          title: Text("Share Document"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          content: Container(
            color: kWhiteColor(),
            child: kTextField(
              controller: _shareEmailController,
              validator: (val) {
                if (AppConstants.kIsEmail(val!) == false) {
                  return "Invalid email";
                }
                return null;
              },
              hint: "Email id",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                AppApi()
                    .shareDocumentRequest(
                        email: _shareEmailController.text,
                        context,
                        docId: data['_id'])
                    .then((value) => Navigator.pop(context, 'OK'));
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    ).then((value) => _shareEmailController.clear());
  }

  TextStyle kNormalTextStyle() {
    return TextStyle(color: ref.read(themeProvider) ? kOffWhite() : null);
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
