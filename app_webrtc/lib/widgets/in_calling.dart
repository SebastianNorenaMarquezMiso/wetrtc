import 'dart:ffi';

import 'package:app_webrtc/blocs/app_state.dart';
import 'package:app_webrtc/blocs/app_state_bloc.dart';
import 'package:app_webrtc/blocs/app_state_events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/webrtc.dart';

class InCalling extends StatelessWidget {
  const InCalling({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStateBloc = BlocProvider.of<AppStateBloc>(context);
    final appStateBlocLocal = BlocProvider.of<AppStateBloc>(context);
    return BlocBuilder<AppStateBloc, AppState> (
      builder: (context, state){
        return Stack(
          children: <Widget>[
            //Video de la persona del otro lado de la llamada
            Positioned.fill(
              child: Transform.scale(
                scale: 2,
                alignment: Alignment.center,
                child: RTCVideoView(appStateBloc.remoteRendered)

              ),
            ),
            Positioned(
              left: 20,
              bottom: 100,
              child: SafeArea(
                child: Transform.scale(
                scale: 0.3,
                alignment: Alignment.bottomLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 480,
                    height: 640,
                    color: Color(0xffcccccc),
                    //Aqui me veo yo
                    child: RTCVideoView(appStateBlocLocal.localRendered),
                  ),
              ),
              ))
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: 'mic',
                    child: Icon(Icons.mic),
                    onPressed: () {}
                    ),
                    CupertinoButton(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(30),
                      child: Icon(Icons.call_end, size: 40),
                      padding: EdgeInsets.symmetric(horizontal:30, vertical: 10),
                      onPressed: (){appStateBloc.add(FinishCallEvent());}
                      ),
                  FloatingActionButton(
                    heroTag: 'cam',
                    child: Icon(state.isFrontCamera? Icons.camera_front : Icons.camera_rear),
                    onPressed: () {
                      appStateBlocLocal.add(SwitchCameraEvent(!state.isFrontCamera));
                    })
                ],
              )

            )
          ],
          alignment: Alignment.center,
        );
      },
      
    );
  }
}