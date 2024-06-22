import 'package:flutter/material.dart';

import '../utils/constants.dart';

enum Currency { EGP, EUR, USD }

class CurrencySelectionScreen extends StatefulWidget {
  final ValueChanged<Currency> onCurrencyChanged;

  const CurrencySelectionScreen({super.key, required this.onCurrencyChanged});

  @override
  _CurrencySelectionScreenState createState() =>
      _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  Currency _selectedCurrency = Currency.USD; // Default currency is USD

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Currency>(
      dropdownColor: primaryColor,
      iconEnabledColor: primaryUltraLightColor,
      style: const TextStyle(
        color: primaryUltraLightColor,
      ),
      underline: const SizedBox(),
      value: _selectedCurrency,
      onChanged: (Currency? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCurrency = newValue;
          });
          widget.onCurrencyChanged(newValue);
        }
      },
      items: Currency.values.map((Currency currency) {
        return DropdownMenuItem<Currency>(
          value: currency,
          child: Text(currencyToString(currency)),
        );
      }).toList(),
    );
  }

  String currencyToString(Currency currency) {
    switch (currency) {
      case Currency.EGP:
        return 'EGP';
      case Currency.EUR:
        return 'EUR';
      case Currency.USD:
        return 'USD';
    }
  }
}
