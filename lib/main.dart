import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_flutter/blocs/bloc_monitor.dart';
import 'package:math_flutter/blocs/runner_bloc.dart';
import 'package:math_flutter/screens/home_page.dart';
import 'package:math_flutter/utils/logging.dart';


void main() async {
  final FimberLog logger = FimberLog('main');
  Bloc.observer = BlocMonitor();
  await Logging.enableDebugLog();
  logger.i('Run app: ${Uri.base}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RunnerBloc>(create: (_) => RunnerBloc()),
      ],
      child: MaterialApp(
        title: 'Math Flutter',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(title: 'Math Flutter'),
      ),
    );
  }
}
