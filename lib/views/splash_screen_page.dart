import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const int sessionDuration = 1 * 60 * 60 * 1000;

  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  Future<void> _startSplashScreen() async {
    // Añade un pequeño retraso para que el SplashScreen sea visible
    await Future.delayed(const Duration(seconds: 3));
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();

    int? sessionStart = prefs.getInt('session_start');

    if (sessionStart != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;

      if ((currentTime - sessionStart) > sessionDuration) {
        await prefs.remove('token');
        await prefs.remove('user_id');
        await prefs.remove('session_start');
      }

      final bool isLoggedIn = prefs.containsKey('token');
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'FINNER',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
