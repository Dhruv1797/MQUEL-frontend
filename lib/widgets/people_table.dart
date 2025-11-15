import 'package:a2y_app/constants/global_var.dart';
import 'package:flutter/material.dart';

class TableColumn {
  final String key;
  final String title;
  final int flex;
  final bool hasCheckbox;
  final bool isStatus;
  final bool isAction;

  const TableColumn({
    required this.key,
    required this.title,
    required this.flex,
    this.hasCheckbox = false,
    this.isStatus = false,
    this.isAction = false,
  });
}

class CustomPeopleTable extends StatefulWidget {
  final List<Map<String, dynamic>> peoples;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final double tableHeight;
  final void Function(int page) onPageChanged;
  final void Function(int personId, String personName) onDeletePressed;
  final void Function(int personId, String personName)? onEditPressed;
  final List<TableColumn> columns;
  final bool showSelectAll;
  final void Function(List<String> selectedIds)? onSelectionChanged;

  const CustomPeopleTable({
    super.key,
    required this.peoples,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onDeletePressed,
    this.onEditPressed,
    this.itemsPerPage = 10,
    this.tableHeight = 300,
    this.columns = const [
      TableColumn(key: 'name', title: 'Name', flex: 3, hasCheckbox: true),
      TableColumn(key: 'designation', title: 'Designation', flex: 2),
      TableColumn(key: 'organization', title: 'Organization', flex: 2),
      TableColumn(key: 'email', title: 'Email', flex: 3),
      TableColumn(
        key: 'status',
        title: 'Assigned/Unassigned',
        flex: 2,
        isStatus: true,
      ),
      TableColumn(key: 'mobile', title: 'Mobile', flex: 2),
      TableColumn(key: 'actions', title: 'Actions', flex: 1, isAction: true),
    ],
    this.showSelectAll = true,
    this.onSelectionChanged,
  });

  @override
  State<CustomPeopleTable> createState() => _CustomPeopleTableState();
}

class _CustomPeopleTableState extends State<CustomPeopleTable> {
  bool _selectAll = false;
  Set<String> _selectedIds = {};

