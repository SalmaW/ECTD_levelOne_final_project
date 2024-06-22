import 'package:data_table_2/data_table_2.dart';
import 'package:final_project/pages/sale_op.dart';
import 'package:final_project/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../widgets/dash_line.dart';
import 'currency_selection.dart';

class AllSales extends StatefulWidget {
  const AllSales({super.key});

  @override
  State<AllSales> createState() => _AllSalesState();
}

class _AllSalesState extends State<AllSales> {
  List<Order>? orders;
  late String currencyText;
  Currency currentCurrency = Currency.USD; // Default currency is USD in App
  Currency selectedCurrency = Currency.EGP;
  @override
  void initState() {
    currencyText = currencyToString(currentCurrency);
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
      appBar: AppBar(title: const Text("All Sales")),
      body: orders == null
          ? const Center(child: CircularProgressIndicator())
          : (orders?.isEmpty ?? false)
              ? const Center(child: Text("No Data Found"))
              : ListView(
                  children: orders?.map((order) {
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            Padding(
                              padding: inputPadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  GestureDetector(
                                    onTapUp: (orders) async {
                                      var result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (ctx) =>
                                                SaleOp(order: order)),
                                      );
                                      if (result ?? false) {
                                        getOrders();
                                      }
                                    },
                                    onLongPressEnd: (orders) {
                                      onDeleteRow(order.id!);
                                    },
                                    child: Card(
                                      color: const Color(0xffF5F5F5),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: double.maxFinite,
                                              padding: inputPadding,
                                              color: const Color(0xffFFF2CD),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  //TODO: replace with date of purchase
                                                  Text(
                                                    currencyConvertorLine(
                                                        currentCurrency),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xffF27D10),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${order.totalPrice} USD",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: iconGrayColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    "Receipt Name:\n${order.label}"),
                                                IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(Icons
                                                        .more_vert_rounded)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 5),
                                                  child: CircleAvatar(
                                                    radius: 16,
                                                    child: Icon(Icons.person),
                                                  ),
                                                ),
                                                Text("${order.clientName}"),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            const DashedSeparator(),
                                            const SizedBox(height: 20),
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Text("product name"),
                                                Text("2 x 20.0 USD"),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                    "Subtotal: ${order.totalPrice} USD"),
                                                Text(
                                                    "Discount: - ${order.discount}%"),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            const DashedSeparator(),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                        "Total: ${order.totalPrice}"),
                                                    Text("Paid"),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList() ??
                      [],
                ),

      /*Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: inputPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  child: Card(
                    color: const Color(0xffF5F5F5),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.maxFinite,
                            padding: inputPadding,
                            color: const Color(0xffFFF2CD),
                            child: Text(
                              currencyConvertorLine(currentCurrency),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xffF27D10),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Receipt Name"),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.more_vert_rounded)),
                            ],
                          ),
                          // const SizedBox(height: 8),
                          const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: CircleAvatar(
                                  radius: 16,
                                  child: Icon(Icons.person),
                                ),
                              ),
                              const Text("Unnamed Clinet"),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const DashedSeparator(),
                          const SizedBox(height: 20),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("product name"),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("2 x 20.0 USD"),
                                  Text("40.0 USD"),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          const DashedSeparator(),
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("Total: 40.0 USD"),
                                  Text("Paid"),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),*/
    );
  }

  String currencyConvertorLine(Currency currency) {
    switch (currency) {
      case Currency.EGP:
        return '1 $currencyText = 0.020 EUR || 0.021 USD';
      case Currency.EUR:
        return '1 $currencyText = 51.1264 EGP ';
      case Currency.USD:
        return '1 $currencyText = 47.66 EGP ';
    }
  }

  String currencyToString(Currency currency) {
    switch (currency) {
      case Currency.EGP:
        return 'EGP';
      case Currency.EUR:
        return 'EUR';
      case Currency.USD:
        return 'USD';
    }
  }

  /*Padding(
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
      ),*/
  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Delete Receipt",
              style: TextStyle(color: redColor),
            ),
            content:
                const Text("Are you sure you want to delete this receipt?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: redColor),
                  )),
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
          "Orders",
          where: "id = ?",
          whereArgs: [id],
        );
        if (result > 0) {
          getOrders();
        }
      }
    } catch (e) {
      print('Error in delete Receipt: $e');
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
