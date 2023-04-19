import 'package:flutter/material.dart';
import 'package:taln/Component/headline.dart';
import 'package:taln/Component/number_picker.dart';
import 'package:taln/Model/taln.dart';
import 'package:taln/View%20Model/home_viewmodel.dart';
import 'package:taln/View%20Model/settings_viewmodel.dart';

class Settings extends StatefulWidget {
  final TALN taln;

  const Settings({required this.taln, super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late final SettingsVM svm;
  int _topsValue = 10;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    svm = SettingsVM(taln: widget.taln);
    init();
  }

  init() async {
    await svm.getStats();
    svm.loadingStream.listen((event) {
      if (loading != event) {
        setState(() {
          loading = event;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.6), BlendMode.lighten),
                image: const AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
                Column(
                  children: [
                    const Expanded(
                        flex: 1,
                        child: Headline(headlineText: "تعدادات الاقتراحات")),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            NumberInput(
                              initialValue: HomeVM.filter,
                              onChanged: ((value) {
                                HomeVM.filter = value;
                              }),
                            ),
                            const Text(
                              "العدد الأقصى",
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Tooltip(
                                message:
                                    "العدد الأقصى للكلمات الموالية المقترحة",
                                child: CircleAvatar(
                                  maxRadius: 7.0,
                                  backgroundColor: Colors.grey.shade500,
                                  child: FractionallySizedBox(
                                      heightFactor: 0.8,
                                      child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(
                                            Icons.question_mark,
                                            color: Colors.grey.shade100,
                                          ))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                        flex: 1, child: Headline(headlineText: "إحصائيات")),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              svm.getTopN(context, _topsValue, height, width);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text("اِفتح هنا"),
                            ),
                          ),
                          NumberInput(
                            initialValue: _topsValue,
                            onChanged: ((value) {
                              _topsValue = value;
                            }),
                          ),
                          Row(
                            children: [
                              const Text(
                                "الكلمات الأكثر تكرارًا",
                                style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Tooltip(
                                  message:
                                      "عدد الكلمات الأكثر ظهوراً في ملف البيانات مع كونه الرقم الذي أدخلته"
                                      " 'N' "
                                      "انقر على الزر الأيسر لرؤية مخطط شريطي يعرض أرقام التكرار ل",
                                  child: CircleAvatar(
                                    maxRadius: 7.0,
                                    backgroundColor: Colors.grey.shade500,
                                    child: FractionallySizedBox(
                                        heightFactor: 0.8,
                                        child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Icon(
                                              Icons.question_mark,
                                              color: Colors.grey.shade100,
                                            ))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: StreamBuilder<List>(
                              stream: svm.statsStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.active) {
                                  var numRows = snapshot.data![0];
                                  var numWords = snapshot.data![1];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "عدد الكلمات: $numWords\nعدد الأسطر: $numRows",
                                          textDirection: TextDirection.rtl,
                                          style: const TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Tooltip(
                                                  message:
                                                      "العدد الإجمالي للكلمات الموجودة في ملف البيانات",
                                                  child: CircleAvatar(
                                                    maxRadius: 7.0,
                                                    backgroundColor:
                                                        Colors.grey.shade500,
                                                    child: FractionallySizedBox(
                                                        heightFactor: 0.8,
                                                        child: FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: Icon(
                                                              Icons
                                                                  .question_mark,
                                                              color: Colors.grey
                                                                  .shade100,
                                                            ))),
                                                  ),
                                                ),
                                              ),
                                              Tooltip(
                                                message:
                                                    "عدد الأسطر الغير فارغة الموجودة في ملف البيانات",
                                                child: CircleAvatar(
                                                  maxRadius: 7.0,
                                                  backgroundColor:
                                                      Colors.grey.shade500,
                                                  child: FractionallySizedBox(
                                                      heightFactor: 0.8,
                                                      child: FittedBox(
                                                          fit: BoxFit.contain,
                                                          child: Icon(
                                                            Icons.question_mark,
                                                            color: Colors
                                                                .grey.shade100,
                                                          ))),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: Colors.grey.shade200,
                                      backgroundColor: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                        flex: 1, child: Headline(headlineText: "معلومات عنا")),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "المؤسسة"
                                ":\n"
                                "\tجامعة وهران للعلوم والتكنولوجيا\n محمد بوضياف",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "السنة الدراسية"
                                ":\n2022/2023",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "القسم"
                                ":\n"
                                "\tالذكاء الإصطناعي وتطبيقاته"
                                "\n"
                                "\tالفوج رقم 01",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "الأعضاء"
                                ":\n"
                                "\tرحماني محمد هشام"
                                "\n"
                                "\tبن حليمة عبد الرحمان",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          loading
              ? Container(
                  height: height,
                  width: width,
                  color: Colors.black.withOpacity(0.5),
                  child: const FractionallySizedBox(
                    heightFactor: 0.1,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        backgroundColor: Colors.grey,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
