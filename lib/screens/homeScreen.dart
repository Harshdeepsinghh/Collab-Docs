import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/auth/saveAuthToken.dart';
import 'package:collabDocs/clients/myScoket.dart';
import 'package:collabDocs/constants/appConsts.dart';
import 'package:collabDocs/models/docsModel.dart';
import 'package:collabDocs/screens/loginScreen/selectLoginScreen.dart';
import 'package:collabDocs/screens/mainDocScreen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String uid;
  const HomeScreen(this.uid, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final String serverUrl = AppApi.kBaseUrl;

  @override
  void initState() {
    super.initState();
    MySocket.socket.on("changes", (data) {
      Logger().f("------------->received data : $data");
      setState(() {});
    });
  }

  bool showDelIcon = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () => showExitPopup(context),
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: Row(
                children: [
                  Spacer(),
                  IconButton(
                      onPressed: () async {
                        await AppApi().createNewDoc().then((value) {
                          DocumentModel documentModel =
                              DocumentModel.fromMap(value);
                          setState(() {});
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainDocumnetScreen(
                                        documentModel: documentModel,
                                      ))).then((value) => setState(() {
                                onGoBack(value);
                              }));
                        });
                      },
                      icon: Icon(Icons.add)),
                  IconButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Container(
                                  height: 200,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Are you sure you want to log out?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 22),
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
                                                        builder: (context) =>
                                                            SelectLoginScreen()));
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
                      icon: Icon(
                        Icons.logout,
                        color: Colors.red,
                      ))
                ],
              ),
            ),
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  FutureBuilder(
                    future: AppApi().getAllDocs(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            final data = snapshot.data[index];
                            return InkWell(
                              onLongPress: () {
                                setState(() {
                                  showDelIcon = true;
                                });
                              },
                              onTap: () {
                                DocumentModel documentModel =
                                    DocumentModel.fromMap(snapshot.data[index]);
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MainDocumnetScreen(
                                                  documentModel: documentModel,
                                                )))
                                    .then((value) => onGoBack(value));
                              },
                              child: Card(
                                color: Colors.purple.shade100,
                                child: ListTile(
                                  title: Text(data["title"]),
                                  subtitle: Text(AppConstants.DateFormatter(
                                      data["createdAt"])),
                                  trailing: Visibility(
                                    // visible: showDelIcon,
                                    child: IconButton(
                                        onPressed: () async {
                                          await AppApi()
                                              .deleteDocById(id: data["_id"])
                                              .then((value) => setState(() {}));
                                          MySocket().makingChanges(
                                              "deleting ${data["title"]}");
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        )),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )
                ],
              ),
            )),
      ),
    );
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
                            Text("No", style: TextStyle(color: Colors.black)),
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
