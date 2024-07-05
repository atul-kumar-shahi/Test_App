import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminOrderDetailsScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('orders').doc(orderId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data!;
          final products = order['products'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer Name: ${order['customerName']}'),
                Text('Shipping Address: ${order['shippingAddress']}'),
                Text('Contact Number: ${order['contactNumber']}'),
                Text('Delivery Date: ${order['deliveryDate']}'),
                const SizedBox(height: 10,),
                Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...products.map((product) => Text('${product['name']} - ${product['quantity']}')),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _updateOrderStatus(order.id, 'Accepted'),
                      child: const Text('Accept'),
                    ),
                    const SizedBox(width: 10,),
                    ElevatedButton(
                      onPressed: () => _updateOrderStatus(order.id, 'Rejected'),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({'status': status});
    // Implement sending notification to customer logic here
  }
}
