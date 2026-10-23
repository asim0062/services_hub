import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth/screens/login_screen.dart';

class ApprovalPendingScreen extends StatefulWidget {
  const ApprovalPendingScreen({super.key});

  @override
  State<ApprovalPendingScreen> createState() => _ApprovalPendingScreenState();
}

class _ApprovalPendingScreenState extends State<ApprovalPendingScreen> {
  String _submissionTime = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchSubmissionTime();
  }

  // Firestore se profile submit hone ka waqt mangwayein
  Future<void> _fetchSubmissionTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('technicians')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data()?['createdAt'] != null) {
          final dynamic timestamp = doc.data()!['createdAt'];
          DateTime dateTime;

          // Check if it's a Timestamp or already a String
          if (timestamp is Timestamp) {
            dateTime = timestamp.toDate();
          } else if (timestamp is String) {
            dateTime = DateTime.parse(timestamp);
          } else {
            dateTime = DateTime.now(); // Fallback
          }

          final formatter = DateFormat('MMM d, h:mm a');
          if (mounted) {
            setState(() {
              _submissionTime = formatter.format(dateTime);
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _submissionTime = 'Just now'; // Agar data nahi mila
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _submissionTime = 'Error loading time';
          });
        }
      }
    }
  } // <-- Yahan function band hoga (Sirf ek bracket)

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E6FD9);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_empty,
                    size: 80,
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 30),

                // Title
                Text(
                  'Profile under review',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  'Our team is checking your documents. This usually takes up to 24 hours.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Timeline
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildTimelineStep(
                        title: 'Profile submitted',
                        subtitle: _submissionTime, // Ab real time aayega
                        isCompleted: true,
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        title: 'Documents under review',
                        subtitle: 'In progress',
                        isCompleted: true,
                        isLast: false,
                        isActive: true,
                      ),
                      _buildTimelineStep(
                        title: 'Account approved',
                        subtitle: 'You will get a notification',
                        isCompleted: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Logout Button
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: Text(
                    'Log out',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
    bool isActive = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF1E6FD9) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF1E6FD9)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? const Color(0xFF1E6FD9)
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
