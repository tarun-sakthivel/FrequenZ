import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  StreamController<List<double>>? _audioStreamController;
  StreamSubscription? _bufferSubscription;
  final List<double> _audioBuffer = [];

  Stream<List<double>> get audioStream {
    if (_audioStreamController == null) {
      throw Exception('Audio stream not initialized. Call start() first.');
    }
    return _audioStreamController!.stream;
  }

  static const int sampleRate = 44100;

  Future<void> start() async {
    try {
      // Ensure clean state
      await stop();

      _audioStreamController = StreamController<List<double>>.broadcast();
      final bufferStreamController = StreamController<Uint8List>();
      
      await _recorder.openRecorder();

      _bufferSubscription = bufferStreamController.stream.listen((buffer) {
        try {
          final samples = buffer.buffer
              .asInt16List()
              .map((e) => e.toDouble())
              .toList();
          
          _audioBuffer.addAll(samples);

          // Buffer until we have enough samples for FFT (1024)
          // We send chunks of data to the bloc
          if (_audioBuffer.length >= 1024) {
             if (_audioStreamController != null && !_audioStreamController!.isClosed) {
                // Send a copy of the buffer
                _audioStreamController!.add(List.from(_audioBuffer));
             }
             // Keep the last part of the buffer for overlap or clear?
             // For simplicity and responsiveness, we can clear. 
             // Ideally we might want overlap, but let's stick to simple chunks.
             _audioBuffer.clear();
          }
        } catch (e) {
          print('Error processing audio buffer: $e');
        }
      });

      await _recorder.startRecorder(
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        numChannels: 1,
        toStream: bufferStreamController.sink,
      );

      print('Audio recording started successfully');
    } catch (e) {
      print('Error starting audio recording: $e');
      // Cleanup on failure
      await stop();
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _recorder.stopRecorder();
      await _recorder.closeRecorder();
      
      await _bufferSubscription?.cancel();
      _bufferSubscription = null;
      
      if (_audioStreamController != null && !_audioStreamController!.isClosed) {
        await _audioStreamController!.close();
      }
      _audioStreamController = null;
      _audioBuffer.clear();
      
      print('Audio recording stopped successfully');
    } catch (e) {
      print('Error stopping audio recording: $e');
    }
  }
}

