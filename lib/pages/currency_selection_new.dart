import 'package:final_project/widgets/currency_card.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../helpers/sql_helper.dart';
import '../utils/constants.dart';

class ExchangeRateDropdowns extends StatefulWidget {
  final String onCurrencyChanged;
  static String line = '';

  const ExchangeRateDropdowns({required this.onCurrencyChanged, super.key});

  @override
  _ExchangeRateDropdownsState createState() => _ExchangeRateDropdownsState();
}

class _ExchangeRateDropdownsState extends State<ExchangeRateDropdowns> {
  List<String> currencies = ['USD', 'EUR', 'EGP'];
  String? selectedCurrencyFrom; // Default selected currency From
  String? selectedCurrencyTo; // Default selected currency To
  double? exchangeRate; // Exchange rate from USD to EGP

  @override
  void initState() {
    ExchangeRateDropdowns.line =
        '1 ${selectedCurrencyFrom ?? 'USD'} = ${exchangeRate ?? 47.66} ${selectedCurrencyTo ?? 'EGP'}';
    selectedCurrencyFrom = selectedCurrencyFrom ?? 'USD';
    selectedCurrencyTo = widget.onCurrencyChanged;
    exchangeRate = exchangeRate ?? 47.66;
    updateExchangeRate(selectedCurrencyFrom, selectedCurrencyTo);
    super.initState();
  }

  void currencyDuplicateRemover(
      String selectedCurrencyFrom, String selectedCurrencyT) {
    switch (selectedCurrencyT) {
      case 'EGP':
        switch (selectedCurrencyFrom) {
          case 'EGP':
            selectedCurrencyTo = 'USD';
            break;
        }

      case 'USD':
        switch (selectedCurrencyFrom) {
          case 'USD':
            selectedCurrencyTo = 'EGP';
            break;
        }

      case 'EUR':
        switch (selectedCurrencyFrom) {
          case 'EUR':
            selectedCurrencyTo = 'EGP';
            break;
        }
    }
  }

  Future<void> updateExchangeRate(String? from, String? to) async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      double rate = await sqlHelper.getExchangeRate(from!, to!);
      setState(() {
        exchangeRate = rate;
      });
    } catch (e) {
      print('Error updating exchange rate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("From "),
            const SizedBox(width: 10),
            DropdownButton<String>(
              iconEnabledColor: primaryColor,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              underline: const SizedBox(),
              value: selectedCurrencyFrom,
              onChanged: (String? newValue) async {
                selectedCurrencyFrom = newValue!;
                currencyDuplicateRemover(
                    selectedCurrencyFrom!, selectedCurrencyTo!);
                await updateExchangeRate(
                    selectedCurrencyFrom, selectedCurrencyTo);
                setState(() {});
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(width: 20),
            const Text("to "),
            const SizedBox(width: 10),
            DropdownButton<String>(
              iconEnabledColor: primaryColor,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              underline: const SizedBox(),
              value: selectedCurrencyTo,
              onChanged: (String? newValue) async {
                selectedCurrencyTo = newValue!;
                currencyDuplicateRemover(
                    selectedCurrencyFrom!, selectedCurrencyTo!);
                await updateExchangeRate(
                    selectedCurrencyFrom, selectedCurrencyTo);
                setState(() {});
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        CurrencyCard(
            selectedCurrencyFrom: selectedCurrencyFrom,
            selectedCurrencyTo: selectedCurrencyTo,
            exchangeRate: exchangeRate),
      ],
    );
  }

  // currencyLine() {
  //   ExchangeRateDropdowns.line =
  //       '1 ${selectedCurrencyFrom ?? 'USD'} = ${exchangeRate ?? 47.66} ${selectedCurrencyTo ?? 'EGP'}';
  //   return ExchangeRateDropdowns.line;
  // }
}
