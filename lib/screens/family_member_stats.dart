import 'package:flutter/material.dart';

class FamilyMemberStatsPage extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String age;
  final String gender;

  const FamilyMemberStatsPage({
    super.key,
    required this.name,
    required this.imageUrl,
    this.age = "",
    this.gender = "",
  });

  @override
  _FamilyMemberStatsPageState createState() => _FamilyMemberStatsPageState();
}

class _FamilyMemberStatsPageState extends State<FamilyMemberStatsPage> {
  String selectedReport = "Today"; // Default report type
  DateTime? startDate;
  DateTime? endDate;

  // Mock health data - replace with real sensor data
  Map<String, Map<String, String>> healthData = {
    "Today": {
      "Temperature": "98.6°F",
      "Pressure": "120/80 mmHg",
      "SPO2": "98%",
      "Glucose": "90 mg/dL",
      "Heart Rate": "72 bpm",
    },
    "Weekly": {
      "Temperature": "98.4°F avg",
      "Pressure": "118/78 mmHg avg",
      "SPO2": "97% avg",
      "Glucose": "88 mg/dL avg",
      "Heart Rate": "70 bpm avg",
    },
    "Monthly": {
      "Temperature": "98.5°F avg",
      "Pressure": "119/79 mmHg avg",
      "SPO2": "98% avg",
      "Glucose": "89 mg/dL avg",
      "Heart Rate": "71 bpm avg",
    },
    "Custom": {
      "Temperature": "98.3°F avg",
      "Pressure": "117/77 mmHg avg",
      "SPO2": "97% avg",
      "Glucose": "87 mg/dL avg",
      "Heart Rate": "69 bpm avg",
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${widget.name}'s Health Report"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile and Basic Info Section
            _buildProfileSection(),
            const SizedBox(height: 40),

            // Health Metrics Section
            _buildHealthMetricsSection(),
            const SizedBox(height: 40),

            // Report Type Selection
            _buildReportTypeButtons(),
            const SizedBox(height: 20),

            // Custom Date Picker (Only when "Custom" is selected)
            if (selectedReport == "Custom") _buildDatePicker(),
            if (selectedReport == "Custom") const SizedBox(height: 20),

            // Compare Button
            _buildCompareButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Image with Add Button
        Stack(
          children: [
            Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF4AFF4A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.imageUrl.isNotEmpty
                    ? Image.asset(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 60, color: Colors.black54);
                  },
                )
                    : const Icon(Icons.person, size: 60, color: Colors.black54),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  // TODO: Implement image picker functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Change profile picture feature coming soon!")),
                  );
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        // Basic Information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Name:", widget.name),
              _buildInfoRow("Age:", widget.age.isEmpty ? "25" : widget.age),
              _buildInfoRow("Gender:", widget.gender.isEmpty ? "Male" : widget.gender),
            ],
          ),
        ),
        // Pills decoration
        _buildPillsDecoration(),
      ],
    );
  }

  Widget _buildPillsDecoration() {
    return Container(
      width: 60,
      height: 40,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 30,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF6B9BFF),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 15,
            child: Container(
              width: 35,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsSection() {
    Map<String, String> currentData = healthData[selectedReport] ?? healthData["Today"]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$selectedReport Health Report",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...currentData.entries.map((entry) => _buildHealthMetric(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeButtons() {
    List<String> reportTypes = ["Today", "Weekly", "Monthly", "Custom"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Report Type:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reportTypes.map((type) => _buildReportButton(type)).toList(),
        ),
      ],
    );
  }

  Widget _buildReportButton(String reportType) {
    bool isSelected = selectedReport == reportType;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedReport = reportType;
          // Reset date selection when switching away from custom
          if (reportType != "Custom") {
            startDate = null;
            endDate = null;
          }
        });

        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Switched to $reportType report"),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A7FFF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A7FFF) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          reportType == "Custom" ? "Custom 📅" : reportType,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Custom Date Range:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: startDate == null ? "Start Date" : "Start: ${_formatDate(startDate!)}",
                  onTap: () => _selectStartDate(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  label: endDate == null ? "End Date" : "End: ${_formatDate(endDate!)}",
                  onTap: () => _selectEndDate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generateCustomReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Generate Custom Report",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF4A7FFF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCompareButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _navigateToComparison,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A7FFF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
        child: const Text(
          "Compare Stats with Family Members",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _selectStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: "Select Start Date",
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      helpText: "Select End Date",
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void _generateCustomReport() {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select both start and end dates"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (startDate!.isAfter(endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Start date cannot be after end date"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implement actual custom report generation with selected date range
    setState(() {
      // This triggers a rebuild to show the custom data
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Generated report from ${_formatDate(startDate!)} to ${_formatDate(endDate!)}"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToComparison() {
    // TODO: Navigate to comparison page
    // Example navigation:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ComparisonPage(
    //       currentMember: widget.name,
    //       healthData: healthData[selectedReport]!,
    //     ),
    //   ),
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Comparison feature coming soon!"),
        backgroundColor: Colors.blue,
      ),
    );
  }
}