import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/widgets/company_add_dialog.dart';
import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final bool showCompanies;
  final bool hasActiveFilter;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onRefreshPressed;
  final bool isFromProfile;
  final VoidCallback? onCompanyAdded;

  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.showCompanies,
    required this.hasActiveFilter,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onRefreshPressed,
    required this.isFromProfile,
    this.onCompanyAdded,
  });

  Future<void> _showAddCompanyDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CompanyCooldownDialog(isEditMode: false),
    );

    if (result == true && onCompanyAdded != null) {
      onCompanyAdded!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(228, 228, 228, 1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: TextField(
              style: const TextStyle(
                fontFamily: globatInterFamily,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color.fromRGBO(166, 166, 166, 1),
              ),
              controller: controller,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search company...',
                hintStyle: const TextStyle(
                  fontFamily: globatInterFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color.fromRGBO(166, 166, 166, 1),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromRGBO(166, 166, 166, 1),
                  size: 20,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Color.fromRGBO(156, 156, 156, 1),
                          size: 20,
                        ),
                        onPressed: () {
                          controller.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color.fromRGBO(249, 249, 249, 1),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    width: 2,
                    color: Color.fromRGBO(204, 204, 204, 1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasActiveFilter ? Colors.blue : Colors.white,
                  foregroundColor: hasActiveFilter
                      ? Colors.white
                      : Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: hasActiveFilter ? Colors.blue : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                onPressed: onFilterPressed,
                icon: const Icon(Icons.tune, size: 16),
                label: Text(
                  hasActiveFilter ? "Sorted" : "Sort by",
                  style: const TextStyle(
                    fontFamily: globatInterFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showAddCompanyDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  "Add",
                  style: TextStyle(
                    fontFamily: globatInterFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
