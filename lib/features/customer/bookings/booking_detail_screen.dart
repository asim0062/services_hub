import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/booking_model.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isLoading = false;
  static const Color primaryColor = Color(0xFF1E6FD9); 

  // Booking Cancel karne ka function
  Future<void> _cancelBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to cancel this booking?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.booking.id)
            .update({
              'status': 'cancelled',
              'updatedAt': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Date format karne ke liye helper function
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is Timestamp) {
      final dt = date.toDate();
      return "${dt.day}-${dt.month}-${dt.year}";
    }
    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.booking.status;
    final isCancelledOrExpired = ['cancelled', 'expired', 'rejected'].contains(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text('Booking Detail', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Booking No & Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.booking.bookingNo,
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 20),

            // Technician Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD9DEE7)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.person, color: primaryColor),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Technician Details', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      Text('See Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.call, color: primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Timeline (Progress)
            if (!isCancelledOrExpired) ...[
              Text('Progress', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildTimeline(status),
            ] else ...[
              // Agar Cancelled ya Expired ho toh alag UI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'This booking has been ${status.toUpperCase()}',
                      style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 25),

            // Details (Date, Address, Price)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD9DEE7)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('When', '${_formatDate(widget.booking.date)} · ${widget.booking.timeSlot}'),
                  const Divider(),
                  _buildDetailRow('Address', widget.booking.address),
                  const Divider(),
                  _buildDetailRow('Problem', widget.booking.problem),
                  const Divider(),
                  _buildDetailRow('Estimated Price', 'Rs ${widget.booking.estimatedPrice.toInt()}', isPrice: true),
                ],
              ),
            ),
            const SizedBox(height: 80), // Space for bottom button
          ],
        ),
      ),

      // Cancel Button (Sirf tab dikhe jab Pending ya Accepted ho)
      bottomNavigationBar: (status == 'pending' || status == 'accepted')
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _cancelBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Colors.red, width: 1),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
                    : Text('Cancel Booking', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            )
          : null,
    );
  }

  // ✅ FIXED TIMELINE WIDGET
  Widget _buildTimeline(String currentStatus) {
    final statuses = ['pending', 'accepted', 'onTheWay', 'inProgress', 'completed'];
    
    // Titles jo UI par dikhenge
    final titles = ['Request Sent', 'Accepted', 'On the way', 'Work in progress', 'Completed'];
    
    // Subtitles jo current step ke neeche dikhenge
    final subtitles = [
      'Waiting for technician',
      'Technician accepted',
      'Arriving soon',
      'Work has started',
      'Job finished successfully'
    ];

    final currentIndex = statuses.indexOf(currentStatus);

    return Column(
      children: List.generate(statuses.length, (index) {
        final isCompleted = index < currentIndex;
        final isCurrent = index == currentIndex;
        
        // Agar step complete hai ya current hai toh blue color
        final activeColor = (isCompleted || isCurrent) ? primaryColor : Colors.grey.shade400;
        
        // Line tabhi blue hogi jab next step bhi complete ho
        final isLineActive = index < currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? primaryColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: activeColor, width: 2),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : (isCurrent ? Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle))) : null),
                ),
                if (index != statuses.length - 1)
                  Container(
                    width: 2,
                    height: 45, // Height thodi badha di taake text fit ho jaye
                    color: isLineActive ? primaryColor : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titles[index],
                      style: GoogleFonts.poppins(
                        fontWeight: (isCurrent || isCompleted) ? FontWeight.bold : FontWeight.w500,
                        color: (isCurrent || isCompleted) ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (isCurrent)
                      Text(
                        subtitles[index], 
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isPrice ? primaryColor : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending': color = Colors.orange; text = 'Pending'; break;
      case 'accepted': color = Colors.blue; text = 'Accepted'; break;
      case 'onTheWay': color = Colors.purple; text = 'On the way'; break;
      case 'inProgress': color = Colors.teal; text = 'In Progress'; break;
      case 'completed': color = Colors.green; text = 'Completed'; break;
      case 'cancelled': color = Colors.red; text = 'Cancelled'; break;
      case 'expired': color = Colors.red; text = 'Expired'; break;
      case 'rejected': color = Colors.red; text = 'Rejected'; break;
      default: color = Colors.grey; text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}