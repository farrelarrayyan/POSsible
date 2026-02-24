class Product {
  final int? id;
  final String name;
  final String category;
  final String imagePath;
  final int weight;
  final int stock;
  final int price;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.weight,
    required this.stock,
    required this.price,
  });

  // Fungsi untuk mengubah object Product menjadi format Map untuk dimasukkan ke sqflite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imagePath': imagePath,
      'weight': weight,
      'stock': stock,
      'price': price,
    };
  }

  // Fungsi untuk mengubah Map dari sqflite kembali menjadi object Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      imagePath: map['imagePath'],
      weight: map['weight'],
      stock: map['stock'],
      price: map['price'],
    );
  }
}