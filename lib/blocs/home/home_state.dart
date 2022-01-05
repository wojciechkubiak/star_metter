part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeSplash extends HomeState {}

class HomeLoading extends HomeState {}

class HomeIntro extends HomeState {
  final bool isInit;

  HomeIntro({
    required this.isInit,
  });

  List<Object> get props => [isInit];
}

class HomeSettings extends HomeState {
  final List<User> users;
  final int userId;

  HomeSettings({
    required this.users,
    required this.userId,
  });

  List<Object> get props => [users, userId];
}

class HomePage extends HomeState {
  final User user;
  final Progress progress;

  HomePage({
    required this.user,
    required this.progress,
  });

  List<Object> get props => [user, progress];
}

class HomeError extends HomeState {}
