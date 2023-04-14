import 'package:flutter/material.dart';
import 'package:taln/View%20Model/home_viewmodel.dart';
import 'package:taln/View/settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final hvm = HomeVM();
  bool show = true;
  bool generating = false;
  bool loading = false;
  bool immmobilize = false;
  String queryText = "";
  List suggestions = [];
  List selections = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    hvm.getGenerating.listen((event) {
      generating != event
          ? setState(() {
              generating = event;
            })
          : null;
    });
    hvm.getImmmobilize.listen((event) {
      immmobilize != event
          ? setState(() {
              immmobilize = event;
            })
          : null;
    });
    hvm.getLoading.listen((event) {
      loading != event
          ? setState(() {
              loading = event;
            })
          : null;
    });
    hvm.getQuery.listen((event) {
      queryText != event
          ? setState(() {
              queryText = event;
            })
          : null;
    });
    hvm.getSelections.listen((event) {
      selections != event
          ? setState(() {
              selections = event;
            })
          : null;
    });
    hvm.getShow.listen((event) {
      show != event
          ? setState(() {
              show = event;
            })
          : null;
    });
    hvm.getSuggestions.listen((event) {
      suggestions != event
          ? setState(() {
              suggestions = event;
            })
          : null;
    });
    hvm.init();
    hvm.resetSuggestions();
    hvm.clinote();
  }

  @override
  void dispose() {
    super.dispose();
    hvm.controller.dispose();
    hvm.taln.finalize();
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
                        controller: hvm.controller,
                        focusNode: hvm.focusNode,
                        onSubmitted: (value) async {
                          setState(() {
                            queryText += " $value";
                            hvm.controller.clear();
                            hvm.focusNode.requestFocus();
                          });
                          hvm.getNextWord(queryText);
                          setState(() {});
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
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const Settings(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = const Offset(1.0, -1.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                position: offsetAnimation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
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
                                    onPressed: immmobilize
                                        ? null
                                        : () async {
                                            hvm.generate(queryText);
                                            setState(() {});
                                          },
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
                                        hvm.removeWord(queryText);
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
                                          hvm.resetSuggestions();
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
                              text: "${queryText} ",
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
                                      color: Colors.grey.shade600,
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
                      itemExtent: width / suggestions.length,
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
                                      hvm.getNextWord(queryText);
                                      setState(() {});
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1.0),
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
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: CircleAvatar(
                                        maxRadius: (height / 3) / 15,
                                        backgroundColor: Colors.grey.shade100,
                                        child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              (len - index).toString(),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            )),
                                      ),
                                    ),
                                    Center(
                                      child: loading
                                          ? CircularProgressIndicator(
                                              backgroundColor:
                                                  Colors.grey.shade400,
                                              color: Colors.grey.shade700,
                                            )
                                          : Text(
                                              suggestions[len - 1 - index],
                                              softWrap: false,
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 30,
                                              ),
                                            ),
                                    ),
                                  ],
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
}
