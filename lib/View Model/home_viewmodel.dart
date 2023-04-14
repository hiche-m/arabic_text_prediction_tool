import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taln/Model/taln.dart';

class HomeVM {
  final taln = TALN();

  static bool show = true;
  static int filter = 7;
  static String dataSetPath = "assets/dataset.txt";

  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

//Generating boolean Stream
  final StreamController<bool> _generatingController =
      StreamController<bool>.broadcast();

  Stream<bool> get getGenerating => _generatingController.stream;

//Show boolean stream
  final StreamController<bool> _showController =
      StreamController<bool>.broadcast();

  Stream<bool> get getShow => _showController.stream;

//Loading boolean stream
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();

  Stream<bool> get getLoading => _loadingController.stream;

//Immmobilize boolean stream
  final StreamController<bool> _immmobilizeController =
      StreamController<bool>.broadcast();

  Stream<bool> get getImmmobilize => _immmobilizeController.stream;

//Query string stream
  final StreamController<String> _queryController =
      StreamController<String>.broadcast();

  Stream<String> get getQuery => _queryController.stream;

//Suggestions String list stream
  final StreamController<List<String>> _suggestionsController =
      StreamController<List<String>>.broadcast();

  Stream<List<String>> get getSuggestions => _suggestionsController.stream;

//Selections boolean list stream
  final StreamController<List<bool>> _selectionsController =
      StreamController<List<bool>>.broadcast();

  Stream<List<bool>> get getSelections => _selectionsController.stream;

  init() async {
    await taln.initialize("python", "assets/taln.py", false);
  }

  clinote() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 800));
      show = !show;
      _showController.add(show);
    }
  }

  void dispose() {
    _generatingController.close();
    _showController.close();
    _loadingController.close();
    _immmobilizeController.close();
    _suggestionsController.close();
    _selectionsController.close();
  }

  Future generate(queryText) async {
    _generatingController.add(true);
    _immmobilizeController.add(true);
    var res = await taln.nextWord(dataSetPath, queryText.trim(), 2, filter);
    while (res["result"] != null && res["result"].isNotEmpty) {
      queryText += " ";
      String addT = "${res["result"][0]}";
      for (int i = 0; i < addT.length; i++) {
        queryText += addT[i];
        _queryController.add(queryText);
        await Future.delayed(const Duration(milliseconds: 50));
      }
      res = await taln.nextWord(dataSetPath, queryText.trim(), 2, filter);
    }
    queryText += ".";
    _queryController.add(queryText);
    _generatingController.add(false);
  }

  Future getNextWord(queryText) async {
    if (queryText != "") {
      _loadingController.add(true);
      var res = await taln.nextWord(dataSetPath, queryText.trim(), 2, filter);
      _loadingController.add(false);
      if (res["result"] != null) {
        resetSuggestions();
        var suggestions = List<String>.filled(res["result"].length, "");
        for (int i = 0; i < res["result"].length; i++) {
          suggestions[i] = res["result"][i];
        }
        _suggestionsController.add(suggestions);
      }
      if (res["result"].length == 0) {
        queryText += ".";
        _queryController.add(queryText);
      }
    }
  }

  resetSuggestions() {
    _immmobilizeController.add(false);
    var suggestions = List<String>.filled(filter, "");
    _suggestionsController.add(suggestions);
    var selections = List<bool>.filled(filter, false);
    _selectionsController.add(selections);
  }

  void removeWord(queryText) async {
    var words = queryText.split(" ");
    words.removeLast();
    queryText = words.join(" ");
    _queryController.add(queryText);
    if (queryText == "") {
      resetSuggestions();
    } else {
      await getNextWord(queryText);
    }
  }
}
