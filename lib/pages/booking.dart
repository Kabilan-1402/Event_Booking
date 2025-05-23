import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Booking extends StatelessWidget {
  const Booking({Key? key}) : super(key: key);

  Future<QuerySnapshot> _getBookings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return await FirebaseFirestore.instance
        .collection('Tickets')
        .where('userId', isEqualTo: uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Color(0xff6351ec),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _getBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching bookings'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          final bookings = snapshot.data!.docs;

          int totalAmount = 0;

          for (var booking in bookings) {
            final rawPrice = booking['eventPrice'];
            final rawCount = booking['ticketCount'];

            int price = rawPrice is String
                ? int.parse(rawPrice)
                : (rawPrice as num).toInt();
            int count = rawCount is String
                ? int.parse(rawCount)
                : (rawCount as num).toInt();

            totalAmount += price * count;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final eventName = booking['eventName'] ?? '';
                    final eventLocation = booking['eventLocation'] ?? '';
                    final eventDate = booking['eventDate'] ?? '';
                    final eventPrice = booking['eventPrice'] ?? 0;
                    final ticketCount = booking['ticketCount'] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Local placeholder event image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Image.asset(
                                'images/event.jpg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      eventName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("Location: $eventLocation"),
                                    Text("Date: $eventDate"),
                                    Text("Tickets: $ticketCount"),
                                    Text(
                                      "Total: \$${(eventPrice is String ? int.parse(eventPrice) : (eventPrice as num).toInt()) * (ticketCount is String ? int.parse(ticketCount) : (ticketCount as num).toInt())}",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total Amount Summary
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                color: Colors.grey[200],
                child: Text(
                  'Total Amount Spent: \$${totalAmount}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
