import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskDetailPage extends StatefulWidget {
  final int id;
  final String type;
  final double amount;
  final String date;
  final String description;
  final String status;

  const TaskDetailPage({
    super.key,
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.status,
  });

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late String _type;
  late double _amount;
  late String _date;
  late String _description;
  late String _status;

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    _amount = widget.amount;
    _date = widget.date;
    _description = widget.description;
    _status = widget.status;
  }

  String _formatDate(String date) {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateReminder(Map<String, dynamic> updatedReminder) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('user_id');

    if (token != null && userId != null) {
      try {
        final response = await http.put(
          Uri.parse('http://23.21.23.111/transaction/${widget.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'type': updatedReminder['type'],
            'user_id': userId,
            'amount': updatedReminder['amount'],
            'date': updatedReminder['date'],
            'description': updatedReminder['description'],
            'status': updatedReminder['status'],
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _type = updatedReminder['type'];
            _amount = updatedReminder['amount'];
            _date = updatedReminder['date'];
            _description = updatedReminder['description'];
            _status = updatedReminder['status'];
          });

          Navigator.of(context)
              .pop(true); // Indicar que se ha actualizado la transacción
        } else {
          print('Error al actualizar la transacción: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();

    Map<String, dynamic> updatedReminder = {
      "type": _type,
      "amount": _amount,
      "date": _date,
      "description": _description,
      "status": _status
    };

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar registro'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: updatedReminder['type'],
                  onChanged: (String? newValue) {
                    setState(() {
                      updatedReminder['type'] = newValue!;
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
                  initialValue: updatedReminder['amount'].toString(),
                  decoration: InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  onSaved: (String? value) {
                    updatedReminder['amount'] =
                        double.tryParse(value ?? '0.0') ?? 0.0;
                  },
                ),
                TextFormField(
                  initialValue: updatedReminder['description'],
                  decoration: InputDecoration(labelText: 'Descripción'),
                  onSaved: (String? value) {
                    updatedReminder['description'] = value!;
                  },
                ),
                TextFormField(
                  initialValue: _formatDate(updatedReminder['date']),
                  decoration: InputDecoration(labelText: 'Fecha (dd/MM/yyyy)'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(updatedReminder['date']),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        updatedReminder['date'] =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: updatedReminder['status'],
                  onChanged: (String? newValue) {
                    setState(() {
                      updatedReminder['status'] = newValue!;
                    });
                  },
                  items: <String>['High', 'Medium', 'Low']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'High'
                            ? 'Alta'
                            : value == 'Medium'
                                ? 'Media'
                                : 'Baja',
                      ),
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  await _updateReminder(updatedReminder);
                  Navigator.of(context).pop(
                      true); // Cierra el diálogo y notifica la actualización
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
    Color statusColor;
    IconData iconData;
    String transactionType;
    switch (_type) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del $transactionType'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showEditDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID:', widget.id.toString()),
                const Divider(),
                _buildDetailRow('Tipo:', transactionType, iconData,
                    transactionType == 'Gasto' ? Colors.red : Colors.green),
                const Divider(),
                _buildDetailRow('Monto:', '\$${_amount.toStringAsFixed(2)}'),
                const Divider(),
                _buildDetailRow('Fecha:', _formatDate(_date)),
                const Divider(),
                _buildDetailRow('Descripción:', _description),
                const Divider(),
                _buildDetailRow(
                    'Prioridad:', _status, null, _getStatusColor(_status)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value,
      [IconData? iconData, Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (iconData != null && color != null) ...[
            Icon(iconData, color: color),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ] else if (color != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value.contains('High')
                    ? 'Alta'
                    : value.contains('Medium')
                        ? 'Media'
                        : 'Baja',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ] else
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
