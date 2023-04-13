import 'package:flutter/material.dart';
import 'package:flython/flython.dart';

void main() {
  runApp(const MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  late List selections;
  final taln = TALN();
  String queryText = "";

  @override
  void initState() {
    super.initState();
    init();
    clinote();
    resetSuggestions();
  }

  init() async {
    await taln.initialize("python", "assets/taln.py", false);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    taln.finalize();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      alignment: Alignment.centerRight,
                      child: TextField(
                        enabled: immmobilize ? false : true,
                        controller: controller,
                        focusNode: focusNode,
                        onSubmitted: (value) async {
                          setState(() {
                            queryText += " $value";
                            controller.clear();
                            focusNode.requestFocus();
                          });
                          await getNextWord();
                        },
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'لتأكيد كتابتك' ' ENTER ' 'إضغط على',
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(':' 'أكتب هنا'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Column(
                      children: [
                        Expanded(
                            child: queryText != ""
                                ? IconButton(
                                    onPressed:
                                        immmobilize ? null : () => generate(),
                                    icon: Icon(
                                      Icons.auto_fix_normal,
                                      color: Colors.grey.shade800,
                                    ),
                                  )
                                : Icon(
                                    Icons.auto_fix_off,
                                    color: Colors.grey.shade600,
                                  )),
                        Expanded(
                          child: IconButton(
                              onPressed: generating || queryText == ""
                                  ? null
                                  : () {
                                      if (queryText != "") {
                                        removeWord();
                                        setState(() {});
                                        immmobilize = false;
                                      }
                                    },
                              icon: Icon(
                                Icons.backspace,
                                color: generating || queryText == ""
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade800,
                              )),
                        ),
                        Expanded(
                          child: IconButton(
                              onPressed: generating || queryText == ""
                                  ? null
                                  : () {
                                      if (queryText != "") {
                                        setState(() {
                                          queryText = "";
                                          resetSuggestions();
                                          immmobilize = false;
                                        });
                                      }
                                    },
                              icon: Icon(
                                Icons.delete,
                                color: generating || queryText == ""
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade800,
                              )),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        textDirection: TextDirection.rtl,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "$queryText ",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 25,
                              ),
                            ),
                            WidgetSpan(
                              child: show
                                  ? Container(
                                      width: 2,
                                      height: 20,
                                      color: Colors.grey,
                                    )
                                  : const SizedBox(),
                              baseline: TextBaseline.alphabetic,
                              alignment: PlaceholderAlignment.middle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (immmobilize)
              const SizedBox()
            else
              SizedBox(
                height: height / 3,
                width: width,
                child: Center(
                  child: ListView.builder(
                      itemCount: suggestions.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        var len = suggestions.length;
                        double opacity = 0.65 * index / (len - 1);
                        opacity = opacity.clamp(0.2, 0.65);
                        if (suggestions[len - 1 - index] != "") {
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onHover: (event) {
                              setState(() {
                                selections[len - 1 - index] = true;
                              });
                            },
                            onExit: (event) {
                              setState(() {
                                selections[len - 1 - index] = false;
                              });
                            },
                            child: GestureDetector(
                              onTap: loading
                                  ? null
                                  : () async {
                                      queryText +=
                                          " ${suggestions[len - 1 - index]}";
                                      setState(() {
                                        selections[len - 1 - index] = false;
                                      });
                                      await getNextWord();
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                width: width / len,
                                decoration: BoxDecoration(
                                  color: selections[len - 1 - index]
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey.shade100
                                          .withOpacity(opacity),
                                  border: Border.all(color: Colors.transparent),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0)),
                                ),
                                child: Center(
                                  child: loading
                                      ? CircularProgressIndicator(
                                          backgroundColor: Colors.grey.shade400,
                                          color: Colors.grey.shade700,
                                        )
                                      : Text(
                                          suggestions[len - 1 - index],
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 30,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool show = true;
  String dataSetPath = "assets/dataset.txt";
  late List suggestions;
  bool loading = false;
  bool generating = false;
  bool immmobilize = false;
  int filter = 7;

  clinote() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        show = !show;
      });
    }
  }

  Future generate() async {
    setState(() {
      generating = true;
      immmobilize = true;
    });
    var res = await taln.nextWord(dataSetPath, queryText.trim(), 2, filter);
    while (res["result"] != null && res["result"].isNotEmpty) {
      queryText += " ${res["result"][0]}";
      setState(() {});
      res = await taln.nextWord(dataSetPath, queryText.trim(), 2, filter);
    }
    queryText += ".";
    setState(() {
      generating = false;
    });
  }

  Future getNextWord() async {
    if (queryText != "") {
      setState(() {
        loading = true;
      });
      var res = await taln.nextWord(dataSetPath, queryText.trim(), 2, filter);
      setState(() {
        loading = false;
      });
      if (res["result"] != null) {
        resetSuggestions();
        for (int i = 0; i < res["result"].length; i++) {
          suggestions[i] = res["result"][i];
        }
        setState(() {});
      }
    }
  }

  resetSuggestions() {
    suggestions = [];
    selections = [];
    for (int i = 0; i < filter; i++) {
      suggestions.add("");
      selections.add(false);
    }
  }

  void removeWord() async {
    var words = queryText.split(" ");
    words.removeLast();
    queryText = words.join(" ");
    if (queryText == "") {
      resetSuggestions();
    } else {
      await getNextWord();
    }
  }
}

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
