import 'package:flutter/material.dart';
import 'package:a2y_app/widgets/generic_table.dart';
import 'package:a2y_app/widgets/unfied_screen_widgets.dart';

class UnifiedScreenTableColumns {
  final BuildContext context;
  final UnifiedScreenWidgetBuilders widgetBuilders;

  UnifiedScreenTableColumns(this.context, {required this.widgetBuilders});

  List<TableColumn> get peopleColumns => [
    TableColumn(
      key: 'name',
      title: 'Name',
      hasCheckbox: true,
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.16,
    ),
    TableColumn(
      key: 'designation',
      title: 'Designation',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.16,
    ),
    TableColumn(
      key: 'city',
      title: 'City',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.07,
    ),
    TableColumn(
      key: 'organization',
      title: 'Organization',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.1,
    ),
    TableColumn(
      key: 'email',
      title: 'Email',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.16,
    ),
    TableColumn(
      key: 'mobile',
      title: 'Mobile',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.08,
    ),
    TableColumn(
      key: 'attended',
      title: 'Attended',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.08,
    ),
    TableColumn(
      key: 'assignedUnassigned',
      title: 'Status',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.08,
    ),
    TableColumn(
      key: 'eventName',
      title: 'Event',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.08,
    ),
    TableColumn(
      key: 'isGoodLead',
      title: 'Good Lead',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.11,
      customBuilder: (value, isHeader, rowData) =>
          widgetBuilders.buildGoodLeadCell(isHeader, value),
    ),

    TableColumn(
      key: 'actions',
      title: 'Actions',
      sortable: false,
      textAlign: TextAlign.center,
      customBuilder: (value, isHeader, rowData) =>
          widgetBuilders.buildPeopleActionsCell(isHeader, rowData),
      width: MediaQuery.of(context).size.width * 0.12,
    ),
  ];

  List<TableColumn> get limitedPeopleColumns => [
    TableColumn(
      key: 'name',
      title: 'Name',
      hasCheckbox: true,
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.3,
    ),
    TableColumn(
      key: 'company',
      title: 'Company',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.3,
    ),

    TableColumn(
      key: 'designation',
      title: 'Designation',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.26,
    ),
    TableColumn(
      key: 'actions',
      title: 'Actions',
      sortable: false,
      textAlign: TextAlign.center,
      customBuilder: (value, isHeader, rowData) =>
          widgetBuilders.buildPeopleActionsCell(isHeader, rowData),
      width: MediaQuery.of(context).size.width * 0.12,
    ),
  ];

  List<TableColumn> get companyColumns => [
    TableColumn(
      key: 'accountName',
      title: 'Account Name',
      hasCheckbox: true,
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.3,
    ),
    TableColumn(
      key: 'aeNam',
      title: 'Account Executive',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.12,
    ),
    TableColumn(
      key: 'segment',
      title: 'Segment',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.08,
    ),
    TableColumn(
      key: 'focusedOrAssigned',
      title: 'Focused/Assigned',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.12,
    ),
    TableColumn(
      key: 'accountStatus',
      title: 'Account Status',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.1,
    ),
    TableColumn(
      key: 'pipelineStatus',
      title: 'Pipeline Status',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.07,
    ),
    TableColumn(
      key: 'accountCategory',
      title: 'Account Category',
      sortable: true,
      textAlign: TextAlign.left,
      width: MediaQuery.of(context).size.width * 0.07,
    ),
    TableColumn(
      key: 'actions',
      title: 'Actions',
      sortable: false,
      textAlign: TextAlign.left,
      customBuilder: (value, isHeader, rowData) =>
          widgetBuilders.buildCompanyActionsCell(isHeader, rowData),
      width: MediaQuery.of(context).size.width * 0.12,
    ),
  ];

  List<TableColumn> getColumns(bool showCompanies, {int tabIndex = 0}) {
    if (showCompanies) {
      return companyColumns;
    } else {
      return tabIndex == 0 ? peopleColumns : limitedPeopleColumns;
    }
  }

  TableColumn? getColumnByKey(
    String key,
    bool showCompanies, {
    int tabIndex = 0,
  }) {
    final columns = getColumns(showCompanies, tabIndex: tabIndex);
    try {
      return columns.firstWhere((column) => column.key == key);
    } catch (e) {
      return null;
    }
  }

  List<TableColumn> getSortableColumns(bool showCompanies, {int tabIndex = 0}) {
    return getColumns(
      showCompanies,
      tabIndex: tabIndex,
    ).where((column) => column.sortable).toList();
  }

  List<TableColumn> getCheckboxColumns(bool showCompanies, {int tabIndex = 0}) {
    return getColumns(
      showCompanies,
      tabIndex: tabIndex,
    ).where((column) => column.hasCheckbox).toList();
  }

  List<TableColumn> getCustomBuilderColumns(
    bool showCompanies, {
    int tabIndex = 0,
  }) {
    return getColumns(
      showCompanies,
      tabIndex: tabIndex,
    ).where((column) => column.customBuilder != null).toList();
  }
}
