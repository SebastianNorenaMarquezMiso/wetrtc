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

class TakeEvent extends AppStateEvent{
  final String heroName;
  TakeEvent(this.heroName): super([heroName]);
}
