
import 'dart:convert';

import 'package:app_webrtc/blocs/app_state.dart';
import 'package:app_webrtc/blocs/app_state_events.dart';
import 'package:app_webrtc/models/hero.dart';
import 'package:app_webrtc/utlis/signaling.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/webrtc.dart';

class AppStateBloc extends Bloc<AppStateEvent, AppState>{
  @override
  AppState get initialState => AppState.initialState();

  AppStateBloc() : super(AppState.initialState()) {
    _init();
  }

  //initialState representa el estado de mi bloc
  //AppStateBloc(AppState initialState) : super(initialState);

  Signaling _signaling = Signaling();
  //muestra el video
  RTCVideoRenderer _localRendered = RTCVideoRenderer();

  RTCVideoRenderer get localRendered => _localRendered;

/*   set localRendered(RTCVideoRenderer localRendered) {
    _localRendered = localRendered;
  } */

  RTCVideoRenderer _remoteRendered = RTCVideoRenderer();
  RTCVideoRenderer get remoteRendered => _remoteRendered;



  


  //AppState get initialState => _init();
  
  _init() async{
    await _localRendered.initialize();
    await _remoteRendered.initialize();
    _signaling.initServer();

    _signaling.onlocalStreamVideoCall = (MediaStream streamVideoCall){
      _localRendered.srcObject = streamVideoCall;
      _localRendered.mirror = true;
    };

    _signaling.onRemoteStreamVideoCall = (MediaStream streamVideoCall){
      _remoteRendered.srcObject = streamVideoCall;
      _remoteRendered.mirror = true;

    };

    _signaling.onConnected = (Map<String,Hero>data) {
      if(data != null){
        //print("Connected ${jsonEncode(data)}");
        add(ShowPickerEvent(data));
      }else{
        //print("No se ejecutó $data");
      }
    };

    _signaling.onAssigned = (String heroName){
      if(heroName == null){
        add(ShowPickerEvent(state.heroes));
      }else{
        print('exito, Se asignó el superheroe que elegimos');
        final myHero = state.heroes[heroName];
        add(ConnectedEvent(myHero!));
      }
    };

    _signaling.onTaken = (String heroName){
      add(TakeEvent(heroName: heroName, isTaken: true));
    };

    _signaling.onDisconnected = (String heroName){
      add(TakeEvent(heroName: heroName, isTaken: false));
    };

    _signaling.onResponse = (dynamic answer){
      print('respuesta desde app_state_bloc $answer');
      if (answer != null) {
        print('debo pasar a la pantalla de llamada');
        add(InCallingEvent());
      }else{
        add(ConnectedEvent(state.heroSelected));
      }
    };

    _signaling.onRequest = (dynamic data){
      add(InCommingEvent(data["superHeroName"]));
    };

    _signaling.onCancelRequest = (){
      add(ConnectedEvent(state.heroSelected));
    };

    _signaling.onFinishCall= (){
      add(ConnectedEvent(state.heroSelected));
    };
  }


  @override
  Future<void> close() {
    _localRendered.dispose();
    _remoteRendered.dispose();
    _signaling.dispose();
    return super.close();
  }

  
  /**
   * mapEventToState voy a capturar todos los eventos de la aplicación 
   */
  @override
  Stream<AppState> mapEventToState(AppStateEvent event) async* {
    if (event is ShowPickerEvent) {
      yield AppState(status: Status.showPicker, heroes: event.heroes, heroSelected: state.heroSelected,
      personGoingToCall: state.personGoingToCall);
    } else if (event is PickHeroEvent) {
      //Si entra aquí se elige un personaje para entrar al chat y pasa de nuevo a loading
      _signaling.emitServer('pick', event.heroName);
      //yield AppState(status: Status.loading, heroes: state.heroes);
      yield state.copyWith(status: Status.loading);
    } else if(event is ConnectedEvent){
      //yield AppState(status: Status.connected, heroes: state.heroes);
      yield state.copyWith(status: Status.connected, heroSelected: event.heroSelected,personGoingToCall: null);
    }  else if(event is TakeEvent){
        print('takeevent $event');
        Map<String, Hero> newHeroes = Map();
        newHeroes.addAll(state.heroes);
        print('props ${newHeroes}');
        final heroSelectedWithOtherUser = newHeroes[event.heroName];
        print ('heroe seleccionado por el otro usuario $heroSelectedWithOtherUser');
        final heroTaken = newHeroes[event.heroName]!.copyWith(name: event.heroName, avatar: heroSelectedWithOtherUser!.avatar, isTaken: event.isTaken);
        print ('heroe a enviar $heroTaken');
        newHeroes[heroTaken.name] = heroTaken;
        print ('heroe newHeroes ${newHeroes[heroTaken.name]}');
        yield state.copyWith(heroes: newHeroes);

    }else if(event is CallingEvent){
      print('CallingEvent $event');
      _signaling.callTo(event.personGoingToCall.name);
      yield state.copyWith(status: Status.calling, personGoingToCall: event.personGoingToCall);
    } else if (event is InCallingEvent){
      yield state.copyWith(status: Status.incalling);
    }else if (event is InCommingEvent){
      final nameCallInput = state.heroes[event.nameCallInput];
      print("InCommingEventtttttttttttt $nameCallInput");
      yield state.copyWith(status: Status.incomming, heroSelected: nameCallInput);
    }else if (event is AcceptOrDeclineCallEvent)  {
      if (event.accept) {
        await _signaling.acceptOrDeclineCall(true);
        yield state.copyWith(status: Status.incalling);
        print('pasar a la pantalla de llamada en curso');
      }else {
        _signaling.acceptOrDeclineCall(false);
        yield state.copyWith(status: Status.connected, personGoingToCall: null);
      }
    }else if(event is CancelRequestEvent){
      _signaling.cancelRequest();
      yield state.copyWith(status: Status.connected, personGoingToCall: null);
    } else if( event is FinishCallEvent){
      _signaling.finishCurrentCall();
      yield state.copyWith(status: Status.connected, personGoingToCall: null);
    }

  }

}

