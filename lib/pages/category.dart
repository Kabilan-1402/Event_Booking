import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail_page.dart';

class CategoriesEvent extends StatefulWidget {
  final String category;
  const CategoriesEvent({Key? key, required this.category}) : super(key: key);

  @override
  _CategoriesEventState createState() => _CategoriesEventState();
}

class _CategoriesEventState extends State<CategoriesEvent> {
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    // Initialize Firestore stream
    _stream = FirebaseFirestore.instance
        .collection('Event')
        .where('Category', isEqualTo: widget.category)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        leading: const BackButton(),
      ),
      body: _stream == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: \${snap.error}'));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No events in this category.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data()! as Map<String, dynamic>;
              final name     = data['Name']     as String? ?? '';
              final price    = data['Price']    as String? ?? '';
              final location = data['Location'] as String? ?? '';
              final dateStr  = data['Date']     as String? ?? '';
              String month='––', day='--';
              try {
                final dt = DateTime.parse(dateStr);
                month = DateFormat('MMM').format(dt);
                day   = DateFormat('dd').format(dt);
              } catch (_) {}

              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPage(
                    name: name,
                    date: dateStr,
                    location: location,
                    price: price,
                    detail: data['Detail'] ?? '',
                    image: 'images/event.jpg',
                  )),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'images/event.jpg',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(children: [
                              Text(month, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text(day,   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ]),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                          Text('\$$price', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff6351ec))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on, size: 18),
                        const SizedBox(width: 4),
                        Expanded(child: Text(location, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16))),
                      ]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
