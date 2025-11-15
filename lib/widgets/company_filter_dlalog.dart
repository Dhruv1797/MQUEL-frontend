import 'package:a2y_app/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class FilterDialog extends StatefulWidget {
  final List<Company> companies;
  final Function(String field, String value) onApplyFilter;
  final String? currentFilterValue;

  const FilterDialog({
    super.key,
    required this.companies,
    required this.onApplyFilter,
    this.currentFilterValue,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog>
    with TickerProviderStateMixin {
  final TextEditingController _accountOwnerController = TextEditingController();
  final FocusNode _accountOwnerFocusNode = FocusNode();
  final List<String> _accountOwners = [];
  bool _hasSelection = false;

  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeData();
    _accountOwnerController.addListener(_onTextChanged);
    _accountOwnerFocusNode.addListener(_onFocusChanged);
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

  void _initializeData() {
    if (widget.currentFilterValue != null) {
      _accountOwnerController.text = widget.currentFilterValue!;
      _hasSelection = true;
    }
  }

  void _onTextChanged() {
    final hasText = _accountOwnerController.text.trim().isNotEmpty;
    if (hasText != _hasSelection) {
      setState(() {
        _hasSelection = hasText;
      });
    }
  }

  void _onFocusChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _accountOwnerController.dispose();
    _accountOwnerFocusNode.dispose();
    super.dispose();
  }

  void _handleApplyFilter() {
    if (_accountOwnerController.text.trim().isEmpty) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    Navigator.of(context).pop();
    widget.onApplyFilter('accountOwner', _accountOwnerController.text.trim());
  }

  void _handleClearFilter() {
    HapticFeedback.lightImpact();
    setState(() {
      _accountOwnerController.clear();
      _hasSelection = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.filter_alt_outlined,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Filter Companies',
                                    style: TextStyle(
                                      fontSize: 32,

                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Find companies by account owner',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Owner',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),

                            TypeAheadField<String>(
                              controller: _accountOwnerController,
                              builder: (context, controller, focusNode) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Enter or select account owner...',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[500],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: focusNode.hasFocus
                                          ? Colors.black
                                          : (isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[500]),
                                    ),
                                    suffixIcon: controller.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: Colors.grey[600],
                                            ),
                                            onPressed: _handleClearFilter,
                                          )
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.grey[600]!
                                            : Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.grey[600]!
                                            : Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                        width: 2,
                                      ),
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
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                );
                              },
                              suggestionsCallback: (pattern) {
                                if (pattern.isEmpty) {
                                  return _accountOwners.take(8).toList();
                                }
                                return _accountOwners
                                    .where(
                                      (owner) => owner.toLowerCase().contains(
                                        pattern.toLowerCase(),
                                      ),
                                    )
                                    .take(8)
                                    .toList();
                              },
                              itemBuilder: (context, suggestion) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          suggestion,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onSelected: (suggestion) {
                                _accountOwnerController.text = suggestion;
                                setState(() {
                                  _hasSelection = true;
                                });
                              },
                              decorationBuilder: (context, child) {
                                return Material(
                                  type: MaterialType.card,
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(12),
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isDark
                                          ? const Color(0xFF374151)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.grey[600]!
                                            : Colors.grey[200]!,
                                      ),
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              offset: const Offset(0, 4),
                              constraints: const BoxConstraints(maxHeight: 240),
                            ),

                            if (widget.currentFilterValue != null)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.filter_alt,
                                      size: 16,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Current: ${widget.currentFilterValue}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 32),

                            Row(
                              children: [
                                Expanded(
                                  child: AnimatedBuilder(
                                    animation: _buttonScaleAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _hasSelection
                                            ? _buttonScaleAnimation.value
                                            : 1.0,
                                        child: SizedBox(
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: _hasSelection
                                                ? _handleApplyFilter
                                                : null,
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
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.filter_alt,
                                                  size: 18,
                                                  color: _hasSelection
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Apply Filter',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: _hasSelection
                                                        ? Colors.white
                                                        : Colors.grey[600],
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
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
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
