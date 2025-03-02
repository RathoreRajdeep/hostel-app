import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hostel/employee_dashboard.dart'; // Import Employee Dashboard

class EmployeeLogin extends StatefulWidget {
  const EmployeeLogin({super.key});

  @override
  State<EmployeeLogin> createState() => _EmployeeLoginState();
}

class _EmployeeLoginState extends State<EmployeeLogin> {
  String email = "", password = "";

  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> employeeLogin() async {
    try {
      // 🔹 Fetch Employee Data from Firestore
      var employeeQuery = await FirebaseFirestore.instance
          .collection('employees')
          .where('email', isEqualTo: email)
          .get();

      if (employeeQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Employee not found")),
        );
        return;
      }

      var employeeDoc = employeeQuery.docs.first;
      String storedPassword = employeeDoc['password'];
      String role = employeeDoc['role'];
      String name = employeeDoc['name']; // 🔹 Fetch Name

      if (password != storedPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect Password")),
        );
        return;
      }

      // 🔹 Navigate to Employee Dashboard with Name & Role
      // 🔹 Navigate to Employee Dashboard with Name, Role & Email
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmployeeDashboard(name: name, role: role, email: email),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: $e")),
      );
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "images/nitwbuilding.png",
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20.0),

                // 🔹 Employee Login Text (Bold)
                const Text(
                  "Employee Login",
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF273671),
                  ),
                ),

                const SizedBox(height: 30.0),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField(mailController, "Email"),
                      const SizedBox(height: 20.0),
                      _buildInputField(passwordController, "Password", obscureText: true),
                      const SizedBox(height: 20.0),

                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              email = mailController.text;
                              password = passwordController.text;
                            });
                            employeeLogin();
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 13.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A1B9A), // Mixture of red and blue (Purple shade)
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              "Employee Login",
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

                const SizedBox(height: 30.0),

                // 🔹 Employee Importance Quote
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "\"Employees are the backbone of every successful organization. Their dedication builds the future.\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(height: 20.0), // Prevents bottom overflow
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
