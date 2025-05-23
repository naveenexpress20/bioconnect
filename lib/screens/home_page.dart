import 'package:flutter/material.dart';
import 'family_page.dart'; // Your file that contains your FamilyPage code

// Placeholder widgets for the other bottom navigation tabs.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: const TextStyle(fontSize: 24)),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // The index of the bottom navigation bar currently selected.
  int _selectedIndex = 0;

  // List of pages corresponding to each bottom navigation item.
  final List<Widget> _pages = [
    const FamilyPage(), // Family tab
    const PlaceholderScreen(title: "Chat Screen"), // Tab 2
    const PlaceholderScreen(title: "Health Screen"), // Tab 3
    const PlaceholderScreen(title: "Alerts"), // Tab 4
    const PlaceholderScreen(title: "Profile"), // Tab 5
  ];

  // Update tab selection.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BioConnect Home"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // Use fixed type to show all five items.
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Family",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: "Health",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class FamilyPage {
  const FamilyPage();
}
