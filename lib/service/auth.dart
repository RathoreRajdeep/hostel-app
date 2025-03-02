import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hostel/home.dart';
import 'package:hostel/service/database.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        return; // User canceled sign-in
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        String userId = userDetails.uid;

        // 🔹 Check if user already exists in Firestore
        DocumentSnapshot userDoc = await firestore.collection("User").doc(userId).get();

        if (!userDoc.exists) {
          // 🔹 Store new user details in Firestore
          Map<String, dynamic> userInfoMap = {
            "email": userDetails.email,
            "name": userDetails.displayName ?? "User",
            "id": userId
          };

          await DatabaseMethods().addUser(userId, userInfoMap);
        }

        // 🔹 Navigate to Home with Username & User ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(username: userDetails.displayName ?? "User", userId: userId),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
