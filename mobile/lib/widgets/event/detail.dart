import 'package:flutter/material.dart';
import 'package:mobile/models/planet.dart';

class EventDetail extends StatelessWidget {
  final Planet planet;

  const EventDetail({super.key, required this.planet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Some text'),
              const Spacer(),
              GestureDetector(
                child: const Text(
                  'view planet',
                  style: TextStyle(
                      // color: Colors.blue,
                      ),
                ),
                onTap: () {},
              ),
            ],
          )
        ],
      ),
    );
  }
}
