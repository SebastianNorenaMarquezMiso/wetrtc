import 'package:app_webrtc/blocs/app_state.dart';
import 'package:app_webrtc/blocs/app_state_bloc.dart';
import 'package:app_webrtc/blocs/app_state_events.dart';
import 'package:app_webrtc/widgets/calling.dart';
import 'package:app_webrtc/widgets/connected.dart';
import 'package:app_webrtc/widgets/show_picker.dart';
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
                return ShowPicker();
              case Status.connected:
                print('Heroe seleccionado $state');
                return Connected();
              case Status.calling:
                return Calling();
              default:
                return Container();
            }
        },
      ),
      )
    );
  }
}