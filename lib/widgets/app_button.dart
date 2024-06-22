import 'package:final_project/utils/constants.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final Color color;

  const AppButton(
      {super.key,
      required this.onPressed,
      required this.label,
      this.color = greenColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: inputPadding,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: label == "Confirm" ? greenColor : primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          fixedSize: const Size(double.maxFinite, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
