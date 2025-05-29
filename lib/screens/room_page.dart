import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class RoomPage extends StatefulWidget {
  final String roomCode;

  const RoomPage({Key? key, required this.roomCode}) : super(key: key);

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with SingleTickerProviderStateMixin {
  // Remove Firebase imports and instances
  final TextEditingController _roomCodeController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();

  late TabController _tabController;
  bool _isLoading = false;
  String _errorMessage = '';
  String _generatedRoomCode = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateRoomCode();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _roomCodeController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  void _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    setState(() {
      _generatedRoomCode = String.fromCharCodes(
          Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
      );
    });
  }

  // TODO: Replace with Supabase implementation
  Future<void> _createRoom() async {
    if (_roomNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a room name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // TODO: Implement user authentication check with Supabase
      // User authentication placeholder
      String? currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        setState(() {
          _errorMessage = 'User not authenticated. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      // TODO: Check if room code already exists in Supabase
      bool roomExists = await _checkRoomExists(_generatedRoomCode);
      if (roomExists) {
        _generateRoomCode();
        await _createRoom();
        return;
      }

      // TODO: Get user data from Supabase
      Map<String, dynamic>? userData = await _getUserData(currentUserId);
      if (userData == null) {
        setState(() {
          _errorMessage = 'User profile not found. Please complete your profile first.';
          _isLoading = false;
        });
        return;
      }

      // TODO: Create room in Supabase
      Map<String, dynamic> roomData = {
        'roomCode': _generatedRoomCode,
        'roomName': _roomNameController.text.trim(),
        'createdBy': currentUserId,
        'createdAt': DateTime.now().toIso8601String(),
        'members': [
          {
            'uid': currentUserId,
            'name': userData['name'] ?? 'Unknown',
            'email': userData['email'] ?? '',
            'phone': userData['phone'] ?? '',
            'age': userData['age'] ?? 0,
            'role': 'admin',
            'joinedAt': DateTime.now().toIso8601String(),
          }
        ],
        'memberCount': 1,
        'isActive': true,
      };

      bool roomCreated = await _createRoomInDatabase(roomData);
      if (!roomCreated) {
        setState(() {
          _errorMessage = 'Failed to create room. Please try again.';
          _isLoading = false;
        });
        return;
      }

      // TODO: Update user's room information in Supabase
      await _updateUserRoom(currentUserId, _generatedRoomCode, _roomNameController.text.trim());

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/family');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create room: ${e.toString()}';
        _isLoading = false;
      });
      print('Error creating room: $e'); // For debugging
    }
  }

  // TODO: Replace with Supabase implementation
  Future<void> _joinRoom() async {
    String roomCode = _roomCodeController.text.trim().toUpperCase();

    if (roomCode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a room code';
      });
      return;
    }

    if (roomCode.length != 6) {
      setState(() {
        _errorMessage = 'Room code must be 6 characters long';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // TODO: Implement user authentication check with Supabase
      String? currentUserId = await _getCurrentUserId();
      if (currentUserId == null) {
        setState(() {
          _errorMessage = 'User not authenticated. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      // TODO: Check if room exists in Supabase
      Map<String, dynamic>? roomData = await _getRoomData(roomCode);
      if (roomData == null) {
        setState(() {
          _errorMessage = 'Room not found. Check the code and try again.';
          _isLoading = false;
        });
        return;
      }

      List<dynamic> members = List.from(roomData['members'] ?? []);

      // Check if user is already in the room
      bool alreadyMember = members.any((member) =>
      member is Map<String, dynamic> && member['uid'] == currentUserId);

      if (alreadyMember) {
        setState(() {
          _errorMessage = 'You are already a member of this room.';
          _isLoading = false;
        });
        return;
      }

      // TODO: Get user data from Supabase
      Map<String, dynamic>? userData = await _getUserData(currentUserId);
      userData ??= {};

      // Add user to room
      members.add({
        'uid': currentUserId,
        'name': userData['name'] ?? 'Unknown',
        'email': userData['email'] ?? '',
        'phone': userData['phone'] ?? '',
        'age': userData['age'] ?? 0,
        'role': 'member',
        'joinedAt': DateTime.now().toIso8601String(),
      });

      // TODO: Update room in Supabase
      bool roomUpdated = await _updateRoomMembers(roomCode, members);
      if (!roomUpdated) {
        setState(() {
          _errorMessage = 'Failed to join room. Please try again.';
          _isLoading = false;
        });
        return;
      }

      // TODO: Update user's room information in Supabase
      await _updateUserRoom(currentUserId, roomCode, roomData['roomName'] ?? 'Unknown Room');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/family');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to join room: ${e.toString()}';
        _isLoading = false;
      });
      print('Error joining room: $e'); // For debugging
    }
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: _generatedRoomCode));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room code copied to clipboard'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // TODO: Placeholder methods to be implemented with Supabase
  Future<String?> _getCurrentUserId() async {
    // TODO: Implement with Supabase Auth
    // For now, return a placeholder
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return 'placeholder_user_id';
  }

  Future<bool> _checkRoomExists(String roomCode) async {
    // TODO: Implement with Supabase
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return false; // Placeholder: assume room doesn't exist
  }

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    // TODO: Implement with Supabase
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return {
      'name': 'Test User',
      'email': 'test@example.com',
      'phone': '+1234567890',
      'age': 25,
    }; // Placeholder data
  }

  Future<bool> _createRoomInDatabase(Map<String, dynamic> roomData) async {
    // TODO: Implement with Supabase
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    return true; // Placeholder: assume success
  }

  Future<void> _updateUserRoom(String userId, String roomCode, String roomName) async {
    // TODO: Implement with Supabase
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
  }

  Future<Map<String, dynamic>?> _getRoomData(String roomCode) async {
    // TODO: Implement with Supabase
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return {
      'roomCode': roomCode,
      'roomName': 'Test Family Room',
      'members': [],
      'memberCount': 0,
      'isActive': true,
    }; // Placeholder data
  }

  Future<bool> _updateRoomMembers(String roomCode, List<dynamic> members) async {
    // TODO: Implement with Supabase
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return true; // Placeholder: assume success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Family Room',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3498DB),
          unselectedLabelColor: const Color(0xFF7F8C8D),
          indicatorColor: const Color(0xFF3498DB),
          tabs: const [
            Tab(text: 'Create Room'),
            Tab(text: 'Join Room'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateRoomTab(),
          _buildJoinRoomTab(),
        ],
      ),
    );
  }

  Widget _buildCreateRoomTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Header
          const Text(
            'Create Family Room',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a room for your family to monitor health stats together',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7F8C8D),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Room Name Input
          const Text(
            'Room Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _roomNameController,
            maxLength: 50,
            decoration: InputDecoration(
              hintText: 'e.g., Smith Family',
              filled: true,
              fillColor: Colors.white,
              counterText: '', // Hide character counter
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
              ),
              prefixIcon: const Icon(Icons.family_restroom, color: Color(0xFF7F8C8D)),
            ),
          ),

          const SizedBox(height: 30),

          // Generated Room Code
          const Text(
            'Room Code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.key, color: Color(0xFF7F8C8D)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _generatedRoomCode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF3498DB)),
                      onPressed: _generateRoomCode,
                      tooltip: 'Generate new code',
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color(0xFF3498DB)),
                      onPressed: _copyRoomCode,
                      tooltip: 'Copy code',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF3498DB)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Share this room code with family members so they can join your room',
                    style: TextStyle(
                      color: const Color(0xFF3498DB).withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Error Message
          if (_errorMessage.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Create Room Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Create Room',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinRoomTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Header
          const Text(
            'Join Family Room',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the room code shared by your family member',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7F8C8D),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Room Code Input
          const Text(
            'Room Code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _roomCodeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: 'Enter 6-digit room code',
              filled: true,
              fillColor: Colors.white,
              counterText: '', // Hide character counter
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
              ),
              prefixIcon: const Icon(Icons.key, color: Color(0xFF7F8C8D)),
            ),
          ),

          const SizedBox(height: 20),

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE74C3C).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFE74C3C)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ask your family member for the room code to join their health monitoring room',
                    style: TextStyle(
                      color: const Color(0xFFE74C3C).withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Error Message
          if (_errorMessage.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Join Room Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _joinRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Join Room',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Quick Access Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need Help?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                _buildHelpItem(
                  icon: Icons.family_restroom,
                  title: 'Ask Family Member',
                  subtitle: 'Request the room code from the room creator',
                ),
                const SizedBox(height: 8),
                _buildHelpItem(
                  icon: Icons.add_circle_outline,
                  title: 'Create New Room',
                  subtitle: 'Switch to Create Room tab to start your own',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF3498DB), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}