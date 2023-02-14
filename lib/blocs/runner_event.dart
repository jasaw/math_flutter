abstract class RunnerEvent {}

class RunnerStartSession extends RunnerEvent {}

class RunnerNextQuestion extends RunnerEvent {
  final double? response;
  final int questionNumber;

  RunnerNextQuestion({this.response, required this.questionNumber});
}

class RunnerPrevQuestion extends RunnerEvent {}

class RunnerEndSession extends RunnerEvent {}
