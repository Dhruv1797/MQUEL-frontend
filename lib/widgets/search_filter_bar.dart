import 'dart:developer';

import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/model/person_model.dart';
import 'package:a2y_app/controller/person_details_controller.dart';
import 'package:a2y_app/model/company_model.dart';
import 'package:a2y_app/widgets/unified_person_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchFilterBar extends StatelessWidget {
  final bool showCompanies;
  final bool hasActiveFilter;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onRefreshPressed;
  final bool isFromProfile;
  final bool showAddInteractionButton;
  final PersonDetailsController? controller;
  final bool isFromUnfiedScreen;

  final List<Company>? companies;
  final Function(String field, String value)? onApplyFilter;
  final Function(
    String field,
    String value,
    DateTime? startDate,
    DateTime? endDate,
  )?
  onApplyPersonFilter;

  final int selectedTabIndex;
  final Function(int)? onTabChanged;

  final bool isFromCompanyDasboardScreen;

  final List<PersonData>? people;

  const SearchFilterBar({
    super.key,
    required this.showCompanies,
    required this.hasActiveFilter,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onRefreshPressed,
    required this.isFromProfile,
    this.showAddInteractionButton = false,
    this.controller,
    required this.isFromUnfiedScreen,
    this.companies,
    this.onApplyFilter,
    required this.selectedTabIndex,
    this.onTabChanged,
    required this.isFromCompanyDasboardScreen,
    required this.people,
    required this.onApplyPersonFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;

          final isVerySmall = screenWidth < 480;
          final isSmall = screenWidth < 768;
          final isMedium = screenWidth < 1024;

          if (isVerySmall) {
            return Column(
              children: [
                _buildTabsAndTitle(context, screenWidth),
                _buildInsideSearchField(),
                const SizedBox(height: 12),
                _buildActionButtons(context, screenWidth),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTabsAndTitle(context, screenWidth),
                    _buildActionButtons(context, screenWidth),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInsideSearchField(),
                    const SizedBox(width: 16),
                    isFromCompanyDasboardScreen
                        ? SizedBox()
                        : showAddInteractionButton
                        ? SizedBox()
                        : _buildFilterButtons(context),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTabsAndTitle(BuildContext context, double screenWidth) {
    if (isFromUnfiedScreen && !isFromProfile) {
      return _buildMainTabs(screenWidth);
    } else {
      return _buildSearchField(context, screenWidth);
    }
  }

  Widget _buildMainTabs(double screenWidth) {
    final isVerySmall = screenWidth < 480;

    return Row(
      children: [
        _buildMainTabButton("Companies", 0, screenWidth),
        const SizedBox(width: 2),
        _buildMainTabButton("Attendees", 1, screenWidth),
      ],
    );
  }

  Widget _buildMainTabButton(String title, int index, double screenWidth) {
    final isSelected = selectedTabIndex == index;
    final isVerySmall = screenWidth < 480;

    return GestureDetector(
      onTap: () => onTabChanged?.call(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isVerySmall ? 12 : 16,
          vertical: isVerySmall ? 8 : 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: globatInterFamily,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            fontSize: isVerySmall ? 16 : 16,
            color: isSelected
                ? Colors.black
                : const Color.fromRGBO(107, 114, 128, 1),
          ),
        ),
      ),
    );
  }

  Widget _buildInsideSearchField() {
    return SizedBox(
      width: 200,
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          isCollapsed: true,
          isDense: true,
          hintText: 'Search',
          hintStyle: const TextStyle(
            fontFamily: globatInterFamily,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color.fromRGBO(156, 163, 175, 1),
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons(BuildContext context) {
    if (selectedTabIndex == 0) {
      return Row(
        children: [
          _buildSmallFilterButton(
            context,
            'Company',
            Icons.keyboard_arrow_down,
            fieldKey: 'accountName',
          ),
          const SizedBox(width: 8),
          _buildSmallFilterButton(
            context,
            'Account Owner',
            Icons.keyboard_arrow_down,
            fieldKey: 'aeNam',
          ),
          const SizedBox(width: 8),
          _buildSmallFilterButton(
            context,
            'City',
            Icons.keyboard_arrow_down,
            fieldKey: 'segment',
          ),
          const SizedBox(width: 8),
          _buildSmallFilterButton(
            context,
            'Focus/Assigned',
            Icons.keyboard_arrow_down,
            fieldKey: 'focusedOrAssigned',
          ),

          if (!isFromUnfiedScreen) ...[
            const SizedBox(width: 8),
            _buildSmallFilterButton(
              context,
              'Select Date Range',
              Icons.calendar_today,
              isDatePicker: true,
            ),
          ],
        ],
      );
    } else {
      return Row(
        children: [
          _buildSmallFilterButton(
            context,
            'Name',
            Icons.keyboard_arrow_down,
            fieldKey: 'name',
            isPersonFilter: true,
          ),
          const SizedBox(width: 8),
          _buildSmallFilterButton(
            context,
            'Designation',
            Icons.keyboard_arrow_down,
            fieldKey: 'designation',
            isPersonFilter: true,
          ),
          const SizedBox(width: 8),
          _buildSmallFilterButton(
            context,
            'Organization',
            Icons.keyboard_arrow_down,
            fieldKey: 'organization',
            isPersonFilter: true,
          ),
          const SizedBox(width: 8),
          _buildSmallFilterButton(
            context,
            'Assigned/Unassigned',
            Icons.keyboard_arrow_down,
            fieldKey: 'assignedorunassigned',
            isPersonFilter: true,
          ),
        ],
      );
    }
  }

  Widget _buildSmallFilterButton(
    BuildContext context,
    String label,
    IconData icon, {
    bool isDatePicker = false,
    String? fieldKey,
    bool isPersonFilter = false,
  }) {
    bool isEnabled = isFromUnfiedScreen || isDatePicker;

    return GestureDetector(
      onTap: isEnabled
          ? () {
              if (isDatePicker) {
                _showDateRangePicker();
              } else {
                _showFilterDialog(context, label, fieldKey!, isPersonFilter);
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade100,
          border: Border.all(
            color: isEnabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDatePicker) ...[
              Icon(
                icon,
                size: 14,
                color: isEnabled ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: globatInterFamily,
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: isEnabled
                    ? const Color.fromRGBO(75, 85, 99, 1)
                    : Colors.grey[400],
              ),
            ),
            if (!isDatePicker) ...[
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 14,
                color: isEnabled ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    String label,
    String fieldKey,
    bool isfromPersonFilter,
  ) {
    if (companies == null || onApplyFilter == null) {
      print('Companies list or onApplyFilter callback is null');
      return;
    }
    log("This pressed ");
    isfromPersonFilter
        ? showDialog(
            context: context,
            builder: (context) => UnifiedPersonFilterDialog(
              people: people!,
              onApplyFilter: onApplyPersonFilter!,
              fieldLabel: label,
              fieldKey: fieldKey,
            ),
          )
        : showDialog(
            context: context,
            builder: (context) => UnifiedFilterDialog(
              companies: companies!,
              onApplyFilter: onApplyFilter!,
              fieldLabel: label,
              fieldKey: fieldKey,
            ),
          );
  }

  void _showFilterOptions(String filterType) {
    print('Show $filterType filter options');
  }

  void _showDateRangePicker() {
    print('Show date range picker');
  }

  Widget _buildSearchField(BuildContext context, double screenWidth) {
    double maxWidth;
    if (screenWidth < 480) {
      maxWidth = double.infinity;
    } else if (screenWidth < 768) {
      maxWidth = screenWidth * 0.6;
    } else if (screenWidth < 1024) {
      maxWidth = 350;
    } else {
      maxWidth = 400;
    }

    return Flexible(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          minWidth: screenWidth < 480 ? double.infinity : 200,
        ),
        child: Text(
          isFromUnfiedScreen
              ? "Companies Overview"
              : isFromProfile
              ? "Meetings Overview"
              : "My Clients",
          style: TextStyle(
            fontFamily: globatInterFamily,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, double screenWidth) {
    final isVerySmall = screenWidth < 480;
    final isSmall = screenWidth < 768;
    final isMedium = screenWidth < 1024;

    if (isVerySmall) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildButtonList(context, screenWidth),
      );
    } else {
      return Row(children: _buildButtonList(context, screenWidth));
    }
  }

  List<Widget> _buildButtonList(BuildContext context, double screenWidth) {
    final isVerySmall = screenWidth < 480;
    final isSmall = screenWidth < 768;

    List<Widget> buttons = [];

    if (showAddInteractionButton) {
      buttons.add(_buildAddInteractionButton(context, screenWidth));
      if (!isVerySmall) buttons.add(const SizedBox(width: 10));
    }

    if (!isVerySmall) buttons.add(const SizedBox(width: 10));
    buttons.add(_buildRefreshButton(screenWidth));

    return buttons;
  }

  Widget _buildAddInteractionButton(BuildContext context, double screenWidth) {
    final isVerySmall = screenWidth < 480;
    final isSmall = screenWidth < 768;

    if (isVerySmall) {
      return Expanded(
        child: ElevatedButton(
          onPressed: () => controller!.showAddInteractionDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: const Icon(Icons.add, size: 18),
        ),
      );
    } else if (isSmall) {
      return ElevatedButton.icon(
        onPressed: () => controller!.showAddInteractionDialog(context),
        icon: const Icon(Icons.add, size: 16),
        label: const Text(
          'Add',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () => controller!.showAddInteractionDialog(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text(
          'Add Interaction',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: globatInterFamily,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      );
    }
  }

  Widget _buildFilterButton(double screenWidth) {
    final isVerySmall = screenWidth < 480;
    final isSmall = screenWidth < 768;

    if (isFromProfile) return SizedBox();

    Widget buttonContent;

    if (isVerySmall) {
      buttonContent = SvgPicture.asset(
        "assets/images/filter.svg",
        colorFilter: hasActiveFilter && showCompanies
            ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
            : null,
      );
    } else {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/images/filter.svg",
            colorFilter: hasActiveFilter && showCompanies
                ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            hasActiveFilter && showCompanies ? "Sorted" : "Sort by",
            style: TextStyle(
              fontFamily: globatInterFamily,
              fontSize: isSmall ? 14 : 16,
              color: hasActiveFilter && showCompanies
                  ? Colors.white
                  : const Color.fromRGBO(91, 91, 91, 1),
            ),
          ),
        ],
      );
    }

    Widget button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: hasActiveFilter && showCompanies
            ? const Color.fromRGBO(59, 130, 246, 1)
            : Colors.white,
        foregroundColor: hasActiveFilter && showCompanies
            ? Colors.white
            : Colors.black,
        padding: EdgeInsets.symmetric(
          horizontal: isVerySmall ? 16 : 16,
          vertical: isVerySmall ? 16 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: hasActiveFilter && showCompanies
                ? const Color.fromRGBO(59, 130, 246, 1)
                : const Color.fromRGBO(204, 204, 204, 1),
            width: 1,
          ),
        ),
      ),
      onPressed: showCompanies ? onFilterPressed : null,
      child: buttonContent,
    );

    if (isVerySmall) {
      button = Expanded(child: button);
    }

    return Stack(
      children: [
        button,
        if (hasActiveFilter && showCompanies)
          Positioned(
            right: isVerySmall ? 8 : 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: const Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRefreshButton(double screenWidth) {
    final isVerySmall = screenWidth < 480;
    final isSmall = screenWidth < 768;

    Widget button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isVerySmall ? 16 : 16,
          vertical: isVerySmall ? 16 : 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: onRefreshPressed,
      child: isVerySmall
          ? const Icon(Icons.refresh, color: Colors.white)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "Refresh",
                  style: TextStyle(
                    color: Colors.white,

                    fontFamily: globatInterFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );

    return isVerySmall ? Expanded(child: button) : button;
  }
}

class UnifiedFilterDialog extends StatefulWidget {
  final List<Company> companies;
  final Function(String field, String value) onApplyFilter;
  final String fieldLabel;
  final String fieldKey;
  final String? currentFilterValue;

  const UnifiedFilterDialog({
    super.key,
    required this.companies,
    required this.onApplyFilter,
    required this.fieldLabel,
    required this.fieldKey,
    this.currentFilterValue,
  });

  @override
  State<UnifiedFilterDialog> createState() => _UnifiedFilterDialogState();
}

class _UnifiedFilterDialogState extends State<UnifiedFilterDialog>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
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
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
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
    Set<String> uniqueValues = {};

    for (Company company in widget.companies) {
      String? value;
      switch (widget.fieldKey) {
        case 'accountName':
          value = company.accountName;
          break;
        case 'aeNam':
          value = company.aeNam;
          break;
        case 'segment':
          value = company.segment;
          break;
        case 'focusedOrAssigned':
          value = company.focusedOrAssigned;
          break;
        case 'accountStatus':
          value = company.accountStatus;
          break;
        case 'pipelineStatus':
          value = company.pipelineStatus;
          break;
        case 'accountCategory':
          value = company.accountCategory;
          break;
      }

      if (value != null && value != 'No Data' && value.isNotEmpty) {
        uniqueValues.add(value);
      }
    }

    _suggestions = uniqueValues.toList()..sort();

    if (widget.currentFilterValue != null) {
      _controller.text = widget.currentFilterValue!;
      _hasSelection = true;
    }
  }

  void _onTextChanged() {
    final currentText = _controller.text.trim();
    final isValidSelection =
        currentText.isNotEmpty && _suggestions.contains(currentText);

    if (isValidSelection != _hasSelection) {
      setState(() {
        _hasSelection = isValidSelection;
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
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleApplyFilter() {
    final currentText = _controller.text.trim();

    if (currentText.isEmpty || !_suggestions.contains(currentText)) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    Navigator.of(context).pop();
    widget.onApplyFilter(widget.fieldKey, currentText);
  }

  void _handleClearFilter() {
    HapticFeedback.lightImpact();
    setState(() {
      _controller.clear();
      _hasSelection = false;
    });
  }

  IconData _getFieldIcon() {
    switch (widget.fieldKey) {
      case 'accountName':
        return Icons.business_outlined;
      case 'aeNam':
        return Icons.person_outline;
      case 'segment':
        return Icons.category_outlined;
      case 'focusedOrAssigned':
        return Icons.assignment_outlined;
      case 'accountStatus':
        return Icons.timeline_outlined;
      case 'pipelineStatus':
        return Icons.show_chart_outlined;
      case 'accountCategory':
        return Icons.label_outline;
      default:
        return Icons.filter_alt_outlined;
    }
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
                                  Text(
                                    'Filter by ${widget.fieldLabel}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Find companies by ${widget.fieldLabel.toLowerCase()}',
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
                              widget.fieldLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),

                            TypeAheadField<String>(
                              controller: _controller,
                              builder: (context, controller, focusNode) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Select ${widget.fieldLabel.toLowerCase()} from suggestions...',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[500],
                                    ),
                                    prefixIcon: Icon(
                                      _getFieldIcon(),
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
                                  return _suggestions.take(8).toList();
                                }
                                return _suggestions
                                    .where(
                                      (suggestion) => suggestion
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()),
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
                                          _getFieldIcon(),
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
                                _controller.text = suggestion;
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

                            if (_controller.text.trim().isNotEmpty &&
                                !_hasSelection)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 16,
                                      color: Colors.red[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Please select from suggestions only',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
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
