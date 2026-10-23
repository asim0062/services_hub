import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:services_hub/features/admin/admin_dashboard_screen.dart';
import 'package:services_hub/features/technician/approval_pending_screen.dart';
import 'package:services_hub/features/technician/technician_setup_screen.dart';
import '../../customer/home/home_screen.dart';

import 'login_screen.dart';
import '../../../data/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  final AuthService _authService = AuthService(); // ✅ ek hi instance

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _checkLoginStatus();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    // Minimum 3 sec splash dikhao
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;

      // ❌ Login nahi hai
      if (user == null) {
        _goToLogin();
        return;
      }

      // ✅ Login hai → user model laao
      final userModel = await _authService.getUserModel(user.uid);

      if (!mounted) return;

      // userModel nahi mila
      if (userModel == null) {
        _goToLogin();
        return;
      }

      // ================= ROLE BASED ROUTING =================

      // 1️⃣ CUSTOMER
      if (userModel.role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
        );
        return;
      }

      // 2️⃣ TECHNICIAN
      if (userModel.role == 'technician') {
        await _routeTechnician(user.uid);
        return;
      }

      // 3️⃣ ADMIN
            if (userModel.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(),
          ),
        );
        return;
      }

      // Unknown role → login
      _goToLogin();
    } catch (e) {
      // Network / permission error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _goToLogin();
    }
  }

  /// Technician ka Firestore data check karke sahi screen pe bhejo
  Future<void> _routeTechnician(String uid) async {
    final techData = await FirebaseFirestore.instance
        .collection('technicians')
        .doc(uid)
        .get();

    if (!mounted) return;

    // Profile setup nahi kiya
    if (!techData.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TechnicianSetupScreen()),
      );
      return;
    }

    final approvalStatus = techData.data()?['approvalStatus'];

    switch (approvalStatus) {
      case 'approved':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Technician Dashboard - Coming Soon')),
            ),
          ),
        );
        break;

      case 'rejected':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aapki profile reject ho gayi. Support se rabta karein.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        _goToLogin();
        break;

      case 'pending':
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ApprovalPendingScreen()),
        );
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E6FD9);
    const Color accentColor = Color(0xFFFF8A00);

    final screenWidth = MediaQuery.of(context).size.width;
    final orbitRadius = screenWidth * 0.35;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          _buildBackgroundCircles(screenWidth),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildOrbitSection(
                  orbitRadius,
                  primaryColor,
                  accentColor,
                  screenWidth,
                ),
                const SizedBox(height: 40),
                _AnimatedFadeSlideIn(
                  delay: 0,
                  duration: const Duration(milliseconds: 1200),
                  child: Text(
                    'Service Hub',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _AnimatedFadeSlideIn(
                  delay: 200,
                  duration: const Duration(milliseconds: 1400),
                  child: Text(
                    'Home services, one tap away',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                _ShineProgressBar(
                  width: screenWidth * 0.5,
                  height: 6,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  progressColor: accentColor,
                  controller: _progressController,
                ),
                const SizedBox(height: 16),
                Text(
                  'Checking your account...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircles(double screenWidth) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: SizedBox(
          width: screenWidth * 1.2,
          height: screenWidth * 1.15,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: screenWidth * 1.0,
                height: screenWidth * 1.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
              Container(
                width: screenWidth * 0.65,
                height: screenWidth * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
              ),
              DottedBorder(
                color: Colors.white.withOpacity(0.2),
                strokeWidth: 1.5,
                dashPattern: const [5, 5],
                borderType: BorderType.Circle,
                child: SizedBox(
                  width: screenWidth * 0.4,
                  height: screenWidth * 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrbitSection(
    double radius,
    Color primary,
    Color accent,
    double screenWidth,
  ) {
    return SizedBox(
      height: radius * 2.5,
      width: screenWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildOrbitIcon(icon: Icons.format_paint, angle: -90, radius: radius),
          _buildOrbitIcon(icon: Icons.water_drop, angle: -30, radius: radius),
          _buildOrbitIcon(
            icon: Icons.electrical_services,
            angle: 30,
            radius: radius,
          ),
          _buildOrbitIcon(
            icon: Icons.cleaning_services,
            angle: 90,
            radius: radius,
          ),
          _buildOrbitIcon(icon: Icons.handyman, angle: 150, radius: radius),
          _buildOrbitIcon(icon: Icons.ac_unit, angle: 210, radius: radius),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.build_rounded,
                        size: 50,
                        color: primary,
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: primary, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitIcon({
    required IconData icon,
    required double angle,
    required double radius,
  }) {
    final double radian = angle * math.pi / 180;
    final double x = math.cos(radian) * radius;
    final double y = math.sin(radian) * radius;

    return Transform.translate(
      offset: Offset(x, y),
      child: _FloatingIcon(icon: icon),
    );
  }
}

// ------------------------------------------------------------------
// REUSABLE WIDGETS (NO CHANGE)
// ------------------------------------------------------------------

class _AnimatedFadeSlideIn extends StatelessWidget {
  final Widget child;
  final int delay;
  final Duration duration;

  const _AnimatedFadeSlideIn({
    required this.child,
    this.delay = 0,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

class _FloatingIcon extends StatefulWidget {
  final IconData icon;
  const _FloatingIcon({required this.icon});

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF1E6FD9).withOpacity(0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 24),
          ),
        );
      },
    );
  }
}

class _ShineProgressBar extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final AnimationController controller;

  const _ShineProgressBar({
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.progressColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Container(
                  width: width * controller.value,
                  height: height,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
            _ShineEffect(width: width, height: height),
          ],
        ),
      ),
    );
  }
}

class _ShineEffect extends StatefulWidget {
  final double width;
  final double height;

  const _ShineEffect({required this.width, required this.height});

  @override
  State<_ShineEffect> createState() => _ShineEffectState();
}

class _ShineEffectState extends State<_ShineEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shineController,
      builder: (context, child) {
        return Positioned(
          left: (widget.width + 50) * _shineController.value - 50,
          child: Container(
            width: 40,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.0),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        );
      },
    );
  }
}
