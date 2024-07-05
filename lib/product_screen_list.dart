import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final products = productSnapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              final product = products[index];
              return ListTile(
                title: Text(product['name']),
                subtitle: Text('\$${product['rate']}'),
                leading: Image.network(product['imageUrl']),
                onTap: () {
                  Navigator.of(context).pushNamed('/product-details', arguments: product.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
