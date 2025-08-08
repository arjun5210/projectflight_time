part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class getevent extends HomeEvent {
  String fromcurrency;
  String tocurrency;
  String amount;

  getevent({
    required this.amount,
    required this.fromcurrency,
    required this.tocurrency,
  });
}
