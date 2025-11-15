import 'package:a2y_app/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class StatusBadgesColumn extends StatelessWidget {
  final String displayCooldownPeriod1;
  final String displayCooldownPeriod2;
  final String displayCooldownPeriod3;

  const StatusBadgesColumn({
    super.key,
    required this.displayCooldownPeriod1,
    required this.displayCooldownPeriod2,
    required this.displayCooldownPeriod3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        StatusBadge(
          label: 'Period 1',
          value: displayCooldownPeriod1,
          color: Colors.blue,
        ),
        const SizedBox(height: 4),
        StatusBadge(
          label: 'Period 2',
          value: displayCooldownPeriod2,
          color: Colors.green,
        ),
        const SizedBox(height: 4),
        StatusBadge(
          label: 'Period 3',
          value: displayCooldownPeriod3,
          color: Colors.orange,
        ),
      ],
    );
  }
}
