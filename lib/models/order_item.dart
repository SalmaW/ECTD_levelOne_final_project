import '../models/product_data.dart';

class OrderItem {
  int? orderId;
  int? productId;
  int? productCount;
  ProductData? productData;

  OrderItem.fromJson(Map<String, dynamic> json) {
    orderId = json["orderId"];
    productId = json["productId"];
    productCount = json["productCount"];
    productData = ProductData.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "productId": productId,
      "productCount": productCount,
      "productData": productData
    };
  }

  OrderItem({
    this.orderId,
    this.productId,
    this.productCount,
    this.productData,
  });
}
