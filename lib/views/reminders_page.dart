import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'task_detail_page.dart'; // Importa TaskDetailPage

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key, required this.title});

  final String title;

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<Map<String, dynamic>> reminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('user_id');

    if (token != null && userId != null) {
      try {
        final response = await http.get(
          Uri.parse('http://23.21.23.111/transaction/user/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            reminders =
                List<Map<String, dynamic>>.from(jsonDecode(response.body));
            isLoading = false;
          });
        } else {
          print('Error fetching reminders: ${response.body}');
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat.yMMMd().format(parsedDate);
  }

  Widget _buildReminderItem(Map<String, dynamic> reminder) {
    Color statusColor;
    IconData iconData;
    String transactionType;
    switch (reminder['type']) {
      case 'income':
        statusColor = Colors.green;
        iconData = Icons.arrow_downward;
        transactionType = 'Ingreso';
        break;
      case 'expense':
      default:
        statusColor = Colors.red;
        iconData = Icons.arrow_upward;
        transactionType = 'Gasto';
        break;
    }

    return ListTile(
      leading: Icon(
        iconData,
        color: statusColor,
      ),
      title: Text(reminder['description']),
      subtitle: Text(
          'Monto: \$${reminder['amount']}, Fecha: ${_formatDate(reminder['date'])}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          transactionType,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(
              id: reminder['id'],
              type: reminder['type'],
              amount: double.parse(reminder['amount']),
              date: reminder['date'],
              description: reminder['description'],
              status: reminder['status'],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos e Ingresos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () {
                    // Acción del botón de filtro (actualmente no hace nada)
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      return _buildReminderItem(reminders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
