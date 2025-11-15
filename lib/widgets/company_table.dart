import 'package:flutter/material.dart';

class TableColumn {
  final String key;
  final String title;
  final int flex;
  final bool hasCheckbox;
  final Widget Function(dynamic value, bool isHeader)? customBuilder;

  TableColumn({
    required this.key,
    required this.title,
    this.flex = 1,
    this.hasCheckbox = false,
    this.customBuilder,
  });
}

class CompanyTable extends StatefulWidget {
  final List<Map<String, dynamic>> companies;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final void Function(int page) onPageChanged;
  final List<TableColumn>? columns;

  const CompanyTable({
    super.key,
    required this.companies,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.itemsPerPage = 10,
    this.columns,
  });

  @override
  State<CompanyTable> createState() => _CompanyTableState();
}

class _CompanyTableState extends State<CompanyTable> {
  bool selectAll = false;
  Set<int> selectedRows = {};

  List<TableColumn> get defaultColumns => [
    TableColumn(key: 'name', title: 'Name', flex: 3, hasCheckbox: true),
    TableColumn(key: 'accountOwner', title: 'Account Owner', flex: 2),
    TableColumn(key: 'type', title: 'Type', flex: 2),
    TableColumn(key: 'focusedAssigned', title: 'Focused/Assigned', flex: 2),
    TableColumn(key: 'etmRegion', title: 'ETM Region', flex: 2),
    TableColumn(
      key: 'latestCooldown',
      title: 'Latest cooldown',
      flex: 2,
      customBuilder: (value, isHeader) => buildCooldownCell(value, isHeader),
    ),
    TableColumn(
      key: 'actions',
      title: 'Actions',
      flex: 2,
      customBuilder: (value, isHeader) => buildActionsCell(isHeader),
    ),
  ];

  List<TableColumn> get columns => widget.columns ?? defaultColumns;

  Widget buildCooldownCell(dynamic value, bool isHeader) {
    if (isHeader) {
      return Text(
        'Latest cooldown',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color.fromRGBO(130, 130, 130, 1),
        ),
      );
    }

    Map<String, dynamic> cooldown = value as Map<String, dynamic>;

    Color bgColor;
    Color textColor;
    Color dotColor;

