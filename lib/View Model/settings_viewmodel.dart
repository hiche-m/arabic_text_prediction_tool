import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:taln/Model/taln.dart';

class SettingsVM {
  SettingsVM({required this.taln});

  final TALN taln;
  int _numRows = 0;
  int _numWords = 0;
  int showingTooltip = -1;
  static String dataSetPath = "assets/dataset.txt";
  var res;

//numRows boolean Stream
  final StreamController<List<int>> _statsController =
      StreamController<List<int>>.broadcast();

  Stream<List<int>> get statsStream => _statsController.stream;

//numRows boolean Stream
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();

  Stream<bool> get loadingStream => _loadingController.stream;

  Future getStats() async {
    var res = await taln.getStats(dataSetPath);
    if (res["result"] != null) {
      var stats = res["result"]["stats"];
      try {
        _numWords = stats.fold(0, (sum, element) => sum + element);
      } catch (e) {
        _numWords = 0;
      }
      try {
        _numRows = stats.length;
      } catch (e) {
        _numRows = 0;
      }
      _statsController.add([_numRows, _numWords]);
    }
  }

  Future getTopN(BuildContext context, int num, height, width) async {
    _loadingController.add(true);
    res = await taln.getTopN(dataSetPath, num);
    return showTop(context, res, height, width);
  }

  BarChartGroupData generateGroupData(int x, int y, showingTooltip) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: showingTooltip == x ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.red],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 20.0,
          borderRadius: const BorderRadius.all(Radius.circular(3.5)),
        ),
      ],
    );
  }

  Future showTop(context, result, height, width) {
    List<BarChartGroupData>? groups = [];
    int j = result.length - 1;
    for (int i = 0; i < result.length; i++) {
      groups.add(generateGroupData(j, result[j][1], showingTooltip));
      j--;
    }
    _loadingController.add(false);
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: SizedBox(
              height: height / 1.1,
              width: width / 1.2,
              child: FractionallySizedBox(
                heightFactor: 0.9,
                widthFactor: 0.85,
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: double.parse((result[0][1] + 1000).toString()),
                    barGroups: groups,
                    gridData: FlGridData(drawVerticalLine: false),
                    borderData: FlBorderData(
                      border: const Border(
                        left: BorderSide(width: 0.1, color: Colors.black),
                        right: BorderSide(width: 0.1, color: Colors.black),
                        bottom: BorderSide(width: 0.1, color: Colors.black),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: getBottomTitles,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: getRightTitles,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    String title = res[value.toInt()][0];
    return SideTitleWidget(
      space: 2.0,
      axisSide: meta.axisSide,
      child: Text(title),
    );
  }

  Widget getRightTitles(double value, TitleMeta meta) {
    String newValue = value.toInt().toString();
    switch (newValue[0]) {
      case "1":
        newValue = "ألف";
        break;
      case "2":
        newValue = "ألفين";
        break;
      default:
        newValue = "${newValue[0]} آ";
        break;
    }
    return SideTitleWidget(
      space: 2.0,
      axisSide: meta.axisSide,
      child: Text(
        newValue,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
    );
  }
}
