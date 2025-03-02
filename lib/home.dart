import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hostel/complaint_form.dart';

class Home extends StatefulWidget {
  final String username;
  final String userId;

  const Home({super.key, required this.username, required this.userId});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int totalComplaints = 0;
  int pendingComplaints = 0;
  int resolvedComplaints = 0;
  int rejectedComplaints = 0;

  @override
  void initState() {
    super.initState();
    _fetchComplaintStats();
  }

  Future<void> _fetchComplaintStats() async {
    try {
      QuerySnapshot allComplaints = await FirebaseFirestore.instance
          .collection("Complaints")
          .where("userId", isEqualTo: widget.userId)
          .get();
      QuerySnapshot pending = await FirebaseFirestore.instance
          .collection("Complaints")
          .where("userId", isEqualTo: widget.userId)
          .where("status", isEqualTo: "Pending")
          .get();
      QuerySnapshot resolved = await FirebaseFirestore.instance
          .collection("Complaints")
          .where("userId", isEqualTo: widget.userId)
          .where("status", isEqualTo: "Resolved")
          .get();
      QuerySnapshot rejected = await FirebaseFirestore.instance
          .collection("Complaints")
          .where("userId", isEqualTo: widget.userId)
          .where("status", isEqualTo: "Rejected")
          .get();

      setState(() {
        totalComplaints = allComplaints.size;
        pendingComplaints = pending.size;
        resolvedComplaints = resolved.size;
        rejectedComplaints = rejected.size;
      });
    } catch (e) {
      print("Error fetching stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String firstName = widget.username.split(" ")[0];

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $firstName"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF273671)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.black, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Hello, $firstName",
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    widget.username,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.article, color: Colors.black),
              title: const Text("News"),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("Total", totalComplaints, Colors.blue),
                _buildStatCard("Pending", pendingComplaints, Colors.orange),
                _buildStatCard("Resolved", resolvedComplaints, Colors.green),
                _buildStatCard("Rejected", rejectedComplaints, Colors.red),
              ],
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplaintForm(
                      username: widget.username,
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF273671),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "Raise a Complaint",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Recent Complaints",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildComplaintSection("Pending"),
            _buildComplaintSection("Resolved"),
            _buildComplaintSection("Rejected"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(title, style: TextStyle(fontSize: 14, color: color)),
        ],
      ),
    );
  }

  Widget _buildComplaintSection(String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Complaints")
              .where("userId", isEqualTo: widget.userId)
              .where("status", isEqualTo: status)
              .orderBy("timestamp", descending: true)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("Error loading complaints."),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("No complaints found."),
              );
            }

            var complaints = snapshot.data!.docs;

            return Column(
              children: [
                ...complaints.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(data["description"] ?? "No description"),
                      subtitle: Text("Submitted: ${data["timestamp"]?.toDate()}"),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
