import 'package:app_webrtc/blocs/app_state.dart';
import 'package:app_webrtc/blocs/app_state_bloc.dart';
import 'package:app_webrtc/blocs/app_state_events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Calling extends StatelessWidget {
  const Calling({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStateBloc = BlocProvider.of<AppStateBloc>(context);
    return BlocBuilder<AppStateBloc, AppState> (
      builder: (context, state){
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  state.heroSelected.avatar, 
                  width: 100
                )
              ),
            Text("Llamando"),
            SizedBox(height: 20),
            FloatingActionButton(
              child: Icon(Icons.call_end),
              backgroundColor: Colors.redAccent,
              onPressed: () {
                appStateBloc.add(CancelRequestEvent());
              }
              )
          ],
        );
      },
      
    );
  }
}