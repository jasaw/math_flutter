import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:math_flutter/system/question.dart';

final FimberLog _logger = FimberLog('WebsocketResponse');

abstract class WebsocketResponse extends Equatable {
  const WebsocketResponse();
  factory WebsocketResponse.currentState(Map<String, dynamic> jsonData) = CurrentStateResponse;
  factory WebsocketResponse.unknown() = UnknownResponse;

  static WebsocketResponse parseJsonData(Map<String, dynamic> jsonData) {
    _logger.v('rsp: $jsonData');
    String? type = jsonData['type'] as String?;

    if (type == 'current_state') {
      return WebsocketResponse.currentState(jsonData);
    }
    return WebsocketResponse.unknown();
  }
}

class CurrentStateResponse extends WebsocketResponse {
  final Map<String, dynamic> jsonData;
  late final List<Question> questions;

  CurrentStateResponse(this.jsonData) {
    // TODO: pull questions and answered from json data
    questions = <Question>[];
  }

  @override
  List<Object> get props => <Object>[jsonData];
}

class UnknownResponse extends WebsocketResponse {
  @override
  List<Object> get props => <Object>[];
}
