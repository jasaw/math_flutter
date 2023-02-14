import 'package:equatable/equatable.dart';

abstract class RunnerState extends Equatable {
  @override
  final List<Object?> props;
  const RunnerState(this.props);
}

class RunnerUninitialised extends RunnerState {
  RunnerUninitialised() : super(<Object>[]);
}

class RunnerQuestion extends RunnerState {
  final double? response;
  final int questionNumber;

  RunnerQuestion({this.response, required this.questionNumber}) : super(<Object?>[response, questionNumber]);
}

class RunnerSessionStarted extends RunnerState {
  RunnerSessionStarted() : super(<Object>[]);
}

class RunnerSessionEnded extends RunnerState {
  RunnerSessionEnded() : super(<Object>[]);
}
