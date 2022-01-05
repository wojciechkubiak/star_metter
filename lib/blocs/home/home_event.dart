part of 'home_bloc.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class HomeLoadInit extends HomeEvent {
  final bool isInit;
  final Function() handlePage;
  final int? userId;

  HomeLoadInit({
    this.isInit = false,
    required this.handlePage,
    this.userId,
  });

  List<Object?> get props => [isInit];
}

class HomeLoadIntro extends HomeEvent {
  final bool isInit;

  HomeLoadIntro({
    this.isInit = true,
  });

  List<Object?> get props => [isInit];
}

class HomeLoadSplash extends HomeEvent {}

class HomeLoadPage extends HomeEvent {
  final User? user;

  HomeLoadPage({this.user});

  List<Object?> get props => [user];
}

class HomeLoadSettings extends HomeEvent {}
