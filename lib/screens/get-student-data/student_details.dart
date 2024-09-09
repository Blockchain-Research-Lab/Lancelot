import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lancelot/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;
  bool isSubmitting = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    if (accessToken == null) {
      _showMessage('Access token missing. Please log in.');
      return;
    }

    final url = Uri.parse('${Config.apiBaseUrl}/get_students/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> studentData = jsonDecode(response.body);
      setState(() {
        students = List<Map<String, dynamic>>.from(studentData);
        filteredStudents = students; // Initial filtered list
        isLoading = false;
      });
    } else {
      _showMessage('Failed to fetch students');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterStudents(String query) {
    final filtered = students.where((student) {
      final studentName = student['name'].toString().toLowerCase();
      final input = query.toLowerCase();
      return studentName.contains(input);
    }).toList();

    setState(() {
      filteredStudents = filtered;
    });
  }
  Future<void> _markAbsent(String rollNo) async {
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

  final url = Uri.parse('${Config.apiBaseUrl}/absent/');
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
    _showMessage("Marked as absent successfully!");
  } else {
    _showMessage("Failed to mark absent. Code: ${response.statusCode}, Body: ${response.body}");
  }

  setState(() {
    isSubmitting = false;
  });
}

  Future<void> _submitManualAttendance(String rollNo) async {
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
      _showMessage("Attendance marked successfully!");
    } else {
      _showMessage("Failed to mark attendance. Code: ${response.statusCode}, Body: ${response.body}");
    }

    setState(() {
      isSubmitting = false;
    });
  }
void _toggleAttendance(int index) {
  final student = filteredStudents[index];
  if (!student['is_present']) {
    // Mark present if currently absent
    _submitManualAttendance(student['univ_roll'].toString()).then((_) {
      setState(() {
        filteredStudents[index]['is_present'] = true;
      });
    });
  } else {
    // Mark absent if currently present
    _markAbsent(student['univ_roll'].toString()).then((_) {
      setState(() {
        filteredStudents[index]['is_present'] = false;
      });
    });
  }
}


  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 8.0,
        margin: const EdgeInsets.all(16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search student by name...',
                prefixIcon: Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterStudents,
            ),
            const SizedBox(height: 16),

            // Student List
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return MinimalistStudentCard(
                          student: student,
                          onTapMarkPresent: () => _toggleAttendance(index),
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

class MinimalistStudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onTapMarkPresent;

  const MinimalistStudentCard({
    Key? key,
    required this.student,
    required this.onTapMarkPresent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(
              student['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // University Roll Number
            Text(
              'Roll No: ${student['univ_roll']}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 4),

            // College Email
            Text(
              'Email: ${student['college_email']}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),

            // Mark Present Button
            MinimalistButton(
              buttonName: student['is_present'] ? 'Present' : 'Not Present',
              bgColor: student['is_present'] ? Colors.black : Colors.grey,
              textColor: Colors.white,
              onTap: onTapMarkPresent,
            ),
          ],
        ),
      ),
    );
  }
}

class MinimalistButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback onTap;
  final Color bgColor;
  final Color textColor;

  const MinimalistButton({
    Key? key,
    required this.buttonName,
    required this.onTap,
    required this.bgColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onTap,
        child: Text(
          buttonName,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }
}
