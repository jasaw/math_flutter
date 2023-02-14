import 'package:fimber/fimber.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocMonitor extends BlocObserver {
  static final FimberLog logger = FimberLog('BlocMonitor');

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    logger.d('${bloc.runtimeType} $change');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    logger.d('event: $event');
  }

  @override
  void onTransition(
      Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    logger.d('state transition: $transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    logger.d('error: $error');
    logger.d('$stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
