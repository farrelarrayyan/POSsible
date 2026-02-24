import 'transaction_item.dart';

class TransactionModel {
  final int? id;
  final String date;
  final int totalAmount;
  
  // List untuk mempermudah membawa data di dalam aplikasi
  List<TransactionItem>? items;

  TransactionModel({
    this.id,
    required this.date,
    required this.totalAmount,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'totalAmount': totalAmount,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      date: map['date'],
      totalAmount: map['totalAmount'],
    );
  }
}