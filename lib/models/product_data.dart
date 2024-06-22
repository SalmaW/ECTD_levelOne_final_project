class ProductData {
  int? id;
  String? name;
  String? description;
  double? price;
  int? stock;
  bool? isAvailable;
  String? image;
  int? categoryId;
  String? categoryName;
  String? categoryDescription;

  ProductData();

  ProductData.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    name = data["name"];
    description = data["description"];
    price = data["price"];
    stock = data["stock"];
    isAvailable = data["isAvailable"] == 1 ? true : false;
    image = data["image"];
    categoryId = data["categoryId"];
    categoryName = data["categoryName"];
    categoryDescription = data["categoryDescription"];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "stock": stock,
      "isAvailable": isAvailable,
      "image": image,
      "categoryId": categoryId,
    };
  }
}
