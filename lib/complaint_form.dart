import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ComplaintForm extends StatefulWidget {
  final String username;
  final String userId;

  const ComplaintForm({super.key, required this.username, required this.userId});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}


class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();
  String selectedRole = "Carpenter";
  bool isLoading = false;

  // 🚀 Submit Complaint to Firestore
  Future<void> submitComplaint() async {
    setState(() => isLoading = true);

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ User is not logged in!")),
      );
      setState(() => isLoading = false);
      return;
    }

    String description = descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please enter a description")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection("Complaints").add({
        "userId": currentUser.uid,
        "email": currentUser.email ?? "Unknown",
        "role": selectedRole,
        "description": description,
        "timestamp": FieldValue.serverTimestamp(),
        "status": "Pending"
      });

      print("✅ Complaint Submitted: $description");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Complaint Submitted Successfully")),
      );

      // Reset form
      setState(() {
        descriptionController.clear();
        selectedRole = "Carpenter";
        isLoading = false;
      });

    } catch (e) {
      print("⚠️ Failed to Submit Complaint: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Failed to Submit Complaint: $e")),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Raise a Complaint"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔹 Dropdown for Employee Role Selection
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: "Select Employee Role"),
              items: ["Carpenter", "Electrician", "Plumber", "Security", "Sweeper", "Warden"]
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) => setState(() => selectedRole = value!),
            ),
            const SizedBox(height: 15),

            // 🔹 Description Field
            TextFormField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Problem Description",
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? "Please enter a description" : null,
            ),
            const SizedBox(height: 15),

            // 🔹 Submit Button
            SizedBox(
              width: double.infinity, // Expand to full width
              child: ElevatedButton(
                onPressed: isLoading ? null : submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF273671),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Slightly rounded corners
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Submit Complaint",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
