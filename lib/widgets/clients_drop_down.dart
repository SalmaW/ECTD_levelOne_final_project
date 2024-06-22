import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/client_data.dart';
import '../helpers/sql_helper.dart';
import '../utils/constants.dart';

class ClientsDropDown extends StatefulWidget {
  final int? selectedValue;
  final void Function(int?)? onChange;
  static late bool decorationContainer;
  const ClientsDropDown({
    super.key,
    this.selectedValue,
    required this.onChange,
  });

  @override
  State<ClientsDropDown> createState() => _ClientsDropDownState();
}

class _ClientsDropDownState extends State<ClientsDropDown> {
  List<ClientData>? clients;

  @override
  void initState() {
    ClientsDropDown.decorationContainer = false;
    getClients();
    super.initState();
  }

  void getClients() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data =
          await sqlHelper.db!.query("Clients"); //select all from categories
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
      print("Error in get data $e");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return clients == null
        ? const Center(child: CircularProgressIndicator())
        : (clients?.isEmpty ?? false)
            ? const Center(child: Text("No Data Found"))
            : Container(
                decoration: ClientsDropDown.decorationContainer
                    ? BoxDecoration(
                        border: Border.all(width: 2, color: primaryColor),
                        borderRadius: BorderRadius.circular(5))
                    : BoxDecoration(
                        border: Border.all(width: 2, color: iconGrayColor),
                        borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
                  child: DropdownButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    iconEnabledColor: ClientsDropDown.decorationContainer
                        ? primaryColor
                        : iconGrayColor,
                    iconSize: 20,
                    underline: const SizedBox(),
                    isExpanded: true,
                    hint: const Text(
                      "Unnamed client",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    value: widget.selectedValue,
                    items: [
                      for (var category in clients!)
                        DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name ?? "No Name"),
                        ),
                    ],
                    onChanged: widget.onChange,
                  ),
                ),
              );
  }
}
