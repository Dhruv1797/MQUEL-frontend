import 'package:a2y_app/widgets/file_upload_dialog.dart';
import 'package:a2y_app/widgets/invite_dialog.dart';
import 'package:a2y_app/widgets/company_filter_dlalog.dart';
import 'package:a2y_app/widgets/generic_table.dart';
import 'package:a2y_app/widgets/add_dlalog.dart';
import 'package:a2y_app/widgets/active_filter_banner.dart';
import 'package:a2y_app/widgets/custom_app_bar.dart';
import 'package:a2y_app/widgets/data_table_container.dart';
import 'package:a2y_app/widgets/table_header_section.dart';
import 'package:a2y_app/widgets/unfied_screen_widgets.dart';
import 'package:a2y_app/controller/unified_screen_controller.dart';
import 'package:a2y_app/widgets/unified_screen_table_columns.dart';
import 'package:a2y_app/model/companyModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:a2y_app/constants/api_constants.dart';
import 'package:a2y_app/services/company_service.dart';
import 'package:a2y_app/widgets/people_helper.dart';
import 'package:a2y_app/model/company_model.dart';
import 'package:a2y_app/model/person_model.dart';

class UnifiedScreen extends StatefulWidget {
  final CompanyModel? companyData;
  final int? clientId;
  final List<int>? initialParticipantFilter;

  const UnifiedScreen({
    super.key,
    this.companyData,
    this.clientId,
    this.initialParticipantFilter,
  });

  @override
  State<UnifiedScreen> createState() => _UnifiedScreenState();
}

class _UnifiedScreenState extends State<UnifiedScreen> {
  late UnifiedScreenController controller;
  late UnifiedScreenWidgetBuilders widgetBuilders;
  late UnifiedScreenTableColumns tableColumns;

  final bool _isApiPaginated = false;
  bool _apiLoading = false;
  int _apiTotalPages = 1;
  int _apiTotalItems = 0;

