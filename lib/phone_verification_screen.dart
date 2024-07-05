import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final Function(String) onVerified;

  const PhoneVerificationScreen({Key? key, required this.onVerified}) : super(key: key);

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+91XXXXXXXXXX',
                errorText: _isPhoneValid(_phoneController.text) ? null : 'Invalid phone number format',
              ),
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
            if (_otpSent) ...[
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'OTP',
                ),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _verifyOTP,
                child: Text('Verify OTP'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _isPhoneValid(_phoneController.text) ? _sendOTP : null,
                child: Text('Send OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isPhoneValid(String phone) {
    final regex = RegExp(r'^\+\d{1,3}\d{10}$');
    return regex.hasMatch(phone);
  }

  void _sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        widget.onVerified(_phoneController.text);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Verification failed')));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _verifyOTP() async {
    if (_verificationId != null) {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );

      try {
        await _auth.signInWithCredential(credential);
        widget.onVerified(_phoneController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP')));
      }
    }
  }
}
