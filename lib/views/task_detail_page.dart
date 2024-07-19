import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends StatelessWidget {
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
        return Colors.grey; // Color por defecto si el estado no es reconocido
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData iconData;
    String transactionType;
    switch (type) {
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
                _buildDetailRow('ID:', id.toString()),
                const Divider(),
                _buildDetailRow(
                    'Tipo:', transactionType, iconData, statusColor),
                const Divider(),
                _buildDetailRow('Monto:', '\$${amount.toStringAsFixed(2)}'),
                const Divider(),
                _buildDetailRow('Fecha:', _formatDate(date)),
                const Divider(),
                _buildDetailRow('Descripción:', description),
                const Divider(),
                _buildDetailRow(
                    'Prioridad:', status, null, _getStatusColor(status)),
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
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14), // Tamaño de texto más pequeño para estado
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
