// home_dashboard_graph.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeDashboardGraph extends StatefulWidget {
  final String selectedCategory;
  final DateTime? selectedDay;

  const HomeDashboardGraph({
    super.key,
    required this.selectedCategory,
    required this.selectedDay,
  });

  @override
  _HomeDashboardGraphState createState() => _HomeDashboardGraphState();
}

class _HomeDashboardGraphState extends State<HomeDashboardGraph> {
  bool _isLoading = true;

  // 棒グラフ (学習達成度) 用データ
  List<BarChartGroupData> _barGroups = [];
  // 折れ線グラフ (目標達成度) 用データ
  List<FlSpot> _lineSpots = [];

  // 7日分の日付
  late DateTime _centerDay;
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _initCenterAndDays();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant HomeDashboardGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dayChanged = (oldWidget.selectedDay != widget.selectedDay);
    final categoryChanged = (oldWidget.selectedCategory != widget.selectedCategory);
    if (dayChanged || categoryChanged) {
      _initCenterAndDays();
      _fetchData();
    }
  }

  void _initCenterAndDays() {
    _centerDay = widget.selectedDay ?? DateTime.now();
    // 前後3日 + 中心日 = 計7日
    _days = List.generate(7, (i) => _centerDay.add(Duration(days: i - 3)));
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        setState(() => _isLoading = false);
        return;
      }

      final followingSubjects =
          List<String>.from(userDoc.data()?['following_subjects'] ?? []);
      final category = widget.selectedCategory;

      // "全体" の場合はフォロー中教科の合計、それ以外は特定教科
      final wordCount = await _calcWordCount(category, followingSubjects);

      final List<BarChartGroupData> barGroups = [];
      final List<FlSpot> lineSpots = [];

      for (int i = 0; i < 7; i++) {
        final day = _days[i];
        final dayKey = DateFormat('yyyy-MM-dd').format(day);

        // Firestore: Users/{uid}/record/{dayKey}
        final recordDocRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('record')
            .doc(dayKey);

        final recordDoc = await recordDocRef.get();

        double sumToday = 0.0; // その日学習達成度合計
        double sumAll = 0.0;   // その日累積学習合計

        if (category == '全体') {
          // 全体 => followingSubjects を合算
          for (final subj in followingSubjects) {
            final colSnap = await recordDocRef.collection(subj).get();
            for (final cDoc in colSnap.docs) {
              final data = cDoc.data();
              sumToday += (data['tierProgress_today'] ?? 0);
              sumAll += (data['tierProgress_all'] ?? 0);
            }
          }
        } else {
          // 特定教科
          final colSnap = await recordDocRef.collection(category).get();
          for (final cDoc in colSnap.docs) {
            final data = cDoc.data();
            sumToday += (data['tierProgress_today'] ?? 0);
            sumAll += (data['tierProgress_all'] ?? 0);
          }
        }

        // 今日の学習目標量
        double todayGoal = 0.0;
        if (recordDoc.exists) {
          final docData = recordDoc.data()!;
          if (category == '全体') {
            for (final subj in followingSubjects) {
              todayGoal += (docData['${subj}_goal'] ?? 0).toDouble();
            }
          } else {
            todayGoal = (docData['${category}_goal'] ?? 0).toDouble();
          }
        }

        // 学習達成度 (バー)
        final todayRatio = (todayGoal == 0)
            ? 0
            : (sumToday / todayGoal).clamp(0, 1);

        // 目標達成度 (ライン)
        final allRatio = (wordCount == 0)
            ? 0
            : (sumAll / wordCount).clamp(0, 1);

        // 1) 棒グラフは 0 でも表示 (該当日が未来でも 0 で棒を出す)
        final rodData = BarChartRodData(
          toY: todayRatio.toDouble(),
          color: const Color(0xFF0ABAB5),
          width: 12,
        );
        final group = BarChartGroupData(
          x: i,
          barRods: [rodData],
        );
        barGroups.add(group);

        // 2) 折れ線グラフはデータがない or 未来日ならスキップ
        final now = DateTime.now();
        // 未来日判定: day.isAfter(DateTime(...))  (時分秒切り捨ててもOK)
        final dayDateOnly = DateTime(day.year, day.month, day.day);
        final todayDateOnly = DateTime(now.year, now.month, now.day);

        final bool isFutureDay = dayDateOnly.isAfter(todayDateOnly);
        //final bool hasNoData = (sumAll == 0); // 累積学習がない⇒データなしとみなす

        if (!isFutureDay) {
          // 未来日でもなく、かつ sumAll>0 な日だけ 折れ線の点を追加
          lineSpots.add(FlSpot(i.toDouble(), allRatio.toDouble()));
        }
      }

      setState(() {
        _barGroups = barGroups;
        _lineSpots = lineSpots;
        _isLoading = false;
      });
    } catch (e) {
      print('HomeDashboardGraph error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<double> _calcWordCount(String category, List<String> following) async {
    if (category == '全体') {
      double sum = 0;
      for (final s in following) {
        sum += _getTotalMinutes(s);
      }
      return sum;
    } else {
      return _getTotalMinutes(category);
    }
  }

  double _getTotalMinutes(String category) {
    switch (category) {
      case 'TOEIC300点':
        return 15;
      case 'TOEIC500点':
        return 27 + 33 + 28;
      case 'TOEIC700点':
        return 39.5 + 8;
      case 'TOEIC900点':
        return 48 + 15 + 45;
      case 'TOEIC990点':
        return 58;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double reservedLeftSide = (screenWidth-40) * 0.122 + 25; 
    final double reservedRightSide = (screenWidth-40) * 0.122 - 5;

    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0ABAB5)))),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // 背面: BarChart
          BarChart(
            BarChartData(
              minY: 0,
              maxY: 1,
              groupsSpace: 10,
              barGroups: _barGroups,
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 0.25,
                    getTitlesWidget: (value, meta) {
                      final perc = (value * 100).toInt();
                      return Text(
                        '$perc%',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= _days.length) {
                        return const SizedBox.shrink();
                      }
                      final dateStr = DateFormat('MM/dd').format(_days[i]);
                      return Text(
                        dateStr,
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: 0.25,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                    dashArray: [4, 2],
                  );
                },
              ),
            ),
          ),

          // 前面: LineChart
          IgnorePointer(
            ignoring: true,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: _lineSpots,
                    color: Colors.orange,
                    isCurved: false,
                    barWidth: 2,
                  ),
                ],
                // 棒グラフと合わせるための titlesData
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: reservedLeftSide,
                      getTitlesWidget: (value, meta) {
                        // 空で返して余白だけ確保
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: reservedRightSide,
                      getTitlesWidget: (value, meta) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
