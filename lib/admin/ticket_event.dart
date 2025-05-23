import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketEvent extends StatefulWidget {
  const TicketEvent({super.key});

  @override
  State<TicketEvent> createState() => _TicketEventState();
}

class _TicketEventState extends State<TicketEvent> {
  late Stream<QuerySnapshot> ticketStream;

  @override
  void initState() {
    super.initState();
    ticketStream = FirebaseFirestore.instance
        .collection('Tickets')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_outlined),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Event Tickets",
                    style: TextStyle(
                      color: Color(0xff6351ec),
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Event List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: ticketStream,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No tickets found.'));
                  }

                  double totalAmount = 0;

                  List<Widget> ticketWidgets = [];
                  for (var doc in docs) {
                    final booking = doc.data() as Map<String, dynamic>;
                    final eventName = booking['eventName'] ?? '';
                    final eventLocation = booking['eventLocation'] ?? '';
                    final eventDate = booking['eventDate'] ?? '';
                    final eventPrice = booking['eventPrice'] ?? 0;
                    final ticketCount = booking['ticketCount'] ?? 0;

                    final price = (eventPrice is String
                        ? double.tryParse(eventPrice)
                        : (eventPrice as num).toDouble()) ?? 0;
                    final count = (ticketCount is String
                        ? int.tryParse(ticketCount)
                        : (ticketCount as num).toInt()) ?? 0;

                    final total = price * count;
                    totalAmount += total;

                    // Format date (optional)
                    final formattedDate = eventDate is Timestamp
                        ? DateFormat.yMMMd().format(eventDate.toDate())
                        : eventDate;

                    ticketWidgets.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              // Event image
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
                              // Ticket info
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
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 18,  color: Color(0xff6351ec)),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(eventLocation, overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold),),),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 18, color: Color(0xff6351ec)),
                                          const SizedBox(width: 4),
                                          Text(formattedDate.toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 18, color: Color(0xff6351ec)),
                                          const SizedBox(width: 4),
                                          Text('$count',style: TextStyle(fontWeight: FontWeight.bold),),
                                        ],
                                      ),

                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.attach_money, size: 18,  color: Color(0xff6351ec)),
                                          const SizedBox(width: 4),
                                          Text(total.toStringAsFixed(2),style: TextStyle(fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: ticketWidgets,
                        ),
                      ),
                      // Total footer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Text(
                          'Total Amount Spent: \$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
