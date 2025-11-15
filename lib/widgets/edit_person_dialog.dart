import 'package:flutter/material.dart';
import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/services/api_services.dart';
import 'package:a2y_app/model/person_model.dart';

class EditPersonDialog extends StatefulWidget {
  final PersonData person;
  final VoidCallback onEditComplete;

  const EditPersonDialog({
    super.key,
    required this.person,
    required this.onEditComplete,
  });

  @override
  State<EditPersonDialog> createState() => _EditPersonDialogState();

  static void show(
    BuildContext context, {
    required PersonData person,
    required VoidCallback onEditComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          EditPersonDialog(person: person, onEditComplete: onEditComplete),
    );
  }
}

class _EditPersonDialogState extends State<EditPersonDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _organizationController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;

  String _selectedAttended = 'Yes';
  String _selectedAssignedUnassigned = 'Assigned';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.person.name ?? '');
    _designationController = TextEditingController(
      text: widget.person.designation ?? '',
    );
    _organizationController = TextEditingController(
      text: widget.person.organization ?? '',
    );
    _emailController = TextEditingController(text: widget.person.email ?? '');
    _mobileController = TextEditingController(text: widget.person.mobile ?? '');

    _selectedAttended = _validateAttendedValue(widget.person.attended);
    _selectedAssignedUnassigned = _validateAssignedUnassignedValue(
      widget.person.assignedUnassigned,
    );
  }

  String _validateAttendedValue(String? value) {
    if (value == null || value.isEmpty) return 'Yes';

    const validValues = ['Yes', 'No'];
    return validValues.contains(value) ? value : 'Yes';
  }

  String _validateAssignedUnassignedValue(String? value) {
    if (value == null || value.isEmpty) return 'Assigned';

    const validValues = ['Assigned', 'Unassigned'];

    if (value.toLowerCase().contains('unassign')) {
      return 'Unassigned';
    }
    if (value.toLowerCase().contains('assign')) {
      return 'Assigned';
    }

    return validValues.contains(value) ? value : 'Assigned';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await PeopleApiService.updatePerson(
        id: int.parse(widget.person.id.toString()),
        name: _nameController.text.trim(),
        designation: _designationController.text.trim(),
        organization: _organizationController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        attended: _selectedAttended,
        assignedUnassigned: _selectedAssignedUnassigned,
        clientId: int.parse(widget.person.clientId.toString()),
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          widget.onEditComplete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Person updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update person'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 16,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Person',
                  style: TextStyle(
                    fontFamily: globatInterFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Update the person\'s information below',
              style: TextStyle(
                fontFamily: globatInterFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'Name',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildTextField(
                        label: 'Designation',
                        controller: _designationController,
                        icon: Icons.work_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Designation is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildTextField(
                        label: 'Organization',
                        controller: _organizationController,
                        icon: Icons.business_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Organization is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildTextField(
                        label: 'Mobile',
                        controller: _mobileController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mobile number is required';
                          }
                          if (value.length < 10) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildDropdownField(
                        label: 'Attended',
                        value: _selectedAttended,
                        items: ['Yes', 'No'],
                        onChanged: (value) {
                          setState(() {
                            _selectedAttended = value!;
                          });
                        },
                        icon: Icons.check_circle_outline,
                      ),

                      const SizedBox(height: 20),

                      _buildDropdownField(
                        label: 'Status',
                        value: _selectedAssignedUnassigned,
                        items: ['Assigned', 'Unassigned'],
                        onChanged: (value) {
                          setState(() {
                            _selectedAssignedUnassigned = value!;
                          });
                        },
                        icon: Icons.assignment_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: globatInterFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: globatInterFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: globatInterFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(51, 51, 51, 1),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          enabled: !_isLoading,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            fontFamily: globatInterFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: globatInterFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(51, 51, 51, 1),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: _isLoading ? null : onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontFamily: globatInterFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            fontFamily: globatInterFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
