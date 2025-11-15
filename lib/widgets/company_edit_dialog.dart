import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:a2y_app/constants/api_constants.dart';
import 'package:a2y_app/provider/user_provider.dart';
import 'package:http/http.dart' as http;

class EditCompanyDialog extends StatefulWidget {
  final Map<String, dynamic> company;
  final VoidCallback onEditComplete;

  const EditCompanyDialog({
    super.key,
    required this.company,
    required this.onEditComplete,
  });

  static void show(
    BuildContext context, {
    required Map<String, dynamic> company,
    required VoidCallback onEditComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          EditCompanyDialog(company: company, onEditComplete: onEditComplete),
    );
  }

  @override
  State<EditCompanyDialog> createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends State<EditCompanyDialog> {
  late TextEditingController aeNameController;
  late TextEditingController segmentController;
  late String focusedOrAssignedValue;
  late TextEditingController accountStatusController;
  late TextEditingController pipelineStatusController;
  late TextEditingController accountCategoryController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    aeNameController = TextEditingController(
      text: widget.company['aeNam']?.toString() ?? '',
    );
    segmentController = TextEditingController(
      text: widget.company['segment']?.toString() ?? '',
    );
    focusedOrAssignedValue =
        widget.company['focusedOrAssigned']?.toString() ?? 'Assigned';
    accountStatusController = TextEditingController(
      text: widget.company['accountStatus']?.toString() ?? '',
    );
    pipelineStatusController = TextEditingController(
      text: widget.company['pipelineStatus']?.toString() ?? '',
    );
    accountCategoryController = TextEditingController(
      text: widget.company['accountCategory']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    aeNameController.dispose();
    segmentController.dispose();
    accountStatusController.dispose();
    pipelineStatusController.dispose();
    accountCategoryController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final tenantId = await UserProvider.getTenantId();
      final payload = {
        'id': widget.company['id'],
        'clientId': widget.company['clientId'],
        'tenantId': tenantId,
        'accountName': widget.company['accountName'],
        'aeNam': aeNameController.text,
        'segment': segmentController.text,
        'focusedOrAssigned': focusedOrAssignedValue,
        'accountStatus': accountStatusController.text,
        'pipelineStatus': pipelineStatusController.text,
        'accountCategory': accountCategoryController.text,
      };

      final url = Uri.parse(
        '${ApiConstants.baseApiPath}/api/companies/excel/update',
      );

      final encoder = const JsonEncoder.withIndent('  ');
      final safeHeaders = Map<String, String>.from(headers);
      if (safeHeaders.containsKey('Authorization')) {
        safeHeaders['Authorization'] = 'Bearer ***';
      }
      if (safeHeaders.containsKey('authorization')) {
        safeHeaders['authorization'] = 'Bearer ***';
      }
      debugPrint('[EditCompanyDialog] PUT $url');
      debugPrint(
        '[EditCompanyDialog] Request headers:\n${encoder.convert(safeHeaders)}',
      );
      debugPrint(
        '[EditCompanyDialog] Request payload:\n${encoder.convert(payload)}',
      );
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      debugPrint('[EditCompanyDialog] Response status: ${response.statusCode}');
      debugPrint(
        '[EditCompanyDialog] Response headers:\n${encoder.convert(response.headers)}',
      );
      debugPrint(
        '[EditCompanyDialog] Response body (${response.body.length} bytes):\n${response.body}',
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        widget.onEditComplete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      debugPrint('[EditCompanyDialog] Exception during update: $e');
      debugPrint('[EditCompanyDialog] Stack trace:\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating company: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: readOnly ? null : 'Enter ${label.toLowerCase()}',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            filled: true,
            fillColor: readOnly ? Colors.grey[50] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.blue[500]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: readOnly ? Colors.grey[600] : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildFocusedAssignedDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Focused or Assigned',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: focusedOrAssignedValue,
          items: const [
            DropdownMenuItem(value: 'Focused', child: Text('Focused')),
            DropdownMenuItem(value: 'Assigned', child: Text('Assigned')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => focusedOrAssignedValue = val);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.blue[500]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Company',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update company information to keep your data current.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'Account Name',
                      controller: TextEditingController(
                        text: widget.company['accountName']?.toString() ?? '',
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      label: 'Account Executive',
                      controller: aeNameController,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      label: 'Segment',
                      controller: segmentController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    _buildFocusedAssignedDropdown(),
                    const SizedBox(height: 16),

                    _buildTextField(
                      label: 'Account Status',
                      controller: accountStatusController,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      label: 'Pipeline Status',
                      controller: pipelineStatusController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      label: 'Account Category',
                      controller: accountCategoryController,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
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
                              'Save',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
