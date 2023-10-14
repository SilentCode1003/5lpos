class ProductPriceModel {
  final String productid;
  final String description;
  final String barcode;
  final String productimage;
  final String price;
  final String category;
  final int quantity;

  ProductPriceModel(this.productid, this.description, this.barcode,
      this.productimage, this.price, this.category, this.quantity);

  factory ProductPriceModel.fromJson(Map<String, dynamic> json) {
    return ProductPriceModel(
      json['productid'],
      json['description'],
      json['barcode'],
      json['productimage'],
      json['price'],
      json['category'],
      json['quantity'],
    );
  }
}
