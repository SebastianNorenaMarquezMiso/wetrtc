import 'package:app_webrtc/models/hero.dart';
import 'package:equatable/equatable.dart';

//estados: cargando, mostrar perfiles y conectado
enum Status{ loading,showPicker,connected }
class AppState extends Equatable{
  final Status status;
  final Map<String, Hero> heroes;
  final Hero heroSelected;

  //AppState({this.status = Status.loading, this.heroes});
  AppState( {this.status = Status.loading, required this.heroes, required this.heroSelected});
  
  @override
  List<Object?> get props => [status, heroes, heroSelected];

  factory AppState.initialState() => AppState(heroes: Map<String, Hero>(),
   heroSelected: Hero(avatar: '',name: '', isTaken: false));

  AppState copyWith({ Status? status, Map<String, Hero>? heroes, Hero? heroSelected }) {
    return AppState(
      status: status ?? this.status,
      heroes: heroes ?? this.heroes,
      heroSelected: heroSelected ?? this.heroSelected
    );
  }

}