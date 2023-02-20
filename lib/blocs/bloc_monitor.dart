import 'package:fimber/fimber.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocMonitor extends BlocObserver {
  static final FimberLog _logger = FimberLog('BlocMonitor');

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.d('${bloc.runtimeType} $change');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.d('event: $event');
  }

  @override
  void onTransition(
      Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    _logger.d('state transition: $transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.d('error: $error');
    _logger.d('$stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
