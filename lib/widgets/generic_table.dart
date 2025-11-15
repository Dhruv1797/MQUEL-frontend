import 'package:flutter/material.dart';

class TableColumn {
  final String key;
  final String title;
  final bool hasCheckbox;
  final bool sortable;
  final Widget Function(
    dynamic value,
    bool isHeader,
    Map<String, dynamic>? rowData,
  )?
  customBuilder;
  final TextAlign textAlign;
  final double width;

  TableColumn({
    required this.key,
    required this.title,
    required this.width,
    this.hasCheckbox = false,
    this.sortable = false,
    this.customBuilder,
    this.textAlign = TextAlign.left,
  });
}

class GenericDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<TableColumn> columns;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;

  final bool? isApiPaginated;

  final int? totalItems;
  final void Function(int page) onPageChanged;
  final void Function(Map<String, dynamic> rowData)? onRowTap;
  final void Function(List<int> selectedIndices)? onSelectionChanged;
  final bool showPagination;
  final bool allowSelection;
  final String? emptyMessage;
  final Widget? emptyWidget;
  final Color? headerBackgroundColor;
  final Color? rowBackgroundColor;
  final Color? borderColor;
  final TextStyle? headerTextStyle;
  final TextStyle? rowTextStyle;
  final double? rowHeight;
  final EdgeInsets? cellPadding;
  final void Function(String columnKey, bool ascending)? onSort;
  final String? sortColumnKey;
  final bool? sortAscending;
  final void Function(int itemsPerPage)? onItemsPerPageChanged;

  const GenericDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.itemsPerPage = 10,
    this.isApiPaginated,
    this.totalItems,
    this.onRowTap,
    this.onSelectionChanged,
    this.showPagination = true,
    this.allowSelection = false,
    this.emptyMessage,
    this.emptyWidget,
    this.headerBackgroundColor,
    this.rowBackgroundColor,
    this.borderColor,
    this.headerTextStyle,
    this.rowTextStyle,
    this.rowHeight,
    this.cellPadding,
    this.onSort,
    this.sortColumnKey,
    this.sortAscending,
    this.onItemsPerPageChanged,
  });

  @override
  State<GenericDataTable> createState() => _GenericDataTableState();
}

class _GenericDataTableState extends State<GenericDataTable> {
  bool selectAll = false;
  Set<int> selectedRows = {};
  late ScrollController _horizontalScrollController;

  Color get defaultHeaderBackgroundColor =>
      const Color.fromRGBO(249, 250, 251, 1);
  Color get defaultRowBackgroundColor => Colors.white;
  Color get defaultBorderColor => const Color.fromRGBO(243, 244, 246, 1);

