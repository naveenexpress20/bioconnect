import 'package:flutter/material.dart';
import 'room_page.dart'; // Import for navigation to room creation/joining
import 'family_member_stats.dart'; // Import for navigation to stats page

class FamilyPage extends StatefulWidget {
  final String? roomCode;
  final List<Map<String, String>>? existingMembers;

  const FamilyPage({
    super.key,
    this.roomCode,
    this.existingMembers,
  });

  @override
  _FamilyPageState createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  List<Map<String, String>> familyMembers = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing members if provided
    if (widget.existingMembers != null) {
      familyMembers = List.from(widget.existingMembers!);
    }

    // Add some default family members for demonstration
    if (familyMembers.isEmpty) {
      familyMembers = [
        {
          'name': 'John Doe',
          'age': '45',
          'gender': 'Male',
          'imageUrl': 'assets/images/profile1.png',
          'relationship': 'Father'
        },
        {
          'name': 'Jane Doe',
          'age': '42',
          'gender': 'Female',
          'imageUrl': 'assets/images/profile2.png',
          'relationship': 'Mother'
        },
        {
          'name': 'Alex Doe',
          'age': '16',
          'gender': 'Male',
          'imageUrl': 'assets/images/profile3.png',
          'relationship': 'Son'
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {
            // Navigate back to room page or previous screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RoomPage()),
            );
          },
        ),
        title: const Text(
          'FAMILY MEMBERS',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            // Room code display (if available)
            if (widget.roomCode != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Room Code',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.roomCode!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Family members grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                itemCount: familyMembers.length + 1, // +1 for add new member card
                itemBuilder: (context, index) {
                  if (index == familyMembers.length) {
                    // Add new member card
                    return _buildAddMemberCard();
                  } else {
                    // Existing family member card
                    return _buildFamilyMemberCard(familyMembers[index], index);
                  }
                },
              ),
            ),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _inviteFamilyMember,
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text(
                        'Invite Family',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7FFF),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _manageRoom,
                      icon: const Icon(Icons.settings, color: Colors.white),
                      label: const Text(
                        'Room Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C757D),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberCard(Map<String, String> member, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to family member stats page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FamilyMemberStatsPage(
              name: member['name'] ?? 'Unknown',
              imageUrl: member['imageUrl'] ?? '',
              age: member['age'] ?? '',
              gender: member['gender'] ?? '',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            // Profile image section with edit button
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4AFF4A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Profile image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: member['imageUrl']!.isNotEmpty
                            ? Image.asset(
                          member['imageUrl']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.black54,
                            );
                          },
                        )
                            : const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    // Edit/Plus button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _editMemberProfile(index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Member info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      member['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${member['age'] ?? 'N/A'} • ${member['relationship'] ?? 'Family'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    // Health status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Healthy',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildAddMemberCard() {
    return GestureDetector(
      onTap: _addNewFamilyMember,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Plus icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF4A7FFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add Family\nMember',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to add',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _addNewFamilyMember() {
    _showAddMemberDialog();
  }

  void _editMemberProfile(int index) {
    _showEditMemberDialog(index);
  }

  void _inviteFamilyMember() {
    String roomCode = widget.roomCode ?? 'ABC123';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invite Family Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Share this room code with your family member:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  roomCode,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement share functionality
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Room code copied to clipboard!')),
                );
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }

  void _manageRoom() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Room Settings'),
          content: const Text('Room management features coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String selectedGender = 'Male';
    String selectedRelationship = 'Family';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Family Member'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedGender = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRelationship,
                      decoration: const InputDecoration(
                        labelText: 'Relationship',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Father', 'Mother', 'Son', 'Daughter', 'Spouse', 'Sibling', 'Other']
                          .map((relation) => DropdownMenuItem(
                        value: relation,
                        child: Text(relation),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedRelationship = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
                      setState(() {
                        familyMembers.add({
                          'name': nameController.text,
                          'age': ageController.text,
                          'gender': selectedGender,
                          'imageUrl': '',
                          'relationship': selectedRelationship,
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Family member added successfully!')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditMemberDialog(int index) {
    final member = familyMembers[index];
    final nameController = TextEditingController(text: member['name']);
    final ageController = TextEditingController(text: member['age']);
    String selectedGender = member['gender'] ?? 'Male';
    String selectedRelationship = member['relationship'] ?? 'Family';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Family Member'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedGender = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRelationship,
                      decoration: const InputDecoration(
                        labelText: 'Relationship',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Father', 'Mother', 'Son', 'Daughter', 'Spouse', 'Sibling', 'Other']
                          .map((relation) => DropdownMenuItem(
                        value: relation,
                        child: Text(relation),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedRelationship = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      familyMembers.removeAt(index);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Family member removed!')),
                    );
                  },
                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
                      setState(() {
                        familyMembers[index] = {
                          'name': nameController.text,
                          'age': ageController.text,
                          'gender': selectedGender,
                          'imageUrl': member['imageUrl'] ?? '',
                          'relationship': selectedRelationship,
                        };
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Family member updated!')),
                      );
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}