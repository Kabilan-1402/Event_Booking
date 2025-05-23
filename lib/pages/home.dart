import 'package:booking_event/pages/category.dart';
import 'package:booking_event/pages/detail_page.dart';
import 'package:booking_event/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream<QuerySnapshot>? eventStream;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String currentAddress = 'Fetching location...';

  final List<_Category> categories = const [
    _Category(label: 'Music', icon: 'images/musical.png'),
    _Category(label: 'Food', icon: 'images/dish.png'),
    _Category(label: 'Festival', icon: 'images/confetti.png'),
    _Category(label: 'Clothing', icon: 'images/tshirt.png'),
  ];

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    DatabaseMethods().getallEvents().then((stream) {
      setState(() => eventStream = stream);
    });
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => currentAddress = 'Location services disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => currentAddress = 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => currentAddress = 'Location permission permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          currentAddress = "${place.locality ?? ''}, ${place.street ?? ''}";
        });
      } else {
        setState(() => currentAddress = 'Unknown location');
      }
    } catch (e) {
      setState(() => currentAddress = 'Failed to get location');
    }
  }

  Widget allEvents() {
    if (eventStream == null) return const SizedBox.shrink();
    return StreamBuilder<QuerySnapshot>(
      stream: eventStream,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final docs = (snap.data?.docs ?? []).where((doc) {
          final data = doc.data()! as Map<String, dynamic>;
          final name = (data['Name'] ?? '').toString().toLowerCase();
          final location = (data['Location'] ?? '').toString().toLowerCase();
          return name.contains(searchQuery) || location.contains(searchQuery);
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text('No matching events found.'));
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final data = docs[i].data()! as Map<String, dynamic>;
            final name = data['Name'] ?? '';
            final price = data['Price'] ?? '';
            final location = data['Location'] ?? '';
            final dateStr = data['Date'] ?? '';
            String month = '––', day = '--';

            try {
              final dt = DateTime.parse(dateStr);
              month = DateFormat('MMM').format(dt);
              day = DateFormat('dd').format(dt);
            } catch (_) {}

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(
                    name: name,
                    date: dateStr,
                    location: location,
                    price: price,
                    detail: data['Detail'] ?? '',
                    image: 'images/event.jpg',
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                            Text(day, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '\$$price',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff6351ec)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe3e6ff), Color(0xfff1f3ff), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  currentAddress,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),

            ]),
            const SizedBox(height: 20),
            const Text(
              "There are 20 Events Around Your Location",
              style: TextStyle(color: Color(0xff6351ec), fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Search for events",
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("Categories", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 15),
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  return Material(
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CategoriesEvent(category: cat.label)),
                      ),
                      child: Container(
                        width: 130,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Image.asset(cat.icon, height: 40, width: 40),
                          const SizedBox(height: 8),
                          Text(cat.label, style: const TextStyle(fontSize: 18)),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("Upcoming Events", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            allEvents(),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }
}

class _Category {
  final String label, icon;
  const _Category({required this.label, required this.icon});
}
