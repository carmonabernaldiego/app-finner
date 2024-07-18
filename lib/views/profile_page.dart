import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> user = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('user_id');

    if (token != null && userId != null) {
      try {
        final response = await http.get(
          Uri.parse('http://23.21.23.111/user/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            user = jsonDecode(response.body);
            _nameController.text = user['name'] ?? '';
            _lastnameController.text = user['lastname'] ?? '';
            _emailController.text = user['email'] ?? '';
          });
        } else {
          print('Error fetching user data: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> _updateUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('user_id');

    if (token != null && userId != null) {
      String name = _nameController.text;
      String lastname = _lastnameController.text;
      String email = _emailController.text;

      if (name.isEmpty || lastname.isEmpty || email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos los campos son obligatorios.')),
        );
        return;
      }

      if (!_validateEmail(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo electrónico no es válido.')),
        );
        return;
      }

      try {
        final response = await http.put(
          Uri.parse('http://23.21.23.111/user/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': name,
            'lastname': lastname,
            'email': email,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            user = jsonDecode(response.body);
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado.')),
          );
        } else {
          final responseBody = jsonDecode(response.body);
          String errorMessage = 'Error.';
          if (responseBody['message'] == 'Email already exists') {
            errorMessage = 'El correo electrónico ya existe.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          print('Error updating user data: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _lastnameController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _updateUser,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('session_start');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/user.png'),
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _showEditProfileDialog,
                child: const Text(
                  'Editar perfil',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileItem('Nombre', user['name'] ?? ''),
              _buildProfileItem('Apellidos', user['lastname'] ?? ''),
              _buildProfileItem('Correo', user['email'] ?? ''),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Gráficas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: Text(value),
          onTap: () {
            // Acción al tocar el ítem
          },
        ),
        const Divider(),
      ],
    );
  }
}
