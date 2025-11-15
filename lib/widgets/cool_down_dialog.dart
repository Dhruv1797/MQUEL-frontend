import 'package:a2y_app/constants/api_constants.dart';
import 'package:a2y_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CooldownDialog extends StatefulWidget {
  final Map<String, dynamic> rowData;

  const CooldownDialog({super.key, required this.rowData});

  @override
  State<CooldownDialog> createState() => _CooldownDialogState();
}

class _CooldownDialogState extends State<CooldownDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _level1Controller = TextEditingController();
  final _level2Controller = TextEditingController();
  final _level3Controller = TextEditingController();
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
    _level1Controller.addListener(_onFormChanged);
    _level2Controller.addListener(_onFormChanged);
    _level3Controller.addListener(_onFormChanged);
    _level1FocusNode.addListener(() => setState(() {}));
    _level2FocusNode.addListener(() => setState(() {}));
    _level3FocusNode.addListener(() => setState(() {}));
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
    _level1Controller.dispose();
    _level2Controller.dispose();
    _level3Controller.dispose();
    _level1FocusNode.dispose();
    _level2FocusNode.dispose();
    _level3FocusNode.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _sendCooldownRequest(
    int orgId,
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
          'orgId': orgId,
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
      print('Error sending cooldown request: $e');
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

    final orgId = widget.rowData['id'] ?? 0;
    final level1 = int.parse(_level1Controller.text);
    final level2 = int.parse(_level2Controller.text);
    final level3 = int.parse(_level3Controller.text);

    try {
      final result = await _sendCooldownRequest(orgId, level1, level2, level3);

      if (result['success']) {
        HapticFeedback.heavyImpact();
        _showCustomSnackBar(
          message: 'Cooldown periods set successfully',
          isSuccess: true,
        );
        Navigator.of(context).pop();
      } else {
        HapticFeedback.lightImpact();
        String errorMessage =
            'Failed to set cooldown periods. Please try again.';
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

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
            prefixIcon: Icon(
              Icons.schedule,
              color: focusNode.hasFocus
                  ? Colors.black
                  : (isDark ? Colors.grey[400] : Colors.grey[500]),
            ),
            suffixText: 'days',
            suffixStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[500],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!, width: 2),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.grey[800]?.withOpacity(0.3)
                : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final companyName = widget.rowData['name'] ?? 'Unknown Company';

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
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 24,
                          top: 24,
                          bottom: 24,
                          right: 24,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Set Cooldown',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Company: $companyName',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNumberField(
                                label: 'Level 1 Cooldown',
                                controller: _level1Controller,
                                focusNode: _level1FocusNode,
                                hintText: 'Enter days for level 1',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter level 1 cooldown days';
                                  }
                                  final level1 = int.tryParse(value);
                                  if (level1 == null || level1 <= 0) {
                                    return 'Please enter a valid number greater than 0';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildNumberField(
                                label: 'Level 2 Cooldown',
                                controller: _level2Controller,
                                focusNode: _level2FocusNode,
                                hintText: 'Enter days for level 2',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter level 2 cooldown days';
                                  }
                                  final level2 = int.tryParse(value);
                                  if (level2 == null || level2 <= 0) {
                                    return 'Please enter a valid number greater than 0';
                                  }
                                  final level1 =
                                      int.tryParse(_level1Controller.text) ?? 0;
                                  if (level1 >= level2) {
                                    return 'Level 2 must be greater than Level 1';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildNumberField(
                                label: 'Level 3 Cooldown',
                                controller: _level3Controller,
                                focusNode: _level3FocusNode,
                                hintText: 'Enter days for level 3',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter level 3 cooldown days';
                                  }
                                  final level3 = int.tryParse(value);
                                  if (level3 == null || level3 <= 0) {
                                    return 'Please enter a valid number greater than 0';
                                  }
                                  final level2 =
                                      int.tryParse(_level2Controller.text) ?? 0;
                                  if (level2 >= level3) {
                                    return 'Level 3 must be greater than Level 2';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: AnimatedBuilder(
                                      animation: _buttonScaleAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _buttonScaleAnimation.value,
                                          child: SizedBox(
                                            height: 50,
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
                                                      BorderRadius.circular(12),
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
                                                          height: 20,
                                                          width: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(Colors.white),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        const Text(
                                                          'Setting...',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.schedule,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        const Text(
                                                          'Set Cooldown',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 50,
                                      child: OutlinedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () => Navigator.of(context).pop(),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          side: BorderSide(
                                            color: isDark
                                                ? Colors.grey[600]!
                                                : Colors.grey[300]!,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
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
