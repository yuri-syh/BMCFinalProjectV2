import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = true;
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _userRole = 'Loading...';

  static const Color _appBarColor = Color(0xFF75a2b9);

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    if (_currentUser != null) {
      _userEmail = _currentUser!.email ?? 'N/A';

      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _userName = data['name'] ?? 'No Name Set';
        _userRole = data['role'] ?? 'user';
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  // logout functionality
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Details"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_appBarColor, Color(0xFF464c56)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _appBarColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Details Header
            const Text(
              "Account Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.grey),

            const SizedBox(height: 10),

            // Name
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.person, color: _appBarColor),
                title: const Text("Name"),
                subtitle: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),

            // Email
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.email, color: _appBarColor),
                title: const Text("Email Address"),
                subtitle: Text(_userEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),

            // Role
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.security, color: _appBarColor), // Lock/Security Icon
                title: const Text("User Role"),
                subtitle: Text(
                    _userRole.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}