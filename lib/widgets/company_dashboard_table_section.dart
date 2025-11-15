import 'dart:developer';

import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/controller/company_dasboard_controller.dart';
import 'package:a2y_app/widgets/company_edit_new_dialog.dart';
import 'package:a2y_app/widgets/data_table_container.dart';
import 'package:a2y_app/widgets/generic_table.dart';
import 'package:a2y_app/screens/unfied_screen.dart';
import 'package:a2y_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class NavigationHelper {
  static void navigateToUnifiedScreen(BuildContext context, dynamic company) {
    goToNextScreenPush(
      context,
      UnifiedScreen(companyData: company, clientId: company.clientId),
    );
  }
}

class CompanyTableSection extends StatelessWidget {
  final CompanyDashboardController controller;

  const CompanyTableSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: DataTableContainer(
        isFromCompanyDasboardScreen: true,
        isFromUserProfile: false,
        isFromPersonScreen: false,
        isFromUnfiedScreen: false,
        controller: null,
        isFromProfile: false,
        isLoading: controller.isLoading,
        errorMessage: controller.errorMessage,
        data: _convertCompaniesToTableData(),
        columns: _getColumns(context),
        currentPage: 1,
        totalPages: 1,
        showCompanies: true,
        hasActiveFilter: controller.hasActiveFilter,
        sortColumnKey: '',
        sortAscending: true,
        onSearchChanged: controller.updateSearchQuery,
        onPageChanged: (page) {},
        onRowTap: (rowData) => _onViewCompany(context, rowData),
        onSelectionChanged: null,
        onSort: (column, ascending) {},
        onFilterPressed: controller.toggleFilter,
        onRefreshPressed: controller.refreshCompanies,
        onRetryPressed: controller.loadCompanies,
        onClearFilters: controller.clearSearchAndRefresh,
        showAddInteractionButton: false,
      ),
    );
  }

  List<TableColumn> _getColumns(BuildContext context) {
    return [
      TableColumn(
        key: 'clientName',
        title: 'Client Name',
        width: MediaQuery.of(context).size.width * 0.45,
        sortable: true,
        hasCheckbox: true,
        customBuilder: (value, isHeader, rowData) {
          return _buildClientNameColumn(context, value, isHeader, rowData);
        },
      ),
      TableColumn(
        key: 'createdOn',
        title: 'Created On',
        width: MediaQuery.of(context).size.width * 0.42,
        sortable: true,
        customBuilder: (value, isHeader, rowData) {
          return _buildCreatedOnColumn(context, value, isHeader, rowData);
        },
      ),
      TableColumn(
        key: 'actions',
        title: 'Actions',
        width: MediaQuery.of(context).size.width * 0.1,
        sortable: false,
        customBuilder: (value, isHeader, rowData) {
          return _buildActionsColumn(context, value, isHeader, rowData);
        },
      ),
    ];
  }

  Widget _buildClientNameColumn(
    BuildContext context,
    dynamic value,
    bool isHeader,
    Map<String, dynamic>? companyData,
  ) {
    if (isHeader) {
      return Text(
        'Client Name',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final clientName = value?.toString() ?? 'No Data';
    return Text(
      clientName,
      style: TextStyle(
        fontFamily: globatInterFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: clientName == 'No Data' ? Colors.grey : Colors.black,
      ),
    );
  }

  Widget _buildCreatedOnColumn(
    BuildContext context,
    dynamic value,
    bool isHeader,
    Map<String, dynamic>? companyData,
  ) {
    if (isHeader) {
      return Text(
        'Created On',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final createdOn = value?.toString() ?? 'No Data';
    return Text(
      createdOn,
      style: TextStyle(
        fontFamily: globatInterFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: createdOn == 'No Data' ? Colors.grey : Colors.black,
      ),
    );
  }

  Widget _buildActionsColumn(
    BuildContext context,
    dynamic value,
    bool isHeader,
    Map<String, dynamic>? rowData,
  ) {
    if (isHeader) {
      return Text(
        'Actions',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w600,

          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _onViewCompany(context, rowData!),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
          ),
          child: const Text(
            'View',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () => _onEditCompany(context, rowData!),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
          ),
          child: Icon(Icons.edit, size: 16),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _convertCompaniesToTableData() {
    return controller.filteredCompanies.map((company) {
      return {
        'clientId': company.clientId,
        'clientName': company.displayOrgName,
        'createdOn': company.displayCreatedOn,
        'actions': 'View',
        'companyData': company,
      };
    }).toList();
  }

  void _onViewCompany(BuildContext context, Map<String, dynamic> rowData) {
    final company = rowData['companyData'];
    _navigateToUnifiedScreen(context, company);
  }

  void _onEditCompany(BuildContext context, Map<String, dynamic> rowData) {
    log("Row Data $rowData");
    showDialog(
      context: context,
      builder: (context) => CompanyEditDialog(
        companyData: rowData,
        onCompanyUpdated: () {
          controller.onCompanyEdited();
        },
      ),
    );
  }

  void _navigateToUnifiedScreen(BuildContext context, dynamic company) {
    NavigationHelper.navigateToUnifiedScreen(context, company);
  }

  Widget _buildNoDataWidget(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[300]!.withOpacity(0.3),
                      Colors.grey[400]!.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.business,
                  size: 48,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Clients Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start by adding your first client to manage your business relationships.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add Client functionality'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Add Client',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: controller.loadCompanies,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text(
                      'Refresh',
                      style: TextStyle(
                        fontFamily: globatInterFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      side: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