  final bool _logSensitiveHeaders = false;

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
    );

    if (widget.initialParticipantFilter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.applyParticipantFilter(widget.initialParticipantFilter!);
      });
    }

    widgetBuilders = UnifiedScreenWidgetBuilders(
      context: context,
      controller: controller,
    );

    tableColumns = UnifiedScreenTableColumns(
      widgetBuilders: widgetBuilders,
      context,
    );

    controller.loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isApiPaginated) {
        _fetchPaginatedPage(pageZeroBased: 0, size: controller.itemsPerPage);
      }
    });
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
      clientId: widget.clientId!,
      selectedTabIndex: controller.selectedTabIndex,
      isFromCompany: true,
    );
  }

  void _showAddCompanyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddCompanyDialog(clientid: widget.clientId!);
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

  void _logApiRequest({
    required String label,
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    final maskedHeaders = Map<String, String>.from(headers);
    if (!_logSensitiveHeaders && maskedHeaders.containsKey('Authorization')) {
      final auth = maskedHeaders['Authorization']!;
      final visible = auth.length >= 16
          ? '${auth.substring(0, 16)}...${auth.substring(auth.length - 6)}'
          : auth;
      maskedHeaders['Authorization'] = visible;
    }

    debugPrint('--- API REQUEST [$label] ---');
    debugPrint('Base: ${ApiConstants.baseApiPath}');
    debugPrint('Path: ${uri.path}');
    debugPrint('Method: $method');
    debugPrint('URL: ${uri.toString()}');
    debugPrint('Query Params: ${uri.queryParameters}');
    debugPrint('Headers: $maskedHeaders');
    if (body != null) debugPrint('Body: $body');
    debugPrint('----------------------------');
  }

  void _logApiResponse({
    required String label,
    required Uri uri,
    required http.Response response,
    required Duration duration,
    int? totalPages,
    int? totalItems,
    int? contentCount,
  }) {
    debugPrint('=== API RESPONSE [$label] ===');
    debugPrint('URL: ${uri.toString()}');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Duration: ${duration.inMilliseconds} ms');
    debugPrint('Resp Headers: ${response.headers}');
    debugPrint('Body length: ${response.bodyBytes.length} bytes');
    if (totalPages != null) debugPrint('totalPages: $totalPages');
    if (totalItems != null) debugPrint('totalItems: $totalItems');
    if (contentCount != null) debugPrint('content length: $contentCount');
    final preview = response.body.length > 512
        ? '${response.body.substring(0, 512)}...'
        : response.body;
    debugPrint('Body preview: $preview');
    debugPrint('============================');
  }

  Future<void> _fetchPaginatedPage({
    required int pageZeroBased,
    required int size,
  }) async {
    try {
      setState(() {
        _apiLoading = true;
        controller.errorMessage = '';
      });

      final decoded = controller.showCompanies
          ? await CompanyService.getCompaniesExcelPaginated(
              clientId: (widget.clientId ?? controller.clientId)!,
              page: pageZeroBased,
              size: size,
            )
          : await CompanyService.getAttendeesExcelPaginated(
              clientId: (widget.clientId ?? controller.clientId)!,
              page: pageZeroBased,
              size: size,
            );
      final List<dynamic> content = decoded['content'] ?? [];
      final int totalItems =
          decoded['totalElements'] ?? decoded['totalItems'] ?? 0;
      final int totalPages =
          decoded['totalPages'] ??
          ((totalItems > 0 && size > 0)
              ? ((totalItems + size - 1) ~/ size)
              : 1);

      final List<Map<String, dynamic>> rows = controller.showCompanies
          ? content
                .map(
                  (item) =>
                      Company.fromJson(Map<String, dynamic>.from(item as Map)),
                )
                .map((company) => company.toCompanyTableFormat())
                .toList()
          : content
                .map(
                  (item) => PersonData.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .map((person) => PeopleHelper.mapPersonForTable(person))
                .toList();

      if (controller.showCompanies) {
        controller.companyTableData = rows;
      } else {
        controller.peopleTableData = rows;
      }

      setState(() {
        _apiTotalPages = totalPages;
        _apiTotalItems = totalItems;
        _apiLoading = false;
      });
    } catch (e) {
      setState(() {
        _apiLoading = false;
        controller.errorMessage = e.toString();
      });
      debugPrint('!!! API ERROR: $e');
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
      appBar: CustomAppBar(
        showNotifications: true,
        onNotificationTap: (participantIds) {
          controller.applyParticipantFilter(participantIds);
        },
      ),
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
              child: TabHeaderSection(
                companyData: widget.companyData,
                showCompanies: controller.showCompanies,
                onTabChanged: (isCompanies) {
                  controller.switchTab(isCompanies);
                  debugPrint(
                    'Tab changed: ${isCompanies ? 'Companies' : 'Attendees'}',
                  );
                  if (_isApiPaginated) {
                    _fetchPaginatedPage(
                      pageZeroBased: 0,
                      size: controller.itemsPerPage,
                    );
                  }
                },
                onInvitePressed: _onInvitePressed,
                onDownloadPressed: _onDownloadPressed,
                onAddPressed: _onAddPressed,
                controller: controller,
              ),
            ),
          ),

          const SizedBox(height: 10),
          if (controller.hasActiveFilter)
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

          if (controller.hasParticipantFilter)
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Showing ${controller.participantFilter?.length ?? 0} participants from notification',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => controller.clearParticipantFilter(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: DataTableContainer(
                isFromCompanyDasboardScreen: false,
                isFromUserProfile: false,
                unifiedScreenController: controller,
                isFromPersonScreen: false,
                isFromUnfiedScreen: true,
                isFromProfile: false,
                isLoading: _isApiPaginated ? _apiLoading : controller.isLoading,
                errorMessage: controller.errorMessage,
                data: displayedData,
                columns: controller.showCompanies
                    ? companyColumns
                    : peopleColumns,
                currentPage: controller.currentPage,
                totalPages: _isApiPaginated
                    ? _apiTotalPages
                    : (displayedData.length / controller.itemsPerPage).ceil(),
                isApiPaginated: _isApiPaginated,
                totalItems: _apiTotalItems,
                showCompanies: controller.showCompanies,
                hasActiveFilter: controller.hasActiveFilter,
                sortColumnKey: controller.sortColumnKey ?? '',
                sortAscending: controller.sortAscending,
                onSearchChanged: (query) => controller.onSearchChanged(query),
                onPageChanged: (page) {
                  controller.onPageChanged(page);
                  debugPrint('Page change requested: $page');
                  if (_isApiPaginated) {
                    _fetchPaginatedPage(
                      pageZeroBased: page - 1,
                      size: controller.itemsPerPage,
                    );
                  }
                },
                onRowTap: (rowData) => controller.onRowTap(rowData, context),
                onSelectionChanged: (selectedIndices) =>
                    controller.onSelectionChanged(selectedIndices),
                onSort: (columnKey, ascending) =>
                    controller.onSort(columnKey, ascending),
                onFilterPressed: _showFilterDialog,
                onRefreshPressed: () {
                  if (_isApiPaginated) {
                    _fetchPaginatedPage(
                      pageZeroBased: controller.currentPage - 1,
                      size: controller.itemsPerPage,
                    );
                  } else {
                    controller.loadData();
                  }
                },
                onRetryPressed: () {
                  if (_isApiPaginated) {
                    _fetchPaginatedPage(
                      pageZeroBased: controller.currentPage - 1,
                      size: controller.itemsPerPage,
                    );
                  } else {
                    controller.loadData();
                  }
                },
                onClearFilters: () => controller.clearFilters(),
                selectedTabIndex: controller.selectedTabIndex,
                onTabChanged: (index) =>
                    controller.onMainTabIndexChanged(index),
                itemsPerPage: controller.itemsPerPage,
                onItemsPerPageChanged: (newSize) {
                  controller.changeItemsPerPage(newSize);
                  debugPrint('Items per page changed: $newSize');
                  if (_isApiPaginated) {
                    controller.currentPage = 1;
                    _fetchPaginatedPage(pageZeroBased: 0, size: newSize);
                  }
                },
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
