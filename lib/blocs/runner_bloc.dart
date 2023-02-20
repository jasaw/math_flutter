// import 'dart:async';
// import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:fimber/fimber.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_flutter/blocs/runner_event.dart';
import 'package:math_flutter/blocs/runner_state.dart';
import 'package:math_flutter/system/websocket_manager.dart';

const int WEBSOCKET_PORT = 8888;

class RunnerBloc extends Bloc<RunnerEvent, RunnerState> {
  static final FimberLog _logger = FimberLog('RunnerBloc');
  late final WebsocketManager _websocketManager;

  RunnerBloc() : super(RunnerUninitialised()) {
    on<RunnerStartSession>(_onStartSession, transformer: droppable());

    _logger.i('${Uri.base}');
    String wsHost;
    bool isProd = const bool.fromEnvironment('dart.vm.product');
    if (isProd) {
      wsHost = Uri.base.host;
    } else {
      wsHost = 'hil-tester';
    }
    String url = 'ws://$wsHost:$WEBSOCKET_PORT';

    _websocketManager = WebsocketManager(url: url);
  }

  Future<void> _onStartSession(RunnerEvent event, Emitter<RunnerState> emit) async {
    _logger.w('Session started');
    emit(RunnerSessionStarted());
  }
}
