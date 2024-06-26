class Order {
  int? id;
  String? label;
  double? totalPrice;
  double? discount;
  int? clientId;
  String? clientName;
  String? clientPhone;
  String? clientAddress;

  Order.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    label = data["label"];
    totalPrice = data["totalPrice"];
    discount = data["discount"];
    clientId = data["clientId"];
    clientName = data["clientName"];
    clientPhone = data["clientPhone"];
    clientAddress = data["clientAddress"];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "label": label,
      "totalPrice": totalPrice,
      "discount": discount,
      "clientId": clientId
    };
  }

  Order(
      {this.id,
      this.label,
      this.totalPrice,
      this.discount,
      this.clientId,
      this.clientName,
      this.clientPhone,
      this.clientAddress});
}
