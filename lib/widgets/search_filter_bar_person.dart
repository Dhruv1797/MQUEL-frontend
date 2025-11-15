import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/controller/person_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonTableBarSection extends StatelessWidget {
  final bool showCompanies;
  final bool hasActiveFilter;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onRefreshPressed;
  final bool isFromProfile;
  final bool showAddInteractionButton;
  final PersonDetailsController? controller;
  final bool isFromUnfiedScreen;
  final int selectedTabIndex;
  final Function(int)? onTabChanged;

  const PersonTableBarSection({
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
    this.selectedTabIndex = 0,
    this.onTabChanged,
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

          if (isVerySmall) {
            return Column(
              children: [
                _buildTabsAndActions(context, screenWidth),
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
                    _buildTabsAndActions(context, screenWidth),
                    _buildActionButtons(context, screenWidth),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInsideSearchField(),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTabsAndActions(BuildContext context, double screenWidth) {
    if (isFromUnfiedScreen) {
      return _buildTabs(screenWidth);
    } else {
      return _buildSearchField(context, screenWidth);
    }
  }

  Widget _buildTabs(double screenWidth) {
    final isVerySmall = screenWidth < 480;
    final isSmall = screenWidth < 768;

    return Row(
      children: [
        _buildTabButton("Attendee List", 0, screenWidth),
        const SizedBox(width: 2),
        _buildTabButton("Persona List", 1, screenWidth),
      ],
    );
  }

  Widget _buildTabButton(String title, int index, double screenWidth) {
    final isSelected = selectedTabIndex == index;
    final isVerySmall = screenWidth < 480;
    final isSmall = screenWidth < 768;

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
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: isVerySmall ? 16 : (isSmall ? 16 : 16),
            color: isSelected
                ? Colors.black
                : const Color.fromRGBO(107, 114, 128, 1),
          ),
        ),
      ),
    );
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
          "My Clients",
          style: TextStyle(
            fontFamily: globatInterFamily,
            fontWeight: FontWeight.w600,
            fontSize: 18,
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

  Widget _buildFilterButtons() {
    return Row(
      children: [
        _buildSmallFilterButton('Company', Icons.keyboard_arrow_down),
        const SizedBox(width: 8),
        _buildSmallFilterButton('Account Owner', Icons.keyboard_arrow_down),
        const SizedBox(width: 8),
        _buildSmallFilterButton('City', Icons.keyboard_arrow_down),
        const SizedBox(width: 8),
        _buildSmallFilterButton('Focus/Assigned', Icons.keyboard_arrow_down),
        const SizedBox(width: 8),
        _buildSmallFilterButton(
          'Select Date Range',
          Icons.calendar_today,
          isDatePicker: true,
        ),
      ],
    );
  }

  Widget _buildSmallFilterButton(
    String label,
    IconData icon, {
    bool isDatePicker = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (isDatePicker) {
          _showDateRangePicker();
        } else {
          _showFilterOptions(label);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDatePicker) ...[
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                fontFamily: globatInterFamily,
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Color.fromRGBO(75, 85, 99, 1),
              ),
            ),
            if (!isDatePicker) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: Colors.grey[600]),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(String filterType) {
    print('Show $filterType filter options');
  }

  void _showDateRangePicker() {
    print('Show date range picker');
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
