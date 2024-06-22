import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/client_data.dart';
import '../../helpers/sql_helper.dart';
import '../../widgets/text_form_field.dart';
import '../../widgets/app_button.dart';

class ClientsOps extends StatefulWidget {
  final ClientData? clients;
  const ClientsOps({super.key, this.clients});

  @override
  State<ClientsOps> createState() => _ClientsOpsState();
}

class _ClientsOpsState extends State<ClientsOps> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? emailController;
  TextEditingController? phoneController;
  TextEditingController? addressController;

  final emailFocusNode = FocusNode();
  final nameFocusNode = FocusNode();
  final addressFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();

  @override
  void initState() {
    nameController = TextEditingController(text: widget.clients?.name);
    emailController = TextEditingController(text: widget.clients?.email);
    phoneController = TextEditingController(text: widget.clients?.phone);
    addressController = TextEditingController(text: widget.clients?.address);
    super.initState();
  }

  @override
  void dispose() {
    nameController?.dispose();
    emailController?.dispose();
    addressController?.dispose();
    phoneController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clients != null ? "Update Data" : "Add New"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppTextFormField(
                  controller: nameController!,
                  labelText: "Name",
                  validator: (value) {
                    if (value!.isEmpty) {
                      emailFocusNode.requestFocus();
                      return "Name is Required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AppTextFormField(
                  controller: emailController!,
                  labelText: "Email",
                  validator: (value) {
                    if (value!.isEmpty) {
                      emailFocusNode.requestFocus();
                      return "Email is Required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AppTextFormField(
                  controller: phoneController!,
                  textInputType: TextInputType.number,
                  labelText: "Phone",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Phone is Required";
                    }
                    if (value.length < 11) {
                      phoneFocusNode.requestFocus();
                      return 'Invalid Phone Number, must be 11 numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AppTextFormField(
                  controller: addressController!,
                  labelText: "Address",
                  validator: (value) {
                    if (value!.isEmpty) {
                      addressFocusNode.requestFocus();
                      return "Address is Required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AppButton(
                  onPressed: () async {
                    await onSubmit();
                  },
                  label: widget.clients != null ? "Update" : "Submit",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        if (widget.clients != null) {
          //update
          var sqlHelper = GetIt.I.get<SqlHelper>();
          await sqlHelper.db!.update(
            "Clients",
            {
              "name": nameController?.text,
              "email": emailController?.text,
              "phone": phoneController?.text,
              "address": addressController?.text,
            },
            where: 'id = ?',
            whereArgs: [widget.clients?.id],
          );
          sqlHelper.backupDatabase();
          // SqlHelper.updateClient(widget.clients!);
        } else {
          var sqlHelper = GetIt.I.get<SqlHelper>();
          await sqlHelper.db!.insert("Clients", {
            "name": nameController?.text,
            "email": emailController?.text,
            "phone": phoneController?.text,
            "address": addressController?.text,
          });
          sqlHelper.backupDatabase();
          // SqlHelper.addClient(widget.clients!);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Client Saved Successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text("Error in Creating Client: $e")),
      );
    }
  }
}
