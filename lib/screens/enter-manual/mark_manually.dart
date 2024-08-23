import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lancelot/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManualAttendanceScreen extends StatefulWidget {
  @override
  _ManualAttendanceScreenState createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  final TextEditingController manualInputController = TextEditingController(); 
  bool isSubmitting = false;  

  @override
  void dispose() {
    manualInputController.dispose(); 
    super.dispose();
  }

  Future<void> _submitManualAttendance() async {
    String rollNo = manualInputController.text.trim();
    if (rollNo.isEmpty) {
      _showMessage("Roll number is required.");
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');  

    if (accessToken == null || accessToken.isEmpty) {
      _showMessage("Authorization token is missing. Please log in.");
      setState(() {
        isSubmitting = false;
      });
      return;
    }

    final url = Uri.parse('${Config.apiBaseUrl}/manual_attendance/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,  
      },
      body: jsonEncode({
        'roll_no': rollNo,
      }),
    );

    if (response.statusCode == 200) {
      _showMessage("Manual attendance marked successfully!");
    } else {
      _showMessage("Failed to mark attendance. Code: ${response.statusCode}, Body: ${response.body}");
    }

    setState(() {
      isSubmitting = false;
    });

    manualInputController.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white), 
        ),
        backgroundColor: Colors.black,  
        behavior: SnackBarBehavior.floating,  
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),  
        ),
        elevation: 8.0,  
        margin: const EdgeInsets.all(16.0),  
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0).copyWith(
            bottom: keyboardHeight, 
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              const Text(
                'Mark Attendance',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Roll number input field
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextField(
                  controller: manualInputController,
                  decoration:  InputDecoration(
                    suffixIcon: const Icon(Icons.person_rounded, color: Colors.black54),
                    labelText: "University Roll Number",
                    labelStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    _submitManualAttendance();
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Submit button or loading spinner
              isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitManualAttendance,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black, 
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 28.0,
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
