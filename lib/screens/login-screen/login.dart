import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lancelot/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lancelot/screens/home/home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    if (accessToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreenPage()),
      );
    }
  }

  // Handle the login API call
  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('${Config.apiBaseUrl}/app_login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token']);
      await prefs.setString('username', data['username']);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreenPage()),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed! Please check your credentials.')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Lancelot 🛡️',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            MyTextField(
              hintText: 'username',
              inputType: TextInputType.name,
              labelText2: 'username',
              secure1: false,
              capital: TextCapitalization.none,
              nameController1: _emailController,
            ),
            const SizedBox(height: 10),
            MyTextField(
              hintText: 'password',
              inputType: TextInputType.text,
              labelText2: 'password',
              secure1: true,
              capital: TextCapitalization.none,
              nameController1: _passwordController,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: isLoading
                  ? CircularProgressIndicator()
                  : Login(
                      bgColor: const Color.fromARGB(255, 0, 0, 0),
                      buttonName: 'Login',
                      onTap: _login,
                      textColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.hintText,
    required this.inputType,
    required this.labelText2,
    required this.secure1,
    required this.capital,
    required this.nameController1,
  });

  final String hintText;
  final TextInputType inputType;
  final String labelText2;
  final bool secure1;
  final TextCapitalization capital;
  final TextEditingController nameController1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: nameController1,
        keyboardType: inputType,
        obscureText: secure1,
        textInputAction: TextInputAction.next,
        textCapitalization: capital,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          labelText: labelText2,
          labelStyle: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}

// Login Widget

class Login extends StatelessWidget {
  const Login({
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
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bgColor,
      ),
      child: TextButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(12),
          shadowColor: MaterialStateProperty.all(Colors.black),
          overlayColor: MaterialStateProperty.resolveWith(
            (states) => Colors.transparent,
          ),
        ),
        onPressed: onTap,
        child: Text(
          buttonName,
          style: TextStyle(fontSize: 20, color: textColor),
        ),
      ),
    );
  }
}
