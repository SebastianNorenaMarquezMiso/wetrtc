import 'package:app_webrtc/blocs/app_state.dart';
import 'package:app_webrtc/blocs/app_state_bloc.dart';
import 'package:flutter/cupertino.dart';
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
            Text('Llamando...')
          ],
        );
      },
      
    );
  }
}