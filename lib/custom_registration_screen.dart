import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerRegistrationScreen extends StatefulWidget {
  @override
  _CustomerRegistrationScreenState createState() => _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState extends State<CustomerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  String _name = '';
  String _contactNumber = '';
  String _email = '';
  String _pincode = '';
  String _state = '';
  String _city = '';
  String _address = '';
  String _password = '';
  String _verificationId = '';
  String _otp = '';
  XFile? _addressProof;
  bool _isLoading = false;
  bool _isOtpSent = false;

  Future<void> _getCityState() async {
    final response = await http.get(Uri.parse('http://www.postalpincode.in/api/pincode/$_pincode'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Status'] == 'Success') {
        setState(() {
          _city = data['PostOffice'][0]['District'];
          _state = data['PostOffice'][0]['State'];
        });
      }
    }
  }

  Future<void> _verifyPhoneNumber() async {
    final phoneNumber = _formatPhoneNumber(_contactNumber);
    if (phoneNumber == null) {
      print('Invalid phone number format');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid phone number format')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _registerCustomer();
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      print('Error sending OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerCustomer() async {
    if (!_formKey.currentState!.validate() || _addressProof == null) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
      final userId = userCredential.user!.uid;

      final addressProofUrl = await _uploadAddressProof(userId);

      await _firestore.collection('customers').doc(userId).set({
        'name': _name,
        'contactNumber': _contactNumber,
        'email': _email,
        'pincode': _pincode,
        'state': _state,
        'city': _city,
        'address': _address,
        'addressProofUrl': addressProofUrl,
      });

      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print('Error registering customer: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _uploadAddressProof(String userId) async {
    final storageRef = FirebaseStorage.instance.ref().child('addressProofs/$userId');
    final uploadTask = storageRef.putFile(File(_addressProof!.path));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _submitOtp() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _otp,
    );

    try {
      await _auth.signInWithCredential(credential);
      _registerCustomer();
    } catch (e) {
      print('Invalid OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.trim();
    final RegExp phoneRegExp = RegExp(r'^\d{10}$');
    if (phoneRegExp.hasMatch(phoneNumber)) {
      return '+91$phoneNumber'; // Country code for India is +91
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Registration')),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Customer Name'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your name';
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty || value.length != 10) return 'Please enter a valid contact number';
                  return null;
                },
                onChanged: (value) => _contactNumber = value.trim(),
                onSaved: (value) => _contactNumber = value!.trim(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email ID'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) return 'Please enter a valid email';
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Pin Code'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a pin code';
                  return null;
                },
                onSaved: (value) => _pincode = value!,
                onChanged: (value) {
                  _pincode = value;
                  _getCityState();
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'State'),
                readOnly: true,
                controller: TextEditingController(text: _state),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'City'),
                readOnly: true,
                controller: TextEditingController(text: _city),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your address';
                  return null;
                },
                onSaved: (value) => _address = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              TextButton(
                onPressed: () async {
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _addressProof = pickedFile;
                  });
                },
                child: Text('Upload Address Proof'),
              ),
              if (_addressProof != null) Text('File selected: ${_addressProof!.name}'),
              SizedBox(height: 20),
              if (!_isOtpSent)
                ElevatedButton(
                  onPressed: () async {
                    await _verifyPhoneNumber();
                  },
                  child: Text('Send OTP'),
                ),
              if (_isOtpSent)
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Enter OTP'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _otp = value;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _submitOtp();
                      },
                      child: Text('Submit OTP'),
                    ),
                  ],
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
