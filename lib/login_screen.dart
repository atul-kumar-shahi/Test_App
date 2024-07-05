import 'package:app/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'main.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50,),
              const Text('Login', style: TextStyle(fontSize: 26, color: Colors.blue),),
              const SizedBox(height: 30,),
              CustomTextField(controller: _emailController, hintText: 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10,),
              CustomTextField(controller: _passwordController, hintText: 'Password', isObscuredText: true),
              const SizedBox(height: 30,),
              CustomButton(text: 'Login', onTap: _login),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                },
                child: Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
