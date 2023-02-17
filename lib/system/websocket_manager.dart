import 'dart:async';

import 'package:fimber/fimber.dart';
// import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

const int WEBSOCKET_INITIAL_BACKOFF_DURATION = 1; // seconds
const int WEBSOCKET_MAX_BACKOFF_DURATION = 64; // seconds
const int WEBSOCKET_TIMEOUT_DURATION = 2; // minutes

class WebsocketManager {
  static final FimberLog logger = FimberLog('WebSocketManager');
  late final String url;
  WebSocketChannel? _ws;
  StreamSubscription<dynamic>? _webSocketSS;
  final StreamController<dynamic> webSocketSC =
      StreamController<dynamic>.broadcast();
  Timer? _connectTimer;
  dynamic _cachedData;
  late int _connectBackoffDuration;

  WebsocketManager({
    required this.url,
  }) {
    _resetConnectBackoffDuration();
    _setupConnectTimer();
  }

  Future<void> dispose() async {
    await webSocketSC.close();
    _connectTimer?.cancel();
    _connectTimer = null;
    await _webSocketSS?.cancel();
    _webSocketSS = null;
    await _ws?.sink.close();
    _ws = null;
  }

  bool isConnected() {
    return _webSocketSS != null;
  }

  void requestConnectNow() {
    _resetConnectBackoffDuration();
    _connectWebSocket();
  }

  void _setupConnectTimer() {
    _connectTimer?.cancel();
    _connectTimer = Timer(Duration(seconds: _connectBackoffDuration), () {
      _connectWebSocket();
    });
  }

  void _resetConnectBackoffDuration() {
    _connectBackoffDuration = WEBSOCKET_INITIAL_BACKOFF_DURATION;
  }

  void _increaseConnectBackoffDuration() {
    _connectBackoffDuration = _connectBackoffDuration * 2;
    if (_connectBackoffDuration >= WEBSOCKET_MAX_BACKOFF_DURATION) {
      _connectBackoffDuration = WEBSOCKET_MAX_BACKOFF_DURATION;
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      if (_ws == null) {
        await runZonedGuarded<Future<void>>(() async {
          _ws = WebSocketChannel.connect(Uri.parse(url));
        }, (err, stackTrace) async {
          logger.e('ERROR: $err');
          logger.d('$stackTrace');
          _increaseConnectBackoffDuration();
          await _cleanReconnect();
        });
        await _webSocketSS?.cancel(); // just in case
        _webSocketSS = _ws!.stream.timeout(const Duration(minutes: WEBSOCKET_TIMEOUT_DURATION),
                  onTimeout: (EventSink<dynamic> eventSink) async {
            logger.w('websocket timed out, closing');
            eventSink.close();
            _increaseConnectBackoffDuration();
            await _cleanReconnect();
          }).listen((dynamic data) {
            _resetConnectBackoffDuration();
            logger.v('websocket data: $data');
            _cachedData = data;
            if (webSocketSC.hasListener) {
              webSocketSC.add(_cachedData);
            }
          }, onDone: () async {
            await _cleanReconnect();
          }, onError: (Object error, StackTrace stacktrace) async {
            logger.e('websocket error: $error');
            await _cleanReconnect();
          }, cancelOnError: true);
      }
    } catch (err, stackTrace) {
      logger.e('ERROR: $err');
      logger.d('$stackTrace');
      _increaseConnectBackoffDuration();
      await _cleanReconnect();
    }
  }

  Future<void> _cleanReconnect() async {
    await _webSocketSS?.cancel();
    _webSocketSS = null;
    await _ws?.sink.close();
    _ws = null;
    _setupConnectTimer();
  }
}
