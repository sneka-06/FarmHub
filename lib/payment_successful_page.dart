import 'package:farm_hub/browse_farm_page.dart';
import 'package:flutter/material.dart';

class PaymentSuccessfulPage extends StatelessWidget {
  const PaymentSuccessfulPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: Stack(
        children: [
          Positioned(
            top: -68,
            left: -87,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Color.fromRGBO(169, 224, 110, 0.75),
            ),
          ),
          Positioned(
            top: 119,
            left: -68,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Color.fromRGBO(235, 233, 109, 0.75),
            ),
          ),
          Positioned(
            left: 275,
            top: 670,
            child: CircleAvatar(
              radius: 130,
              backgroundColor: Color(0xBFA8DF6E),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset("assets/images/success.png", width: 250),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Congratulations!",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(17, 26, 44, 1),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  "You have successfully made\nthe payment, enjoy our service!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BrowseFarmsPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(235, 233, 109, 0.75),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Return to Home Page",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.home, size: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
