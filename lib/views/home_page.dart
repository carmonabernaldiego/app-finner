import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
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
          final responseBody = jsonDecode(response.body);
          setState(() {
            transactions = responseBody;
            transactions.sort((a, b) =>
                DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
            if (transactions.length > 3) {
              transactions = transactions.sublist(0, 3);
            }
            isLoading = false;
          });
        } else {
          print('Error fetching transactions: ${response.body}');
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

  void _showCreateTransactionModal(DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Crear nuevo gasto o ingreso'),
          content: CreateTransactionForm(selectedDate: selectedDate),
        );
      },
    ).then((value) {
      if (value == true) {
        _fetchTransactions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FINNER'),
          automaticallyImplyLeading: false,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result =
                              await Navigator.pushNamed(context, '/reminders');
                          if (result == true) {
                            _fetchTransactions();
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Últimos gastos e ingresos',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        transactions.map<Widget>((transaction) {
                                      String type =
                                          transaction['type'].toString();
                                      String amount =
                                          transaction['amount'].toString();
                                      DateTime parsedDate =
                                          DateTime.parse(transaction['date']);
                                      String date = DateFormat('dd/MM/yyyy')
                                          .format(parsedDate);

                                      String typeText = type == 'income'
                                          ? 'Ingreso'
                                          : 'Gasto';
                                      Color textColor = type == 'income'
                                          ? Colors.green
                                          : Colors.red;

                                      return Column(
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Icon(
                                              type == 'income'
                                                  ? Icons.arrow_downward
                                                  : Icons.arrow_upward,
                                              color: textColor,
                                            ),
                                            title: Text(
                                              '$typeText - \$$amount',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                            subtitle: Text(
                                              date,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.grey[300],
                                            thickness: 1,
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Crear un gasto o ingreso',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TableCalendar(
                                firstDay: DateTime.utc(2010, 10, 16),
                                lastDay: DateTime.utc(2030, 3, 14),
                                focusedDay: DateTime.now(),
                                onDaySelected: (selectedDay, focusedDay) {
                                  _showCreateTransactionModal(selectedDay);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
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
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/home');
                break;
              case 1:
                Navigator.pushNamed(context, '/dashboard');
                break;
              case 2:
                Navigator.pushNamed(context, '/profile');
                break;
            }
          },
        ),
      ),
    );
  }
}

class CreateTransactionForm extends StatefulWidget {
  final DateTime selectedDate;

  CreateTransactionForm({required this.selectedDate});

  @override
  _CreateTransactionFormState createState() => _CreateTransactionFormState();
}

class _CreateTransactionFormState extends State<CreateTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'expense';
  double _amount = 0.0;
  String _description = '';
  String _status = 'Medium';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _createTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('user_id');

    if (token != null && userId != null) {
      try {
        final response = await http.post(
          Uri.parse('http://23.21.23.111/transaction/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'type': _type,
            'user_id': userId,
            'amount': _amount,
            'date': widget.selectedDate.toIso8601String(),
            'description': _description,
            'status': _status,
          }),
        );

        if (response.statusCode == 201) {
          Navigator.of(context).pop(true);
          await Navigator.pushNamed(context, '/reminders');
        } else {
          print('Error creating transaction: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: _type,
            onChanged: (String? newValue) {
              setState(() {
                _type = newValue!;
              });
            },
            items: <String>['expense', 'income']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value == 'expense' ? 'Gasto' : 'Ingreso'),
              );
            }).toList(),
            decoration: const InputDecoration(labelText: 'Tipo'),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Monto'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSaved: (value) {
              _amount = double.parse(value!);
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Descripción'),
            onSaved: (value) {
              _description = value!;
            },
          ),
          DropdownButtonFormField<String>(
            value: _status,
            onChanged: (String? newValue) {
              setState(() {
                _status = newValue!;
              });
            },
            items: <String>['Low', 'Medium', 'High']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value == 'Low'
                    ? 'Baja'
                    : value == 'Medium'
                        ? 'Media'
                        : 'Alta'),
              );
            }).toList(),
            decoration: const InputDecoration(labelText: 'Prioridad'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                _createTransaction();
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}
