class ProductModel {
  final int id;
  final String name;
  final int quantity;
  final String expiryDate;
  final String status;
  final String categoryName;
  final int userId;
  final String? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.status,
    required this.categoryName,
    required this.userId,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      expiryDate: json['expiryDate'],
      status: json['status'],
      categoryName: json['categoryName'],
      userId: json['userId'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate,
      'status': status,
      'categoryName': categoryName,
      'userId': userId,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
