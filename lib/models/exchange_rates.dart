class ExchangeRate {
  int id;
  String currencyFrom;
  String currencyTo;
  double rate;

  ExchangeRate({
    required this.id,
    required this.currencyFrom,
    required this.currencyTo,
    required this.rate,
  });

  // Convert ExchangeRate object to a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currencyFrom': currencyFrom,
      'currencyTo': currencyTo,
      'rate': rate,
    };
  }

  // Create an ExchangeRate object from a Map object
  factory ExchangeRate.fromMap(Map<String, dynamic> map) {
    return ExchangeRate(
      id: map['id'],
      currencyFrom: map['currencyFrom'],
      currencyTo: map['currencyTo'],
      rate: map['rate'],
    );
  }
}
