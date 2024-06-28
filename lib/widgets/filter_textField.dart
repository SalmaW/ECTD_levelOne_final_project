import 'package:flutter/material.dart';

class FilterTextField extends StatelessWidget {
  final void Function(String)? onChange;
  final TextEditingController? addressController;
  final TextInputType? textInputType;
  final String label;
  const FilterTextField({
    this.textInputType,
    required this.onChange,
    required this.addressController,
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      keyboardType: textInputType ?? TextInputType.text,
      controller: addressController,
      onChanged: onChange,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.filter_alt_rounded),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        labelText: label,
      ),
    );
  }
}
