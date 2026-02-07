part of 'frequency_bloc.dart';

@immutable
sealed class FrequencyEvent {}

class StartListening extends FrequencyEvent {}

class StopListening extends FrequencyEvent {}

class AudioDataReceived extends FrequencyEvent {
  final List<double> samples;
  AudioDataReceived(this.samples);
}
