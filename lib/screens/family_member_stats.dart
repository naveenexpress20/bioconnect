import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FamilyMemberStatsPage extends StatefulWidget {
  final String memberId;
  final String memberName;
  final String memberAge;
  final String memberImage;

  const FamilyMemberStatsPage({
    Key? key,
    required this.memberId,
    required this.memberName,
    required this.memberAge,
    this.memberImage = '', // Made optional with empty string default
  }) : super(key: key);

  @override
  State<FamilyMemberStatsPage> createState() => _FamilyMemberStatsPageState();
}

class _FamilyMemberStatsPageState extends State<FamilyMemberStatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedTimeFrame = 'Daily';

  // Mock health data - replace with actual data source later
  final Map<String, dynamic> _mockHealthData = {
    'heartRate': 75,
    'systolic': 120,
    'diastolic': 80,
    'temperature': 98.6,
    'glucose': 95,
    'spo2': 98,
    'respirationRate': 16,
  };

  // Mock historical data for trends
  final List<Map<String, dynamic>> _mockHistoryData = [
    {'heartRate': 72, 'systolic': 118, 'temperature': 98.4, 'glucose': 92, 'timestamp': DateTime.now().subtract(Duration(days: 6))},
    {'heartRate': 74, 'systolic': 122, 'temperature': 98.5, 'glucose': 94, 'timestamp': DateTime.now().subtract(Duration(days: 5))},
    {'heartRate': 76, 'systolic': 119, 'temperature': 98.7, 'glucose': 96, 'timestamp': DateTime.now().subtract(Duration(days: 4))},
    {'heartRate': 73, 'systolic': 121, 'temperature': 98.3, 'glucose': 93, 'timestamp': DateTime.now().subtract(Duration(days: 3))},
    {'heartRate': 75, 'systolic': 120, 'temperature': 98.6, 'glucose': 95, 'timestamp': DateTime.now().subtract(Duration(days: 2))},
    {'heartRate': 77, 'systolic': 123, 'temperature': 98.8, 'glucose': 97, 'timestamp': DateTime.now().subtract(Duration(days: 1))},
    {'heartRate': 75, 'systolic': 120, 'temperature': 98.6, 'glucose': 95, 'timestamp': DateTime.now()},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.memberName}\'s Health Stats',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: () => _shareStats(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Member Info Header
          _buildMemberHeader(),

          // Time Frame Selector
          _buildTimeFrameSelector(),

          // Stats Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVitalsTab(),
                _buildTrendsTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildMemberHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: widget.memberImage.isNotEmpty
                ? NetworkImage(widget.memberImage)
                : null,
            backgroundColor: const Color(0xFF4A90E2),
            child: widget.memberImage.isEmpty
                ? Text(
              widget.memberName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.memberName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age: ${widget.memberAge}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // Health status using mock data
                Builder(
                  builder: (context) {
                    final status = _getHealthStatus(_mockHealthData);
                    return Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: status['color'],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status['text'],
                          style: TextStyle(
                            fontSize: 12,
                            color: status['color'],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4A90E2),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF4A90E2),
            tabs: const [
              Tab(text: 'Vitals'),
              Tab(text: 'Trends'),
              Tab(text: 'Reports'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Daily', 'Weekly', 'Monthly'].map((timeFrame) {
              return GestureDetector(
                onTap: () => setState(() => selectedTimeFrame = timeFrame),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedTimeFrame == timeFrame
                        ? const Color(0xFF4A90E2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selectedTimeFrame == timeFrame
                          ? const Color(0xFF4A90E2)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    timeFrame,
                    style: TextStyle(
                      color: selectedTimeFrame == timeFrame
                          ? Colors.white
                          : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsTab() {
    // Using mock data instead of Firebase stream
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildVitalCard(
            'Heart Rate',
            '${_mockHealthData['heartRate']}',
            'bpm',
            Icons.favorite,
            Colors.red,
            _getHeartRateStatus(_mockHealthData['heartRate']),
          ),
          _buildVitalCard(
            'Blood Pressure',
            '${_mockHealthData['systolic']}/${_mockHealthData['diastolic']}',
            'mmHg',
            Icons.monitor_heart,
            Colors.purple,
            _getBloodPressureStatus(_mockHealthData['systolic'], _mockHealthData['diastolic']),
          ),
          _buildVitalCard(
            'Body Temperature',
            '${_mockHealthData['temperature']}',
            '°F',
            Icons.thermostat,
            Colors.orange,
            _getTemperatureStatus(_mockHealthData['temperature']),
          ),
          _buildVitalCard(
            'Glucose Level',
            '${_mockHealthData['glucose']}',
            'mg/dL',
            Icons.water_drop,
            Colors.blue,
            _getGlucoseStatus(_mockHealthData['glucose']),
          ),
          _buildVitalCard(
            'SpO₂',
            '${_mockHealthData['spo2']}',
            '%',
            Icons.air,
            Colors.teal,
            _getSpO2Status(_mockHealthData['spo2']),
          ),
          _buildVitalCard(
            'Respiration Rate',
            '${_mockHealthData['respirationRate']}',
            'breaths/min',
            Icons.healing,
            Colors.green,
            _getRespirationStatus(_mockHealthData['respirationRate']),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, String unit, IconData icon,
      Color color, Map<String, dynamic> status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: status['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status['text'],
                      style: TextStyle(
                        fontSize: 12,
                        color: status['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    // Using mock historical data instead of Firebase stream
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTrendChart('Heart Rate', 'heartRate', Colors.red),
          _buildTrendChart('Blood Pressure (Systolic)', 'systolic', Colors.purple),
          _buildTrendChart('Temperature', 'temperature', Colors.orange),
          _buildTrendChart('Glucose', 'glucose', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildTrendChart(String title, String field, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Builder(
              builder: (context) {
                // Use mock historical data
                if (_mockHistoryData.isEmpty) {
                  return Center(
                    child: Text(
                      'No trend data available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                final spots = _mockHistoryData.asMap().entries.map((entry) {
                  final data = entry.value;
                  final value = (data[field] ?? 0).toDouble();
                  return FlSpot(entry.key.toDouble(), value);
                }).toList();

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: color,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withOpacity(0.1),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: color,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportCard(
            'Weekly Summary',
            'View comprehensive weekly health report',
            Icons.calendar_today,
            Colors.blue,
                () => _generateWeeklyReport(),
          ),
          _buildReportCard(
            'Monthly Analysis',
            'Detailed monthly health analysis and trends',
            Icons.date_range,
            Colors.green,
                () => _generateMonthlyReport(),
          ),
          _buildReportCard(
            'Custom Report',
            'Generate custom date range reports',
            Icons.tune,
            Colors.orange,
                () => _generateCustomReport(),
          ),
          _buildReportCard(
            'Export Data',
            'Export health data to PDF or CSV',
            Icons.download,
            Colors.purple,
                () => _exportData(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _compareWithFamily(),
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Compare'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4A90E2),
                side: const BorderSide(color: Color(0xFF4A90E2)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _setAlerts(),
              icon: const Icon(Icons.notifications),
              label: const Text('Set Alerts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No health data available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sensor data will appear here once connected',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Health status helper methods
  Map<String, dynamic> _getHealthStatus(Map<String, dynamic> data) {
    // Overall health status based on multiple vitals
    final heartRate = data['heartRate'] ?? 0;
    final systolic = data['systolic'] ?? 0;
    final diastolic = data['diastolic'] ?? 0;
    final temperature = data['temperature'] ?? 0.0;

    if (heartRate > 100 || systolic > 140 || diastolic > 90 || temperature > 100.4) {
      return {'color': Colors.red, 'text': 'Attention Needed'};
    } else if (heartRate < 60 || systolic < 90 || diastolic < 60) {
      return {'color': Colors.orange, 'text': 'Monitor Closely'};
    } else {
      return {'color': Colors.green, 'text': 'Normal Range'};
    }
  }

  Map<String, dynamic> _getHeartRateStatus(dynamic heartRate) {
    final hr = (heartRate ?? 0).toInt();
    if (hr < 60) return {'color': Colors.orange, 'text': 'Below Normal'};
    if (hr > 100) return {'color': Colors.red, 'text': 'Above Normal'};
    return {'color': Colors.green, 'text': 'Normal'};
  }

  Map<String, dynamic> _getBloodPressureStatus(dynamic systolic, dynamic diastolic) {
    final sys = (systolic ?? 0).toInt();
    final dia = (diastolic ?? 0).toInt();
    if (sys > 140 || dia > 90) return {'color': Colors.red, 'text': 'High'};
    if (sys < 90 || dia < 60) return {'color': Colors.orange, 'text': 'Low'};
    return {'color': Colors.green, 'text': 'Normal'};
  }

  Map<String, dynamic> _getTemperatureStatus(dynamic temperature) {
    final temp = (temperature ?? 0.0).toDouble();
    if (temp > 100.4) return {'color': Colors.red, 'text': 'Fever'};
    if (temp < 97.0) return {'color': Colors.orange, 'text': 'Low'};
    return {'color': Colors.green, 'text': 'Normal'};
  }

  Map<String, dynamic> _getGlucoseStatus(dynamic glucose) {
    final gluc = (glucose ?? 0).toInt();
    if (gluc > 140) return {'color': Colors.red, 'text': 'High'};
    if (gluc < 70) return {'color': Colors.orange, 'text': 'Low'};
    return {'color': Colors.green, 'text': 'Normal'};
  }

  Map<String, dynamic> _getSpO2Status(dynamic spo2) {
    final sp = (spo2 ?? 0).toInt();
    if (sp < 95) return {'color': Colors.red, 'text': 'Low'};
    if (sp < 98) return {'color': Colors.orange, 'text': 'Monitor'};
    return {'color': Colors.green, 'text': 'Normal'};
  }

  Map<String, dynamic> _getRespirationStatus(dynamic respirationRate) {
    final rr = (respirationRate ?? 0).toInt();
    if (rr > 20 || rr < 12) return {'color': Colors.orange, 'text': 'Monitor'};
    return {'color': Colors.green, 'text': 'Normal'};
  }

  // Action methods
  void _shareStats() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality will be implemented')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View History'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _generateWeeklyReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating weekly report...')),
    );
  }

  void _generateMonthlyReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating monthly report...')),
    );
  }

  void _generateCustomReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom report generator will be implemented')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality will be implemented')),
    );
  }

  void _compareWithFamily() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Family comparison will be implemented')),
    );
  }

  void _setAlerts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert settings will be implemented')),
    );
  }
}