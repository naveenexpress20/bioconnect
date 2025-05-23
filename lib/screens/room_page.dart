import 'package:flutter/material.dart';
import 'family_member_stats.dart'; // ✅ Import Health Stats Page

class RoomPage extends StatefulWidget {
  final String roomCode;
  final bool isCreator;

  const RoomPage({super.key, required this.roomCode, required this.isCreator});

  @override
  RoomPageState createState() => RoomPageState();
}

class RoomPageState extends State<RoomPage> {
  // Dummy list of family members
  final List<Map<String, dynamic>> familyMembers = [
    {"name": "Alice", "age": 45, "imageUrl": "assets/alice.png"},
    {"name": "Bob", "age": 50, "imageUrl": "assets/bob.png"},
    {"name": "Charlie", "age": 25, "imageUrl": "assets/charlie.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Family Room: ${widget.roomCode}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Family Members",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: familyMembers.length,
                itemBuilder: (context, index) {
                  final member = familyMembers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(member["imageUrl"]),
                      radius: 30,
                    ),
                    title: Text(member["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text("Age: ${member["age"]}"),
                    onTap: () {
                      // ✅ Navigate to Health Stats Page when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FamilyMemberStatsPage(
                            name: member["name"],
                            imageUrl: member["imageUrl"],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