    switch (cooldown['color']) {
      case 'green':
        bgColor = const Color.fromRGBO(240, 253, 244, 1);
        textColor = const Color.fromRGBO(22, 163, 74, 1);
        dotColor = const Color.fromRGBO(34, 197, 94, 1);
        break;
      case 'red':
        bgColor = const Color.fromRGBO(254, 242, 242, 1);
        textColor = const Color.fromRGBO(220, 38, 38, 1);
        dotColor = const Color.fromRGBO(239, 68, 68, 1);
        break;
      case 'yellow':
      default:
        bgColor = const Color.fromRGBO(254, 252, 232, 1);
        textColor = const Color.fromRGBO(161, 98, 7, 1);
        dotColor = const Color.fromRGBO(245, 158, 11, 1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromRGBO(229, 231, 235, 1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            cooldown['label'],
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionsCell(bool isHeader) {
    if (isHeader) {
      return Text(
        'Actions',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color.fromRGBO(130, 130, 130, 1),
        ),
      );
    }

    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey[600]),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget buildTableRow({
    required bool isHeader,
    required Map<String, dynamic>? data,
    required int? index,
  }) {
    final headerStyle = const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Color.fromRGBO(130, 130, 130, 1),
    );

    final rowTextStyle = const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color.fromRGBO(17, 24, 39, 1),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color.fromRGBO(243, 244, 246, 1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: columns.map((column) {
          if (column.hasCheckbox && !isHeader) {
            return Expanded(
              flex: column.flex,
              child: Row(
                children: [
                  Checkbox(
                    value: index != null ? selectedRows.contains(index) : false,
                    onChanged: (value) {
                      setState(() {
                        if (value == true && index != null) {
                          selectedRows.add(index);
                        } else if (index != null) {
                          selectedRows.remove(index);
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: Color.fromRGBO(209, 213, 219, 1),
                      width: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data![column.key].toString(),
                      style: rowTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          } else if (column.hasCheckbox && isHeader) {
            return Expanded(
              flex: column.flex,
              child: Row(
                children: [
                  Checkbox(
                    value: selectAll,
                    onChanged: (value) {
                      setState(() {
                        selectAll = value ?? false;
                        if (selectAll) {
                          selectedRows = Set.from(
                            List.generate(widget.companies.length, (i) => i),
                          );
                        } else {
                          selectedRows.clear();
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: Color.fromRGBO(209, 213, 219, 1),
                      width: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(column.title, style: headerStyle),
                ],
              ),
            );
          } else {
            return Expanded(
              flex: column.flex,
              child: column.customBuilder != null
                  ? column.customBuilder!(
                      isHeader ? column.title : data![column.key],
                      isHeader,
                    )
                  : Text(
                      isHeader ? column.title : data![column.key].toString(),
                      style: isHeader ? headerStyle : rowTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
            );
          }
        }).toList(),
      ),
    );
  }

  Widget buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color.fromRGBO(209, 213, 219, 1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: widget.currentPage > 1
                ? () => widget.onPageChanged(widget.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left, size: 20),
            label: const Text('Previous'),
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageNumbers(),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color.fromRGBO(209, 213, 219, 1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: widget.currentPage < widget.totalPages
                ? () => widget.onPageChanged(widget.currentPage + 1)
                : null,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Next'),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageButtons = [];

    const int maxVisiblePages = 5;

    if (widget.totalPages <= maxVisiblePages) {
      for (int i = 1; i <= widget.totalPages; i++) {
        pageButtons.add(_buildPageButton(i));
      }
    } else {
      int startPage = 1;
      int endPage = widget.totalPages;

      if (widget.currentPage <= 3) {
        startPage = 1;
        endPage = maxVisiblePages;
      } else if (widget.currentPage >= widget.totalPages - 2) {
        startPage = widget.totalPages - maxVisiblePages + 1;
        endPage = widget.totalPages;
      } else {
        startPage = widget.currentPage - 2;
        endPage = widget.currentPage + 2;
      }

      if (startPage > 1) {
        pageButtons.add(_buildPageButton(1));
        if (startPage > 2) {
          pageButtons.add(_buildEllipsis());
        }
      }

      for (int i = startPage; i <= endPage; i++) {
        pageButtons.add(_buildPageButton(i));
      }

      if (endPage < widget.totalPages) {
        if (endPage < widget.totalPages - 1) {
          pageButtons.add(_buildEllipsis());
        }
        pageButtons.add(_buildPageButton(widget.totalPages));
      }
    }

    return pageButtons;
  }

  Widget _buildPageButton(int pageNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.currentPage == pageNumber
              ? Colors.black
              : Colors.white,
          foregroundColor: widget.currentPage == pageNumber
              ? Colors.white
              : Colors.black,
          side: const BorderSide(color: Color.fromRGBO(209, 213, 219, 1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(40, 40),
        ),
        onPressed: () => widget.onPageChanged(pageNumber),
        child: Text('$pageNumber'),
      ),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int start = (widget.currentPage - 1) * widget.itemsPerPage;
    int end = (start + widget.itemsPerPage) > widget.companies.length
        ? widget.companies.length
        : (start + widget.itemsPerPage);
    List<Map<String, dynamic>> pagedCompanies = widget.companies.sublist(
      start,
      end,
    );

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(249, 250, 251, 1),
            border: Border(
              bottom: BorderSide(
                color: Color.fromRGBO(243, 244, 246, 1),
                width: 1,
              ),
            ),
          ),
          child: buildTableRow(isHeader: true, data: null, index: null),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: pagedCompanies.length,
            itemBuilder: (context, index) {
              final company = pagedCompanies[index];
              return GestureDetector(
                onTap: () {
                  print('Tapped on ${company['name']}');
                },
                child: buildTableRow(
                  isHeader: false,
                  data: company,
                  index: start + index,
                ),
              );
            },
          ),
        ),

        buildPagination(),
      ],
    );
  }
}
