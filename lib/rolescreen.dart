// import 'dart:ui';

import 'package:flutter/material.dart';
import 'doctor/doctorlogin.dart';
import 'patient/patientlogin.dart';

class Roleselectionscreen extends StatefulWidget {
  const Roleselectionscreen({super.key});

  @override
  State<Roleselectionscreen> createState() => _RoleselectionscreenState();
}

class _RoleselectionscreenState extends State<Roleselectionscreen> {
  String selectedrole = "";
  void _navigateToNextScreen() {
    if (selectedrole == "Doctor") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Doctorloginscreen()),
      );
    } else if (selectedrole == "Patient") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PatientLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Select your role",
              style: TextStyle(
                fontSize: sw * 0.07,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Please select your role to continue",
              style: TextStyle(fontSize: sw * 0.04, color: Colors.grey),
            ),
            SizedBox(height: sh * 0.05),
            RoleCard(
              title: "I am a Doctor",
              imagepath: "assets/images/doc.png",
              isselected: selectedrole == "Doctor",
              onTap: () {
                setState(() {
                  selectedrole = "Doctor";
                });
              },
            ),
            SizedBox(height: sh * 0.03),
            RoleCard(
              title: "I am a Patient",
              imagepath: "assets/images/pat.png",
              isselected: selectedrole == "Patient",
              onTap: () {
                setState(() {
                  selectedrole = "Patient";
                });
              },
            ),
            SizedBox(height: sh * 0.04),
            ElevatedButton(
              onPressed: selectedrole.isNotEmpty ? _navigateToNextScreen : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedrole.isNotEmpty
                    ? Colors.blue
                    : Colors.grey.shade300,
                padding: EdgeInsets.symmetric(vertical: 22, horizontal: 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String imagepath;
  final bool isselected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.imagepath,
    required this.isselected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sw * 0.85,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: isselected ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isselected ? Colors.blue : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                imagepath,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: sw * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
