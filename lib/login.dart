import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hostel/forgot_password.dart';
import 'package:hostel/home.dart';
import 'package:hostel/service/auth.dart';
import 'package:hostel/signup.dart';
import 'package:hostel/employee_login.dart'; // ✅ Import Employee Login Page

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";

  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  // ✅ Updated userLogin() Function
  userLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        String userId = user.uid; // ✅ Get userId from Firebase Auth

        // 🔹 Fetch user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("User")
            .doc(userId)
            .get();

        if (userDoc.exists) {
          // ✅ Fetch "id" and "name" from Firestore
          String storedUserId = userDoc["id"] ?? userId;
          String username = userDoc["name"] ?? "User";

          // ✅ Navigate to Home Page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(username: username, userId: storedUserId),
            ),
          );
        } else {
          _showSnackBar("User not found in database", Colors.orangeAccent);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackBar("No User Found for that Email", Colors.red);
      } else if (e.code == 'wrong-password') {
        _showSnackBar("Wrong Password Provided", Colors.red);
      } else {
        _showSnackBar("Error: ${e.message}", Colors.red);
      }
    }
  }

  /// ✅ **Helper function to show SnackBar**
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18.0)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Image.asset(
                  "images/nitwbuilding.png",
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 30.0),

                Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      _buildInputField(mailcontroller, "Email"),
                      const SizedBox(height: 20.0),
                      _buildInputField(passwordcontroller, "Password", obscureText: true),
                      const SizedBox(height: 20.0),

                      GestureDetector(
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              email = mailcontroller.text;
                              password = passwordcontroller.text;
                            });
                            userLogin();
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 13.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF273671),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20.0),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPassword()),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFF8c8e98),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                const Text(
                  "or Log In with",
                  style: TextStyle(
                    color: Color(0xFF273671),
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20.0),

                GestureDetector(
                  onTap: () {
                    AuthMethods().signInWithGoogle(context);
                  },
                  child: Image.asset(
                    "images/google.png",
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Color(0xFF8c8e98),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                        );
                      },
                      child: const Text(
                        "SignUp",
                        style: TextStyle(
                          color: Color(0xFF273671),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),

                // Employee Login Button
                const Text(
                  "Are you an employee?",
                  style: TextStyle(
                    color: Color(0xFF8c8e98),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmployeeLogin()), // ✅ Navigate to Employee Login
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: const EdgeInsets.symmetric(vertical: 13.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF6A1B9A), // Different color for employee login
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text(
                        "Employee Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
      decoration: BoxDecoration(
        color: const Color(0xFFedf0f8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please Enter $hintText';
          }
          return null;
        },
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0),
        ),
      ),
    );
  }
}
