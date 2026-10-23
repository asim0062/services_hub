import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:services_hub/features/customer/technicians/technician_detail_screen.dart';
import '../../../../data/models/technician_model.dart';
import '../../../../data/services/technician_service.dart';

class TechnicianListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const TechnicianListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<TechnicianListScreen> createState() => _TechnicianListScreenState();
}

class _TechnicianListScreenState extends State<TechnicianListScreen> {
  final TechnicianService _technicianService = TechnicianService();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E6FD9);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1B1F27),
      ),
      body: FutureBuilder<List<TechnicianModel>>(
        future: _technicianService.getTechniciansByCategory(widget.categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No technicians available for this category.',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            );
          }

          final technicians = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final tech = technicians[index];
              return GestureDetector(
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianDetailScreen(technician: tech),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD9DEE7)),
                  ),
                  child: Row(
                    children: [
                      // Profile Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: const Icon(Icons.person, size: 35, color: primaryColor),
                      ),
                      const SizedBox(width: 15),
                      
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  tech.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                if (tech.isVerified)
                                  const Icon(Icons.verified, size: 16, color: Colors.blue),
                              ],
                            ),
                            Text(
                              '${tech.categoryName} · ${tech.experienceYears} yrs',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  '${tech.ratingAvg} (${tech.completedJobs} jobs)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rs ${tech.hourlyRate.toInt()}/hr',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Book Now ka kaam aage aayega
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Book',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Temporary Seed Button (Testing ke liye)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _technicianService.seedTechnicians();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test technicians added!')),
          );
          setState(() {});
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}