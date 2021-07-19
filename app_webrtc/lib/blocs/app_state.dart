import 'package:app_webrtc/models/hero.dart';
import 'package:equatable/equatable.dart';

//estados: cargando, mostrar perfiles y conectado, llamando, llamada en curso, llamada entrante
enum Status{ loading,showPicker,connected, calling, incalling, incomming }
class AppState extends Equatable{
  final Status status;
  final Map<String, Hero> heroes;
  final Hero heroSelected, personGoingToCall;
  final bool isFrontCamera,mute;
  

  //AppState({this.status = Status.loading, this.heroes});
  AppState( {
    this.status = Status.loading,
    required this.heroes,
    required this.heroSelected,
    required this.personGoingToCall,
    this.isFrontCamera=true,
    this.mute = false
    });
  
  @override
  List<Object?> get props => [status, heroes, heroSelected, personGoingToCall,
                               isFrontCamera, mute ];

  factory AppState.initialState() => AppState(heroes: Map<String, Hero>(),
   heroSelected: Hero(avatar: '',name: '', isTaken: false),
   personGoingToCall:  Hero(avatar: '',name: '', isTaken: false));

  AppState copyWith({ Status? status, Map<String, Hero>? heroes, Hero? heroSelected, Hero? personGoingToCall, bool? isFrontCamera, bool? mute }) {
    return AppState(
      status: status ?? this.status,
      heroes: heroes ?? this.heroes,
      heroSelected: heroSelected ?? this.heroSelected,
      personGoingToCall: personGoingToCall ?? this.personGoingToCall,
      isFrontCamera: isFrontCamera??this.isFrontCamera,
      mute: mute??this.mute
    );
  }

}