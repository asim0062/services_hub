import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:services_hub/features/admin/admin_approvals_screen.dart';
import 'package:services_hub/features/auth/screens/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex = 0;

  // ✅ Futures initState me store — baar baar Firestore call nahi
  late Future<int> _customersFuture;
  late Future<int> _techniciansFuture;
  late Future<int> _bookingsFuture;
  late Future<int> _pendingFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _customersFuture = _getCount('users');
    _techniciansFuture = _getCount('technicians');
    _bookingsFuture = _getCount('bookings');
    _pendingFuture = _getPendingCount();
  }

  Future<void> _refresh() async {
    setState(() => _loadStats());
    await Future.wait([
      _customersFuture,
      _techniciansFuture,
      _bookingsFuture,
      _pendingFuture,
    ]);
  }

  // ✅ count() use karo — poore docs load nahi hote
  Future<int> _getCount(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).count().get();
      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _getPendingCount() async {
    try {
      final snapshot = await _firestore
          .collection('technicians')
          .where('approvalStatus', isEqualTo: 'pending')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Log out?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleLogout();
            },
            child: Text(
              'Log out',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Har tab ka apna screen
  Widget _buildBody() {
    switch (_currentIndex) {
      case 1:
        return AdminApprovalsScreen();
      case 2:
        return _buildComingSoon('Users');
      case 3:
        return _buildComingSoon('Bookings');
      case 0:
      default:
        return _buildDashboardBody();
    }
  }

  // 👇 Simple "Coming Soon" placeholder
  Widget _buildComingSoon(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            '$title - Coming Soon',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E6FD9);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 4) {
            _showLogoutDialog();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFF6B7280),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Approvals',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
      body: Column(
        children: [
          // TOP BLUE HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin console',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _getTitleForIndex(_currentIndex),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // MAIN CONTENT
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Approvals';
      case 2:
        return 'Users';
      case 3:
        return 'Bookings';
      case 0:
      default:
        return 'Overview';
    }
  }

  Widget _buildDashboardBody() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATS GRID
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Customers',
                    icon: Icons.people,
                    color: Colors.blue,
                    future: _customersFuture,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    title: 'Technicians',
                    icon: Icons.engineering,
                    color: Colors.purple,
                    future: _techniciansFuture,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Bookings',
                    icon: Icons.calendar_today,
                    color: Colors.green,
                    future: _bookingsFuture,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    title: 'Pending approvals',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                    future: _pendingFuture,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // BOOKINGS BY STATUS
            Text(
              'Bookings by status',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildBookingsStatusCard(),
            const SizedBox(height: 25),

            // RECENT ACTIVITY
            Text(
              'Recent activity',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<QuerySnapshot>(
              future: _firestore
                  .collection('bookings')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Text(
                    'No recent activity',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  );
                }
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildActivityTile(
                      icon: Icons.calendar_today,
                      color: Colors.blue,
                      title: 'Booking #${doc.id.substring(0, 6)}',
                      subtitle: data['status'] ?? 'pending',
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsStatusCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9DEE7)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 62,
                child: Container(height: 10, color: Colors.green),
              ),
              Expanded(
                flex: 14,
                child: Container(height: 10, color: Colors.teal),
              ),
              Expanded(
                flex: 16,
                child: Container(height: 10, color: Colors.orange),
              ),
              Expanded(
                flex: 8,
                child: Container(height: 10, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _buildLegendItem(
                color: Colors.green,
                label: 'Completed',
                value: '62%',
              ),
              _buildLegendItem(
                color: Colors.teal,
                label: 'In progress',
                value: '14%',
              ),
              _buildLegendItem(
                color: Colors.orange,
                label: 'Pending',
                value: '16%',
              ),
              _buildLegendItem(
                color: Colors.red,
                label: 'Cancelled',
                value: '8%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required Future<int> future,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD9DEE7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 15),
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    '—',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  );
                }
                return Text(
                  '${snapshot.data ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text('$label ', style: GoogleFonts.poppins(fontSize: 12)),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9DEE7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
