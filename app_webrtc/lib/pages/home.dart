import 'package:app_webrtc/utlis/signaling.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/media_stream.dart';
import 'package:flutter_webrtc/rtc_video_view.dart';
//import 'package:flutter_webrtc/webrtc.dart';



class homePage extends StatefulWidget {
  homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {

  RTCVideoRenderer _localRendered = RTCVideoRenderer();
  Signaling _signaling = Signaling();

  String ?_me ;
  late String _userName = '';

  @override
  void initState() {
    print("Me  $_me");
    super.initState();
    _localRendered.initialize();

    _signaling.init();
    
    _signaling.onlocalStream=(MediaStream stream) {
      _localRendered.srcObject=stream;;
      _localRendered.mirror = true;
    };
    _signaling.onJoined = (bool isOk){
      if (isOk) {
        setState(() {
          _me=_userName;
        });
      }
    };

  }

  @override
  void dispose() {
    _signaling.dispose();
    _localRendered.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: _me == null
        ? Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CupertinoTextField(
                placeholder: 'Ingrese Su Nombre',
                textAlign: TextAlign.center,
                onChanged: ( text ) => _userName = text
              ),
              SizedBox(height: 20),
              CupertinoButton(
                child: Text("JOIN"),
                color: Colors.blue,
                onPressed: () {
                  //join es el evento que permite hacer la solicitud al server para unirse
                  //a la video llamada
                  if (_userName.trim().length == 0) {
                    return;
                  }
                  _signaling.emit('join', _userName);
                })
            ],
        ),
      ) 
        :  Stack(
          children: <Widget>[
            Positioned(
            left: 20,
            bottom: 40,
            child: Transform.scale(
            scale: 0.3,
            alignment: Alignment.bottomLeft,
            child:  ClipRRect(
              borderRadius: BorderRadius.circular(20),
                child: Container(
                width: 480,
                height: 640,
                color: Colors.black12,
                child: RTCVideoView(_localRendered),),
            ),)
            )
          ],
        ) ,
      )
    );
  }
}
