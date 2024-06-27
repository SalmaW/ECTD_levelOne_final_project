import '../../utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import '../../helpers/sql_helper.dart';
import '../../models/product_data.dart';
import '../../widgets/categories_drop_down.dart';
import '../../widgets/text_form_field.dart';
import '../../widgets/app_button.dart';

class ProductsOps extends StatefulWidget {
  final ProductData? products;
  const ProductsOps({super.key, this.products});

  @override
  State<ProductsOps> createState() => _ProductsOpsState();
}

class _ProductsOpsState extends State<ProductsOps> {
  var formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? descriptionController;
  TextEditingController? priceController;
  TextEditingController? stockController;
  TextEditingController? imageController;
  String noImageController =
      "https://static-00.iconduck.com/assets.00/no-image-icon-512x512-lfoanl0w.png";
  bool isAvailable = false;
  int? selectedCategoryId;

  @override
  void initState() {
    setInitialData();
    super.initState();
  }

  void setInitialData() {
    nameController = TextEditingController(text: widget.products?.name);
    descriptionController =
        TextEditingController(text: widget.products?.description);

    imageController = TextEditingController(text: widget.products?.image);

    priceController =
        TextEditingController(text: '${widget.products?.price ?? ''}');
    stockController =
        TextEditingController(text: '${widget.products?.stock ?? ''}');

    isAvailable = widget.products?.isAvailable ?? false;
    selectedCategoryId = widget.products?.categoryId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.products != null ? "Update Date" : "Add new"),
      ),
      body: Padding(
        padding: defaultPadding,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppTextFormField(
                  controller: nameController!,
                  textInputAction: TextInputAction.next,
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
                  textInputAction: TextInputAction.next,
                  labelText: "Description",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Description is Required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        controller: priceController!,
                        labelText: "Price",
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Price is Required";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: AppTextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        controller: stockController!,
                        labelText: "Stock",
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Stock is Required";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppTextFormField(
                  controller: imageController!,
                  textInputAction: TextInputAction.next,
                  labelText: "Image",
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Switch(
                        value: isAvailable,
                        onChanged: (value) {
                          setState(() {
                            isAvailable = value;
                          });
                        }),
                    const SizedBox(width: 10),
                    const Text("Is Available"),
                  ],
                ),
                const SizedBox(height: 20),
                CategoriesDropDown(
                  selectedValue: selectedCategoryId,
                  onChange: (categoryId) {
                    if (categoryId != null) {
                      selectedCategoryId = categoryId;
                      CategoriesDropDown.decorationContainer = true;
                    } else {
                      CategoriesDropDown.decorationContainer = false;
                    }
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20),
                AppButton(
                  onPressed: () async {
                    CategoriesDropDown.decorationContainer = false;
                    await onSubmit();
                  },
                  label: widget.products != null ? "Update" : "Submit",
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
        if (widget.products != null) {
          //update
          var sqlHelper = GetIt.I.get<SqlHelper>();
          await sqlHelper.db!.update(
              'Products',
              {
                'name': nameController?.text,
                'description': descriptionController?.text,
                'price': priceController?.text,
                'stock': stockController?.text,
                'image': imageController!.text.isEmpty
                    ? noImageController
                    : imageController?.text,
                'isAvailable': isAvailable,
                'categoryId': selectedCategoryId,
              },
              where: 'id =?',
              whereArgs: [widget.products?.id]);
          sqlHelper.backupDatabase();
        } else {
          var sqlHelper = GetIt.I.get<SqlHelper>();
          await sqlHelper.db!.insert("Products", {
            'name': nameController?.text,
            'description': descriptionController?.text,
            'price': priceController?.text,
            'stock': stockController?.text,
            'image': imageController!.text.isEmpty
                ? noImageController
                : imageController?.text,
            'isAvailable': isAvailable,
            'categoryId': selectedCategoryId,
          });
          sqlHelper.backupDatabase();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Product Saved Successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
                "Please Make Sure to Select a Category or You Are Connected to the WIFI")),
      );
      print("Error in Creating Product: $e");
    }
  }
}
