import 'package:fimber/fimber.dart';

DebugTree? debugTree;

class Logging {
  static final Map<String, ColorizeStyle> defaultColourMap =
      <String, ColorizeStyle>{
    'V': ColorizeStyle(<AnsiStyle>[AnsiStyle.foreground(AnsiColor.cyan)]),
    'D': ColorizeStyle(<AnsiStyle>[AnsiStyle.foreground(AnsiColor.green)]),
    'I': ColorizeStyle(<AnsiStyle>[AnsiStyle.foreground(AnsiColor.blue)]),
    'W': ColorizeStyle(<AnsiStyle>[AnsiStyle.foreground(AnsiColor.yellow)]),
    'E': ColorizeStyle(<AnsiStyle>[AnsiStyle.foreground(AnsiColor.red)])
  };

  static Future<void> enableDebugLog() async {
    const List<String> logLevels = <String>['V', 'D', 'I', 'W', 'E'];
    if (debugTree != null) {
      Fimber.unplantTree(debugTree!);
      debugTree = null;
    }
    debugTree = DebugTree(printTimeType: 0, logLevels: logLevels);
    debugTree!.colorizeMap = defaultColourMap;
    Fimber.plantTree(debugTree!);
  }
}
