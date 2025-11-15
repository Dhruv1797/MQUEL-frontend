import 'package:flutter/material.dart';
import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/widgets/add_interaction_dialog.dart';
import 'package:a2y_app/widgets/edit_interaction_details.dart';
import 'package:a2y_app/services/interaction_api_services.dart';
import 'package:a2y_app/widgets/preview_dialog.dart';
import 'package:a2y_app/model/interaction_history_model.dart';
import 'package:a2y_app/widgets/generic_table.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:a2y_app/provider/user_provider.dart';

class PersonDetailsController extends ChangeNotifier {
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  String _sortColumnKey = '';
  bool _sortAscending = true;
  bool _hasActiveFilter = false;
  List<int> _selectedIndices = [];
  List<InteractionHistory> _interactionHistory = [];
  List<Map<String, dynamic>> _tableData = [];

  Map<String, dynamic> _personData = {};

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get sortColumnKey => _sortColumnKey;
  bool get sortAscending => _sortAscending;
  bool get hasActiveFilter => _hasActiveFilter;
  List<int> get selectedIndices => _selectedIndices;
  List<InteractionHistory> get interactionHistory => _interactionHistory;
  List<Map<String, dynamic>> get tableData => _tableData;
  Map<String, dynamic> get personData => _personData;

  void initialize(Map<String, dynamic> personData) {
    _personData = personData;
    loadInteractionHistory();
  }

  Future<void> loadInteractionHistory() async {
    _setLoading(true);
    _setErrorMessage('');

    try {
      final name = _personData['name'] ?? '';
      final organization = _personData['organization'] ?? '';
      final clientId = _personData['clientId'] ?? '';

      final history = await InteractionApiServices.getInteractionHistory(
        participantName: name,
        organization: organization,
        clientId: int.parse(clientId.toString()),
      );

      _interactionHistory = history;
      _tableData = history.map((h) => h.toTableFormat()).toList();
      _totalPages = (_tableData.length / 10).ceil();
      _setLoading(false);
    } catch (e) {
      _setErrorMessage('Failed to load interaction history: ${e.toString()}');
      _setLoading(false);
    }
  }

  List<TableColumn> getColumns(
    BuildContext context,
    Map<String, dynamic> personData,
  ) => [
    TableColumn(
      key: 'participantName',
      title: 'Name',

      width: MediaQuery.of(context).size.width * 0.2,
      hasCheckbox: true,
      sortable: true,
    ),
    TableColumn(
      key: 'organization',
      title: 'Organization',

      width: MediaQuery.of(context).size.width * 0.14,
      sortable: true,
    ),
    TableColumn(
      key: 'designation',
      title: 'Designation',

      width: MediaQuery.of(context).size.width * 0.14,
      sortable: true,
    ),
    TableColumn(
      key: 'eventName',
      title: 'Event Name',
      width: MediaQuery.of(context).size.width * 0.14,

      sortable: true,
    ),
    TableColumn(
      key: 'eventDate',
      title: 'Event Date',
      width: MediaQuery.of(context).size.width * 0.14,

      sortable: true,
    ),
    TableColumn(
      key: 'meetingDone',
      title: 'Meeting Done',
      width: MediaQuery.of(context).size.width * 0.14,

      customBuilder: (value, isHeader, rowData) {
        return _buildMeetingDoneColumn(value, isHeader);
      },
    ),
    TableColumn(
      key: 'actions',
      title: 'Actions',
      width: MediaQuery.of(context).size.width * 0.12,

      customBuilder: (value, isHeader, rowData) {
        return _buildActionsColumn(
          context,
          value,
          isHeader,
          rowData,
          personData,
        );
      },
    ),
  ];

  Widget _buildNameColumn(dynamic value, bool isHeader) {
    if (isHeader) {
      return Text(
        'Name',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final name = value?.toString() ?? 'No Data';
    return Text(
      name,
      style: TextStyle(
        fontFamily: globatInterFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: name == 'No Data' ? Colors.grey : Colors.black,
      ),
    );
  }

  Widget _buildOrganizationColumn(dynamic value, bool isHeader) {
    if (isHeader) {
      return Text(
        'Organization',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final organization = value?.toString() ?? 'No Data';
    return Text(
      organization,
      style: TextStyle(
        fontFamily: globatInterFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: organization == 'No Data' ? Colors.grey : Colors.black,
      ),
    );
  }

  Widget _buildDesignationColumn(dynamic value, bool isHeader) {
    if (isHeader) {
      return Text(
        'Designation',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final designation = value?.toString() ?? 'No Data';
    return Text(
      designation,
      style: TextStyle(
        fontFamily: globatInterFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: designation == 'No Data' ? Colors.grey : Colors.black,
      ),
    );
  }

  Widget _buildEventNameColumn(dynamic value, bool isHeader) {
    if (isHeader) {
      return Text(
        'Event Name',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final eventName = value?.toString() ?? 'No Data';
    return Text(
      eventName,
      style: TextStyle(
        fontFamily: globatInterFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: eventName == 'No Data' ? Colors.grey : Colors.black,
      ),
    );
  }

  Widget _buildEventDateColumn(dynamic value, bool isHeader) {
    if (isHeader) {
      return Text(
        'Event Date',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final eventDate = value?.toString() ?? 'No Data';
    return Text(
      eventDate,
      style: TextStyle(
        fontFamily: globatInterFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: eventDate == 'No Data' ? Colors.grey : Colors.black,
      ),
    );
  }

  Widget _buildMeetingDoneColumn(dynamic value, bool isHeader) {
    if (isHeader) {
      return Text(
        'Meeting Done',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }

    final meetingDone = value as bool? ?? false;
    final status = meetingDone ? 'Completed' : 'Incomplete';
    Color statusColor;
    Color bgColor;

    if (meetingDone) {
      statusColor = const Color.fromRGBO(23, 178, 106, 1);
      bgColor = const Color.fromRGBO(212, 255, 235, 1);
    } else {
      statusColor = const Color.fromRGBO(178, 59, 23, 1);
      bgColor = const Color.fromRGBO(255, 212, 212, 1);
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
                status,
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
    Map<String, dynamic>? personData,
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
                      handleEditAction(context, rowData!, personData!);
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
                handleForwardAction(context, rowData!);
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
    Map<String, dynamic> personData,
  ) async {
    print('Edit action for: $rowData');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditDetailsDialog(rowData: rowData, personData: personData);
      },
    );

    if (result == true) {
      await loadInteractionHistory();
      print('Details updated successfully');
    }
  }

  void handleForwardAction(BuildContext context, Map<String, dynamic> rowData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PreviewDialog(rowData: rowData);
      },
    );
  }

  Future<void> showAddInteractionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddInteractionDialog(personData: _personData),
    );

    if (result == true) {
      await loadInteractionHistory();
    }
  }

  void onSearchChanged(String query) {}

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
    notifyListeners();
  }

  void onFilterPressed() {}

  void onRefreshPressed() {
    loadInteractionHistory();
  }

  void onRetryPressed() {
    loadInteractionHistory();
  }

  void onClearFilters() {
    _hasActiveFilter = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
