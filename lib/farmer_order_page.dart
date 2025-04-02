import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FarmerOrdersPage extends StatelessWidget {
  const FarmerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentFarmerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Color(0xFFA9E06E),
      appBar: AppBar(
        title: Text("My Orders", style: TextStyle(fontFamily: "Fredoka")),
        backgroundColor: Color(0xFFA9E06E),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('orders')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;
          List<Widget> myOrders = [];

          for (var order in orders) {
            final data = order.data() as Map<String, dynamic>;
            final List<dynamic> items = data['items'] ?? [];

            // Filter items for this farmer
            final List<dynamic> farmerItems =
                items
                    .where((item) => item['farmerId'] == currentFarmerId)
                    .toList();

            if (farmerItems.isNotEmpty) {
              myOrders.add(
                Card(
                  margin: EdgeInsets.all(10),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Buyer: ${data['userId'] ?? 'Unknown'}",
                          style: TextStyle(
                            fontFamily: "Fredoka",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...farmerItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              "${item['title']} × ${item['quantity']}",
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: "Fredoka",
                              ),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 10),
                        Text(
                          "Payment ID: ${data['paymentId']}",
                          style: TextStyle(fontSize: 13),
                        ),
                        Text(
                          "Date: ${data['timestamp']?.toDate()?.toLocal().toString().split('.')[0] ?? 'Unknown'}",
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }

          return myOrders.isEmpty
              ? Center(
                child: Text(
                  "No orders yet.",
                  style: TextStyle(fontSize: 18, fontFamily: "Fredoka"),
                ),
              )
              : ListView(children: myOrders);
        },
      ),
    );
  }
}
