import 'package:flutter/material.dart';
import '../API-config/apiconfig.dart';
import '../eventpage/event.dart';
import '../qr-scan/qrscan.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}
class _HomeScreenPageState extends State<HomeScreenPage> {
  int _currentIndex = 1; // Set the initial index to 1 for the Events page

  final List<Widget> _pages = [
    API_Config(),
    QrScanPage(),
    EventPage(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Lancelot 🛡️'),
      ),
      
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.api_rounded),
            label: 'API Config',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_2_outlined),
            label: 'QR Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'Event',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
