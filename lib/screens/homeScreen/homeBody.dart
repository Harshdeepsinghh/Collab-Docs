import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/clients/myScoket.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/constants/appConsts.dart';
import 'package:collabDocs/models/docsModel.dart';
import 'package:collabDocs/screens/mainDocScreen.dart';
import 'package:flutter/material.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
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
