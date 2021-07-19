

import 'dart:convert';

import 'package:app_webrtc/models/hero.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:flutter_webrtc/media_stream.dart';

//import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utlis/webRTCConfig.dart';
import 'package:flutter_incall/flutter_incall.dart';

/**
 * Aquí se va a realizar todo el proceso para enviar y recibir 
 * la info de los dos chats
 */

typedef OnlocalStream (MediaStream stream);
typedef OnRemoteStream(MediaStream streamRemote);
typedef OnJoined(bool isOk);

typedef OnConnected (Map<String, Hero> heroes);
typedef OnAssigned(String heroName);
typedef OnTaken(String heroName);
typedef OnDisconnected(String heroNameDisconnected);
typedef OnlocalStreamVideoCall(MediaStream streamVideoCall);
typedef OnResponse(dynamic answer);
typedef OnRequest(dynamic data);
typedef OnCancelRequest();
typedef OnFinishCall();
typedef OnRemoteStreamVideoCall(MediaStream streamVideoCall);

class Signaling{

   late IO.Socket _socket;
   late OnlocalStream onlocalStream;
   late OnRemoteStream onRemoteStream;
   late OnJoined onJoined;

//Como es una llamada de 1 a 1 necesitamos un peer, si fueran 3 personas serían 2 peers
   late RTCPeerConnection _peer;

//El nombre del usuario del otro lado de la llamada
   late String _usuario2;

   late MediaStream _localStream;

    //Variables segundo chat
   late OnConnected onConnected;
   late OnAssigned onAssigned;
   late OnTaken onTaken;
   late OnDisconnected onDisconnected;
   late RTCPeerConnection _peerConnection;
   late OnlocalStreamVideoCall onlocalStreamVideoCall;
   late MediaStream _onlocalStreamVideoCall;
   //guarda el nombre de la otra persona del otro lado de la llamada
   //requestId: es el id que genera la llamada
   //_incomming: es la oferta que envío
   late String _person2, _requestId;
   late OnResponse onResponse;
   late OnRequest onRequest;
   late OnCancelRequest onCancelRequest;
   late RTCSessionDescription _inCommingOffer;
   late OnFinishCall onFinishCall;
   late OnRemoteStreamVideoCall onRemoteStreamVideoCall;
   IncallManager _incallManager = IncallManager();



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

    _localStream= stream;
    onlocalStream(stream);
    _connect();

    
  }

  //Segundo chat
  Future<void>initServer() async {
    _onlocalStreamVideoCall = await navigator.getUserMedia(WebRTCConfig.mediaConstraints);
    onlocalStreamVideoCall(_onlocalStreamVideoCall);
    _connectServer();
  }

/*   Future<void> initChat() async { 
  } */


