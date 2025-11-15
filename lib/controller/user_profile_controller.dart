import 'dart:convert';
import 'dart:developer';
import 'package:a2y_app/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/model/user_model.dart';
import 'package:a2y_app/widgets/generic_table.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:a2y_app/provider/user_provider.dart';
import 'package:http/http.dart' as http;

class UserProfileController extends ChangeNotifier {
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  String _sortColumnKey = '';
  bool _sortAscending = true;
  bool _hasActiveFilter = false;
  List<int> _selectedIndices = [];
  List<UserModel> _invitedUsers = [];
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _filteredData = [];
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get sortColumnKey => _sortColumnKey;
  bool get sortAscending => _sortAscending;
  bool get hasActiveFilter => _hasActiveFilter;
  List<int> get selectedIndices => _selectedIndices;
  List<UserModel> get invitedUsers => _invitedUsers;
  List<Map<String, dynamic>> get tableData =>
      _filteredData.isEmpty && _searchQuery.isEmpty
      ? _tableData
      : _filteredData;
  String get searchQuery => _searchQuery;

  void initialize(int adminId) {
    loadInvitedUsersWithAdminId(adminId);
  }

  Future<void> loadInvitedUsersWithAdminId(int adminId) async {
    log("user admin id $adminId");

    adminId = 2;
    _setLoading(true);
    _setErrorMessage('');

    try {
      final headers = await ApiConstants.getAuthHeaders();
      headers['accept'] = '*/*';

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseApiPath}/api/auth/getInvitedUsers?adminId=$adminId',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _invitedUsers = jsonData
            .map((json) => UserModel.fromJson(json))
            .toList();
        _tableData = _invitedUsers
            .map((user) => _userToTableFormat(user))
            .toList();
        _totalPages = (_tableData.length / 10).ceil();

        if (_searchQuery.isNotEmpty) {
          _applySearch(_searchQuery);
        }

        _setLoading(false);
      } else {
        throw Exception('Failed to load invited users: ${response.statusCode}');
      }
    } catch (e) {
      _setErrorMessage('Failed to load invited users: ${e.toString()}');
      _setLoading(false);
    }
  }

  Map<String, dynamic> _userToTableFormat(UserModel user) {
    return {
      'id': user.id,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'role': user.role,
      'isReset': user.isReset,
    };
  }

  List<TableColumn> getColumns(BuildContext context) => [
    TableColumn(
      key: 'firstName',
      title: 'First Name',
      width: MediaQuery.of(context).size.width * 0.3,
      hasCheckbox: true,
      sortable: true,
      customBuilder: (value, isHeader, rowData) {
        return _buildFirstNameColumn(value, isHeader);
      },
    ),
    TableColumn(
      key: 'email',
      title: 'Email',
      width: MediaQuery.of(context).size.width * 0.3,
      sortable: true,
      customBuilder: (value, isHeader, rowData) {
        return _buildEmailColumn(value, isHeader);
      },
    ),
    TableColumn(
      key: 'role',
      title: 'Role',
      width: MediaQuery.of(context).size.width * 0.3,
      sortable: true,
      customBuilder: (value, isHeader, rowData) {
        return _buildRoleColumn(value, isHeader);
      },
    ),
    TableColumn(
      key: 'actions',
      title: 'Actions',
      width: MediaQuery.of(context).size.width * 0.12,
      customBuilder: (value, isHeader, rowData) {
        return _buildActionsColumn(context, value, isHeader, rowData);
      },
    ),
  ];

  Widget _buildFirstNameColumn(dynamic value, bool isHeader) {
    if (isHeader) {
      return Text(
        'First Name',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final firstName = value?.toString() ?? 'No Data';
    return Text(
      firstName,
      style: TextStyle(
        fontFamily: globatInterFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: firstName == 'No Data' ? Colors.grey : Colors.black,
      ),
    );
  }

  Widget _buildEmailColumn(dynamic value, bool isHeader) {
    if (isHeader) {
      return Text(
        'Email',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final email = value?.toString() ?? 'No Data';
    return Text(
      email,
      style: TextStyle(
        fontFamily: globatInterFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: email == 'No Data' ? Colors.grey : Colors.black,
      ),
    );
  }

  Widget _buildRoleColumn(dynamic value, bool isHeader) {
    if (isHeader) {
      return Text(
        'Role',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final role = value?.toString() ?? 'No Data';
    Color statusColor;
    Color bgColor;

    switch (role.toUpperCase()) {
      case 'ADMIN':
        statusColor = const Color.fromRGBO(23, 178, 106, 1);
        bgColor = const Color.fromRGBO(212, 255, 235, 1);
        break;
      case 'USER':
        statusColor = const Color.fromRGBO(178, 59, 23, 1);
        bgColor = const Color.fromRGBO(255, 212, 212, 1);
        break;
      default:
        statusColor = const Color.fromRGBO(107, 114, 128, 1);
        bgColor = const Color.fromRGBO(243, 244, 246, 1);
        break;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Color.fromRGBO(217, 217, 217, 1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              SizedBox(width: 6),
              Text(
                role,
                style: TextStyle(
                  fontFamily: globatInterFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
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
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isUserRole = userProvider.role == 'USER';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 24,
              onPressed: isUserRole
                  ? null
                  : () {
                      handleEditAction(context, rowData!);
                    },
              icon: SvgPicture.asset(
                "assets/images/profile_edit.svg",
                colorFilter: isUserRole
                    ? const ColorFilter.mode(Colors.grey, BlendMode.srcIn)
                    : null,
              ),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 8),
            IconButton(
              iconSize: 24,
              onPressed: () {
                handleViewAction(context, rowData!);
              },
              icon: SvgPicture.asset("assets/images/profile_arrow.svg"),
              padding: EdgeInsets.zero,
            ),
          ],
        );
      },
    );
  }

  Future<void> handleEditAction(
    BuildContext context,
    Map<String, dynamic> rowData,
  ) async {
    print('Edit action for user: $rowData');
  }

  void handleViewAction(BuildContext context, Map<String, dynamic> rowData) {
    print('View action for user: $rowData');
  }

  void onSearchChanged(String query) {
    _searchQuery = query.trim();
    _currentPage = 1;

    if (_searchQuery.isEmpty) {
      _filteredData = [];
      _totalPages = (_tableData.length / 10).ceil();
    } else {
      _applySearch(_searchQuery);
    }

    notifyListeners();
  }

  void _applySearch(String query) {
    if (query.isEmpty) {
      _filteredData = [];
      _totalPages = (_tableData.length / 10).ceil();
      return;
    }

    final lowercaseQuery = query.toLowerCase();

    _filteredData = _tableData.where((user) {
      final firstName = (user['firstName']?.toString() ?? '').toLowerCase();
      final lastName = (user['lastName']?.toString() ?? '').toLowerCase();
      final email = (user['email']?.toString() ?? '').toLowerCase();
      final role = (user['role']?.toString() ?? '').toLowerCase();
      final fullName = '$firstName $lastName';

      return firstName.contains(lowercaseQuery) ||
          lastName.contains(lowercaseQuery) ||
          fullName.contains(lowercaseQuery) ||
          email.contains(lowercaseQuery) ||
          role.contains(lowercaseQuery);
    }).toList();

    _totalPages = (_filteredData.length / 10).ceil();
    if (_totalPages == 0) _totalPages = 1;
  }

  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void onRowTap(Map<String, dynamic> rowData) {
    print('Row tapped: $rowData');
  }

  void onSelectionChanged(List<int> indices) {
    _selectedIndices = indices;
    notifyListeners();
  }

  void onSort(String columnKey, bool ascending) {
    _sortColumnKey = columnKey;
    _sortAscending = ascending;

    final dataToSort = _filteredData.isEmpty && _searchQuery.isEmpty
        ? _tableData
        : _filteredData;

    dataToSort.sort((a, b) {
      final aValue = a[columnKey]?.toString() ?? '';
      final bValue = b[columnKey]?.toString() ?? '';

      if (ascending) {
        return aValue.compareTo(bValue);
      } else {
        return bValue.compareTo(aValue);
      }
    });

    if (_filteredData.isNotEmpty || _searchQuery.isNotEmpty) {
      _filteredData = dataToSort;
    } else {
      _tableData = dataToSort;
    }

    notifyListeners();
  }

  void onFilterPressed() {}

  void onRefreshPressed(int adminId) {
    loadInvitedUsersWithAdminId(adminId);
  }

  void onRetryPressed(int adminId) {
    loadInvitedUsersWithAdminId(adminId);
  }

  void onClearFilters() {
    _hasActiveFilter = false;
    _searchQuery = '';
    _filteredData = [];
    _currentPage = 1;
    _totalPages = (_tableData.length / 10).ceil();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredData = [];
    _currentPage = 1;
    _totalPages = (_tableData.length / 10).ceil();
    notifyListeners();
  }

  bool get hasSearchFilter => _searchQuery.isNotEmpty;

  int get totalRecords => _filteredData.isEmpty && _searchQuery.isEmpty
      ? _tableData.length
      : _filteredData.length;
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
