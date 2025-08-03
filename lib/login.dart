import 'package:flutter/material.dart';
import 'addcrime.dart';
import 'crimeview.dart';
import 'services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both username and password')),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> result = await ApiService.login(username, password);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      String role = result['role'] ?? 'CITIZEN';
      // Always navigate to ViewCrime, but pass the role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ViewCrime(userRole: role)),
      );
    } else {
      // Fallback to hardcoded credentials for development/testing if API is not reachable
      // IMPORTANT: Remove this block in production
      if (username == 'admin' && password == 'admin1234') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ViewCrime(userRole: 'ADMIN')),
        );
      } else if (username == 'officer1' && password == 'officer123') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ViewCrime(userRole: 'OFFICER')),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ViewCrime(userRole: 'CITIZEN')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login to Continue',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}