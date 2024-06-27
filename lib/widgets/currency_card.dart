import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CurrencyCard extends StatelessWidget {
  final String? selectedCurrencyFrom; // Default selected currency From
  final String? selectedCurrencyTo; // Default selected currency To
  final double? exchangeRate;

  const CurrencyCard(
      {this.selectedCurrencyFrom,
      this.selectedCurrencyTo,
      this.exchangeRate,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xffFFF2CD),
      child: Padding(
        padding: inputPadding,
        child: Text(
          'Exchange Rate: 1 $selectedCurrencyFrom = $exchangeRate $selectedCurrencyTo',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xffF27D10),
          ),
        ),
      ),
    );
  }
}
