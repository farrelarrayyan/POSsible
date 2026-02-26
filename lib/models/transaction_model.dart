import 'transaction_item.dart';

class TransactionModel {
  final int? id;
  final String date;
  final int totalAmount;
  final String paymentMethod;
  final int cashAmount;
  
  // List untuk mempermudah membawa data di dalam aplikasi
  List<TransactionItem>? items;

  TransactionModel({
    this.id,
    required this.date,
    required this.totalAmount,
    required this.paymentMethod,
    this.cashAmount = 0,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'cashAmount': cashAmount,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      date: map['date'],
      totalAmount: map['totalAmount'],
      paymentMethod: map['paymentMethod'] ?? 'Tunai', // Default tunai
      cashAmount: map['cashAmount'] ?? 0,
    );
  }
}