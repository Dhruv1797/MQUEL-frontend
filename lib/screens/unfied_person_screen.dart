import 'package:a2y_app/widgets/file_upload_dialog.dart';
import 'package:a2y_app/widgets/invite_dialog.dart';
import 'package:a2y_app/widgets/company_filter_dlalog.dart';
import 'package:a2y_app/widgets/generic_table.dart';
import 'package:a2y_app/widgets/add_dlalog.dart';
import 'package:a2y_app/widgets/active_filter_banner.dart';
import 'package:a2y_app/widgets/custom_app_bar.dart';
import 'package:a2y_app/widgets/data_table_container.dart';
import 'package:a2y_app/widgets/table_header_section_person.dart';
import 'package:a2y_app/widgets/unfied_screen_widgets.dart';
import 'package:a2y_app/controller/unified_screen_controller.dart';
import 'package:a2y_app/widgets/unified_screen_table_columns.dart';
import 'package:a2y_app/model/companyModel.dart';
import 'package:flutter/material.dart';

class UnifiedPersonScreen extends StatefulWidget {
  final CompanyModel companyData;
  final int clientId;
  final Map<String, dynamic> rowData;

  const UnifiedPersonScreen({
    super.key,
    required this.companyData,
    required this.clientId,
    required this.rowData,
  });

  @override
  State<UnifiedPersonScreen> createState() => _UnifiedPersonScreenState();
}

class _UnifiedPersonScreenState extends State<UnifiedPersonScreen> {
  late UnifiedScreenController controller;
  late UnifiedScreenWidgetBuilders widgetBuilders;
  late UnifiedScreenTableColumns tableColumns;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    controller = UnifiedScreenController(
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
      companyData: widget.companyData,
      clientId: widget.clientId,
      rowData: widget.rowData,
    );

    controller.showCompanies = false;

    widgetBuilders = UnifiedScreenWidgetBuilders(
      context: context,
      controller: controller,
    );

    tableColumns = UnifiedScreenTableColumns(
      widgetBuilders: widgetBuilders,
      context,
    );

    controller.loadData();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          companies: controller.companiesList,
          onApplyFilter: (field, value) {
            if (value.isNotEmpty) {
              controller.fetchFilteredCompanies(field, value);
            }
          },
          currentFilterValue: controller.currentFilterValue,
        );
      },
    );
  }

  void _showUploadDialog() {
    FileUploadDialog.show(
      context,
      onUploadComplete: () => controller.loadPeople(),
      clientId: widget.clientId,
      selectedTabIndex: controller.selectedPersonTabIndex,
      isFromCompany: false,
    );
  }

  void _showAddCompanyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddCompanyDialog(clientid: widget.clientId);
      },
    ).then((result) {
      if (result == true) {
        controller.loadCompanies();
      }
    });
  }

  void _onDownloadPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download functionality coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onInvitePressed() {
    if (controller.showCompanies) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return InviteDialog(isCompanyInvite: true);
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return InviteDialog(isCompanyInvite: false);
        },
      );
    }
  }

  void _onAddPressed() {
    if (controller.showCompanies) {
      _showAddCompanyDialog();
    } else {
      _showUploadDialog();
    }
  }

  List<TableColumn> get peopleColumns => tableColumns.peopleColumns;

  List<TableColumn> get companyColumns => tableColumns.companyColumns;
  List<TableColumn> dummydata = [];

  @override
  Widget build(BuildContext context) {
    final displayedData = controller.getFilteredData();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Color.fromRGBO(228, 228, 228, 1),
                ),
                top: BorderSide(
                  width: 1,
                  color: Color.fromRGBO(228, 228, 228, 1),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 25,
              ),
              child: PersonTabHeaderSection(
                rowData: widget.rowData,
                companyData: widget.companyData,
                showCompanies: controller.showCompanies,
                onTabChanged: (isCompanies) =>
                    controller.switchTab(isCompanies),
                onInvitePressed: _onInvitePressed,
                onDownloadPressed: _onDownloadPressed,
                onAddPressed: _onAddPressed,
                controller: controller,
              ),
            ),
          ),

          const SizedBox(height: 10),
          if (controller.hasActiveFilter && controller.showCompanies)
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: ActiveFilterBanner(
                filterName: controller.getFilterDisplayName(
                  controller.currentFilter,
                ),
                filterValue: controller.currentFilterValue ?? '',
                resultCount: controller.filteredCompaniesList.length,
                onClearFilter: () => controller.clearFilters(),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: DataTableContainer(
                isFromCompanyDasboardScreen: false,
                isFromUserProfile: false,
                isFromPersonScreen: true,
                isFromUnfiedScreen: true,
                isFromProfile: false,
                isLoading: controller.isLoading,
                errorMessage: controller.errorMessage,
                data: displayedData,
                columns: controller.showCompanies
                    ? companyColumns
                    : tableColumns.getColumns(
                        false,
                        tabIndex: controller.selectedPersonTabIndex,
                      ),
                currentPage: controller.currentPage,
                totalPages: (displayedData.length / controller.itemsPerPage)
                    .ceil(),
                showCompanies: controller.showCompanies,
                hasActiveFilter: controller.hasActiveFilter,
                sortColumnKey: controller.sortColumnKey ?? '',
                sortAscending: controller.sortAscending,
                onSearchChanged: (query) => controller.onSearchChanged(query),
                onPageChanged: (page) => controller.onPageChanged(page),
                onRowTap: (rowData) => controller.onRowTap(rowData, context),
                onSelectionChanged: (selectedIndices) =>
                    controller.onSelectionChanged(selectedIndices),
                onSort: (columnKey, ascending) =>
                    controller.onSort(columnKey, ascending),
                onFilterPressed: _showFilterDialog,
                onRefreshPressed: () => controller.loadData(),
                onRetryPressed: () => controller.loadData(),
                onClearFilters: () => controller.clearFilters(),

                selectedTabIndex: controller.selectedPersonTabIndex,
                onTabChanged: (index) =>
                    controller.onPersonTabIndexChanged(index),
                itemsPerPage: controller.itemsPerPage,
                onItemsPerPageChanged: controller.changeItemsPerPage,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
