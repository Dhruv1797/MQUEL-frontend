import 'package:flutter/material.dart';

class ActiveFilterBanner extends StatelessWidget {
  final String filterName;
  final String filterValue;
  final int resultCount;
  final VoidCallback onClearFilter;

  const ActiveFilterBanner({
    super.key,
    required this.filterName,
    required this.filterValue,
    required this.resultCount,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(239, 246, 255, 1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromRGBO(59, 130, 246, 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_list,
            size: 16,
            color: Color.fromRGBO(59, 130, 246, 1),
          ),
          const SizedBox(width: 8),
          const Text(
            'Active Filter: ',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(59, 130, 246, 1),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(59, 130, 246, 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$filterName = "$filterValue"',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(59, 130, 246, 1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($resultCount results)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClearFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear, size: 14, color: Colors.red.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Clear Filter',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
