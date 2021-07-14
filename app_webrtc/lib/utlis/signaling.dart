//import 'dart:html';

import 'package:flutter_webrtc/webrtc.dart';
import 'package:flutter_webrtc/media_stream.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/**
 * Aquí se va a realizar todo el proceso para enviar y recibir 
 * la info de los dos chats
 */

typedef OnlocalStream (MediaStream stream);
class Signaling{
/*   IO.Socket socket = IO.io('http://localhost:3000', <String, dynamic> {
    'transports': ['WebSocket'],
    'extraHeaders': {'foo': 'bar'}
  }); */
   late IO.Socket _socket;
   late OnlocalStream onlocalStream;

  init() async {
    MediaStream stream = await navigator.getUserMedia({
      "audio": true,
      "video": {
        "mandatory": {
          "minWidth":'480', // Provide your own width, height and frame rate here
          "minHeight": '640',
          "minFrameRate": '30',
        },
        "facingMode": "user",
        "optional": [],
      }
    });

    onlocalStream(stream);
  }

  _connect(){
  _socket = IO.io('https://backend-simple-webrtc.herokuapp.com/',
  OptionBuilder()
      .setTransports(['websocket']) // for Flutter or Dart VM
      .setExtraHeaders({'foo': 'bar'}) // optional
      .build());
  }

  dispose(){
    _socket.disconnect();
  }


}

