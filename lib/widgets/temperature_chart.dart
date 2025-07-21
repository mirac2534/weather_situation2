import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/wheather_model.dart';

class TemperatureChart extends StatelessWidget {
  final List<WheatherModel> weathers;

  const TemperatureChart({Key? key, required this.weathers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    final chartHeight = deviceHeight * 0.45;
    final leftPadding = deviceWidth * 0.17;
    final rightPadding = deviceWidth * 0.11;
    final chartWidth = deviceWidth - leftPadding - rightPadding;
    final horizontalPadding = deviceWidth * 0.11;
    final itemSpacing = chartWidth / (weathers.length - 1);

    final maxTemps = weathers.map((w) => double.tryParse(w.max) ?? 0).toList();
    final minTemps = weathers.map((w) => double.tryParse(w.min) ?? 0).toList();
    final allTemps = [...maxTemps, ...minTemps];
    final maxY = allTemps.reduce((a, b) => a > b ? a : b) + 2;
    final minY = allTemps.reduce((a, b) => a < b ? a : b) - 2;

    return SizedBox(
      height: chartHeight + 60,
      child: Stack(
        children: [
          // Grafik (tek LineChart içinde 2 çizgi)
          Positioned(
            left: horizontalPadding,
            right: horizontalPadding,
            top: 0,
            height: chartHeight,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  _buildLine(maxTemps, const Color(0xFFF57C00)), // Gündüz
                  _buildLine(minTemps, const Color(0xFF1565C0)), // Gece
                ],
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(enabled: false),
              ),
            ),
          ),

          // Gündüz değerleri
          ..._buildValueTexts(
            temps: maxTemps,
            color: const Color(0xFFF57C00),
            chartHeight: chartHeight,
            chartWidth: chartWidth,
            itemSpacing: itemSpacing,
            minY: minY,
            maxY: maxY,
            horizontalPadding: horizontalPadding,
            shiftY: -22,
          ),

          // Gece değerleri
          ..._buildValueTexts(
            temps: minTemps,
            color: const Color(0xFF1565C0),
            chartHeight: chartHeight,
            chartWidth: chartWidth,
            itemSpacing: itemSpacing,
            minY: minY,
            maxY: maxY,
            horizontalPadding: horizontalPadding,
            shiftY: 8,
          ),

          // Gün etiketleri
          ..._buildDayLabels(
            count: weathers.length,
            itemSpacing: itemSpacing,
            horizontalPadding: horizontalPadding,
            topOffset: chartHeight + 20,
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(List<double> temps, Color color) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 1,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(show: false),
      spots: temps.asMap().entries.map((entry) {
        final index = entry.key;
        return FlSpot(index.toDouble(), entry.value);
      }).toList(),
    );
  }

  List<Widget> _buildValueTexts({
    required List<double> temps,
    required Color color,
    required double chartHeight,
    required double chartWidth,
    required double itemSpacing,
    required double minY,
    required double maxY,
    required double horizontalPadding,
    required double shiftY,
  }) {
    return temps.asMap().entries.map((entry) {
      final index = entry.key;
      final temp = entry.value;

      final x = horizontalPadding + index * itemSpacing;
      final yRatio = (temp - minY) / (maxY - minY);
      final y = chartHeight * (1 - yRatio);

      return Positioned(
        left: x - 10,
        top: y + shiftY,
        child: Text(
          '${temp.round()}°',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildDayLabels({
    required int count,
    required double itemSpacing,
    required double horizontalPadding,
    required double topOffset,
  }) {
    return List.generate(count, (index) {
      final label = _getDayLabel(index);
      final x = horizontalPadding + index * itemSpacing;

      return Positioned(
        left: x - 10,
        top: topOffset,
        child: Text(label, style: _labelStyle),
      );
    });
  }

  String _getDayLabel(int index) {
    if (index == 0) return "Bugün";
    if (index == 1) return "Yarın";

    // Haftanın günlerini Monday=1, Sunday=7 sırasına göre diz
    final dayNames = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
    final date = DateTime.now().add(Duration(days: index));

    return dayNames[date.weekday - 1];
  }

  static const _labelStyle = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
  );
}
