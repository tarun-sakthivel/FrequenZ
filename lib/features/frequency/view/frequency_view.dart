import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/frequency_bloc.dart';

class FrequencyView extends StatelessWidget {
  const FrequencyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FrequencyBloc, FrequencyState>(
        builder: (context, state) {
          final isListening = state is FrequencyListeningStarted || state is FrequencyUpdated;
          final color = state is FrequencyUpdated
              ? state.model.color
              : Colors.black;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100), // Faster animation for real-time feel -> 300ms was too slow for 30ms updates
            color: color,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state is FrequencyUpdated)
                    Column(
                      children: [
                        Text(
                          "${state.model.frequency.toStringAsFixed(1)} Hz",
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.model.colorName,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    )
                  else if (isListening && state is! FrequencyUpdated)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else
                    const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (isListening) {
                        context.read<FrequencyBloc>().add(StopListening());
                      } else {
                        context.read<FrequencyBloc>().add(StartListening());
                      }
                    },
                    child: Text(
                      isListening ? 'Stop' : 'Start',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

