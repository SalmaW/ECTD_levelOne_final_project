import 'package:data_table_2/data_table_2.dart';
import 'package:final_project/utils/constants.dart';
import 'package:final_project/widgets/search_textField.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../widgets/app_table.dart';

class AllSales extends StatefulWidget {
  const AllSales({super.key});

  @override
  State<AllSales> createState() => _AllSalesState();
}

class _AllSalesState extends State<AllSales> {
  List<Order>? orders;
  @override
  void initState() {
    getOrders();
    super.initState();
  }

  void getOrders() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select O.* ,C.name as clientName,C.phone as clientPhone,C.address as clientAddress
      from Orders O
      inner join Clients C
      where O.clientId = C.id
      """);

      if (data.isNotEmpty) {
        orders = [];
        for (var item in data) {
          orders!.add(Order.fromJson(item));
        }
      } else {
        orders = [];
      }
    } catch (e) {
      print('Error In get data from orders $e');
      orders = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Sales"),
      ),
      body: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
            SearchTextField(
              rawQueryText: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                await sqlHelper.db!.rawQuery("""
                SELECT * FROM Orders
                WHERE label LIKE '%$value%';
                """);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AppTable(
                minWidth: 1100,
                columns: const [
                  DataColumn(label: Text("Id")),
                  DataColumn(label: Text("Label")),
                  DataColumn(label: Text("Total Price")),
                  DataColumn(label: Text("Discount")),
                  DataColumn(label: Text("Client ID")),
                  DataColumn(label: Text("Client Name")),
                  DataColumn(label: Text("Client Phone")),
                  DataColumn(label: Text("Client Address")),
                  DataColumn(label: Center(child: Text("Actions"))),
                ],
                source: OrdersTableSource(
                  orders: orders,
                  onShow: (order) {},
                  onDelete: (order) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete Product"),
            content:
                const Text("Are you sure you want to delete this product?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('OK')),
            ],
          );
        },
      );
      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          "Products",
          where: "id = ?",
          whereArgs: [id],
        );
        if (result > 0) {
          getOrders();
        }
      }
    } catch (e) {
      print('Error in delete Products: $e');
    }
  }
}

class OrdersTableSource extends DataTableSource {
  List<Order>? orders;
  void Function(Order) onShow;
  void Function(Order) onDelete;

  OrdersTableSource({
    required this.orders,
    required this.onShow,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    return DataRow2(
      cells: [
        DataCell(Text("${orders?[index].id}")),
        DataCell(Text("${orders?[index].label}")),
        DataCell(Text("${orders?[index].totalPrice}")),
        DataCell(Text("${orders?[index].discount}")),
        DataCell(Text("${orders?[index].clientId}")),
        DataCell(Text("${orders?[index].clientName}")),
        DataCell(Text("${orders?[index].clientPhone}")),
        DataCell(Text("${orders?[index].clientAddress}")),
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                onShow.call(orders![index]);
              },
              icon: const Icon(Icons.visibility),
            ),
            IconButton(
              onPressed: () async {
                onDelete.call(orders![index]);
              },
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => orders?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
