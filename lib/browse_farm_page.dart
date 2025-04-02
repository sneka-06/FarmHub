import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_hub/buyingpage.dart';
import 'package:farm_hub/cart_page.dart';
import 'package:farm_hub/selection_page.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;

class BrowseFarmsPage extends StatefulWidget {
  const BrowseFarmsPage({super.key});

  @override
  _BrowseFarmsPageState createState() => _BrowseFarmsPageState();
}

class _BrowseFarmsPageState extends State<BrowseFarmsPage> {
  String currentLocation = "Fetching location...";
  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => currentLocation = "Location services disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => currentLocation = "Location permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => currentLocation = "Location permanently denied");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // ✅ Store and Print consumer coordinates
    userLat = position.latitude;
    userLng = position.longitude;

    print("📍 Consumer Latitude: $userLat");
    print("📍 Consumer Longitude: $userLng");

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];

    setState(() {
      currentLocation = "${place.locality}, ${place.administrativeArea}";
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA8DF6E),
      appBar: AppBar(
        title: const Text(
          "FarmHub",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            fontFamily: "Fredoka",
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFA8DF6E),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SelectionPage()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Color(0xFFA8DF6E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/fruit_basket.png", height: 40),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TODAY'S OFFER",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Free fruits with every order",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          "OFFER",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.black),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Near You",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(currentLocation, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('farmers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final farmers = snapshot.data!.docs;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: farmers.length,
                  itemBuilder: (context, index) {
                    final farmData =
                        farmers[index].data() as Map<String, dynamic>;
                    double distance = 0.0;

                    if (userLat != null &&
                        userLng != null &&
                        farmData.containsKey('latitude') &&
                        farmData.containsKey('longitude')) {
                      distance = calculateDistance(
                        userLat!,
                        userLng!,
                        farmData['latitude'],
                        farmData['longitude'],
                      );
                    }

                    return FarmCard(
                      name: farmData['farmName'] ?? 'Unknown',
                      location: farmData['location'] ?? '',
                      rating: 4,
                      distance: distance,
                      imagePath: 'assets/images/farmer1.png',
                      farmerId: farmData['uid'] ?? '',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FarmCard extends StatelessWidget {
  final String name;
  final String location;
  final int rating;
  final double distance;
  final String imagePath;
  final String farmerId;

  const FarmCard({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.distance,
    required this.imagePath,
    required this.farmerId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[200],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyingPage(farmerId: farmerId),
                ),
              );
            },
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: "Fredoka",
              fontSize: 20,
            ),
          ),
          Text(
            location,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: "Fredoka",
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 16,
                color: index < rating ? Colors.orange : Colors.grey,
              );
            }),
          ),
          const SizedBox(height: 5),
          Text(
            distance < 0.1
                ? "Less than 0.1 km"
                : "${distance.toStringAsFixed(1)} km",
            style: const TextStyle(
              fontSize: 18,
              fontFamily: "Fredoka",
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
