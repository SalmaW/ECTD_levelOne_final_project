import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class AppTable extends StatelessWidget {
  final List<DataColumn> columns;
  final DataTableSource source;
  final double minWidth;
  const AppTable({
    super.key,
    required this.columns,
    required this.source,
    this.minWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      // showCheckboxColumn: true,
      empty: const Center(child: Text("No Data Found")),
      renderEmptyRowsInTheEnd: false,
      isHorizontalScrollBarVisible: true,
      minWidth: minWidth,
      columnSpacing: 20,
      horizontalMargin: 20,
      wrapInCard: false,
      rowsPerPage: 15,
      border: TableBorder.all(),
      headingTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
      headingRowColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
      columns: columns,
      source: source,
    );
  }
}
