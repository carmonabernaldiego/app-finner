import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'task_detail_page.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key, required this.title});

  final String title;

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<Map<String, dynamic>> reminders = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReminders();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _fetchReminders(searchController.text);
  }

  Future<void> _fetchReminders([String query = '']) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('user_id');

    if (token != null && userId != null) {
      try {
        final response = await http.get(
          Uri.parse('http://23.21.23.111/transaction/$userId/search/$query'),
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

  Future<void> _deleteReminder(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        final response = await http.delete(
          Uri.parse('http://23.21.23.111/transaction/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            reminders.removeWhere((reminder) => reminder['id'] == id);
          });
        } else {
          print('Error deleting reminder: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> _createReminder(Map<String, dynamic> reminderData) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('http://23.21.23.111/transaction/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(reminderData),
        );

        if (response.statusCode == 201) {
          setState(() {
            reminders.add(jsonDecode(response.body));
            _fetchReminders();
          });
        } else {
          print('Error creating reminder: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
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
          'Monto: \$${reminder['amount']}, Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(reminder['date']))}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
          IconButton(
            icon: Icon(Icons.delete, color: Colors.grey),
            onPressed: () async {
              bool confirm = await _showConfirmationDialog(reminder['id']);
              if (confirm) {
                _deleteReminder(reminder['id']);
              }
            },
          ),
        ],
      ),
      onTap: () async {
        final result = await Navigator.push(
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
        if (result == true) {
          _fetchReminders();
        }
      },
    );
  }

  Future<bool> _showConfirmationDialog(int id) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirmar eliminación'),
              content:
                  Text('¿Estás seguro de que deseas eliminar este registro?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Eliminar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _showCreateDialog() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    final _formKey = GlobalKey<FormState>();

    Map<String, dynamic> newReminder = {
      "type": "expense",
      "user_id": userId,
      "amount": 0.0,
      "date": DateTime.now().toIso8601String(),
      "description": "",
      "status": "Alta" // Valor inicial predeterminado para el estatus
    };

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Crear nuevo registro'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: newReminder['type'],
                  onChanged: (String? newValue) {
                    setState(() {
                      newReminder['type'] = newValue!;
                    });
                  },
                  items: <String>['income', 'expense']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'income' ? 'Ingreso' : 'Gasto'),
                    );
                  }).toList(),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  onSaved: (String? value) {
                    newReminder['amount'] =
                        double.tryParse(value ?? '0.0') ?? 0.0;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Descripción'),
                  onSaved: (String? value) {
                    newReminder['description'] = value!;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: newReminder['status'],
                  onChanged: (String? newValue) {
                    setState(() {
                      newReminder['status'] = newValue!;
                    });
                  },
                  items: <String>['Alta', 'Media', 'Baja']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Prioridad'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (newReminder['status'] == 'Alta') {
                    newReminder['status'] = 'High';
                  } else if (newReminder['status'] == 'Media') {
                    newReminder['status'] = 'Medium';
                  } else if (newReminder['status'] == 'Baja') {
                    newReminder['status'] = 'Low';
                  }
                  _createReminder(newReminder);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gastos e Ingresos'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
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
                      controller: searchController,
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
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _showCreateDialog();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reminders.isEmpty
                      ? const Center(
                          child: Text(
                            'Sin resultados',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: reminders.length,
                          itemBuilder: (context, index) {
                            return _buildReminderItem(reminders[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
