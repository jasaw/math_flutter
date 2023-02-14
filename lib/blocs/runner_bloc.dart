// import 'dart:async';
// import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:fimber/fimber.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_flutter/blocs/runner_event.dart';
import 'package:math_flutter/blocs/runner_state.dart';

class RunnerBloc extends Bloc<RunnerEvent, RunnerState> {
  static final FimberLog logger = FimberLog('RunnerBloc');

  RunnerBloc() : super(RunnerUninitialised()) {
    on<RunnerStartSession>(_onStartSession, transformer: droppable());
  }

  Future<void> _onStartSession(RunnerEvent event, Emitter<RunnerState> emit) async {
    logger.w('Session started');
    emit(RunnerSessionStarted());
  }
}
