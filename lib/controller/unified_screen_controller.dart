import 'dart:developer';

import 'package:a2y_app/services/api_services.dart';
import 'package:a2y_app/widgets/people_helper.dart';
import 'package:a2y_app/model/person_model.dart';
import 'package:a2y_app/model/company_model.dart';
import 'package:a2y_app/model/companyModel.dart';
import 'package:a2y_app/screens/person_details_screen.dart';
import 'package:a2y_app/screens/unfied_person_screen.dart';
import 'package:a2y_app/services/company_service.dart';
import 'package:a2y_app/services/excel_export_service.dart';
import 'package:a2y_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class UnifiedScreenController {
  bool showCompanies = true;
  int selectedTabIndex = 0;
  int selectedPersonTabIndex = 0;

  int _itemsPerPage = 10;
  int get itemsPerPage => _itemsPerPage;

  int currentPage = 1;
  bool isLoading = true;
  String searchQuery = '';
  String errorMessage = '';
  String? sortColumnKey;
  bool sortAscending = true;

  List<PersonData> _people = [];
  List<Map<String, dynamic>> peopleTableData = [];

  List<Company> companies = [];
  List<Map<String, dynamic>> companyTableData = [];
  List<Company> filteredCompanies = [];

  String? currentFilter;
  String? currentFilterValue;
  bool hasActiveFilter = false;

  List<int>? participantFilter;
  bool hasParticipantFilter = false;

  List<int> _selectedIndices = [];
  List<int> get selectedIndices => _selectedIndices;

  final VoidCallback? onStateChanged;
  final CompanyModel? companyData;
  final int? clientId;
  final Map<String, dynamic>? rowData;

  UnifiedScreenController({
    this.onStateChanged,
    this.companyData,
    this.clientId,
    this.rowData,
  }) {
    if (companyData != null) {
      print(
        'UnifiedScreenController initialized with company: ${companyData!.displayOrgName}',
      );
      print('Client ID: $clientId');
    }
    if (rowData != null) {
      print('Row data: $rowData');
    }
  }

  void _notifyStateChanged() {
    onStateChanged?.call();
  }

  Future<void> loadData() async {
    if (showCompanies) {
      await loadCompanies();
    } else {
      await loadPeople();
    }
  }

  void changeItemsPerPage(int newItemsPerPage) {
    _itemsPerPage = newItemsPerPage;
    currentPage = 1;
    _notifyStateChanged();
  }

  int getTotalPages() {
    final data = getFilteredData();
    return (data.length / _itemsPerPage).ceil();
  }

  Future<void> loadCompanies() async {
    try {
      isLoading = true;
      errorMessage = '';
      _notifyStateChanged();

      List<Company> fetchedCompanies = await CompanyService.getAllCompanies(
        clientId: clientId,
      );

      companies = fetchedCompanies;
      filteredCompanies = fetchedCompanies;
      updateTableData();
      isLoading = false;
      _notifyStateChanged();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      _notifyStateChanged();
    }
  }

  Future<void> loadPeople() async {
    try {
      isLoading = true;
      errorMessage = '';
      _notifyStateChanged();

      List<PersonData> people = [];

      if (rowData != null) {
        if (selectedPersonTabIndex == 0) {
          people = await PeopleApiService.fetchAttendees(
            orgId: rowData!['id'],
            clientId: rowData!['clientId'],
          );
        } else if (selectedPersonTabIndex == 1) {
          people = await PeopleApiService.fetchPersonas(
            clientId: rowData!['clientId'],
            company: rowData!['accountName'],
          );
        }
      } else {
        people = await PeopleApiService.fetchPeople(clientId: clientId);
      }

      _people = people;
      peopleTableData = people
          .map((person) => PeopleHelper.mapPersonForTable(person))
          .toList();
      isLoading = false;
      _notifyStateChanged();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      _notifyStateChanged();
    }
  }

  void onMainTabIndexChanged(int tabIndex) {
    if (selectedTabIndex != tabIndex) {
      selectedTabIndex = tabIndex;
      showCompanies = (tabIndex == 0);
      currentPage = 1;
      searchQuery = '';
      isLoading = true;

      clearFilters();
      _notifyStateChanged();

      loadData();
    }
  }

  void onPersonTabIndexChanged(int tabIndex) {
    if (selectedPersonTabIndex != tabIndex) {
      selectedPersonTabIndex = tabIndex;
      currentPage = 1;
      searchQuery = '';
      isLoading = true;
      clearFilters();
      _notifyStateChanged();

      if (!showCompanies && rowData != null) {
        loadPeople();
      }
    }
  }

  void onTabIndexChanged(int tabIndex) {
    if (selectedTabIndex != tabIndex) {
      selectedTabIndex = tabIndex;
      currentPage = 1;
      searchQuery = '';
      isLoading = true;
      clearFilters();
      _notifyStateChanged();

      if (!showCompanies) {
        loadPeople();
      }
    }
  }

  void updateTableData() {
    if (showCompanies) {
      companyTableData = (hasActiveFilter ? filteredCompanies : companies)
          .map((company) => company.toCompanyTableFormat())
          .toList();
    } else {
      peopleTableData = _people
          .map((person) => PeopleHelper.mapPersonForTable(person))
          .toList();
    }
  }

  Future<void> fetchFilteredCompanies(String field, String value) async {
    try {
      isLoading = true;
      errorMessage = '';
      _notifyStateChanged();

      String apiField;
      switch (field) {
        case 'accountName':
          apiField = 'company';
          break;
        case 'aeNam':
          apiField = 'aename';
          break;
        case 'segment':
          apiField = 'city';
          break;
        case 'focusedOrAssigned':
          apiField = 'focusedorassigned';
          break;
        case 'accountStatus':
          apiField = 'accountstatus';
          break;
        case 'pipelineStatus':
          apiField = 'pipelinestatus';
          break;
        case 'accountCategory':
          apiField = 'accountcategory';
          break;
        default:
          apiField = field;
      }

      List<Company> fetchedCompanies =
          await CompanyService.getFilteredCompanies(
            apiField,
            value,
            clientId: clientId,
          );

      filteredCompanies = fetchedCompanies;
      currentFilter = field;
      currentFilterValue = value;
      hasActiveFilter = true;
      updateTableData();
      isLoading = false;
      _notifyStateChanged();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      _notifyStateChanged();
    }
  }

  Future<void> handleFilterApplication(String field, String value) async {
    await fetchFilteredCompanies(field, value);
  }

  void clearFilters() {
    filteredCompanies = companies;

    if (!showCompanies && hasActiveFilter) {
      loadPeople();
    }

    currentFilter = null;
    currentFilterValue = null;
    hasActiveFilter = false;
    searchQuery = '';

    participantFilter = null;
    hasParticipantFilter = false;

    updateTableData();
    _notifyStateChanged();
  }

  void clearRegularFilters() {
    filteredCompanies = companies;

    if (!showCompanies && hasActiveFilter) {
      loadPeople();
    }

    currentFilter = null;
    currentFilterValue = null;
    hasActiveFilter = false;
    searchQuery = '';

    updateTableData();
    _notifyStateChanged();
  }

  void applyParticipantFilter(List<int> participantIds) {
    if (!showCompanies &&
        hasParticipantFilter &&
        participantFilter != null &&
        _listsEqual(participantFilter!, participantIds)) {
      return;
    }

    participantFilter = participantIds;
    hasParticipantFilter = true;

    if (showCompanies) {
      switchTab(false);
    } else {
      updateTableData();
      _notifyStateChanged();
    }
  }

  bool _listsEqual(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!list2.contains(list1[i])) return false;
    }
    return true;
  }

  void clearParticipantFilter() {
    participantFilter = null;
    hasParticipantFilter = false;
    _notifyStateChanged();
  }

  void switchTab(bool isCompanies) {
    showCompanies = isCompanies;
    selectedTabIndex = isCompanies ? 0 : 1;
    currentPage = 1;
    searchQuery = '';
    sortColumnKey = null;
    sortAscending = true;
    isLoading = true;
    clearRegularFilters();
    _notifyStateChanged();
    loadData();
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    currentPage = 1;
    _notifyStateChanged();
  }

  void onPageChanged(int page) {
    currentPage = page;
    _notifyStateChanged();
  }

  void onSort(String columnKey, bool ascending) {
    sortColumnKey = columnKey;
    sortAscending = ascending;

    if (showCompanies) {
      companyTableData.sort((a, b) {
        var aValue = a[columnKey];
        var bValue = b[columnKey];

        if (aValue == null && bValue == null) return 0;
        if (aValue == null) return ascending ? -1 : 1;
        if (bValue == null) return ascending ? 1 : -1;

        String aStr = aValue.toString().toLowerCase();
        String bStr = bValue.toString().toLowerCase();

        int result = aStr.compareTo(bStr);
        return ascending ? result : -result;
      });
    } else {
      peopleTableData.sort((a, b) {
        var aValue = a[columnKey];
        var bValue = b[columnKey];

        if (aValue == null && bValue == null) return 0;
        if (aValue == null) return ascending ? -1 : 1;
        if (bValue == null) return ascending ? 1 : -1;

        if (columnKey == 'status') {
          if (aValue is Map<String, dynamic> &&
              bValue is Map<String, dynamic>) {
            aValue = aValue['label'] ?? '';
            bValue = bValue['label'] ?? '';
          }
        }

        String aStr = aValue.toString().toLowerCase();
        String bStr = bValue.toString().toLowerCase();

        int result = aStr.compareTo(bStr);
        return ascending ? result : -result;
      });
    }
    _notifyStateChanged();
  }

  Future<bool> handleDeletePerson(int personId) async {
    final success = await PeopleApiService.deletePerson(personId);
    if (success) {
      await loadPeople();
    }
    return success;
  }

  PersonData? getPersonById(String personId) {
    for (var person in _people) {
      if (person.id.toString() == personId) {
        return person;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> getFilteredData() {
    List<Map<String, dynamic>> dataToFilter = showCompanies
        ? companyTableData
        : peopleTableData;

    if (!showCompanies && hasParticipantFilter && participantFilter != null) {
      dataToFilter = dataToFilter.where((person) {
        final personId = person['id'];
        if (personId is int) {
          return participantFilter!.contains(personId);
        } else if (personId is String) {
          try {
            final id = int.parse(personId);
            return participantFilter!.contains(id);
          } catch (e) {
            return false;
          }
        }
        return false;
      }).toList();
    }

    if (searchQuery.isEmpty) {
      return dataToFilter;
    }

    if (showCompanies) {
      return dataToFilter.where((company) {
        final accountName = company['accountName'].toString().toLowerCase();
        final aeNam = company['aeNam'].toString().toLowerCase();
        final segment = company['segment'].toString().toLowerCase();
        final focusedOrAssigned = company['focusedOrAssigned']
            .toString()
            .toLowerCase();
        final accountStatus = company['accountStatus'].toString().toLowerCase();
        final pipelineStatus = company['pipelineStatus']
            .toString()
            .toLowerCase();
        final accountCategory = company['accountCategory']
            .toString()
            .toLowerCase();
        final query = searchQuery.toLowerCase();

        return accountName.contains(query) ||
            aeNam.contains(query) ||
            segment.contains(query) ||
            focusedOrAssigned.contains(query) ||
            accountStatus.contains(query) ||
            pipelineStatus.contains(query) ||
            accountCategory.contains(query);
      }).toList();
    } else {
      return dataToFilter.where((person) {
        final name = person['name'].toString().toLowerCase();
        final designation = person['designation'].toString().toLowerCase();
        final organization = person['organization'].toString().toLowerCase();
        final email = person['email'].toString().toLowerCase();
        final query = searchQuery.toLowerCase();

        return name.contains(query) ||
            designation.contains(query) ||
            organization.contains(query) ||
            email.contains(query);
      }).toList();
    }
  }

  Future<void> fetchFilteredPeople(
    String field,
    String value,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      isLoading = true;
      errorMessage = '';
      _notifyStateChanged();

      String startDateStr = startDate != null
          ? "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}T${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}:${startDate.second.toString().padLeft(2, '0')}.${startDate.millisecond.toString().padLeft(3, '0')}Z"
          : DateTime.now().toIso8601String();

      String endDateStr = endDate != null
          ? "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}T${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}:${endDate.second.toString().padLeft(2, '0')}.${endDate.millisecond.toString().padLeft(3, '0')}Z"
          : DateTime.now().toIso8601String();

      List<PersonData> filteredPeople =
          await PeopleApiService.fetchFilteredPeople(
            field: field,
            value: value,
            clientId: clientId!,
            startDate: startDateStr,
            endDate: endDateStr,
          );

      _people = filteredPeople;
      peopleTableData = filteredPeople
          .map((person) => PeopleHelper.mapPersonForTable(person))
          .toList();

      currentFilter = field;
      currentFilterValue = value;
      hasActiveFilter = true;
      isLoading = false;
      _notifyStateChanged();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      _notifyStateChanged();
    }
  }

  Future<void> handlePersonFilterApplication(
    String field,
    String value,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    await fetchFilteredPeople(field, value, startDate, endDate);
  }

  String getFilterDisplayName(String? filterField) {
    if (filterField == null) return '';

    switch (filterField.toLowerCase()) {
      case 'accountname':
        return 'Company';
      case 'aenam':
        return 'Account Executive';
      case 'segment':
        return 'City';
      case 'focusedorassigned':
        return 'Focused/Assigned';
      case 'accountstatus':
        return 'Account Status';
      case 'pipelinestatus':
        return 'Pipeline Status';
      case 'accountcategory':
        return 'Account Category';
      default:
        return filterField.substring(0, 1).toUpperCase() +
            filterField.substring(1);
    }
  }

  void onRowTap(Map<String, dynamic> rowData, context) {
    log('Row tapped: $rowData');
    if (showCompanies) {
      goToNextScreenPush(
        context,
        UnifiedPersonScreen(
          clientId: clientId!,
          companyData: companyData!,
          rowData: rowData,
        ),
      );
    } else {
      if (selectedPersonTabIndex == 0) {
        goToNextScreenPush(context, PersonDetailsScreen(personData: rowData));
      }
    }
  }

  void onSelectionChanged(List<int> selectedIndices) {
    _selectedIndices = selectedIndices;
    print('Selected rows: $selectedIndices');
  }

  Future<void> exportSelectedPeopleToExcel(BuildContext context) async {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one person to export"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      List<Map<String, dynamic>> selectedData = [];
      List<String> columnHeaders;
      List<String> columnKeys;

      if (selectedPersonTabIndex == 0) {
        columnHeaders = ExcelExportService.getPeopleColumnHeaders();
        columnKeys = ExcelExportService.getPeopleColumnKeys();

        for (int index in _selectedIndices) {
          if (index < peopleTableData.length) {
            selectedData.add(peopleTableData[index]);
          }
        }
      } else {
        columnHeaders = ExcelExportService.getLimitedPeopleColumnHeaders();
        columnKeys = ExcelExportService.getLimitedPeopleColumnKeys();

        for (int index in _selectedIndices) {
          if (index < peopleTableData.length) {
            Map<String, dynamic> limitedData = {};
            var fullData = peopleTableData[index];

            for (String key in columnKeys) {
              limitedData[key] = fullData[key];
            }
            selectedData.add(limitedData);
          }
        }
      }

      if (selectedData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No valid data found for selected rows"),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      String timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      String fileName = 'people_export_$timestamp.xlsx';

      bool success = await ExcelExportService.exportPeopleToExcel(
        selectedData: selectedData,
        columnHeaders: columnHeaders,
        columnKeys: columnKeys,
        fileName: fileName,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Excel file exported successfully to Downloads folder",
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to export Excel file"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error occurred while exporting: $e"),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<PersonData> get people => _people;

  List<Company> get companiesList => companies;

  List<Company> get filteredCompaniesList => filteredCompanies;

  String? get activeFilterField => currentFilter;
  String? get activeFilterValue => currentFilterValue;

  bool get isFilterActive => hasActiveFilter;
}
