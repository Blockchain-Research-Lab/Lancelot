import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lancelot/config/config.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeScreen extends StatefulWidget {
  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrResult = "Scan a QR code";
  TextEditingController manualInputController = TextEditingController();
  bool isSubmitting = false;
  bool isCameraOn = true;
  bool _isDialogShowing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    manualInputController.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isDialogShowing) {
        _isDialogShowing = true;
        _showScanConfirmationDialog(scanData.code);
      }
    });
  }

  Future<void> _showScanConfirmationDialog(String? qrData) async {
    if (qrData == null || qrData.isEmpty) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Confirm Submission',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            'Submit QR code data: $qrData?',
            style: const TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing = false;
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
              ),
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                _submitQRData(qrData);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitQRData(String? qrData) async {
    if (qrData == null || qrData.isEmpty) {
      _showMessage("No QR data to submit!");
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

    final url = Uri.parse('${Config.apiBaseUrl}/attendance/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
      body: jsonEncode({
        'qr_data': qrData,
      }),
    );

    if (response.statusCode == 200) {
      _showMessage("QR data submitted successfully!");
    } else {
      _showMessage("Failed to submit QR data.\n${response.body}");
    }

    setState(() {
      isSubmitting = false;
      _isDialogShowing = false;
    });
  }

  void _toggleCamera() {
    if (controller != null) {
      if (isCameraOn) {
        controller?.pauseCamera();
      } else {
        controller?.resumeCamera();
      }
      setState(() {
        isCameraOn = !isCameraOn;
      });
    }
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
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Quote Box
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'The World Is Changing. There\'s A Reason Why Aristocrats Develop Weak Chins.',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // QR Scanner
              Expanded(
                flex: 6,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.black,
                    borderRadius: 10,
                    overlayColor: Colors.black.withOpacity(0.7),
                    borderLength: 20,
                    borderWidth: 5,
                    cutOutSize: mediaQuery.size.width * 0.6,
                  ),
                ),
              ),

              // Manual Input Section
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: keyboardHeight,
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                  ),
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Camera Toggle Button
                      MinimalistButton(
                        buttonName: isCameraOn ? 'Turn Camera Off' : 'Turn Camera On',
                        onTap: _toggleCamera,
                        bgColor: Colors.black,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Minimalist Button for reuse
class MinimalistButton extends StatelessWidget {
  const MinimalistButton({
    Key? key,
    required this.buttonName,
    required this.onTap,
    required this.bgColor,
    required this.textColor,
  }) : super(key: key);

  final String buttonName;
  final VoidCallback onTap;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: bgColor,
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          primary: textColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        onPressed: onTap,
        child: Text(
          buttonName,
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ),
    );
  }
}
