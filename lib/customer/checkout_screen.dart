import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/custom_textfield.dart';

class CustomerCheckoutScreen extends StatefulWidget {
  @override
  _CustomerCheckoutScreenState createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _deliveryDateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _paymentMethod = 'Online';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(controller: _addressController, hintText: 'Full Shipping Address'),
              const SizedBox(height: 10,),
              CustomTextField(controller: _contactNumberController, hintText: 'Contact Number'),
              const SizedBox(height: 10,),
              CustomTextField(controller: _deliveryDateController, hintText: 'Delivery Date', keyboardType: TextInputType.datetime),
              const SizedBox(height: 10,),
              DropdownButtonFormField(
                value: _paymentMethod,
                onChanged: (String? newValue) {
                  setState(() {
                    _paymentMethod = newValue!;
                  });
                },
                items: <String>['Online', 'Pay on Delivery']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: _placeOrder,
                child: const Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      final address = _addressController.text;
      final contactNumber = _contactNumberController.text;
      final deliveryDate = _deliveryDateController.text;

      final user = _auth.currentUser;
      final cartItems = await _firestore.collection('cart').get();

      try {
        await _firestore.collection('orders').add({
          'customerId': user!.uid,
          'customerName': user.displayName,
          'shippingAddress': address,
          'contactNumber': contactNumber,
          'deliveryDate': deliveryDate,
          'paymentMethod': _paymentMethod,
          'products': cartItems.docs.map((doc) => doc.data()).toList(),
          'status': 'Pending',
        });

        // Clear the cart after placing the order
        for (var doc in cartItems.docs) {
          await _firestore.collection('cart').doc(doc.id).delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Placed Successfully')));
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
