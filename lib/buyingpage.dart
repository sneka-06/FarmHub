import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cart_data.dart';
import 'cart_page.dart';

class BuyingPage extends StatefulWidget {
  final String farmerId;

  const BuyingPage({super.key, required this.farmerId});

  @override
  State<BuyingPage> createState() => _BuyingPageState();
}

class _BuyingPageState extends State<BuyingPage> {
  String farmName = '';
  String farmLocation = '';
  String farmDescription =
      'Welcome to my farm, where we grow fresh, organic fruits and vegetables with love.';

  @override
  void initState() {
    super.initState();
    _fetchFarmerDetails();
  }

  void _fetchFarmerDetails() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('farmers')
            .doc(widget.farmerId)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        farmName = data['farmName'] ?? 'Unnamed Farm';
        farmLocation = data['location'] ?? 'Unknown';
      });
    }
  }

  void addToCart(String image, String title, String description, String price) {
    bool itemExists = false;
    for (var item in cartItems) {
      if (item["title"] == title && item["farmerId"] == widget.farmerId) {
        int currentQuantity = int.parse(item["quantity"].toString());
        item["quantity"] = (currentQuantity + 1).toString();
        itemExists = true;
        break;
      }
    }

    if (!itemExists) {
      cartItems.add({
        "image": image,
        "title": title,
        "description": description,
        "price": price,
        "quantity": "1",
        "farmerId": widget.farmerId,
        "farmerName": farmName, // ✅ Added for CartPage and Orders
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/images/farm.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 40,
                        left: 10,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Fredoka",
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          farmLocation,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          farmDescription,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🔥 Load products from Firestore
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('products')
                                  .where('farmerId', isEqualTo: widget.farmerId)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Text(
                                "Error loading products: ${snapshot.error}",
                              );
                            }

                            final products = snapshot.data!.docs;

                            if (products.isEmpty) {
                              return const Text("No products available");
                            }

                            return Column(
                              children:
                                  products.map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    return ProductCard(
                                      image:
                                          data['imageUrl'] ??
                                          'assets/images/fruit_basket.png',
                                      title: data['name'] ?? '',
                                      description: data['description'] ?? '',
                                      price: "₹${data['price']}/kg",
                                      onAdd: addToCart,
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              label: const Text(
                "Go to Cart",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Fredoka",
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final String price;
  final Function(String, String, String, String) onAdd;

  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.price,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading:
            image.startsWith("http")
                ? Image.network(image, width: 50, height: 50, fit: BoxFit.cover)
                : Image.asset(image, width: 50),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: "Fredoka",
            fontSize: 24,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: "Fredoka",
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: "Fredoka",
                color: Colors.green,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => onAdd(image, title, description, price),
          child: const Text("Add"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
