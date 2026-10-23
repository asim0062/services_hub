import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/technician_service.dart';
import '../../data/services/category_service.dart';
import '../../data/models/category_model.dart';
import 'approval_pending_screen.dart';

class TechnicianSetupScreen extends StatefulWidget {
  const TechnicianSetupScreen({super.key});

  @override
  State<TechnicianSetupScreen> createState() => _TechnicianSetupScreenState();
}

class _TechnicianSetupScreenState extends State<TechnicianSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  final _rateController = TextEditingController();
  final _bioController = TextEditingController();

  final TechnicianService _technicianService = TechnicianService();
  final CategoryService _categoryService = CategoryService();

  late Future<List<CategoryModel>> _categoriesFuture;

  String? _selectedCategoryId;
  String? _selectedCategoryName; // <-- Naya variable
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _rateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      await _technicianService.setupTechnicianProfile(
        uid: user.uid,
        name: user.displayName ?? 'Technician',
        categoryName: _selectedCategoryName ?? 'Service', // <-- Yahan pass kiya
        categoryIds: [_selectedCategoryId!],
        experienceYears: int.parse(_experienceController.text.trim()),
        hourlyRate: double.parse(_rateController.text.trim()),
        bio: _bioController.text.trim(),
        cnicUrl: 'pending_upload',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile submitted for approval!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ApprovalPendingScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E6FD9);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(
          'Setup Your Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selection
              Text(
                'Service Category',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<CategoryModel>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Failed to load categories',
                      style: GoogleFonts.poppins(color: Colors.red),
                    );
                  }

                  final categories = snapshot.data ?? [];
                  if (categories.isEmpty) {
                    return Text(
                      'No categories available',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    hint: Text('Select category', style: GoogleFonts.poppins()),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                        // Category ka naam bhi save karein
                        _selectedCategoryName = categories
                            .firstWhere((c) => c.id == val)
                            .name;
                      });
                    },
                    validator: (val) => val == null ? 'Select category' : null,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Experience
              Text(
                'Experience (Years)',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 5',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter experience';
                  final n = int.tryParse(val);
                  if (n == null) return 'Enter valid number';
                  if (n < 0) return 'Cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Hourly Rate
              Text(
                'Hourly Rate (PKR)',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 800',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter rate';
                  final n = double.tryParse(val);
                  if (n == null) return 'Enter valid amount';
                  if (n <= 0) return 'Rate must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Bio
              Text(
                'Short Bio',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: 'Tell customers about your skills...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter bio';
                  if (val.trim().length < 20) {
                    return 'Bio should be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Submit for Approval',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
