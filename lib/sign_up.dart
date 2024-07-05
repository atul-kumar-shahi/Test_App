import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'phone_verification_screen.dart';
import 'login_screen.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_textfield.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _addressProof;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPhoneVerified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50,),
                const Text('Welcome !', style: TextStyle(fontSize: 26, color: Colors.blue),),
                const SizedBox(height: 30,),
                CustomTextField(controller: _nameController, hintText: 'Full Name', keyboardType: TextInputType.name),
                const SizedBox(height: 10,),
                CustomTextField(controller: _contactNumberController, hintText: 'Contact Number', keyboardType: TextInputType.phone, onChanged: _handlePhoneChange),
                ElevatedButton(
                  onPressed: _isPhoneVerified ? null : _verifyPhone,
                  child: Text(_isPhoneVerified ? 'Phone Verified' : 'Verify Phone'),
                ),
                const SizedBox(height: 10,),
                CustomTextField(controller: _emailController, hintText: 'Email', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10,),
                CustomTextField(controller: _pinCodeController, hintText: 'Pin Code', keyboardType: TextInputType.number, onChanged: _fetchCityAndState),
                const SizedBox(height: 10,),
                CustomTextField(controller: _stateController, hintText: 'State', readOnly: true),
                const SizedBox(height: 10,),
                CustomTextField(controller: _cityController, hintText: 'City', readOnly: true),
                const SizedBox(height: 10,),
                CustomTextField(controller: _addressController, hintText: 'Address', keyboardType: TextInputType.streetAddress),
                const SizedBox(height: 10,),
                CustomTextField(controller: _passwordController, hintText: 'Password', isObscuredText: true),
                const SizedBox(height: 10,),
                CustomTextField(controller: _confirmPasswordController, hintText: 'Confirm Password', isObscuredText: true),
                const SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: _pickAddressProof,
                  child: const Text('Upload Address Proof'),
                ),
                const SizedBox(height: 30,),
                CustomButton(text: 'Sign Up', onTap: _signUp),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey[400],),
                      ),
                      const SizedBox(height: 70,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OR', style: TextStyle(color: Colors.grey.shade700,),),
                      ),
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey[400],),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text('Already have an account? SignIn'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePhoneChange(String phone) {
    setState(() {
      _isPhoneVerified = false;
    });
  }

  void _verifyPhone() {
    final formattedPhone = _formatPhoneNumber(_contactNumberController.text);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneVerificationScreen(
          onVerified: (phone) {
            setState(() {
              _contactNumberController.text = phone;
              _isPhoneVerified = true;
            });
          },
        ),
      ),
    );
  }
  String _formatPhoneNumber(String phone) {
    // Ensure the phone number is in E.164 format
    if (!phone.startsWith('+')) {
      return '+91$phone'; // Replace '+91' with your default country code
    }
    return phone;
  }

  Future<void> _fetchCityAndState(String pinCode) async {
    if (pinCode.length == 6) {
      final url = 'http://www.postalpincode.in/api/pincode/$pinCode';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Status'] == 'Success') {
          final postOffice = data['PostOffice'][0];
          setState(() {
            _cityController.text = postOffice['District'];
            _stateController.text = postOffice['State'];
          });
        }
      }
    }
  }

  Future<void> _pickAddressProof() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _addressProof = pickedFile;
    });
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate() && _isPhoneVerified) {
      final name = _nameController.text;
      final contactNumber = _contactNumberController.text;
      final email = _emailController.text;
      final pinCode = _pinCodeController.text;
      final state = _stateController.text;
      final city = _cityController.text;
      final address = _addressController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }

      if (_addressProof == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload address proof')));
        return;
      }

      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        final user = userCredential.user;

        if (user != null) {
          await user.sendEmailVerification();

          await _firestore.collection('users').doc(user.uid).set({
            'name': name,
            'contactNumber': contactNumber,
            'email': email,
            'pinCode': pinCode,
            'state': state,
            'city': city,
            'address': address,
            'addressProof': _addressProof!.path,
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful. Please verify your email.')));
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } else if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please verify your phone number')));
    }
  }
}
