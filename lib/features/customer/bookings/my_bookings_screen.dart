import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:services_hub/features/customer/bookings/booking_detail_screen.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E6FD9);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please login'))
          : FutureBuilder<List<BookingModel>>(
              future: _bookingService.getCustomerBookings(user.uid),
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
                      'No bookings found.',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  );
                }

                final allBookings = snapshot.data!;

                // Bookings ko status ke hisaab se filter karein
                final activeBookings = allBookings
                    .where(
                      (b) =>
                          b.status == 'pending' ||
                          b.status == 'accepted' ||
                          b.status == 'onTheWay' ||
                          b.status == 'inProgress',
                    )
                    .toList();

                final completedBookings = allBookings
                    .where((b) => b.status == 'completed')
                    .toList();

                final cancelledBookings = allBookings
                    .where(
                      (b) =>
                          b.status == 'cancelled' ||
                          b.status == 'rejected' ||
                          b.status == 'expired',
                    )
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(activeBookings, 'No active bookings.'),
                    _buildBookingList(
                      completedBookings,
                      'No completed bookings.',
                    ),
                    _buildBookingList(
                      cancelledBookings,
                      'No cancelled bookings.',
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailScreen(booking: booking),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Number & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Technician Name & Category (Naya Design)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.build,
                        color: Color(0xFF1E6FD9),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.categoryName, // Category Name
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${booking.technicianName} · ${booking.bookingNo}', // Tech Name
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                    _buildStatusChip(booking.status),
                  ],
                ),
               
                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade300),

                // Date & Time
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${booking.date} · ${booking.timeSlot}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Price',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    Text(
                      'Rs ${booking.estimatedPrice.toInt()}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E6FD9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'accepted':
        color = Colors.blue;
        text = 'Accepted';
        break;
      case 'onTheWay':
        color = Colors.purple;
        text = 'On the way';
        break;
      case 'inProgress':
        color = Colors.teal;
        text = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Cancelled';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
