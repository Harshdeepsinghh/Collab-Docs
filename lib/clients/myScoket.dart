import 'package:logger/logger.dart';
import 'package:mydocsy/api/appApi.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MySocket {
  static String server = AppApi.kBaseUrl;

  static IO.Socket socket = IO.io(server, <String, dynamic>{
    'transports': ['websocket'],
    'autoconnect': true
  });

  makingChanges(data) {
    socket.emit("makingChanges", data);
    Logger().d(data);
  }

  listeningChanges(dynamic setState) {
    socket.on("changes", (data) {
      Logger().f("received data : $data");
      setState(data);
    });
  }
}