//Cargamos los perfiles disponibles para hacer la llamada
  _connectServer(){
      _socket = IO.io('https://backend-super-hero-call.herokuapp.com/',
      IO.OptionBuilder()
      .setTransports(['websocket']) // for Flutter or Dart VM
      .setExtraHeaders({'foo': 'bar'}) // optional
      .build());

      _socket.on("on-connected", (data) {
        final tmp = Map.from(data);
         print('temporal $tmp');
         final Map<String, Hero> heroes = tmp.map((key, value) {
           //print('value $value');
           final Hero heroe = Hero.fromJson(value);
           ///print('hero $heroe');
           return MapEntry<String, Hero>(key, heroe);
         });
        onConnected(heroes);
      });

      //Se asigna el héroe seleccionado desde nuestra app para entrar al chat
      _socket.on('on-assigned', (heroName) {
        onAssigned(heroName);
      });

      /**
       * Cuando se selecciona un héroe por el otro usuario, debemos obtener 
       * ese nombre para seleccionarlo en nuestra interfaz 
       */
      _socket.on('on-taken', (heroName) {
        onTaken(heroName);
      });

      /**
       * Detecta cuando un usuario se desconecta
       */
      _socket.on('on-disconnected', (heroNameDisconnected) {
        onDisconnected(heroNameDisconnected);
      });

      /**
       * Si la solicitud de llamada dura más de 10 segundos,
       * la respuesta será null y se cuelga la llamada
       */
      _socket.on('on-response', (answer) async {
        _incallManager.startRingtone(RingtoneUriType.DEFAULT, 'default', 10);
        print("respuesta de la llamada ${answer}");
        if (answer == null) {
          _finishCall();
        }else{
          RTCSessionDescription anserTmp = RTCSessionDescription(answer['sdp'], answer['type']);
          await _peerConnection.setRemoteDescription(anserTmp);
        }
        onResponse(answer);
      });

      /**
       * Evento para escuchar una llamada entrante
       */
      _socket.on('on-request', (data) async {
        _person2 = data['superHeroName'];
        _requestId = data['requestId'];
        final tmp = data['offer'];
        _inCommingOffer = RTCSessionDescription(tmp['sdp'], tmp['type']);
        onRequest(data);
      });

    /**Escucha cuando la persona que llamó cuelga */
      _socket.on('on-cancel-request', (_) async {
        _incallManager.stopRingtone();
        _finishCall();
        onCancelRequest();
      });

//Escucho los iceCandidate de la persona del otro lado de la llamada(Información)
      _socket.on('on-candidate', (data) async {
        print("on-candidate---- $data");
        if (_peerConnection != null) {
          final iceCandidate = RTCIceCandidate( data["candidate"], data["sdpMid"], data["sdpMLineIndex"]);
          //agrego el iceCandidate de la otra persona para establecer la conexión
          await _peerConnection.addCandidate(iceCandidate);
        }else print("No se enviaron los iceCandidate");
      });

//con _ le decimos que no recibe ningún parámetro
//cuando en plena videollamada una de las dos personas 
//se desconecta por alguna razón, finalizamos la llamada. 

      _socket.on('on-finish-call', (_){
        _finishCall();
        print('Se colgó la llamada');
        onFinishCall();
      });

  }

  emitServer(String event, dynamic data){
   if(_socket != null) _socket.emit(event,data);
  }

  Future<void> _createPeerServer() async{
    _peerConnection =  await createPeerConnection(WebRTCConfig.configuration, {});
    _peerConnection.addStream(this._onlocalStreamVideoCall);

    //Escuchamos nuestro iceCandidate
    _peerConnection.onIceCandidate = (RTCIceCandidate iceCandidate){
      print('estos son mis iceCandidateeeeeeee $iceCandidate');
      if (iceCandidate != null) {
        print("enviando mis icecandidate");
        //debo saber si hay otra persona del otro lado de la llamada
        if (_person2 != '' || _person2 != null) {
          //enviamos nuestro iceCandidate al otro lado de la llamada
          emitServer('candidate', {"him":_person2,"candidate": iceCandidate.toMap()});
          /**
          emitServer('candidate', {
            "him":_person2,
            "candidate": { "candidate": iceCandidate.toMap()}
          });
           */
        }
      }
    };

    //Se ejecuta cuando obtengo el video de la otra persona que está al otro lado de la llamada
    this._peerConnection.onAddStream = (MediaStream streamVideoCall){
      print("Listos para el streaming $streamVideoCall");
      onRemoteStreamVideoCall(streamVideoCall);
    };
  }

  /**
   * Guardamos el nombre de la otra persona que se va a llamar
   */
  callTo(String nameCall) async{
    //_usuario2 = nameCall;
    _person2 = nameCall;
    await _createPeerServer();
    final RTCSessionDescription offerNameCall = await _peerConnection.createOffer(WebRTCConfig.offerSdpConstraints);
    await _peerConnection.setLocalDescription(offerNameCall);
    emitServer('request', {"superHeroName": nameCall, "offer": offerNameCall.toMap()});
  }

 /**
  * Funciona para aceptar una llamada entrante
  */
  acceptOrDeclineCall(bool accept)async{
    _incallManager.stopRingtone();
    if (accept) {
      await _createPeerServer();
      // registro la información de la persona que está llamando
      //cuando la acepto (offer)
      await _peerConnection.setRemoteDescription(_inCommingOffer);
      final RTCSessionDescription myAnswer = await _peerConnection.createAnswer(WebRTCConfig.offerSdpConstraints);
      //registro mi respuesta
      _peerConnection.setLocalDescription(myAnswer);
      emitServer('response', {
        "requestId": _requestId,
        "answer": myAnswer.toMap()
      });
    }else{
      emitServer('response', {'requestId': _requestId, 'answer': null});
      _finishCall();
    }
  }

/**
 * Nos sirve para colgar mientras estamos marcando(rechazar llamada saliente)
 */
  cancelRequest(){
    _socket.emit('cancel-request');
    _finishCall();
  }

  _finishCall(){
    _person2 = "";
    _peerConnection.close();
    _peerConnection = null as RTCPeerConnection;
    _requestId = "";
    _incallManager.stop();
  }