  TextStyle get defaultHeaderTextStyle => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Color.fromRGBO(130, 130, 130, 1),
  );

  TextStyle get defaultRowTextStyle => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(17, 24, 39, 1),
  );

  EdgeInsets get defaultCellPadding =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 2);

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GenericDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      selectedRows.clear();
      selectAll = false;
    }
  }

  void _handleSelectionChange() {
    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(selectedRows.toList());
    }
  }

  double get totalTableWidth {
    return widget.columns.fold(0.0, (sum, column) => sum + column.width);
  }

  Widget _buildSortIcon(String columnKey) {
    if (widget.sortColumnKey != columnKey) {
      return const Icon(Icons.unfold_more, size: 16, color: Colors.grey);
    }

    return Icon(
      widget.sortAscending == true
          ? Icons.keyboard_arrow_up
          : Icons.keyboard_arrow_down,
      size: 16,
      color: Colors.grey[700],
    );
  }

  Color _getRowBackgroundColor(Map<String, dynamic>? data) {
    if (data != null && data['isGoodLead'] == false) {
      return const Color.fromRGBO(255, 245, 245, 1);
    }
    return const Color.fromRGBO(255, 255, 255, 1);
  }

  Widget _buildTableRow({
    required bool isHeader,
    required Map<String, dynamic>? data,
    required int? index,
  }) {
    final headerStyle = widget.headerTextStyle ?? defaultHeaderTextStyle;
    final rowStyle = widget.rowTextStyle ?? defaultRowTextStyle;
    final padding = widget.cellPadding ?? defaultCellPadding;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        children: [
          Container(
            height: widget.rowHeight,
            decoration: BoxDecoration(
              color: isHeader
                  ? const Color.fromRGBO(249, 249, 249, 1)
                  : _getRowBackgroundColor(data),
              border: Border(
                bottom: BorderSide(
                  color: const Color.fromRGBO(228, 228, 228, 1),
                  width: 1,
                ),

                top: isHeader
                    ? BorderSide(
                        color: const Color.fromRGBO(228, 228, 228, 1),
                        width: 1,
                      )
                    : BorderSide(
                        color: const Color.fromRGBO(228, 228, 228, 1),
                        width: 1,
                      ),
              ),
            ),
            child: Row(
              children: widget.columns.map((column) {
                Widget cellContent;

                if (column.hasCheckbox && widget.allowSelection) {
                  if (isHeader) {
                    cellContent = Container(
                      width: column.width,
                      padding: padding,
                      child: Row(
                        children: [
                          Checkbox(
                            value: selectAll,
                            onChanged: (value) {
                              setState(() {
                                selectAll = value ?? false;
                                if (selectAll) {
                                  selectedRows = Set.from(
                                    List.generate(widget.data.length, (i) => i),
                                  );
                                } else {
                                  selectedRows.clear();
                                }
                              });
                              _handleSelectionChange();
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

                          if (column.sortable && widget.onSort != null)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  bool ascending =
                                      widget.sortColumnKey == column.key
                                      ? !(widget.sortAscending ?? true)
                                      : true;
                                  widget.onSort!(column.key, ascending);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        column.title,
                                        style: headerStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    _buildSortIcon(column.key),
                                  ],
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: Text(
                                column.title,
                                style: headerStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    );
                  } else {
                    cellContent = Container(
                      width: column.width,
                      padding: padding,
                      child: Row(
                        children: [
                          Checkbox(
                            value: index != null
                                ? selectedRows.contains(index)
                                : false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true && index != null) {
                                  selectedRows.add(index);
                                } else if (index != null) {
                                  selectedRows.remove(index);
                                }
                              });
                              _handleSelectionChange();
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
                            child: _buildCellContent(
                              column,
                              data,
                              isHeader,
                              rowStyle,
                              headerStyle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  cellContent = Container(
                    width: column.width,
                    padding: padding,
                    child: _buildCellContent(
                      column,
                      data,
                      isHeader,
                      rowStyle,
                      headerStyle,
                    ),
                  );
                }

                return cellContent;
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCellContent(
    TableColumn column,
    Map<String, dynamic>? data,
    bool isHeader,
    TextStyle rowStyle,
    TextStyle headerStyle,
  ) {
    if (column.customBuilder != null) {
      return column.customBuilder!(
        isHeader ? column.title : data?[column.key],
        isHeader,
        data,
      );
    }

    if (isHeader) {
      if (column.sortable && widget.onSort != null) {
        return GestureDetector(
          onTap: () {
            bool ascending = widget.sortColumnKey == column.key
                ? !(widget.sortAscending ?? true)
                : true;
            widget.onSort!(column.key, ascending);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  column.title,
                  style: headerStyle,
                  textAlign: column.textAlign,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              _buildSortIcon(column.key),
            ],
          ),
        );
      } else {
        return Text(
          column.title,
          style: headerStyle,
          textAlign: column.textAlign,
          overflow: TextOverflow.ellipsis,
        );
      }
    } else {
      return Text(
        data?[column.key]?.toString() ?? '',
        style: rowStyle,
        textAlign: column.textAlign,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildEmptyState() {
    if (widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage ?? 'No data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (!widget.showPagination) return const SizedBox.shrink();

    final localPages = (widget.data.length / widget.itemsPerPage).ceil();
    final apiMode = widget.isApiPaginated ?? (widget.totalPages > localPages);
    int start = (widget.currentPage - 1) * widget.itemsPerPage + 1;
    int end = apiMode
        ? (start + (widget.data.isEmpty ? 0 : widget.data.length - 1))
        : ((widget.currentPage * widget.itemsPerPage) > widget.data.length
              ? widget.data.length
              : (widget.currentPage * widget.itemsPerPage));
    final ofTotal = apiMode
        ? (widget.totalItems ?? (widget.totalPages * widget.itemsPerPage))
        : widget.data.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.rowBackgroundColor ?? defaultRowBackgroundColor,
        border: Border(
          top: BorderSide(
            color: widget.borderColor ?? defaultBorderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(
                      color: Color.fromRGBO(209, 213, 219, 1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: widget.currentPage > 1
                      ? () => widget.onPageChanged(widget.currentPage - 1)
                      : null,
                  child: const Text('Back'),
                ),

                const SizedBox(width: 8),

                ..._buildPageNumbers(),

                const SizedBox(width: 8),

                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(
                      color: Color.fromRGBO(209, 213, 219, 1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: widget.currentPage < widget.totalPages
                      ? () => widget.onPageChanged(widget.currentPage + 1)
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),

          Row(
            children: [
              const Text(
                'Result per page',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(209, 213, 219, 1),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: widget.itemsPerPage,
                    isDense: true,
                    items: [10, 20, 50].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null &&
                          widget.onItemsPerPageChanged != null) {
                        widget.onItemsPerPageChanged!(newValue);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$start-$end of $ofTotal',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Color.fromRGBO(209, 213, 219, 1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: widget.currentPage > 1
              ? () => widget.onPageChanged(widget.currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),

        Text(
          '${widget.currentPage} of ${widget.totalPages}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),

        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Color.fromRGBO(209, 213, 219, 1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: widget.currentPage < widget.totalPages
              ? () => widget.onPageChanged(widget.currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildFullPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Color.fromRGBO(233, 233, 233, 1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
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
              borderRadius: BorderRadius.circular(4),
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
          side: const BorderSide(color: Color.fromRGBO(233, 233, 233, 1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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

  Widget _buildTableContent() {
    if (widget.data.isEmpty) {
      return Column(
        children: [
          _buildTableRow(isHeader: true, data: null, index: null),

          Expanded(child: _buildEmptyState()),
        ],
      );
    }

    final localPages = (widget.data.length / widget.itemsPerPage).ceil();
    final apiMode = widget.isApiPaginated ?? (widget.totalPages > localPages);
    int start = (widget.currentPage - 1) * widget.itemsPerPage;
    int end = (start + widget.itemsPerPage) > widget.data.length
        ? widget.data.length
        : (start + widget.itemsPerPage);
    List<Map<String, dynamic>> pagedData = apiMode
        ? widget.data
        : widget.data.sublist(start, end);

    return Column(
      children: [
        _buildTableRow(isHeader: true, data: null, index: null),

        Expanded(
          child: ListView.builder(
            itemCount: pagedData.length,
            itemBuilder: (context, index) {
              final rowData = pagedData[index];
              return GestureDetector(
                onTap: widget.onRowTap != null
                    ? () => widget.onRowTap!(rowData)
                    : null,
                child: _buildTableRow(
                  isHeader: false,
                  data: rowData,
                  index: apiMode ? index : (start + index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (totalTableWidth > constraints.maxWidth) {
                return Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 8.0,
                  radius: const Radius.circular(4.0),
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: totalTableWidth,
                      child: _buildTableContent(),
                    ),
                  ),
                );
              } else {
                return _buildTableContent();
              }
            },
          ),
        ),

        if (widget.showPagination) _buildPagination(),
      ],
    );
  }
}
