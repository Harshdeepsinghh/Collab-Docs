import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:logger/logger.dart';
import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/clients/myScoket.dart';
import 'package:collabDocs/models/docsModel.dart';

class MainDocumnetScreen extends StatefulWidget {
  final DocumentModel? documentModel;
  final bool addingNew;
  const MainDocumnetScreen(
      {super.key, required this.addingNew, this.documentModel});

  @override
  State<MainDocumnetScreen> createState() => _MainDocumnetScreenState();
}

class _MainDocumnetScreenState extends State<MainDocumnetScreen> {
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
  }

  @override
  void initState() {
    super.initState();
    setDocData();
    MySocket.socket.on("changes", (data) {
      Logger().f("------------->received data : $data");
      setState(() {});
    });
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
                      title: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: TextFormField(
                          controller: _controller,
                          onFieldSubmitted: (value) async {
                            await AppApi().patchDocTitle(
                              id: _model.docId,
                              title: value,
                            );
                            MySocket()
                                .makingChanges("changing doc name: $value");
                          },
                        ),
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
}
