import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immerse/features/frequency/bloc/frequency_bloc.dart';
import 'package:immerse/features/frequency/view/frequency_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: BlocProvider(
        create: (_) => FrequencyBloc(),
        child: const FrequencyView(),
      ),
    );
  }
}
