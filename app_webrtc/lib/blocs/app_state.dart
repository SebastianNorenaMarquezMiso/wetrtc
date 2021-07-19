import 'package:app_webrtc/models/hero.dart';
import 'package:equatable/equatable.dart';

//estados: cargando, mostrar perfiles y conectado, llamando, llamada en curso, llamada entrante
enum Status{ loading,showPicker,connected, calling, incalling, incomming }
class AppState extends Equatable{
  final Status status;
  final Map<String, Hero> heroes;
  final Hero heroSelected, personGoingToCall;

  //AppState({this.status = Status.loading, this.heroes});
  AppState( {this.status = Status.loading, required this.heroes, required this.heroSelected, required this.personGoingToCall});
  
  @override
  List<Object?> get props => [status, heroes, heroSelected, personGoingToCall];

  factory AppState.initialState() => AppState(heroes: Map<String, Hero>(),
   heroSelected: Hero(avatar: '',name: '', isTaken: false),
  personGoingToCall:  Hero(avatar: '',name: '', isTaken: false));

  AppState copyWith({ Status? status, Map<String, Hero>? heroes, Hero? heroSelected, Hero? personGoingToCall }) {
    return AppState(
      status: status ?? this.status,
      heroes: heroes ?? this.heroes,
      heroSelected: heroSelected ?? this.heroSelected,
      personGoingToCall: personGoingToCall ?? this.personGoingToCall
    );
  }

}