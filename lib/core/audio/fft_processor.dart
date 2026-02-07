import 'dart:math';
import 'package:fft/fft.dart';

class FFTProcessor {
  static ({double frequency, double amplitude}) analyze(List<double> samples, int sampleRate) {
    if (samples.length < 1024) return (frequency: 0, amplitude: 0);

    // Calculate RMS amplitude
    double sum = 0;
    for (var sample in samples) {
      sum += sample * sample;
    }
    final amplitude = sqrt(sum / samples.length);
    // Let's use simple mean squared for performance, or just root.
    // Actually, `sqrt(sum / length)` is proper RMS.
    // But since we just need a relative threshold, `sum / length` (Mean Square) is fine and faster.
    // Let's stick to true RMS for "correctness" if we want to display it, but here it's just for gating.
    // I'll return the Mean Squared Error (MSE) / Power as "amplitude" for gating. 
    // Actually, let's just do RMS.
    
    // NOTE: FFT package might need windowing for better accuracy, but let's stick to simple implementation.
    
    final fftInput = samples.take(1024).toList();
    final fft = FFT.Transform(fftInput);

    double maxMag = 0;
    int maxIndex = 0;

    for (int i = 0; i < fft.length ~/ 2; i++) {
      final mag = fft[i].abs();
      if (mag > maxMag) {
        maxMag = mag;
        maxIndex = i;
      }
    }

    final frequency = maxIndex * sampleRate / 1024;
    return (frequency: frequency, amplitude: amplitude);
  }
}