//finaliza la llamada actual
  finishCurrentCall(){
    _finishCall();
    _socket.emit('finish-call');
  }



















  _connect(){
  _socket = IO.io('https://backend-simple-webrtc.herokuapp.com/',
  IO.OptionBuilder()
      .setTransports(['websocket']) // for Flutter or Dart VM
      .setExtraHeaders({'foo': 'bar'}) // optional
      .build());

    onJoin();
    
  }
/**
 * Sirve para solicitar al servidor unirse a la videio llamada
 * donde se envía el evento
 */
  emit(String eventName, dynamic data){
    if(_socket != null) _socket.emit(eventName,data); 
  }

  /**
   * Nos sirve para escuchar la respuesta del servidor
   * cuando ingresamos nuestro nombre
   */
  onJoin(){
    _socket.on('on-join', (isOk) async {
      print("Estoy escuchardo aaaaaaaaaaaaaaaaaaaaaaaaaaaaa $isOk ");
        onJoined(isOk);
    });


    _socket.on('on-call', (data) async {
      print("Estoy recibiendo los datos de la persona que me esta llamando de la llaaaaaaaaaaaaaaaaaaaaaaaaaaaaa $data ");
      await _createPeer();
      final String username = data['username'];
      _usuario2 = username;
      final offer = data["offer"];
      final RTCSessionDescription desc = RTCSessionDescription(offer['sdp'], offer['type']);
      await _peer.setRemoteDescription(desc);

      final constraintsPersonaQueLlamar = {
        "mandatory": {
          "OfferToReceiveAudio": true,
          "OfferToReceiveVideo": true
        },
        "opcional": []
      };
      //acepto la llamada entrante y con answer genero la respuesta para el otro usuario
      final RTCSessionDescription answer = await _peer.createAnswer(constraintsPersonaQueLlamar);
      await _peer.setLocalDescription(answer);

      emit('answer', {
        "username": _usuario2,
        "answer": answer.toMap()
        });

    });

    //Captura la respuesta del usuario
    _socket.on('on-answer', (answerUser) {
      print("respuesta recibida $answerUser");
      final RTCSessionDescription description = RTCSessionDescription(answerUser["sdp"], answerUser["type"]);
      _peer.setRemoteDescription(description);
    });

      //escucho el candidate del otro usuario
        _socket.on('on-candidate', (data) async{
          print("on-candidate $data");
          final RTCIceCandidate candidate = RTCIceCandidate(data["candidate"], data["sdpMid"], data["sdpMLineIndex"]);
          await _peer.addCandidate(candidate);
    });
  }

  /**
   * Cuando la aplicación no está en ejecución, se liberan los recurosos
  */
  dispose(){
    _socket.disconnect();
    _socket.destroy();
    //_socket = null;
    _onlocalStreamVideoCall.dispose();
    _peerConnection.close();
    _peerConnection.dispose();
    _incallManager.stop();
  }

/**
 * Nos permite enlazar la llamada.
 * Debemos pasarle los stun servers 
 * los stunServers son los que nos permite obtener los iceCandidates una vez que
 *  ambas partes aceptan la comunicación
 * nos retorna datos como ip publica, ip privada, puertos, mac adress 
 * (a esto se le llama iceCandidate)
 * 
 */
  _createPeer() async{
    this._peer = await createPeerConnection({
      "iceServers":[
        {
         "urls": ['stun:stun1.l.google.com:19302'] 
        }
      ]
    }, {});
    await _peer.addStream(_localStream);
    // me retorna el iceCandidate
    _peer.onIceCandidate = (RTCIceCandidate candidate) {
      if(candidate == null){
        return;
      }
      print("Se aceptó la conexión entre ambas partes");
      //Aquí se envían mis iceCandidate
      emit('candidate', {"username": _usuario2, "candidate": candidate.toMap()});

    };

    //Cuando ambas partes aceptan la conexion se invoca este método
    // remoteStream son los datos de audio y video de la otra persona
    _peer.onAddStream = (MediaStream remoteStream){
      onRemoteStream(remoteStream);
    };
  }

  call(String username) async{
    _usuario2 = username;
    await _createPeer();
    //quiero obtener los datos de la persona que voy a llamar
    final constraintsPersonaALlamar = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true
      },
      "opcional": []
    };
    final RTCSessionDescription offer = await _peer.createOffer(constraintsPersonaALlamar);
    //debo registrar en el peer que quiero llamar a la otra persona
    _peer.setLocalDescription(offer);

    emit('call', {"username": username, "offer": offer.toMap()});
    print("persona que estoy llamando $username");
  }


}

