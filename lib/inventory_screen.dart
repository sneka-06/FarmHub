import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? farmerId;

  @override
  void initState() {
    super.initState();
    farmerId = _auth.currentUser?.uid;
  }

  Future<String?> uploadImageToCloudinary(XFile imageFile) async {
    const cloudName = 'dbi0syxmv';
    const uploadPreset = 'farmhub_upload'; // Use your unsigned preset

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resData = json.decode(await response.stream.bytesToString());
      return resData['secure_url'];
    } else {
      print("Cloudinary upload failed: ${response.statusCode}");
      return null;
    }
  }

  Future<void> _showProductDialog({
    Map<String, dynamic>? product,
    String? docId,
  }) async {
    final nameController = TextEditingController(text: product?['name']);
    final priceController = TextEditingController(text: product?['price']);
    final quantityController = TextEditingController(
      text: product?['quantity'],
    );
    final descriptionController = TextEditingController(
      text: product?['description'],
    );
    XFile? pickedImage;
    String? imageUrl = product?['imageUrl'];

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                product == null ? 'Add Product' : 'Edit Product',
                style: const TextStyle(fontFamily: "Fredoka"),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          setStateSB(() => pickedImage = picked);
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            pickedImage != null
                                ? FileImage(File(pickedImage!.path))
                                : (imageUrl != null
                                        ? NetworkImage(imageUrl)
                                        : null)
                                    as ImageProvider?,
                        child:
                            pickedImage == null && imageUrl == null
                                ? const Icon(Icons.camera_alt)
                                : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInput(nameController, "Name"),
                    _buildInput(priceController, "Price (₹)"),
                    _buildInput(quantityController, "Quantity (kg)"),
                    _buildInput(
                      descriptionController,
                      "Description",
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    String? finalImageUrl = imageUrl;

                    if (pickedImage != null) {
                      finalImageUrl = await uploadImageToCloudinary(
                        pickedImage!,
                      );
                      if (finalImageUrl == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("❌ Image upload failed"),
                          ),
                        );
                        return;
                      }
                    }

                    final newProduct = {
                      'name': nameController.text.trim(),
                      'price': priceController.text.trim(),
                      'quantity': quantityController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'imageUrl': finalImageUrl,
                      'farmerId': farmerId,
                      'timestamp': FieldValue.serverTimestamp(),
                    };

                    if (docId == null) {
                      await _firestore.collection('products').add(newProduct);
                    } else {
                      await _firestore
                          .collection('products')
                          .doc(docId)
                          .update(newProduct);
                    }

                    if (mounted) Navigator.pop(context);
                  },
                  child: Text(product == null ? "Add" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(String docId) async {
    await _firestore.collection('products').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA8DF6E),
      appBar: AppBar(
        title: const Text(
          "My Inventory",
          style: TextStyle(fontFamily: "Fredoka"),
        ),
        backgroundColor: const Color(0xFFA8DF6E),
        elevation: 0,
        centerTitle: true,
      ),
      body:
          farmerId == null
              ? const Center(child: Text("You are not logged in"))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('products')
                        .where('farmerId', isEqualTo: farmerId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No products found",
                        style: TextStyle(fontFamily: "Fredoka"),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final product =
                          docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: ListTile(
                          leading:
                              product['imageUrl'] != null
                                  ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      product['imageUrl'],
                                    ),
                                  )
                                  : const CircleAvatar(
                                    child: Icon(Icons.image),
                                  ),
                          title: Text(
                            product['name'],
                            style: const TextStyle(fontFamily: "Fredoka"),
                          ),
                          subtitle: Text(
                            "₹${product['price']} • ${product['quantity']} kg",
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showProductDialog(
                                  product: product,
                                  docId: docId,
                                );
                              } else if (value == 'delete') {
                                _deleteProduct(docId);
                              }
                            },
                            itemBuilder:
                                (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text("Edit"),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text("Delete"),
                                  ),
                                ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
