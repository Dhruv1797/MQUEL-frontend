import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/widgets/generic_table.dart';
import 'package:flutter/material.dart';

class TableContent extends StatelessWidget {
  final bool isLoading;
  final String errorMessage;
  final List<Map<String, dynamic>> data;
  final List<TableColumn> columns;
  final int currentPage;
  final int totalPages;
  final bool? isApiPaginated;
  final int? totalItems;
  final bool showCompanies;
  final bool hasActiveFilter;
  final String sortColumnKey;
  final bool sortAscending;
  final Function(int) onPageChanged;
  final Function(Map<String, dynamic>) onRowTap;
  final void Function(List<int> selectedIndices)? onSelectionChanged;
  final Function(String, bool) onSort;
  final VoidCallback onRetryPressed;
  final VoidCallback onClearFilters;
  final int? itemsPerPage;
  final void Function(int)? onItemsPerPageChanged;

  const TableContent({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.data,
    required this.columns,
    required this.currentPage,
    required this.totalPages,
    this.isApiPaginated,
    this.totalItems,
    required this.showCompanies,
    required this.hasActiveFilter,
    required this.sortColumnKey,
    required this.sortAscending,
    required this.onPageChanged,
    required this.onRowTap,
    required this.onSelectionChanged,
    required this.onSort,
    required this.onRetryPressed,
    required this.onClearFilters,
    this.itemsPerPage,
    this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage.isNotEmpty) {
      return _buildEmptyState();
    }

    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTableState();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error loading ${showCompanies ? 'companies' : 'people'}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetryPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showCompanies ? Icons.business : Icons.people,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveFilter && showCompanies
                ? 'No companies match the current filter'
                : 'No ${showCompanies ? 'companies' : 'people'} found',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          if (hasActiveFilter && showCompanies) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onClearFilters,
              child: const Text(
                'Clear filters to see all companies',
                style: TextStyle(fontFamily: 'Inter', color: Colors.blue),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableState() {
    return GenericDataTable(
      itemsPerPage: itemsPerPage ?? 10,
      onItemsPerPageChanged: onItemsPerPageChanged,
      data: data,
      columns: columns,
      currentPage: currentPage,
      totalPages: totalPages,
      isApiPaginated: isApiPaginated,
      totalItems: totalItems,
      onPageChanged: onPageChanged,

      onRowTap: onRowTap,
      onSelectionChanged: onSelectionChanged,
      allowSelection: true,
      showPagination: true,
      onSort: onSort,
      sortColumnKey: sortColumnKey,
      sortAscending: sortAscending,
      emptyMessage: 'No ${showCompanies ? 'companies' : 'people'} found',
      headerBackgroundColor: const Color.fromRGBO(249, 250, 251, 1),
      rowBackgroundColor: Colors.white,
      borderColor: const Color.fromRGBO(243, 244, 246, 1),
      headerTextStyle: const TextStyle(
        fontFamily: globatInterFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color.fromRGBO(102, 112, 113, 1),
      ),
      rowTextStyle: const TextStyle(
        fontFamily: globatInterFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color.fromRGBO(144, 144, 144, 1),
      ),
    );
  }
}
