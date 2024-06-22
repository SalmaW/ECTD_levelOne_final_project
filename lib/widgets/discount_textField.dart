import 'package:final_project/utils/constants.dart';
import 'package:flutter/material.dart';

class DiscountTextField extends StatelessWidget {
  final void Function(String)? onChange;
  final TextEditingController discountController;
  static bool decorationContainer = false;
  const DiscountTextField({
    required this.discountController,
    required this.onChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      controller: discountController,
      textInputAction: TextInputAction.done,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChange,
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.percent_rounded),
        suffixIconColor: decorationContainer ? primaryColor : iconGrayColor,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              width: 1.3,
              color: decorationContainer ? primaryColor : iconGrayColor),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        labelText: 'Add Discount',
        labelStyle: TextStyle(
            color: decorationContainer ? primaryColor : iconGrayColor),
      ),
    );
  }
}
