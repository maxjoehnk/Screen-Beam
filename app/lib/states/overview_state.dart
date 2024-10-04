import 'package:bloc/bloc.dart';

class OverviewState {
  final int currentIndex;

  OverviewState({this.currentIndex = 1});
}

class OverviewCubit extends Cubit<OverviewState> {
  OverviewCubit() : super(OverviewState());

  void changeTab(int index) {
    emit(OverviewState(currentIndex: index));
  }
}
