import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../widgets/custom_textfield.dart';

class AdminProductMasterScreen extends StatefulWidget {
  @override
  _AdminProductMasterScreenState createState() => _AdminProductMasterScreenState();
}

class _AdminProductMasterScreenState extends State<AdminProductMasterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  XFile? _productImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Master'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(controller: _nameController, hintText: 'Product Name'),
              const SizedBox(height: 10,),
              CustomTextField(controller: _descriptionController, hintText: 'Description'),
              const SizedBox(height: 10,),
              CustomTextField(controller: _rateController, hintText: 'Rate', keyboardType: TextInputType.number),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: _pickProductImage,
                child: const Text('Upload Product Image'),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProductImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _productImage = pickedFile;
    });
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final description = _descriptionController.text;
      final rate = double.parse(_rateController.text);

      try {
        await _firestore.collection('products').add({
          'name': name,
          'description': description,
          'rate': rate,
          'image': _productImage!.path,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product Added Successfully')));
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
