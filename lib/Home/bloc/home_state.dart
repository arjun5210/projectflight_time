part of 'home_bloc.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

class getsucess extends HomeState {
  String result;
  getsucess({required this.result});
}

class dataloaded extends HomeState {
  String convertedresult;
  String timestamp;
  final bool isCached;

  dataloaded({
    required this.convertedresult,
    required this.timestamp,
    required this.isCached,
  });
}

class dataerror extends HomeState {
  String error;
  dataerror({required this.error});
}

class dataloading extends HomeState {}
