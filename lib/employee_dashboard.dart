import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeeDashboard extends StatelessWidget {
  final String name;
  final String role;
  final String email;

  const EmployeeDashboard({super.key, required this.name, required this.role, required this.email});

  @override
  Widget build(BuildContext context) {
    // 🔹 Capitalize first letter to match Firestore format
    String formattedRole = role[0].toUpperCase() + role.substring(1).toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text("$name's Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    "Welcome, $name!",
                    style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Role: $formattedRole",
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Email: $email",
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Pending Complaints",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Complaints List (Fixed Height)
            Container(
              height: MediaQuery.of(context).size.height * 0.6, // ✅ Limits height to prevent overflow
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Complaints')
                    .where('role', isEqualTo: formattedRole) // Match role
                    .where('status', isEqualTo: "Pending") // Show only pending complaints
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No pending complaints."));
                  }

                  return ListView.builder(
                    shrinkWrap: true, // ✅ Prevent ListView from taking infinite height
                    physics: const NeverScrollableScrollPhysics(), // ✅ Avoid nested scroll issue
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var complaint = snapshot.data!.docs[index];
                      String docId = complaint.id; // Document ID for updating Firestore

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0), // ✅ Adds padding for better spacing
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Status: ${complaint['status']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("Description: ${complaint['description']}"),
                              Text("User Email: ${complaint['email']}"),
                              Text("Timestamp: ${complaint['timestamp'].toDate()}"),
                              const SizedBox(height: 10), // ✅ Space before buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ✅ Centers buttons horizontally
                                children: [
                                  // ✅ Resolve Button
                                  ElevatedButton(
                                    onPressed: () => _updateComplaintStatus(docId, "Resolved"),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text("Resolve", style: TextStyle(color: Colors.white)),
                                  ),
                                  // ✅ Reject Button
                                  ElevatedButton(
                                    onPressed: () {
                                      print("Reject button pressed for $docId");
                                      _updateComplaintStatus(docId, "Rejected");
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text("Reject", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Function to Update Complaint Status in Firestore
  void _updateComplaintStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('Complaints').doc(docId).update({
        'status': newStatus,
      });
      print("Complaint status updated to $newStatus"); // Debugging print
    } catch (e) {
      print("Error updating complaint: $e");
    }
  }
}
