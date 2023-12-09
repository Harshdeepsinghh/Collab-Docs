import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/constants/appConsts.dart';
import 'package:collabDocs/constants/appIcons.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:logger/logger.dart';
import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/clients/myScoket.dart';
import 'package:collabDocs/models/docsModel.dart';

class MainDocumentScreen extends ConsumerStatefulWidget {
  final DocumentModel? documentModel;
  final bool addingNew;
  const MainDocumentScreen(
      {this.documentModel, required this.addingNew, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MainDocumentScreenState();
}

class _MainDocumentScreenState extends ConsumerState<MainDocumentScreen>
    with WidgetsBindingObserver {
  late DocumentModel documentModel;
  late DocumentModel _model;
  bool isLoading = true;
  setDocData() async {
    widget.addingNew
        ? await AppApi().createNewDoc().then((value) {
            documentModel = DocumentModel.fromMap(value);
          })
        : null;
    _model =
        widget.documentModel == null ? documentModel : widget.documentModel!;
    setState(() {
      isLoading = false;
    });
    widget.addingNew
        ? AppApi().updateView(docId: _model.docId, uid: _model.uid)
        : AppApi().updateView(
            docId: widget.documentModel!.docId, uid: widget.documentModel!.uid);
  }

  @override
  void initState() {
    super.initState();
    setDocData();
    MySocket.socket.on("changes", (data) {
      Logger().f("------------->received data : $data");
      setState(() {});
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    widget.addingNew
        ? AppApi().updateView(docId: _model.docId, uid: _model.uid)
        : AppApi().updateView(
            docId: widget.documentModel!.docId, uid: widget.documentModel!.uid);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      AppApi().updateView(
          docId: widget.documentModel!.docId, uid: widget.documentModel!.uid);
    }
  }

  QuillController? _quillController;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: AppApi().getDocById(id: _model.docId),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  _controller.text = snapshot.data["title"];
                  _quillController = QuillController(
                      document: snapshot.data["content"].isEmpty
                          ? Document()
                          : Document.fromDelta(
                              Delta.fromJson(snapshot.data["content"])),
                      selection: TextSelection.collapsed(offset: 0));

                  _quillController!.document.changes.listen((event) async {
                    var json = _quillController!.document.toDelta();

                    await AppApi().patchDocContent(
                        id: snapshot.data["_id"], content: json);
                    MySocket().makingChanges("editing doc");

                    // if (event.source == ChangeSource.local) {
                    //   Map<String, dynamic> map = {"delta": event};
                    //   MySocket().makingChanges(map);
                    // }
                  });
                  return Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      flexibleSpace: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.navigate_before)),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: TextFormField(
                              controller: _controller,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10)),
                              onChanged: (value) async {
                                await AppApi().patchDocTitle(
                                  id: _model.docId,
                                  title: value,
                                );
                                MySocket()
                                    .makingChanges("changing doc name: $value");
                              },
                            ),
                          ),
                          Spacer(),
                          PopupMenuButton(
                            surfaceTintColor: ref.read(themeProvider)
                                ? kBlackColor()
                                : kWhiteColor(),
                            icon: Iconify(kMoreOptionsIcon()),
                            itemBuilder: (BuildContext context) {
                              return [
                                kPopupItems(
                                    iconColor: kRedColor(),
                                    label: 'Delete',
                                    onTap: () {
                                      kDelDocument(context, snapshot.data).then(
                                          (value) => Navigator.pop(context));
                                    },
                                    icon: kDeleteIcon()),
                                kPopupItems(
                                    label: 'Share',
                                    onTap: () {
                                      kShareDoc(context, snapshot.data);
                                    },
                                    icon: kShareIcon())
                              ];
                            },
                          )
                        ],
                      ),
                    ),
                    body: QuillProvider(
                      configurations: QuillConfigurations(
                        controller: _quillController!,
                        sharedConfigurations: const QuillSharedConfigurations(
                          locale: Locale('en'),
                        ),
                      ),
                      child: Column(
                        children: [
                          const QuillToolbar(),
                          Expanded(
                            child: Card(
                              color: ref.read(themeProvider)
                                  ? kBlackColor()
                                  : kWhiteColor(),
                              child: QuillEditor.basic(
                                configurations: const QuillEditorConfigurations(
                                  padding: EdgeInsets.all(20),
                                  readOnly: false,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
    ));
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

  int i = 0;
  void refresh() {
    setState(() {
      i++;
    });
  }

  onGoBack(value) {
    refresh();
  }

  TextEditingController _shareEmailController = TextEditingController();
  Future<dynamic> kDelDocument(BuildContext context, data) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (_, WidgetRef ref, __) {
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
                    AppApi().deleteDocsArray(context,
                        docIds: [data["_id"]]).then((value) {
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
      },
    );
  }

  PopupMenuItem<dynamic> kPopupItems(
      {required String label,
      Color? iconColor,
      required Function()? onTap,
      required String icon}) {
    return PopupMenuItem(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(color: iconColor),
            ),
            Spacer(),
            Iconify(icon)
          ],
        ),
      ),
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
