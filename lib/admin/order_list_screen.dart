import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_detail_screen.dart';

class AdminOrderListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text(order['customerName']),
                subtitle: Text(order['shippingAddress']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminOrderDetailsScreen(orderId: order.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
