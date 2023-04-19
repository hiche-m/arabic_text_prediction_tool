import 'package:flython/flython.dart';

class TALN extends Flython {
  Future<dynamic> nextWord(
    String inputFile,
    String query,
    int num,
    int filtre,
  ) async {
    String text = '';
    for (int i = 0; i < query.length; i++) {
      int codePoint = query.codeUnitAt(i);
      text += '\\u${codePoint.toRadixString(16).padLeft(4, '0')}';
    }
    var command = {
      "cmd": 0,
      "input": {
        "path": inputFile,
        "query": text,
        "num": num,
        "filtre": filtre,
      },
    };
    return await runCommand(command);
  }

  Future<dynamic> getStats(String inputFile) async {
    var command = {
      "cmd": 1,
      "input": {
        "path": inputFile,
      },
    };
    return await runCommand(command);
  }

  Future<dynamic> getTopN(String inputFile, int num) async {
    var command = {
      "cmd": 2,
      "input": {
        "path": inputFile,
        "num": num,
      },
    };
    return await runCommand(command);
  }

  Future<dynamic> generate(
    String inputFile,
    String query,
  ) async {
    String text = '';
    for (int i = 0; i < query.length; i++) {
      int codePoint = query.codeUnitAt(i);
      text += '\\u${codePoint.toRadixString(16).padLeft(4, '0')}';
    }
    var command = {
      "cmd": 3,
      "input": {
        "path": inputFile,
        "query": text,
      },
    };
    return await runCommand(command);
  }
}
