import 'package:data_table_2/data_table_2.dart';
import 'package:final_project/utils/constants.dart';
import 'package:final_project/widgets/search_textField.dart';
import '../../widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../helpers/sql_helper.dart';
import '../category/categories_ops.dart';
import '../../models/category_data.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<ClientData>? categories;
  final SqlHelper _dbHelper = SqlHelper();
  @override
  void initState() {
    getCategories();
    super.initState();
    _dbHelper.init();
  }

  void getCategories() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data =
          await sqlHelper.db!.query("Categories"); //select all from categories
      if (data.isNotEmpty) {
        categories = [];
        for (var item in data) {
          // categories ??= [];
          categories!.add(ClientData.fromJson(item));
        }
      } else {
        categories = [];
      }
    } catch (e) {
      categories = [];
      print("Error in get data in categories: $e");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        actions: [
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => const CategoriesOps()));
              if (result ?? false) {
                getCategories();
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
                SELECT * FROM Categories
                WHERE name LIKE '%$value%' OR description LIKE '%$value%'
                """);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AppTable(
                columns: const [
                  DataColumn(label: Text("Id")),
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Description")),
                  DataColumn(label: Center(child: Text("Actions"))),
                ],
                source: CategoriesTableSource(
                  categories: categories,
                  onUpdate: (categoryData) async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) =>
                              CategoriesOps(categories: categoryData)),
                    );
                    if (result ?? false) {
                      getCategories();
                    }
                  },
                  onDelete: (categoryData) {
                    _attemptDeleteCategory(categoryData.id!);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _attemptDeleteCategory(int categoryId) async {
    int dependentCount = await _dbHelper.getDependentProductCount(categoryId);

    if (dependentCount > 0) {
      _showWarningDialog(dependentCount);
    } else {
      onDeleteRow(categoryId);
    }
  }

  void _showWarningDialog(int count) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.red,
          title: const Text(
            'Warning',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'There are $count rows in Products that reference this category. Cannot delete this Category.',
            style: const TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete Category"),
            content:
                const Text("Are you sure you want to delete this category?"),
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
          "Categories",
          where: "id = ?",
          whereArgs: [id],
        );
        if (result > 0) {
          getCategories();
        }
      }
    } catch (e) {
      print('Error in delete category: $e');
    }
  }
}

class CategoriesTableSource extends DataTableSource {
  List<ClientData>? categories;
  void Function(ClientData) onUpdate;
  void Function(ClientData) onDelete;

  CategoriesTableSource({
    required this.categories,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    return DataRow2(
      // onSelectChanged: (value) {},
      // selected: true,
      cells: [
        DataCell(Text("${categories?[index].id}")),
        DataCell(Text("${categories?[index].name}")),
        DataCell(Text("${categories?[index].description}")),
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (ctx) => CategoriesOps()));
                onUpdate.call(categories![index]);
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () async {
                // await onDeleteRow(categories?[index].id ?? 0);
                onDelete.call(categories![index]);
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
  int get rowCount => categories?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
