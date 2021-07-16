

import 'package:app_webrtc/models/hero.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:flutter_webrtc/media_stream.dart';

//import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utlis/webRTCConfig.dart';

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
   late String _person2;



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
    //_connect();

    
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

      print('por aquí pasé');
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
  }

  emitServer(String event, dynamic data){
   if(_socket != null) _socket.emit(event,data);
  }

  Future<void> _createPeerServer() async{
    this._peerConnection =  await createPeerConnection(WebRTCConfig.configuration, {});
    _peerConnection.addStream(this._onlocalStreamVideoCall);
    //Se ejecuta cuando obtengo el video de la otra persona que está al otro lado de la llamada
    _peerConnection.onAddStream = (MediaStream streamVideoCall){

    };
  }

  /**
   * Guardamos el nombre de la otra persona que se va a llamar
   */
  callTo(String nameCall) async{
    _usuario2 = nameCall;
    await _createPeerServer();
    final RTCSessionDescription offerNameCall = await _peerConnection.createOffer(WebRTCConfig.offerSdpConstraints);
    await _peerConnection.setLocalDescription(offerNameCall);
    emit('request', {"superHeroName": nameCall, "offer": offerNameCall.toMap()});


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

