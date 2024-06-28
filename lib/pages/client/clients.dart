import 'package:data_table_2/data_table_2.dart';
import 'package:final_project/widgets/filter_textField.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../utils/constants.dart';
import '../../widgets/search_textField.dart';
import '../../widgets/app_table.dart';
import '../../models/client_data.dart';
import '../../pages/client/client_ops.dart';
import '../../helpers/sql_helper.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<ClientData>? clients;
  bool sortAscending = true;
  String? selectedSortCriteria;
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    getClients();
    super.initState();
  }

  void getClients({String? addressFilter}) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var query = "SELECT * FROM Clients";
      if (addressFilter != null && addressFilter.isNotEmpty) {
        query += " WHERE address LIKE '%$addressFilter%'";
      }
      var data =
          await sqlHelper.db!.rawQuery(query); //select all from categories
      if (data.isNotEmpty) {
        clients = [];
        for (var item in data) {
          clients!.add(ClientData.fromJson(item));
        }
      } else {
        clients = [];
      }
    } catch (e) {
      clients = [];
      print("Error in get data in clients: $e");
    }
    sortClients();
  }

  void sortClients() {
    if (clients != null && selectedSortCriteria != null) {
      switch (selectedSortCriteria) {
        case 'Name':
          clients!.sort((a, b) => sortAscending
              ? a.name!.compareTo(b.name!)
              : b.name!.compareTo(a.name!));
          break;
        case 'Email':
          clients!.sort((a, b) => sortAscending
              ? a.email!.compareTo(b.email!)
              : b.email!.compareTo(a.email!));
          break;
        // Add more cases for additional criteria here
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sortCriteria = <String>['Name', 'Email'];

    // Ensure that the selectedSortCriteria is valid and in the list
    if (selectedSortCriteria != null &&
        !sortCriteria.contains(selectedSortCriteria)) {
      selectedSortCriteria = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients"),
        actions: [
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => const ClientsOps()));
              if (result ?? false) {
                getClients();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  value: selectedSortCriteria,
                  hint: const Text('Sort by'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSortCriteria =
                          newValue; // Update selectedSortCriteria
                      sortClients(); // Sort clients based on new criteria
                    });
                  },
                  items: sortCriteria
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                ),
                Expanded(
                  child: Padding(
                    padding: inputPadding,
                    child: FilterTextField(
                      addressController: addressController,
                      label: "Filter by Address",
                      onChange: (value) {
                        getClients(addressFilter: value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SearchTextField(
              rawQueryText: (value) async {
                var sqlHelper = GetIt.I.get<SqlHelper>();
                await sqlHelper.db!.rawQuery("""
                SELECT * FROM Clients
                WHERE name LIKE '%$value%' OR phone LIKE '%$value%'
                """);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AppTable(
                minWidth: 1000,
                columns: const [
                  DataColumn(label: Text("Id")),
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Email")),
                  DataColumn(label: Text("Phone")),
                  DataColumn(label: Text("Address")),
                  DataColumn(label: Center(child: Text("Actions"))),
                ],
                source: ClientsTableSource(
                  clients: clients ?? [],
                  onUpdate: (clients) async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => ClientsOps(clients: clients)),
                    );
                    if (result ?? false) {
                      getClients();
                    }
                  },
                  onDelete: (clients) {
                    onDeleteRow(clients.id!);
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
            title: const Text("Delete Client"),
            content: const Text("Are you sure you want to delete this client?"),
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
        // var result = await SqlHelper.deleteClient(clients![id]);
        // if (result > 0) {
        //   SqlHelper.getAllClients();
        // }
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          "Clients",
          where: "id = ?",
          whereArgs: [id],
        );
        if (result > 0) {
          getClients();
        }
      }
    } catch (e) {
      print('Error in delete client: $e');
    }
  }
}

class ClientsTableSource extends DataTableSource {
  List<ClientData>? clients;
  void Function(ClientData) onUpdate;
  void Function(ClientData) onDelete;

  ClientsTableSource({
    required this.clients,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    return DataRow2(
      cells: [
        DataCell(Text("${clients?[index].id}")),
        DataCell(Text("${clients?[index].name}")),
        DataCell(Text("${clients?[index].email}")),
        DataCell(Text("${clients?[index].phone}")),
        DataCell(Text("${clients?[index].address}")),
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                onUpdate.call(clients![index]);
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () async {
                onDelete.call(clients![index]);
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
  int get rowCount => clients?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
