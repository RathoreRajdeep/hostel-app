import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeeDashboard extends StatefulWidget {
  final String name;
  final String role;
  final String email;

  const EmployeeDashboard({super.key, required this.name, required this.role, required this.email});

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int credits = 0; // Stores employee credits

  @override
  void initState() {
    super.initState();
    _fetchEmployeeCredits(); // Fetch credits on load
  }

  // 🔹 Fetch Employee Credits from Firestore
  Future<void> _fetchEmployeeCredits() async {
    try {
      DocumentReference employeeRef = FirebaseFirestore.instance.collection('employees').doc(widget.email);
      DocumentSnapshot employeeDoc = await employeeRef.get();

      if (employeeDoc.exists) {
        print("✅ Firestore document found: ${employeeDoc.data()}");

        setState(() {
          credits = int.tryParse(employeeDoc['credits'].toString()) ?? 0;
        });

        print("🎯 Credits Fetched: $credits");
      } else {
        print("⚠️ Firestore document NOT found for ${widget.email}");
      }
    } catch (e) {
      print("❌ Error fetching credits: $e");
    }
  }

  // 🔹 Update Employee Credits in Firestore
  Future<void> _updateEmployeeCredits(int change) async {
    try {
      int newCredits = credits + change; // Calculate new credits

      print("🔄 Updating credits: Old - $credits, New - $newCredits");

      await FirebaseFirestore.instance
          .collection('employees') // ✅ Ensure correct collection name
          .doc(widget.email)
          .update({'credits': newCredits.toString()}); // Store as String

      setState(() {
        credits = newCredits; // ✅ Update UI
      });

      print("✅ Credits successfully updated to $newCredits");
    } catch (e) {
      print("❌ Error updating credits: $e");
    }
  }

  // 🔹 Update Complaint Status & Adjust Credits
  void _updateComplaintStatus(String docId, String newStatus) async {
    int creditChange = (newStatus == "Resolved") ? 5 : -3;

    try {
      // Update complaint status in Firestore
      await FirebaseFirestore.instance.collection('Complaints').doc(docId).update({
        'status': newStatus,
      });

      // Update employee credits
      await _updateEmployeeCredits(creditChange);
    } catch (e) {
      print("❌ Error updating complaint: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedRole = widget.role[0].toUpperCase() + widget.role.substring(1).toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.name}'s Dashboard"),
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
                  Text("Welcome, ${widget.name}!", style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Role: $formattedRole", style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Text("Email: ${widget.email}", style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 20),
                  Text(
                    "Credits: $credits", // ✅ Display updated credits
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  const Text("Pending Complaints", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Complaints')
                    .where('role', isEqualTo: formattedRole)
                    .where('status', isEqualTo: "Pending")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No pending complaints."));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var complaint = snapshot.data!.docs[index];
                      String docId = complaint.id;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Status: ${complaint['status']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("Description: ${complaint['description']}"),
                              Text("User Email: ${complaint['email']}"),
                              Text("Timestamp: ${complaint['timestamp'].toDate()}"),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _updateComplaintStatus(docId, "Resolved"),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text("Resolve", style: TextStyle(color: Colors.white)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _updateComplaintStatus(docId, "Rejected"),
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
}
