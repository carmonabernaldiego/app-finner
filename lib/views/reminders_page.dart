import 'package:flutter/material.dart';
import 'task_detail_page.dart'; // Importa TaskDetailPage

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key, required this.title});

  final String title;

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final List<Map<String, String>> reminders = [
    {'task': 'FIG-121', 'title': 'Write blog post for demo day', 'priority': 'High'},
    {'task': 'FIG-122', 'title': 'Publish blog page', 'priority': 'Low'},
    {'task': 'FIG-123', 'title': 'Add gradients to design sys...', 'priority': 'Medium'},
    {'task': 'FIG-124', 'title': 'Responsive behavior doesn\'t...', 'priority': 'Medium'},
    {'task': 'FIG-125', 'title': 'Confirmation states not ren...', 'priority': 'Medium'},
    {'task': 'FIG-126', 'title': 'Revise copy on the About p...', 'priority': 'Low'},
    {'task': 'FIG-127', 'title': 'Text wrapping is awkward o...', 'priority': 'Low'},
    {'task': 'FIG-128', 'title': 'Publish HackerNews post', 'priority': 'Low'},
    {'task': 'FIG-129', 'title': 'Review image licensing for...', 'priority': 'High'},
    {'task': 'FIG-130', 'title': 'Accessibility focused state f...', 'priority': 'High'},
    {'task': 'FIG-131', 'title': 'Header IA revision to suppo...', 'priority': 'Low'},
  ];

  Widget _buildReminderItem(Map<String, String> reminder) {
    Color priorityColor;
    switch (reminder['priority']) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
      default:
        priorityColor = Colors.green;
        break;
    }

    return ListTile(
      leading: Text(reminder['task']!),
      title: Text(reminder['title']!),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: priorityColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          reminder['priority']!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(
              task: reminder['task']!,
              title: reminder['title']!,
              priority: reminder['priority']!,
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
        title: const Text('Reminders'),
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
                      hintText: 'Search',
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
            child: ListView.builder(
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
