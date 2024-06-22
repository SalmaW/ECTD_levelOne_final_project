import '../../helpers/sql_helper.dart';
import '../../models/category_data.dart';
import '../../widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../widgets/app_button.dart';

class CategoriesOps extends StatefulWidget {
  final ClientData? categories;
  const CategoriesOps({super.key, this.categories});

  @override
  State<CategoriesOps> createState() => _CategoriesOpsState();
}

class _CategoriesOpsState extends State<CategoriesOps> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? descriptionController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.categories?.name);
    descriptionController =
        TextEditingController(text: widget.categories?.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categories != null ? "Update Date" : "Add new"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              AppTextFormField(
                controller: nameController!,
                labelText: "Name",
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Name is Required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppTextFormField(
                controller: descriptionController!,
                labelText: "Description",
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Description is Required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppButton(
                onPressed: () async {
                  await onSubmit();
                },
                label: widget.categories != null ? "Update" : "Submit",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        if (widget.categories != null) {
          //update
          var sqlHelper = GetIt.I.get<SqlHelper>();
          await sqlHelper.db!.update(
            "Categories",
            {
              "name": nameController?.text,
              "description": descriptionController?.text,
            },
            where: 'id = ?',
            whereArgs: [widget.categories?.id],
          );
          sqlHelper.backupDatabase();
        } else {
          var sqlHelper = GetIt.I.get<SqlHelper>();
          await sqlHelper.db!.insert("Categories", {
            "name": nameController?.text,
            "description": descriptionController?.text,
          });
          sqlHelper.backupDatabase();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Category Saved Successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text("Error in Creating Category: $e")),
      );
    }
  }
}
