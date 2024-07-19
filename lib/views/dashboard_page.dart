import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Información',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      color: Colors.blue,
                      title: '40%',
                    ),
                    PieChartSectionData(
                      value: 30,
                      color: Colors.red,
                      title: '30%',
                    ),
                    PieChartSectionData(
                      value: 20,
                      color: Colors.green,
                      title: '20%',
                    ),
                    PieChartSectionData(
                      value: 10,
                      color: Colors.yellow,
                      title: '10%',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1),
                        FlSpot(1, 3),
                        FlSpot(2, 2),
                        FlSpot(3, 5),
                        FlSpot(4, 3),
                      ],
                      isCurved: true,
                      color: Colors.blue, // Use colors property here
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
