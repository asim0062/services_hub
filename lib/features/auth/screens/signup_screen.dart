import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:services_hub/data/services/auth_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _selectedRole = 'customer'; // Default role

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _authService.signUpWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Color(0xFF22A06B), // Green
            ),
          );
          Navigator.pop(context); // Wapas Login par bhej dein
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: const Color(0xFFE5484D), // Red
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E6FD9);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section (Back Button & Title)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Create account',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I want to',
                          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 10),
                        
                        // Role Selection (Customer vs Technician)
                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleCard(
                                title: 'Book services',
                                subtitle: 'I need a technician',
                                icon: Icons.home_outlined,
                                role: 'customer',
                                isSelected: _selectedRole == 'customer',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildRoleCard(
                                title: 'Offer services',
                                subtitle: 'I am a technician',
                                icon: Icons.build_outlined,
                                role: 'technician',
                                isSelected: _selectedRole == 'technician',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('Full name'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'Ali Raza',
                          prefixIcon: Icons.person_outline,
                          controller: _nameController,
                          validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('Email'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'ali.raza@gmail.com',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => val!.contains('@') ? null : 'Enter a valid email',
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('Phone'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: '0300 1234567',
                          prefixIcon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (val) => val!.length < 10 ? 'Enter a valid phone' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          controller: _passwordController,
                          isPassword: true,
                          validator: (val) => val!.length < 6 ? 'Min 6 characters' : null,
                        ),
                        const SizedBox(height: 30),

                        CustomButton(
                          text: 'Create account',
                          isLoading: _isLoading,
                          onPressed: _handleSignup,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1B1F27)),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String role,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F1FD) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF1E6FD9) : const Color(0xFFD9DEE7),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF1E6FD9) : const Color(0xFF6B7280)),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF1E6FD9) : const Color(0xFF1B1F27),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}