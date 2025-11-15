import 'package:a2y_app/controller/person_details_controller.dart';
import 'package:a2y_app/widgets/generic_table.dart';
import 'package:a2y_app/widgets/search_filter_bar.dart';
import 'package:a2y_app/widgets/search_filter_bar_person.dart';
import 'package:a2y_app/widgets/search_filter_user.dart';
import 'package:a2y_app/widgets/table_content.dart';
import 'package:a2y_app/controller/unified_screen_controller.dart';
import 'package:a2y_app/controller/user_profile_controller.dart';
import 'package:flutter/material.dart';

class DataTableContainer extends StatelessWidget {
  final bool isLoading;
  final String errorMessage;
  final List<Map<String, dynamic>> data;
  final List<TableColumn> columns;
  final int currentPage;
  final int totalPages;
  final bool showCompanies;
  final bool hasActiveFilter;
  final String sortColumnKey;
  final bool sortAscending;
  final Function(String) onSearchChanged;
  final Function(int) onPageChanged;
  final Function(Map<String, dynamic>) onRowTap;
  final void Function(List<int> selectedIndices)? onSelectionChanged;
  final Function(String, bool) onSort;
  final VoidCallback onFilterPressed;
  final VoidCallback onRefreshPressed;
  final VoidCallback onRetryPressed;
  final VoidCallback onClearFilters;
  final bool isFromProfile;
  final bool showAddInteractionButton;
  final UnifiedScreenController? unifiedScreenController;
  final PersonDetailsController? controller;
  final bool isFromUnfiedScreen;
  final bool isFromPersonScreen;
  final int selectedTabIndex;
  final Function(int)? onTabChanged;
  final bool isFromUserProfile;
  final UserProfileController? userProfileController;
  final bool isFromCompanyDasboardScreen;
  final int? itemsPerPage;
  final void Function(int)? onItemsPerPageChanged;

  final bool? isApiPaginated;
  final int? totalItems;

  const DataTableContainer({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.data,
    required this.columns,
    required this.currentPage,
    required this.totalPages,
    required this.showCompanies,
    required this.hasActiveFilter,
    required this.sortColumnKey,
    required this.sortAscending,
    required this.onSearchChanged,
    required this.onPageChanged,
    required this.onRowTap,
    required this.onSelectionChanged,
    required this.onSort,
    required this.onFilterPressed,
    required this.onRefreshPressed,
    required this.onRetryPressed,
    required this.onClearFilters,
    required this.isFromProfile,
    this.showAddInteractionButton = false,
    this.controller,
    this.userProfileController,
    required this.isFromUnfiedScreen,
    required this.isFromPersonScreen,
    this.selectedTabIndex = 0,
    this.onTabChanged,
    this.unifiedScreenController,
    required this.isFromUserProfile,
    required this.isFromCompanyDasboardScreen,
    this.itemsPerPage,
    this.onItemsPerPageChanged,
    this.isApiPaginated,
    this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color.fromRGBO(228, 228, 228, 1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          isFromPersonScreen
              ? PersonTableBarSection(
                  showCompanies: showCompanies,
                  hasActiveFilter: hasActiveFilter,
                  onSearchChanged: onSearchChanged,
                  onFilterPressed: onFilterPressed,
                  onRefreshPressed: onRefreshPressed,
                  isFromProfile: isFromProfile,
                  showAddInteractionButton: showAddInteractionButton,
                  controller: controller,
                  isFromUnfiedScreen: isFromUnfiedScreen,
                  selectedTabIndex: selectedTabIndex,
                  onTabChanged: onTabChanged,
                )
              : isFromUserProfile
              ? SearchFilterUser(
                  showCompanies: showCompanies,
                  hasActiveFilter: hasActiveFilter,
                  onSearchChanged: onSearchChanged,
                  onFilterPressed: onFilterPressed,
                  onRefreshPressed: onRefreshPressed,
                  isFromProfile: isFromProfile,
                  showAddInteractionButton: showAddInteractionButton,
                  controller: userProfileController,
                  isFromUnfiedScreen: isFromUnfiedScreen,
                  onApplyFilter: isFromUnfiedScreen
                      ? unifiedScreenController!.handleFilterApplication
                      : null,
                  companies: isFromUnfiedScreen
                      ? unifiedScreenController!.companies
                      : null,
                  selectedTabIndex: selectedTabIndex,
                  onTabChanged: onTabChanged,
                )
              : SearchFilterBar(
                  isFromCompanyDasboardScreen: isFromCompanyDasboardScreen,
                  showCompanies: showCompanies,
                  hasActiveFilter: hasActiveFilter,
                  onSearchChanged: onSearchChanged,
                  onFilterPressed: onFilterPressed,
                  onRefreshPressed: onRefreshPressed,
                  isFromProfile: isFromProfile,
                  showAddInteractionButton: showAddInteractionButton,
                  controller: controller,
                  isFromUnfiedScreen: isFromUnfiedScreen,
                  onApplyFilter: isFromUnfiedScreen
                      ? unifiedScreenController!.handleFilterApplication
                      : null,
                  companies: isFromUnfiedScreen
                      ? unifiedScreenController!.companies
                      : null,
                  selectedTabIndex: selectedTabIndex,
                  onTabChanged: onTabChanged,
                  people: isFromUnfiedScreen
                      ? unifiedScreenController!.people
                      : null,
                  onApplyPersonFilter: isFromUnfiedScreen
                      ? unifiedScreenController!.handlePersonFilterApplication
                      : null,
                ),
          const SizedBox(height: 8),
          Expanded(
            child: TableContent(
              isLoading: isLoading,
              errorMessage: errorMessage,
              data: data,
              columns: columns,
              currentPage: currentPage,
              totalPages: totalPages,
              isApiPaginated: isApiPaginated,
              totalItems: totalItems,
              showCompanies: showCompanies,
              hasActiveFilter: hasActiveFilter,
              sortColumnKey: sortColumnKey,
              sortAscending: sortAscending,
              onPageChanged: onPageChanged,
              onRowTap: onRowTap,
              onSelectionChanged: onSelectionChanged,
              onSort: onSort,
              onRetryPressed: onRetryPressed,
              onClearFilters: onClearFilters,
              itemsPerPage: itemsPerPage,
              onItemsPerPageChanged: onItemsPerPageChanged,
            ),
          ),
        ],
      ),
    );
  }
}
