import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hostel/home.dart';
import 'package:hostel/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> registration() async {
    if (password.isNotEmpty &&
        nameController.text.isNotEmpty &&
        mailController.text.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;
        if (user != null) {
          // 🔹 Store user details in Firestore
          await FirebaseFirestore.instance.collection("User").doc(user.uid).set({
            "email": email,
            "id": user.uid, // ✅ Store User ID
            "name": nameController.text, // ✅ Store Name
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Registered Successfully",
              style: TextStyle(fontSize: 20.0),
            ),
          ));

          // 🔹 Navigate to Home with Username and User ID
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(
                username: nameController.text,
                userId: user.uid,
              ),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already Exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
    }
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

                const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Color(0xFF273671),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField(nameController, "Name"),
                      const SizedBox(height: 20.0),
                      _buildInputField(mailController, "Email"),
                      const SizedBox(height: 20.0),
                      _buildInputField(passwordController, "Password", obscureText: true),
                      const SizedBox(height: 20.0),

                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              email = mailController.text;
                              name = nameController.text;
                              password = passwordController.text;
                            });
                            registration();
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
                              "Sign Up",
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

                const SizedBox(height: 40.0),

                const Text(
                  "or Log In with",
                  style: TextStyle(
                    color: Color(0xFF273671),
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30.0),

                GestureDetector(
                  onTap: () {
                    // 🔹 Add Google Sign-In Logic Here
                  },
                  child: Image.asset(
                    "images/google.png",
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 40.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
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
                          MaterialPageRoute(builder: (context) => LogIn()),
                        );
                      },
                      child: const Text(
                        "Log In",
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
