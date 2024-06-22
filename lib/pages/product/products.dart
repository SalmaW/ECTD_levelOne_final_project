import 'package:data_table_2/data_table_2.dart';
import 'package:final_project/utils/constants.dart';
import 'package:final_project/widgets/search_textField.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../widgets/app_table.dart';
import '../../helpers/sql_helper.dart';
import '../../models/product_data.dart';
import '../product/products_ops.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<ProductData>? products;
  @override
  void initState() {
    getProducts();
    super.initState();
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
        title: const Text("Products"),
        actions: [
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => const ProductsOps()));
              if (result ?? false) {
                getProducts();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
            SearchTextField(
              rawQueryText: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                await sqlHelper.db!.rawQuery("""
                SELECT * FROM Products
                WHERE name LIKE '%$value%' OR categoryName LIKE '%$value%' OR price LIKE '%$value%'
                """);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AppTable(
                minWidth: 1800,
                columns: const [
                  DataColumn(label: Text("Id")),
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Description")),
                  DataColumn(label: Text("Category ID")),
                  DataColumn(label: Text("Category Name")),
                  DataColumn(label: Text("Category Description")),
                  DataColumn(label: Text("Price")),
                  DataColumn(label: Text("Stock")),
                  DataColumn(label: Text("isAvailable")),
                  DataColumn(label: Text("Image")),
                  DataColumn(label: Center(child: Text("Actions"))),
                ],
                source: ProductsTableSource(
                  products: products,
                  onUpdate: (productData) async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => ProductsOps(products: productData)),
                    );
                    if (result ?? false) {
                      getProducts();
                    }
                  },
                  onDelete: (productData) {
                    onDeleteRow(productData.id!);
                  },
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
          getProducts();
        }
      }
    } catch (e) {
      print('Error in delete Products: $e');
    }
  }
}

class ProductsTableSource extends DataTableSource {
  List<ProductData>? products;
  void Function(ProductData) onUpdate;
  void Function(ProductData) onDelete;

  ProductsTableSource({
    required this.products,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    return DataRow2(
      cells: [
        DataCell(Text("${products?[index].id}")),
        DataCell(Text("${products?[index].name}")),
        DataCell(Text("${products?[index].description}")),
        DataCell(Text("${products?[index].categoryId}")),
        DataCell(Text("${products?[index].categoryName}")),
        DataCell(Text("${products?[index].categoryDescription}")),
        DataCell(Text("${products?[index].price}")),
        DataCell(Text("${products?[index].stock}")),
        DataCell(Text("${products?[index].isAvailable}")),
        DataCell(Image.network(
          "${products?[index].image}",
          fit: BoxFit.cover,
        )),
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                onUpdate.call(products![index]);
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () async {
                onDelete.call(products![index]);
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
  int get rowCount => products?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
