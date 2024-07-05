import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerProductDetailsScreen extends StatelessWidget {
  final String productId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CustomerProductDetailsScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('products').doc(productId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final product = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product Name: ${product['name']}'),
                Text('Description: ${product['description']}'),
                Text('Rate: \$${product['rate']}'),
                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () => _addToCart(product.id),
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _addToCart(String productId) async {
    // Implement add to cart logic here
  }
}
