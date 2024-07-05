import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout_screen.dart';

class CustomerCartScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              return ListTile(
                title: Text(cartItem['productName']),
                subtitle: Text('Quantity: ${cartItem['quantity']}'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editQuantity(cartItem.id),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerCheckoutScreen()));
          },
          child: const Text('Checkout'),
        ),
      ),
    );
  }

  void _editQuantity(String cartItemId) {
    // Implement edit quantity logic here
  }
}
