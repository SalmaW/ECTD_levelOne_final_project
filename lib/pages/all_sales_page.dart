import 'package:data_table_2/data_table_2.dart';
import 'package:final_project/pages/sale_op.dart';
import 'package:final_project/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../helpers/sql_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product_data.dart';
import '../widgets/dash_line.dart';
import 'currency_selection.dart';

class AllSales extends StatefulWidget {
  const AllSales({super.key});

  @override
  State<AllSales> createState() => _AllSalesState();
}

class _AllSalesState extends State<AllSales> {
  List<Order>? orders;
  List<ProductData>? products;
  late String currencyText;
  Currency currentCurrency = Currency.USD; // Default currency is USD in App
  Currency selectedCurrency = Currency.EGP;
  List<OrderItem> selectedOrderItem = [];
  late String selectedCurrencyText;

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
                                    //update receipt
                                    onTapUp: (orderClick) async {
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
                                    //delete receipt
                                    onLongPressEnd: (orderClick) {
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
                                                //todo: remove the static text
                                                Text("2 x 20.0 USD"),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                        "Subtotal: ${order.totalPrice} USD"),
                                                    Text(
                                                        "Discount: - ${order.discount! * 100}%"),
                                                  ],
                                                ),
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
                                                        "Total: ${calculateProductPriceAfterDiscount(discount: order.discount!, total: order.totalPrice!)}"),
                                                    const Text("Paid"),
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
    );
  }

  double calculateProductPriceAfterDiscount(
      {required double discount, required double total}) {
    return (total - (total * discount));
  }

  convertPrice(var price, String fromCurrency, String toCurrency) {
    final Map<String, double> exchangeRates = {
      'EGPtoUSD': 0.021,
      'EGPtoEUR': 0.02,
      'USDtoEUR': 0.93,
      'EURtoUSD': 1.07,
      'USDtoEGP': 47.66,
      'EURtoEGP': 51.13,
    };

    // if (fromCurrency == toCurrency) return price;
    switch ("${fromCurrency}to$toCurrency") {
      case 'EGPtoUSD':
        return "${(price * exchangeRates['EGPtoUSD']).toStringAsFixed(4)} $selectedCurrencyText";
      case 'EGPtoEUR':
        return "${(price * exchangeRates['EGPtoEUR']).toStringAsFixed(4)} $selectedCurrencyText";
      case 'USDtoEUR':
        return "${(price * exchangeRates['USDtoEUR']).toStringAsFixed(4)} $selectedCurrencyText";
      case 'EURtoUSD':
        return "${(price * exchangeRates['EURtoUSD']).toStringAsFixed(4)} $selectedCurrencyText";
      case 'USDtoEGP':
        return "${(price * exchangeRates['USDtoEGP']).toStringAsFixed(4)} $selectedCurrencyText";
      case 'EURtoEGP':
        return "${(price * exchangeRates['EURtoEGP']).toStringAsFixed(4)} $selectedCurrencyText";
      default:
        return price;
    }
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
        sqlHelper.backupDatabase();
        // if (result > 0) {
        //   getOrders();
        //   setState(() {});
        // }
        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order deleted successfully")),
          );
          getOrders(); // Refresh the list after deletion
        }
        print(">>>>>>>>>>> selected order & orderItem are deleted : $result");
      }
    } catch (e) {
      print('Error in delete Receipt: $e');
    }
  }
}
