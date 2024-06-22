import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/category_data.dart';
import '../helpers/sql_helper.dart';
import '../utils/constants.dart';

class CategoriesDropDown extends StatefulWidget {
  final int? selectedValue;
  final void Function(int?)? onChange;
  static late bool decorationContainer;
  const CategoriesDropDown({
    super.key,
    this.selectedValue,
    required this.onChange,
  });

  @override
  State<CategoriesDropDown> createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<CategoriesDropDown> {
  List<ClientData>? categories;
  @override
  void initState() {
    CategoriesDropDown.decorationContainer = false;
    getCategories();
    super.initState();
  }

  void getCategories() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data =
          await sqlHelper.db!.query("Categories"); //select all from categories
      if (data.isNotEmpty) {
        categories = [];
        for (var item in data) {
          categories!.add(ClientData.fromJson(item));
        }
      } else {
        categories = [];
      }
    } catch (e) {
      categories = [];
      print("Error in get data $e");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return categories == null
        ? const Center(child: CircularProgressIndicator())
        : (categories?.isEmpty ?? false)
            ? const Center(child: Text("No Data Found"))
            : Container(
                decoration: CategoriesDropDown.decorationContainer
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
                    iconEnabledColor: CategoriesDropDown.decorationContainer
                        ? primaryColor
                        : iconGrayColor,
                    underline: const SizedBox(),
                    isExpanded: true,
                    hint: const Text(
                      "Select Category",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    value: widget.selectedValue,
                    items: [
                      for (var category in categories!)
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
