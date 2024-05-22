import 'package:flutter/material.dart';

class EventsScreen extends StatefulWidget {
  static const String routePath = '/events';
  static const String routeName = 'events';

  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<dynamic> defences = [
    {
      "health": 69,
      "planet": {
        "maxHealth": 420,
        "name": "Super Earth",
      },
    },
    {
      "health": 69,
      "planet": {
        "maxHealth": 420,
        "name": "Super Earth",
      },
    }
  ];

  final List<dynamic> liberation = [
    {
      "health": 69,
      "planet": {
        "maxHealth": 420,
        "name": "Big Earth",
      },
    },
    {
      "health": 69,
      "planet": {
        "maxHealth": 420,
        "name": "Big Earth",
      },
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Liberations
          const Text(
            "Ongoing Liberations",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: liberation.length,
            itemBuilder: (context, index) {
              final liberationItem = liberation[index];

              return ListTile(
                title: Text(liberationItem['planet']['name']),
                subtitle: Text("Health: ${liberationItem['health']}"),
              );
            },
          ),

          const SizedBox(height: 16),

          // Defences
          const Text(
            "Ongoing Defences",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          ListView.builder(
            itemCount: defences.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final defenceItem = defences[index];

              return Column(
                children: [
                  const Text(
                    "Victory in 420H 42M, 69 hours left",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  ListTile(
                    title: Text(defenceItem['planet']['name']),
                    subtitle: Text(
                        "${(defenceItem['health'] * 100 / defenceItem['planet']['maxHealth']).toStringAsFixed(2)}% liberated"),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
