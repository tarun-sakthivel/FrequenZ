import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:immerse/core/audio/audio_services.dart';
import 'package:immerse/core/audio/fft_processor.dart';
import 'package:immerse/core/permissions/mic_permission.dart';
import 'package:immerse/core/utils/frequency_color_mapper.dart';
import 'package:immerse/features/frequency/model/frequency_model.dart';
import 'package:meta/meta.dart';

part 'frequency_event.dart';
part 'frequency_state.dart';

class FrequencyBloc extends Bloc<FrequencyEvent, FrequencyState> {
  final AudioService _audioService = AudioService();
  StreamSubscription? _sub;
  DateTime _lastUpdate = DateTime.now();
  bool _isListening = false;

  FrequencyBloc() : super(FrequencyInitial()) {
    on<StartListening>(_onStart);
    on<AudioDataReceived>(_onAudio);
    on<StopListening>(_onStop);
  }

  Future<void> _onStart(
    StartListening event,
    Emitter<FrequencyState> emit,
  ) async {
    if (_isListening) return;

    final granted = await MicPermission.request();
    if (!granted) {
      print('Microphone permission denied');
      return;
    }

    _isListening = true;
    try {
      await _audioService.start();
      emit(FrequencyListeningStarted());

      _sub = _audioService.audioStream.listen(
        (samples) {
          // print('Received ${samples.length} audio samples'); 
          add(AudioDataReceived(samples));
        },
        onError: (error) {
          print('Error in audio stream: $error');
          _isListening = false;
          add( StopListening()); // Ensure clean stop
        },
        onDone: () {
          print('Audio stream ended');
          _isListening = false;
          add( StopListening());
        },
      );
    } catch (e) {
      print('Error starting listening: $e');
      _isListening = false;
      emit(FrequencyListeningStopped()); // Ensure UI knows we failed
    }
  }

  double _smoothedFreq = 0;
  
  void _onAudio(AudioDataReceived event, Emitter<FrequencyState> emit) {
    // Throttle to ~100ms (approx 10fps) for better readability and stability
    if (DateTime.now().difference(_lastUpdate).inMilliseconds < 100) return;
    _lastUpdate = DateTime.now();

    final result = FFTProcessor.analyze(
      event.samples,
      AudioService.sampleRate,
    );

    // Noise Gate: Ignore if amplitude is too low (e.g. background noise)
    // Increased to 1500 to aggressively filter out background noise
    if (result.amplitude < 1500) {
        return; 
    }

    // Smoothing (Exponential Moving Average)
    // Alpha 0.15 means 15% new value, 85% old value -> Very smooth, stable
    if (_smoothedFreq == 0) {
      _smoothedFreq = result.frequency;
    } else {
      _smoothedFreq = 0.15 * result.frequency + 0.85 * _smoothedFreq;
    }

    final color = FrequencyColorMapper.map(_smoothedFreq);
    final name = FrequencyColorMapper.name(_smoothedFreq);

    emit(
      FrequencyUpdated(
        FrequencyModel(frequency: _smoothedFreq, color: color, colorName: name),
      ),
    );
  }

  Future<void> _onStop(
    StopListening event,
    Emitter<FrequencyState> emit,
  ) async {
    if (!_isListening) return;

    _isListening = false;
    await _sub?.cancel();
    await _audioService.stop();
    emit(FrequencyListeningStopped());
  }

  @override
  Future<void> close() {
    if (_isListening) {
      add(StopListening());
    }
    return super.close();
  }
}
