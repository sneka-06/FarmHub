import 'package:farm_hub/farm_account.dart';
import 'package:flutter/material.dart';

class PaymentFarmer extends StatelessWidget {
  const PaymentFarmer({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> transactions = [
      {"date": "12 FEB 2025", "status": "Received", "amount": "₹500"},
      {"date": "29 JAN 2025", "status": "Pending", "amount": "₹400"},
      {"date": "18 JAN 2025", "status": "Received", "amount": "₹100"},
      {"date": "06 JAN 2025", "status": "Received", "amount": "₹300"},
      {"date": "31 DEC 2024", "status": "Received", "amount": "₹350"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FarmAccount()),
            );
          },
        ),
        title: const Text(
          "Payment Details",
          style: TextStyle(
            fontFamily: "Fredoka",
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEarningsCard(
                      "Total earnings",
                      "₹3000",
                      const Color(0xFF2F5D3E),
                    ),
                    const SizedBox(width: 16), // Space between the boxes
                    _buildEarningsCard(
                      "Pending",
                      "₹400",
                      const Color(0xFF2F5D3E),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(String title, String amount, Color color) {
    return Container(
      width: 160, // Ensures both cards are of equal width
      height: 100, // Ensures both cards are of equal height
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: "Fredoka",
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: title == "Pending" ? Colors.red : Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            amount,
            style: const TextStyle(
              fontFamily: "Fredoka",
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, String> transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction["date"]!,
                style: const TextStyle(
                  fontFamily: "Fredoka",
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                transaction["status"]!,
                style: TextStyle(
                  fontFamily: "Fredoka",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      transaction["status"] == "Pending"
                          ? Colors.red
                          : Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            transaction["amount"]!,
            style: const TextStyle(
              fontFamily: "Fredoka",
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
