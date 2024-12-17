import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'utils/toast.dart';
import 'verification_screen.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  bool isSignIn = true;

  void signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
        Navigator.pushReplacementNamed(context, '/list');
      } else {
        showToast('Please verify your email');
      }
    } catch (e) {
      showToast('Login failed: $e');
    }
  }

  void signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseAuth.instance.currentUser?.sendEmailVerification();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VerificationScreen()),
      );
    } catch (e) {
      showToast('Sign-up failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isSignIn ? "Sign In" : "Sign Up")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) => email = value!,
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) => password = value!,
                validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    isSignIn ? signIn() : signUp();
                  }
                },
                child: Text(isSignIn ? "Sign In" : "Sign Up"),
              ),
              RichText(
                text: TextSpan(
                  text: isSignIn ? "Don't have an account? " : "Already have an account? ",
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: isSignIn ? "Sign Up" : "Sign In",
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () => setState(() => isSignIn = !isSignIn),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
