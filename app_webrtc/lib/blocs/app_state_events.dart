import 'package:app_webrtc/models/hero.dart';
import 'package:equatable/equatable.dart';

class AppStateEvent extends Equatable{
  
  final List _props;

  AppStateEvent([this._props = const[]]); 
  @override
  
  List<Object?> get props => _props;

}

//Muestra un indicador de cargando
class LoadingEvent extends AppStateEvent{

}

//muestra la interfaz de un perfil correspondiente
class ShowPickerEvent extends AppStateEvent{
  final Map<String, Hero> heroes;
  ShowPickerEvent(this.heroes): super([heroes]);
}

class PickHeroEvent extends AppStateEvent{
  final String heroName;

  PickHeroEvent(this.heroName): super([heroName]);

}


class ConnectedEvent extends AppStateEvent{
  final Hero heroSelected;
  ConnectedEvent(this.heroSelected): super([heroSelected]);
  
}
//isTaken es true un superheroe ha sido seleccionado, si está dispoible será false
class TakeEvent extends AppStateEvent{
  final String heroName;
  final bool isTaken;
  TakeEvent({required this.heroName, required this.isTaken}): super([heroName, isTaken]);
}

/**
 * Clase para detectar cuando un usuario se desconecta
 */
class DisconnectedEvent extends AppStateEvent{
  final String heroNameDesconnected;
  DisconnectedEvent(this.heroNameDesconnected): super([heroNameDesconnected]);
}

/**
 * Evento para empezar una llamada
 * personGoingToCall => persona a la que voy a llamar
 */
class CallingEvent extends AppStateEvent{
  final Hero personGoingToCall;
  CallingEvent(this.personGoingToCall): super([personGoingToCall]);
}

/**
 * Evento que permite enlazar una llamada
 */
class InCallingEvent extends AppStateEvent {}

/**
 * Evento para escuchar una llamada entrante
 */
class InCommingEvent extends AppStateEvent {
  //Nombre de la persona que está llamando
  final String nameCallInput;
  InCommingEvent(this.nameCallInput): super([nameCallInput]);
}

/**
 * Nos sirve para aceptar o rechazar una llamada entrante
 */
class AcceptOrDeclineCallEvent extends AppStateEvent{
  final bool accept;
  AcceptOrDeclineCallEvent(this.accept): super([accept]);
}

class CancelRequestEvent extends AppStateEvent{ }

class FinishCallEvent extends AppStateEvent{ }

class SwitchCameraEvent extends AppStateEvent{
  final bool isFrontCamera;
  SwitchCameraEvent(this.isFrontCamera): super([isFrontCamera]);
 }

class MuteEvent extends AppStateEvent{
  final bool mute;
  MuteEvent(this.mute): super([mute]);
 }

 


