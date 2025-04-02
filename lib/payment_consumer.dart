import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_hub/cart_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_hub/payment_successful_page.dart';
import 'package:farm_hub/secrets.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'cart_data.dart';

class PaymentConsumer extends StatefulWidget {
  const PaymentConsumer({super.key});

  @override
  State<PaymentConsumer> createState() => _PaymentConsumerState();
}

class _PaymentConsumerState extends State<PaymentConsumer> {
  late Razorpay _razorpay;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    calculateCartTotal();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void calculateCartTotal() {
    totalAmount = 0.0;
    for (var item in cartItems) {
      double price = double.parse(
        (item["price"] ?? "").replaceAll("₹", "").replaceAll("/kg", "").trim(),
      );
      int quantity = int.parse(item["quantity"] ?? "0");
      totalAmount += price * quantity;
    }
  }

  void _openRazorpayCheckout() {
    var options = {
      'key': paymentapikey,
      'amount': (totalAmount * 100).toInt(),
      'name': 'FarmHub',
      'description': 'Farm Product Purchase',
      'prefill': {'contact': '9876543210', 'email': 'user@example.com'},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Checkout Error: $e");
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'paymentId': response.paymentId,
        'totalAmount': totalAmount,
        'timestamp': FieldValue.serverTimestamp(),
        'items':
            cartItems.map((item) {
              return {
                'title': item['title'],
                'price': item['price'],
                'quantity': item['quantity'],
                'description': item['description'],
                'image': item['image'],
                'farmerName': item['farmerName'],
                'farmerId': item['farmerId'] ?? 'unknown_farmer',
              };
            }).toList(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Payment Successful!")));

      cartItems.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PaymentSuccessfulPage()),
      );
    } catch (e) {
      print("Firestore Save Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Payment saved, but failed to store order.")),
      );
    }
  }

  void _handleError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("❌ Payment Failed")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("💼 Wallet: ${response.walletName}")),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA9E06E),
      appBar: AppBar(
        title: const Text("Payment", style: TextStyle(fontFamily: "Fredoka")),
        backgroundColor: const Color(0xFFA9E06E),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "You are about to pay",
                      style: TextStyle(fontSize: 16, fontFamily: "Fredoka"),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "₹${totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontFamily: "Fredoka",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _openRazorpayCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Pay ₹${totalAmount.toStringAsFixed(2)} with Razorpay",
                style: const TextStyle(fontSize: 16, fontFamily: "Fredoka"),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Back to Cart",
                style: TextStyle(fontSize: 16, fontFamily: "Fredoka"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
