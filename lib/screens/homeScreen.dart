import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:mydocsy/api/appApi.dart';
import 'package:mydocsy/auth/saveAuthToken.dart';
import 'package:mydocsy/clients/myScoket.dart';
import 'package:mydocsy/constants/appConsts.dart';
import 'package:mydocsy/models/docsModel.dart';
import 'package:mydocsy/screens/loginScreen.dart';
import 'package:mydocsy/screens/mainDocScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeScreen extends ConsumerStatefulWidget {
  final String uid;
  const HomeScreen(this.uid, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final String serverUrl = AppApi.kBaseUrl;
  late IO.Socket socket;

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
                              int val = 0;
                              val++;
                              val;
                            }));
                      });
                    },
                    icon: Icon(Icons.add)),
                IconButton(
                    onPressed: () async {
                      GoogleSignIn().signOut();
                      SharedPrefData().clearToken();
                      SharedPrefData().clearUid();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
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
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                                      builder: (context) => MainDocumnetScreen(
                                            documentModel: documentModel,
                                          )));
                            },
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
                                    icon: Icon(Icons.delete)),
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
    );
  }
}
