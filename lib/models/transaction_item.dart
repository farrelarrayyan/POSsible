class TransactionItem {
  final int? id;
  final int? transactionId;
  final int productId;
  final String productName;
  final int productPrice;
  final int quantity;

  TransactionItem({
    this.id,
    this.transactionId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      transactionId: map['transactionId'],
      productId: map['productId'],
      productName: map['productName'],
      productPrice: map['productPrice'],
      quantity: map['quantity'],
    );
  }
}