  void _handleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        _selectedIds = widget.peoples
            .map((person) => person['id'].toString())
            .toSet();
      } else {
        _selectedIds.clear();
      }
    });
    widget.onSelectionChanged?.call(_selectedIds.toList());
  }

  void _handleItemSelection(String id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
      _selectAll = _selectedIds.length == widget.peoples.length;
    });
    widget.onSelectionChanged?.call(_selectedIds.toList());
  }

  Widget _buildHeaderCell(TableColumn column) {
    if (column.hasCheckbox && widget.showSelectAll) {
      return Expanded(
        flex: column.flex,
        child: Row(
          children: [
            Checkbox(
              value: _selectAll,
              onChanged: _handleSelectAll,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(
                width: 1.5,
                color: Color.fromRGBO(204, 204, 204, 1),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              checkColor: Colors.white,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                return states.contains(WidgetState.selected)
                    ? Colors.black
                    : Colors.transparent;
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                column.title,
                style: const TextStyle(
                  fontFamily: globatInterFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(130, 130, 130, 1),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Expanded(
      flex: column.flex,
      child: Text(
        column.title,
        style: const TextStyle(
          fontFamily: globatInterFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(130, 130, 130, 1),
        ),
      ),
    );
  }

  Widget _buildDataCell(TableColumn column, Map<String, dynamic> data) {
    if (column.hasCheckbox) {
      final personId = data['id'].toString();
      final isSelected = _selectedIds.contains(personId);

      return Expanded(
        flex: column.flex,
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) => _handleItemSelection(personId, value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(
                width: 1.5,
                color: Color.fromRGBO(204, 204, 204, 1),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              checkColor: Colors.white,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                return states.contains(WidgetState.selected)
                    ? Colors.black
                    : Colors.transparent;
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                data[column.key]?.toString() ?? 'N/A',
                style: const TextStyle(
                  fontFamily: globatInterFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(51, 51, 51, 1),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (column.isStatus) {
      return _buildStatusCell(data[column.key], column.flex);
    }

    if (column.isAction) {
      return _buildActionButtons(data, column.flex);
    }

    return Expanded(
      flex: column.flex,
      child: Text(
        data[column.key]?.toString() ?? 'N/A',
        style: const TextStyle(
          fontFamily: globatInterFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color.fromRGBO(51, 51, 51, 1),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusCell(dynamic statusData, int flex) {
    String label;
    Color containerColor;
    Color textColor;

    if (statusData is Map<String, dynamic>) {
      label = statusData['label'] ?? 'Unknown';
    } else {
      label = statusData?.toString() ?? 'Unknown';
    }

    if (label.toLowerCase().contains('assigned') &&
        !label.toLowerCase().contains('unassigned')) {
      containerColor = const Color.fromRGBO(220, 252, 231, 1);
      textColor = const Color.fromRGBO(22, 163, 74, 1);
    } else if (label.toLowerCase().contains('unassigned')) {
      containerColor = const Color.fromRGBO(254, 226, 226, 1);
      textColor = const Color.fromRGBO(220, 38, 38, 1);
    } else {
      containerColor = const Color.fromRGBO(255, 247, 237, 1);
      textColor = const Color.fromRGBO(194, 120, 3, 1);
    }

    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: globatInterFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> data, int flex) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(248, 248, 248, 1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color.fromRGBO(229, 229, 229, 1),
                width: 1,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                try {
                  final personIdString = data['id'];
                  final personId = int.parse(personIdString.toString());
                  final personName = data['name']?.toString() ?? 'Unknown';
                  widget.onDeletePressed(personId, personName);
                } catch (e) {
                  print("Error parsing person ID: $e");
                }
              },
              icon: const Icon(
                Icons.delete_outline,
                size: 16,
                color: Color.fromRGBO(107, 114, 128, 1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(248, 248, 248, 1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color.fromRGBO(229, 229, 229, 1),
                width: 1,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (widget.onEditPressed != null) {
                  try {
                    final personIdString = data['id'];
                    final personId = int.parse(personIdString.toString());
                    final personName = data['name']?.toString() ?? 'Unknown';
                    widget.onEditPressed!(personId, personName);
                  } catch (e) {
                    print("Error parsing person ID: $e");
                  }
                }
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color.fromRGBO(107, 114, 128, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required bool isHeader,
    required Map<String, dynamic>? data,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isHeader
                ? const Color.fromRGBO(229, 229, 229, 1)
                : const Color.fromRGBO(243, 244, 246, 1),
            width: 1,
          ),
        ),
        color: isHeader ? const Color.fromRGBO(249, 250, 251, 1) : Colors.white,
      ),
      child: Row(
        children: widget.columns.map((column) {
          return isHeader
              ? _buildHeaderCell(column)
              : _buildDataCell(column, data!);
        }).toList(),
      ),
    );
  }

  Widget _buildPagination() {
    List<Widget> pages = [];
    int maxVisiblePages = 5;
    int startPage = (widget.currentPage - 2).clamp(1, widget.totalPages);
    int endPage = (widget.currentPage + 2).clamp(1, widget.totalPages);

    if (endPage - startPage < maxVisiblePages - 1) {
      if (startPage == 1) {
        endPage = (startPage + maxVisiblePages - 1).clamp(1, widget.totalPages);
      } else {
        startPage = (endPage - maxVisiblePages + 1).clamp(1, widget.totalPages);
      }
    }

    if (startPage > 1) {
      pages.add(_buildPageButton(1));
      if (startPage > 2) {
        pages.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text("..."),
          ),
        );
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pages.add(_buildPageButton(i));
    }

    if (endPage < widget.totalPages) {
      if (endPage < widget.totalPages - 1) {
        pages.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text("..."),
          ),
        );
      }
      pages.add(_buildPageButton(widget.totalPages));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromRGBO(107, 114, 128, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: Color.fromRGBO(229, 229, 229, 1),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: widget.currentPage > 1
                ? () => widget.onPageChanged(widget.currentPage - 1)
                : null,
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            label: const Text("Previous"),
          ),

          Row(children: pages),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromRGBO(107, 114, 128, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: Color.fromRGBO(229, 229, 229, 1),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: widget.currentPage < widget.totalPages
                ? () => widget.onPageChanged(widget.currentPage + 1)
                : null,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Next"),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(int pageNumber) {
    final isActive = widget.currentPage == pageNumber;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 40,
        height: 40,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Colors.black : Colors.white,
            foregroundColor: isActive
                ? Colors.white
                : const Color.fromRGBO(107, 114, 128, 1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isActive
                    ? Colors.black
                    : const Color.fromRGBO(229, 229, 229, 1),
                width: 1,
              ),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => widget.onPageChanged(pageNumber),
          child: Text(
            "$pageNumber",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int start = (widget.currentPage - 1) * widget.itemsPerPage;
    int end = (start + widget.itemsPerPage) > widget.peoples.length
        ? widget.peoples.length
        : (start + widget.itemsPerPage);
    List<Map<String, dynamic>> pagedPeoples = widget.peoples.sublist(
      start,
      end,
    );

    return Column(
      children: [
        _buildTableRow(isHeader: true, data: null),

        Expanded(
          child: ListView.builder(
            itemCount: pagedPeoples.length,
            itemBuilder: (context, index) {
              final person = pagedPeoples[index];
              return _buildTableRow(isHeader: false, data: person);
            },
          ),
        ),

        _buildPagination(),
      ],
    );
  }
}
