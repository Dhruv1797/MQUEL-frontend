import 'package:flutter/material.dart';
import 'package:a2y_app/model/companyModel.dart';
import 'package:a2y_app/services/company_api_service.dart';

class CompanyDashboardController extends ChangeNotifier {
  String _searchQuery = '';
  bool _hasActiveFilter = false;
  bool _isLoading = true;
  String _errorMessage = '';
  List<CompanyModel> _companies = [];
  List<CompanyModel> _filteredCompanies = [];

  final TextEditingController _searchController = TextEditingController();

  String get searchQuery => _searchQuery;
  bool get hasActiveFilter => _hasActiveFilter;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<CompanyModel> get companies => _companies;
  List<CompanyModel> get filteredCompanies => _filteredCompanies;
  TextEditingController get searchController => _searchController;

  CompanyDashboardController() {
    _initializeController();
  }

  void _initializeController() {
    loadCompanies();
  }

  Future<void> loadCompanies() async {
    _setLoading(true);
    _setErrorMessage('');

    try {
      final fetchedCompanies = await CompanyService.getCompanies();
      _setCompanies(fetchedCompanies);
      _filterCompanies();
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void onCompanyAdded() {
    loadCompanies();
  }

  void onCompanyEdited() {
    loadCompanies();
  }

  Future<bool> editCompanyCooldown({
    required String clientId,
    required String cooldownPeriod1,
    required String cooldownPeriod2,
    required String cooldownPeriod3,
  }) async {
    try {
      final success = await CompanyService.editCompanyCooldown(
        clientId: clientId,
        cooldownPeriod1: cooldownPeriod1,
        cooldownPeriod2: cooldownPeriod2,
        cooldownPeriod3: cooldownPeriod3,
      );

      if (success) {
        await loadCompanies();
      }

      return success;
    } catch (e) {
      _setErrorMessage(e.toString());
      return false;
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterCompanies();
    notifyListeners();
  }

  void _filterCompanies() {
    if (_searchQuery.isEmpty) {
      _filteredCompanies = _companies;
    } else {
      _filteredCompanies = _companies.where((company) {
        return company.displayOrgName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            company.clientId.toString().contains(_searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  void toggleFilter() {
    _hasActiveFilter = !_hasActiveFilter;
    notifyListeners();
  }

  void clearSearchAndRefresh() {
    _searchQuery = '';
    _searchController.clear();
    _filterCompanies();
    notifyListeners();
  }

  void handleMenuAction(
    String action,
    CompanyModel company,
    BuildContext context,
  ) {
    switch (action) {
      case 'Edit':
        loadCompanies();
        break;
      case 'Delete':
        loadCompanies();
        break;
    }
  }

  Future<void> refreshCompanies() async {
    await loadCompanies();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
