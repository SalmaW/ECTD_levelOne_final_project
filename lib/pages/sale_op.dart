import 'package:get/get.dart';

import '../utils/constants.dart';
import '../widgets/clients_drop_down.dart';
import '../widgets/dash_line.dart';
import '../widgets/discount_textField.dart';

import '../models/order.dart';
import '../models/order_item.dart';
import '../widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../helpers/sql_helper.dart';
import '../models/product_data.dart';
import 'currency_selection.dart';

class SaleOp extends StatefulWidget {
  final Order? order;
  const SaleOp({this.order, super.key});

  @override
  State<SaleOp> createState() => _SaleOpState();
}

class _SaleOpState extends State<SaleOp> {
  String? orderLabel;
  List<ProductData>? products;
  List<OrderItem> selectedOrderItem = [];
  int? selectedClientId;

  Currency currentCurrency = Currency.USD; // Default currency is USD in App
  Currency selectedCurrency = Currency.EGP;

  late String currencyText;
  late String selectedCurrencyText;

  late TextEditingController discountController;
  double? discount = 0.0;

  @override
  void initState() {
    initPage();
    super.initState();
  }

  void initPage() {
    orderLabel = widget.order == null
        ? "#ORDER${DateTime.now().microsecondsSinceEpoch}"
        : "${widget.order!.id}";
    selectedClientId = widget.order?.clientId;
    currencyText = currencyToString(currentCurrency);
    selectedCurrencyText = currencyToString(selectedCurrency);
    discountController = TextEditingController(
        text: widget.order == null ? "" : "${widget.order!.discount! * 100}");
    getProducts();
    setState(() {});
  }

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""
      select P.* ,C.name as categoryName,C.description as categoryDescription 
      from Products P
      inner join Categories C
      where P.categoryId = C.id
      """);

      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products!.add(ProductData.fromJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      print('Error In get data $e');
      products = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Add New Sale' : 'Update Sale'),
        actions: [
          CurrencySelectionScreen(
            onCurrencyChanged: (currency) {
              currentCurrency = currency;
              currencyText = currencyToString(currency);
              selectedCurrency == currentCurrency
                  ? selectedCurrency = Currency.USD
                  : null;
              selectedCurrencyText = currencyToString(selectedCurrency);
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 20),
            Padding(
              padding: inputPadding,
              child: ClientsDropDown(
                selectedValue: selectedClientId,
                onChange: (clientId) {
                  if (clientId != null) {
                    selectedClientId = clientId;
                    ClientsDropDown.decorationContainer = true;
                  } else {
                    ClientsDropDown.decorationContainer = false;
                  }
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: inputPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: const Color(0xffF5F5F5),
                    child: Column(
                      children: [
                        for (var orderItem in selectedOrderItem)
                          Padding(
                            padding: inputPadding,
                            child: ListTile(
                              leading: Image.network(
                                  orderItem.productData?.image ?? ""),
                              title: Text(orderItem.productData?.name ?? ""),
                              subtitle: Text(
                                  "${convertPrice(orderItem.productData?.price, currencyToString(currentCurrency), currencyToString(selectedCurrency))}\n${(orderItem.productData?.price ?? 0)} $currencyText"),
                              trailing: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      width: 1, color: iconGrayColor),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: iconGrayColor, blurRadius: 1)
                                  ],
                                  color: const Color(0xffF5F5F5),
                                ),
                                child: Text(
                                  '${(orderItem.productCount ?? 0)}X',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        AppButton(
                          onPressed: () {
                            onClickedAddProduct();
                          },
                          label: "Add Product",
                        ),
                        const Padding(
                          padding: inputPadding,
                          child: DashedSeparator(),
                        ),
                        Padding(
                          padding: inputPadding,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Subtotal: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "${calculateProductPrice()} $currencyText ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: inputPadding,
                          child: DashedSeparator(),
                        ),
                        Padding(
                          padding: inputPadding,
                          child: DiscountTextField(
                            discountController: discountController,
                            onChange: (discountValue) {
                              if (discountController.text.isNotEmpty) {
                                discountValue = discountController.text;
                                discount = double.parse(discountValue) / 100;
                                DiscountTextField.decorationContainer = true;
                              } else {
                                DiscountTextField.decorationContainer = false;
                                discount = 0.0;
                              }
                              setState(() {});
                            },
                          ),
                        ),
                        const Padding(
                          padding: inputPadding,
                          child: DashedSeparator(),
                        ),
                        Padding(
                          padding: inputPadding,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "${calculateProductPrice(discount)} $currencyText ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppButton(
                onPressed: selectedOrderItem.isEmpty
                    ? null
                    : () async {
                        ClientsDropDown.decorationContainer = false;
                        DiscountTextField.decorationContainer = false;
                        await onSetOrder();
                      },
                label: 'Confirm'),
          ],
        ),
      ),
    );
  }

  Future<void> onSetOrder() async {
    try {
      Order newOrder;
      if (widget.order != null) {
        //update
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var orderId = await sqlHelper.db!.update(
          "Orders",
          {
            "label": orderLabel,
            "totalPrice": calculateProductPrice(),
            "discount": discount,
            "clientId": selectedClientId
          },
          where: 'id = ?',
          whereArgs: [widget.order?.id],
        );
        newOrder = Order(
          id: orderId,
          label: orderLabel,
          totalPrice: calculateProductPrice(),
          discount: discount,
          clientId: selectedClientId,
        );

        var batch = sqlHelper.db!.batch();
        for (var orderItem in selectedOrderItem) {
          batch.update(
            'orderProductItems',
            {
              "orderId": orderId,
              "productId": orderItem.productId,
              "productCount": orderItem.productCount ?? 0,
            },
            where: 'id = ?',
            whereArgs: [orderId],
          );
          sqlHelper.backupDatabase();
          var result = await batch.commit();
          print(">>>>>>>>>>> Update selected order items ids: $result");
        }
      } else {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var orderId = await sqlHelper.db!.insert(
          "Orders",
          {
            "label": orderLabel,
            "totalPrice": calculateProductPrice(),
            "discount": discount,
            "clientId": selectedClientId
          },
        );
        newOrder = Order(
          id: orderId,
          label: orderLabel,
          totalPrice: calculateProductPrice(),
          discount: discount,
          clientId: selectedClientId,
        );

        var batch = sqlHelper.db!.batch();
        for (var orderItem in selectedOrderItem) {
          batch.insert(
            'orderProductItems',
            {
              "orderId": orderId,
              "productId": orderItem.productId,
              "productCount": orderItem.productCount ?? 0,
            },
          );
          sqlHelper.backupDatabase();
          var result = await batch.commit();
          print(">>>>>>>>>>> selected order items ids: $result");
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Order Set Successfully")),
      );
      Navigator.pop(context, newOrder);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Please Make Sure to Select a Client")),
      );
      print("Error in Creating Order: $e");
    }
  }

  double? calculateProductPrice([double? discount]) {
    double total = 0;
    discount = discount ?? 0;
    double totalNet;
    for (var orderItem in selectedOrderItem) {
      total +=
          ((orderItem.productCount ?? 0) * (orderItem.productData?.price ?? 0));
    }
    if (discount <= 1) {
      total -= (total * discount);
    }
    switch (currentCurrency) {
      case Currency.USD:
      case Currency.EGP:
      case Currency.EUR:
        totalNet = double.parse(total.toStringAsFixed(2));
        return totalNet;
    }
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

  void onClickedAddProduct() async {
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateDialog) {
            return Dialog(
              insetPadding: inputPadding,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ((products?.isEmpty ?? false))
                    ? const Center(child: Text("No Data Found"))
                    : Column(
                        children: [
                          const Text(
                            "Products",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView(
                              children: widget.order != null
                                  ? []
                                  : [
                                      for (var product in products!)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: ListTile(
                                            leading: Image.network(
                                                product.image ?? "no image"),
                                            title:
                                                Text(product.name ?? "no name"),
                                            subtitle:
                                                getOrderItem(product.id!) ==
                                                        null
                                                    ? null
                                                    : Row(
                                                        children: [
                                                          IconButton(
                                                              onPressed: getOrderItem(product
                                                                              .id!) !=
                                                                          null &&
                                                                      getOrderItem(product.id!)
                                                                              ?.productCount ==
                                                                          1
                                                                  ? null
                                                                  : () {
                                                                      getOrderItem(product
                                                                              .id!)
                                                                          ?.productCount = (getOrderItem(product.id!)?.productCount ??
                                                                              0) -
                                                                          1;
                                                                      setStateDialog(
                                                                          () {});
                                                                    },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .remove)),
                                                          Text(getOrderItem(
                                                                  product.id!)!
                                                              .productCount
                                                              .toString()),
                                                          IconButton(
                                                              onPressed: () {
                                                                getOrderItem(product
                                                                            .id!)
                                                                        ?.productCount =
                                                                    (getOrderItem(product.id!)?.productCount ??
                                                                            0) +
                                                                        1;
                                                                setStateDialog(
                                                                    () {});
                                                              },
                                                              icon: const Icon(
                                                                  Icons.add)),
                                                        ],
                                                      ),
                                            trailing: getOrderItem(
                                                        product.id!) ==
                                                    null
                                                ? IconButton(
                                                    onPressed: () {
                                                      onAddItem(product);
                                                      setStateDialog(() {});
                                                    },
                                                    icon: const Icon(Icons.add))
                                                : IconButton(
                                                    onPressed: () {
                                                      onDeleteItem(product.id!);
                                                      setStateDialog(() {});
                                                    },
                                                    icon: const Icon(
                                                        Icons.delete)),
                                          ),
                                        ),
                                    ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              label: "Back"),
                        ],
                      ),
              ),
            );
          });
        });
    setState(() {});
  }

  OrderItem? getOrderItem(int productId) {
    for (var item in selectedOrderItem) {
      //todo: when the user tap on a receipt it shows the selected products
      // if (widget.order != null) {
      //   selectedOrderItem = widget.order;
      //   return item;
      // }
      if (item.productId == productId) {
        return item;
      }
    }
    return null;
  }

  void onAddItem(ProductData product) {
    selectedOrderItem.add(OrderItem(
        productId: product.id, productCount: 1, productData: product));
  }

  void onDeleteItem(int productId) {
    for (var i = 0; i < selectedOrderItem.length; i++) {
      if (selectedOrderItem[i].productId == productId) {
        selectedOrderItem.removeAt(i);
        break;
      }
    }
  }
}
