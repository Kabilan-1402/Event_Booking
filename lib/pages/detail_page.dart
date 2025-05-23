import 'dart:convert';
import 'package:booking_event/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPage extends StatefulWidget {
  final String image, name, location, date, detail, price;

  const DetailPage({
    Key? key,
    required this.image,
    required this.name,
    required this.location,
    required this.date,
    required this.detail,
    required this.price,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int ticketCount = 1;
  bool _isLoading = false;
  String? userName, userImage, userId;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    Stripe.publishableKey = 'pk_test_51ROgSiPxHNNQUnVYGqaxvp2x4bgvMRZXZcio1eK9Vmx6xAHIeWnQ8xRJ3Of5JS0T7uzvbKArbibbqDB0YuBKZVxi00HMmHUsvL';
  }

  Future<void> loadUserInfo() async {
    userName = await SharedPreferenceHelper().getUserName();
    userImage = await SharedPreferenceHelper().getUserImage();
    userId = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  int get totalAmount {
    final price = int.tryParse(widget.price);
    return price != null ? price * ticketCount : 0;
  }

  String get formattedTotalAmount {
    final formatCurrency = NumberFormat.simpleCurrency();
    return formatCurrency.format(totalAmount);
  }

  String getFormattedDate(String input) {
    if (input.trim().isEmpty) return 'Unknown date';
    final iso = DateTime.tryParse(input);
    if (iso != null) return DateFormat.yMMMMd().format(iso);

    try {
      final custom = DateFormat('dd-MM-yyyy hh:mm:ss a').parse(input);
      return DateFormat.yMMMMd().format(custom);
    } catch (_) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6351EC),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top image with overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.asset(
                    widget.image,
                    width: double.infinity,
                    height: 340,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(getFormattedDate(widget.date), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(widget.location, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.detail),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Number of Tickets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 120),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setState(() => ticketCount++),
                            ),
                            Text('$ticketCount', style: const TextStyle(fontSize: 23, color: Color(0xFF6351EC))),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: ticketCount > 1 ? () => setState(() => ticketCount--) : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount: $formattedTotalAmount',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6351EC)),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          setState(() => _isLoading = true);
                          await _initiatePayment(totalAmount.toString());
                          setState(() => _isLoading = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6351EC),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Book Now', style: TextStyle(color: Colors.white, fontSize: 16)),
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
  }

  Future<void> _initiatePayment(String amount) async {
    try {
      final intentData = await _createPaymentIntent(amount, 'usd');
      final secret = intentData['client_secret'] as String;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: secret,
          merchantDisplayName: 'Event Booking App',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      await _storeBooking();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(String amount, String currency) async {
    const secretKey = 'sk_test_51ROgSiPxHNNQUnVYQgEXc8wFYuQ3tLkyHpybksRd03pQgyNelv3fIawptXnDXrOgDM72vXJL3ZPBRdEohNjaaZGz002w6lV87F';

    final body = {
      'amount': (int.parse(amount) * 100).toString(),
      'currency': currency,
      'payment_method_types[]': 'card',
    };

    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create PaymentIntent');
    }
  }

  Future<void> _storeBooking() async {
    final bookingData = {
      "userName": userName,
      "userId": userId,
      "userImage": userImage,
      "ticketCount": ticketCount,
      "eventName": widget.name,
      "eventLocation": widget.location,
      "eventDate": widget.date,
      "eventPrice": widget.price,
      "timestamp": FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection("Event")
        .doc(widget.name)
        .collection("Booking")
        .add(bookingData);

    await FirebaseFirestore.instance
        .collection("Tickets")
        .add(bookingData);
  }
}
