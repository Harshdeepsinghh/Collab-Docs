import 'dart:async';

import 'package:logger/logger.dart';
import 'package:collabDocs/api/appApi.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MySocket {
  static String server = AppApi.kBaseUrl;
  // StreamController get changesController => _changesController;
  final changesController = StreamController<dynamic>.broadcast();

  static IO.Socket socket = IO.io(server, <String, dynamic>{
    'transports': ['websocket'],
    'autoconnect': true
  });

  makingChanges(data) {
    socket.emit("makingChanges", data);
    Logger().d(data);
  }

  listeningChanges() {
    socket.on("changes", (data) {
      Logger().f("------------->received data : $data");
      changesController.add(data);
    });
  }
}
