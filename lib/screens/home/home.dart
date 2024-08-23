import 'package:flutter/material.dart';
import 'package:lancelot/screens/enter-manual/mark_manually.dart';
import 'package:lancelot/screens/get-student-data/student_details.dart';
import '../qr-scan/qrscan.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  int _currentIndex = 1; 

  final List<Widget> _pages = [
    ManualAttendanceScreen(),
    QRCodeScreen(),
    StudentListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Lancelot 🛡️',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Mark Manually',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_2_outlined),
            label: 'QR Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_library_books_outlined),
            label: 'Student Data',
          ),
        ],
        currentIndex: _currentIndex,
        backgroundColor: Colors.white, 
        selectedItemColor: Colors.black, 
        unselectedItemColor: Colors.grey, 
        elevation: 5,
        type: BottomNavigationBarType.fixed, 
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
