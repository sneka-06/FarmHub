import 'package:farm_hub/browse_farm_page.dart';
import 'package:farm_hub/selection_page.dart';
import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top circles
          Positioned(
            top: -68,
            right: -87,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Color.fromRGBO(169, 224, 110, 0.75),
            ),
          ),
          Positioned(
            top: 119,
            right: -68,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Color.fromRGBO(235, 233, 109, 0.75),
            ),
          ),
          Positioned(
            top: 30,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SelectionPage()),
                );
              },
            ),
          ),
          // Bottom circles
          Positioned(
            right: 143,
            top: 814,
            child: CircleAvatar(
              radius: 104,
              backgroundColor: Color(0xBFA8DF6E),
            ),
          ),
          Positioned(
            right: 275,
            top: 670,
            child: CircleAvatar(
              radius: 130,
              backgroundColor: Color(0xBFEAE86C),
            ),
          ),

          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset("assets/images/map.png", width: 250)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BrowseFarmsPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(169, 224, 110, 1),
                  foregroundColor: Color.fromRGBO(0, 0, 0, 1),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "ACCESS LOCATION",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Fredoka",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.location_on_outlined, size: 30),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
