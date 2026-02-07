import 'package:flutter/material.dart';

class FrequencyColorMapper {
  static Color map(double freq) {
    if (freq < 250) return Colors.red;
    if (freq < 500) return Colors.orange;
    if (freq < 1000) return Colors.yellow;
    if (freq < 2000) return Colors.green;
    if (freq < 4000) return Colors.cyan;
    if (freq < 8000) return Colors.blue;
    return Colors.purple;
  }

  static String name(double freq) {
    if (freq < 250) return "Red";
    if (freq < 500) return "Orange";
    if (freq < 1000) return "Yellow";
    if (freq < 2000) return "Green";
    if (freq < 4000) return "Cyan";
    if (freq < 8000) return "Blue";
    return "Violet";
  }
}
