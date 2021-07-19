import 'package:app_webrtc/blocs/app_state.dart';
import 'package:app_webrtc/blocs/app_state_bloc.dart';
import 'package:app_webrtc/blocs/app_state_events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Incomming extends StatelessWidget {
  const Incomming({Key? key}) : super(key: key);

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
              SizedBox(height: 10),
              Text("Llamada entrante"),
              Text(state.heroSelected.name),
              SizedBox(width: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FloatingActionButton(
                    backgroundColor: Colors.green[800],
                    child: Icon(Icons.call),
                    onPressed: () {appStateBloc.add(AcceptOrDeclineCallEvent(true));
                    }),
                  SizedBox(width: 80),
                  FloatingActionButton(
                    backgroundColor: Colors.redAccent[700],
                    child: Icon(Icons.call_end),
                    onPressed: (){ appStateBloc.add(AcceptOrDeclineCallEvent(false));
                    })
                ],
              )
          ]
        );
      }
    );
  }
}