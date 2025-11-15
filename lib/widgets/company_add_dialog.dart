import 'package:a2y_app/constants/api_constants.dart';
import 'package:a2y_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompanyCooldownDialog extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic>? rowData;

  const CompanyCooldownDialog({
    super.key,
    this.isEditMode = false,
    this.rowData,
  });

  @override
  State<CompanyCooldownDialog> createState() => _CompanyCooldownDialogState();
}

class _CompanyCooldownDialogState extends State<CompanyCooldownDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _level1Controller = TextEditingController();
  final _level2Controller = TextEditingController();
  final _level3Controller = TextEditingController();
  final _orgNameFocusNode = FocusNode();
  final _level1FocusNode = FocusNode();
  final _level2FocusNode = FocusNode();
  final _level3FocusNode = FocusNode();

  bool _isLoading = false;
  bool _isFormValid = false;

  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupListeners();
    _initializeFormData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  void _setupListeners() {
    _orgNameController.addListener(_onFormChanged);
    _level1Controller.addListener(_onFormChanged);
    _level2Controller.addListener(_onFormChanged);
    _level3Controller.addListener(_onFormChanged);
    _orgNameFocusNode.addListener(() => setState(() {}));
    _level1FocusNode.addListener(() => setState(() {}));
    _level2FocusNode.addListener(() => setState(() {}));
    _level3FocusNode.addListener(() => setState(() {}));
  }

  void _initializeFormData() {
    if (widget.isEditMode && widget.rowData != null) {
      _orgNameController.text = widget.rowData!['name'] ?? '';
    }
  }

  void _onFormChanged() {
    final isValid = _validateForm();
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  bool _validateForm() {
    if (_orgNameController.text.trim().isEmpty) return false;

    final level1 = int.tryParse(_level1Controller.text) ?? 0;
    final level2 = int.tryParse(_level2Controller.text) ?? 0;
    final level3 = int.tryParse(_level3Controller.text) ?? 0;

    return level1 > 0 &&
        level2 > 0 &&
        level3 > 0 &&
        level1 < level2 &&
        level2 < level3;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _orgNameController.dispose();
    _level1Controller.dispose();
    _level2Controller.dispose();
    _level3Controller.dispose();
    _orgNameFocusNode.dispose();
    _level1FocusNode.dispose();
    _level2FocusNode.dispose();
    _level3FocusNode.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _sendCompanyRequest(
    String orgName,
    int cooldownPeriod1,
    int cooldownPeriod2,
    int cooldownPeriod3,
  ) async {
    try {
      final url = Uri.parse('${ApiConstants.baseApiPath}/api/client');
      final tenantId = await UserProvider.getTenantId();
      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'orgName': orgName,
          'tenantId': tenantId ?? 0,
          'cooldownPeriod1': cooldownPeriod1,
          'cooldownPeriod2': cooldownPeriod2,
          'cooldownPeriod3': cooldownPeriod3,
        }),
      );

      return {
        'success': response.statusCode == 201,
        'message': response.body,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('Error sending company request: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
        'statusCode': 0,
      };
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    setState(() {
      _isLoading = true;
    });

    final orgName = _orgNameController.text.trim();
    final level1 = int.parse(_level1Controller.text);
    final level2 = int.parse(_level2Controller.text);
    final level3 = int.parse(_level3Controller.text);

    try {
      final result = await _sendCompanyRequest(orgName, level1, level2, level3);

      if (result['success']) {
        HapticFeedback.heavyImpact();
        _showCustomSnackBar(
          message: widget.isEditMode
              ? 'Client updated successfully'
              : 'Client added successfully',
          isSuccess: true,
        );
        Navigator.of(context).pop(true);
      } else {
        HapticFeedback.lightImpact();
        String errorMessage = widget.isEditMode
            ? 'Failed to update client. Please try again.'
            : 'Failed to add client. Please try again.';

        if (result['statusCode'] != 201 && result['statusCode'] != 0) {
          errorMessage = 'Error (Status: ${result['statusCode']})';
        }

        _showCustomSnackBar(message: errorMessage, isSuccess: false);
      }
    } catch (e) {
      HapticFeedback.lightImpact();
      _showCustomSnackBar(
        message: 'An unexpected error occurred. Please try again.',
        isSuccess: false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCustomSnackBar({required String message, required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.black : Colors.grey[800],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 440),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 20,
                          right: 16,
                          bottom: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add a Client',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add a client to begin managing your clients efficiently.',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF6B7280),
                                size: 20,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(24, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                label: 'Company Name',
                                controller: _orgNameController,
                                focusNode: _orgNameFocusNode,
                                hintText: '',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter company name';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Company name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                label: 'Cooldown Period-1',
                                controller: _level1Controller,
                                focusNode: _level1FocusNode,
                                hintText: 'Enter cooldown period',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter cooldown period 1';
                                  }
                                  final level1 = int.tryParse(value);
                                  if (level1 == null || level1 <= 0) {
                                    return 'Please enter a valid number greater than 0';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                label: 'Cooldown Period-2',
                                controller: _level2Controller,
                                focusNode: _level2FocusNode,
                                hintText: 'Enter cooldown period',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter cooldown period 2';
                                  }
                                  final level2 = int.tryParse(value);
                                  if (level2 == null || level2 <= 0) {
                                    return 'Please enter a valid number greater than 0';
                                  }
                                  final level1 =
                                      int.tryParse(_level1Controller.text) ?? 0;
                                  if (level1 >= level2) {
                                    return 'Period 2 must be greater than Period 1';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                label: 'Cooldown Period-3',
                                controller: _level3Controller,
                                focusNode: _level3FocusNode,
                                hintText: 'Enter cooldown period',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter cooldown period 3';
                                  }
                                  final level3 = int.tryParse(value);
                                  if (level3 == null || level3 <= 0) {
                                    return 'Please enter a valid number greater than 0';
                                  }
                                  final level2 =
                                      int.tryParse(_level2Controller.text) ?? 0;
                                  if (level2 >= level3) {
                                    return 'Period 3 must be greater than Period 2';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 44,
                                      child: OutlinedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () => Navigator.of(context).pop(),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF6B7280,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          backgroundColor: Colors.white,
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AnimatedBuilder(
                                      animation: _buttonScaleAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _buttonScaleAnimation.value,
                                          child: SizedBox(
                                            height: 44,
                                            child: ElevatedButton(
                                              onPressed: _isLoading
                                                  ? null
                                                  : _handleSubmit,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                disabledBackgroundColor:
                                                    Colors.grey[400],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                elevation: 0,
                                                shadowColor: Colors.transparent,
                                              ),
                                              child: _isLoading
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                          height: 16,
                                                          width: 16,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(Colors.white),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          'Adding...',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ],
                                                    )
                                                  : const Text(
                                                      'Add',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
