import 'package:app_webrtc/blocs/app_state.dart';
import 'package:app_webrtc/blocs/app_state_bloc.dart';
import 'package:app_webrtc/blocs/app_state_events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class HomeApp extends StatelessWidget {
  const HomeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStateBloc = BlocProvider.of<AppStateBloc>(context);

    return Scaffold(
      body: Center(
        child: BlocBuilder<AppStateBloc,AppState>(
        builder: (BuildContext context, AppState state) {
            print(state.status);
            switch (state.status) {
              case Status.loading:
                return CupertinoActivityIndicator(radius:15);
              case Status.showPicker:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Selecciona tu heroe ", style: TextStyle(fontSize: 30),),
                    SizedBox(height: 10),
                    Wrap(children: state.heroes.values.map((hero) {
                      return AbsorbPointer(
                        absorbing: hero.isTaken,
                        child: Opacity(
                          opacity: hero.isTaken ? 0.3 : 1,
                          child:  CupertinoButton(
                            child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(hero.avatar, width: 100)
                          ),
                          onPressed: (){
                            print('hero seleccionado $hero');
                            appStateBloc.add(PickHeroEvent(hero.name));
                          }
                      )
                       ),
                      );
                    }).toList()
                    )
                  ],
                );
              case Status.connected:
                print('Heroe seleccionado $state');
                return Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: <Widget>[
                        ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(state.heroSelected.avatar, width: 100)
                      ),
                      SizedBox(height: 10),
                    Text(state.heroSelected.name)
                  ]
                );
              default:
                return Container();
            }
        },
      ),
      )
    );
  }
}