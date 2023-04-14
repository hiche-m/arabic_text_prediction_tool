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
      "input": {
        "path": inputFile,
        "query": text,
        "num": num,
        "filtre": filtre,
      },
    };
    return await runCommand(command);
  }
}
