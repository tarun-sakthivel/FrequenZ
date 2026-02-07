part of 'frequency_bloc.dart';

@immutable
sealed class FrequencyState {}

final class FrequencyInitial extends FrequencyState {}

class FrequencyListeningStarted extends FrequencyState {}

class FrequencyListeningStopped extends FrequencyState {}

class FrequencyUpdated extends FrequencyState {
  final FrequencyModel model;
  FrequencyUpdated(this.model);
}
