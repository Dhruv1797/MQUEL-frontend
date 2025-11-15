import 'package:a2y_app/constants/api_constants.dart';
import 'package:a2y_app/controller/unified_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompanyDeleteDialog extends StatefulWidget {
  final String companyName;
  final int companyId;
  final int clientId;
  final UnifiedScreenController controller;

  const CompanyDeleteDialog({
    super.key,
    required this.companyName,
    required this.companyId,
    required this.clientId,
    required this.controller,
  });

  @override
  State<CompanyDeleteDialog> createState() => _CompanyDeleteDialogState();
}

class _CompanyDeleteDialogState extends State<CompanyDeleteDialog> {
  bool _isLoading = false;

  Future<void> _deleteCompany() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseApiPath}/api/companies/excel/delete/${widget.companyId}?clientId=${widget.clientId}',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (responseBody.toLowerCase() == 'true') {
          print('Company deleted successfully');

          widget.controller.loadData();

          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.companyName} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('Unexpected response: $responseBody');
          _showErrorMessage('Failed to delete company. Unexpected response.');
        }
      } else {
        print('Delete failed with status code: ${response.statusCode}');
        _showErrorMessage('Failed to delete company. Please try again.');
      }
    } catch (e) {
      print('Error deleting company: $e');
      _showErrorMessage('An error occurred while deleting the company.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Are you sure?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: 'You are going to delete all the details of ',
                  ),
                  TextSpan(
                    text: widget.companyName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '. Make sure you are completely sure.'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _deleteCompany,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
