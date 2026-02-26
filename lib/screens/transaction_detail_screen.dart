import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item.dart';
import '../services/database_helper.dart';
import '../providers/store_provider.dart'; 

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  List<TransactionItem> _items = [];
  bool _isLoading = true;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadTransactionItems();
  }

  Future<void> _loadTransactionItems() async {
    if (widget.transaction.id != null) {
      final items = await DatabaseHelper.instance.getTransactionItems(widget.transaction.id!);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  // Format tanggal
  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Memanggil StoreProvider untuk mendapatkan data toko
    final storeProvider = Provider.of<StoreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: isDark ? Colors.grey.shade900 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header toko
                      Center( // Bungkus dengan Center agar rapi di tengah
                        child: storeProvider.imagePath.isNotEmpty
                            ? ClipOval(
                                child: Image.file(
                                  File(storeProvider.imagePath),
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover, 
                                ),
                              )
                            : CircleAvatar(
                                radius: 32,
                                backgroundColor: primaryColor.withOpacity(0.1),
                                child: Icon(Icons.storefront, size: 32, color: primaryColor),
                              ),
                      ),
                      // Nama toko
                      const SizedBox(height: 12),
                      Text(
                        storeProvider.storeName.isNotEmpty 
                            ? storeProvider.storeName 
                            : 'Nama Toko',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      // Lokasi toko
                      if (storeProvider.storeLocation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          storeProvider.storeLocation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: 24),
                      
                      // Info transaksi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ID Transaksi:', style: TextStyle(color: Colors.grey)),
                          Text('#${widget.transaction.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tanggal:', style: TextStyle(color: Colors.grey)),
                          Text(_formatDate(widget.transaction.date)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Metode Pembayaran:', style: TextStyle(color: Colors.grey)),
                          Text(widget.transaction.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      
                      const Divider(height: 32, thickness: 1),

                      // Daftar barang yang dibeli
                      const Text('RINCIAN PESANAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                      const SizedBox(height: 16),
                      
                      ..._items.map((item) {
                        final subTotal = item.productPrice * item.quantity;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      '@ ${currencyFormatter.format(item.productPrice)}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Text(currencyFormatter.format(subTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }),

                      const Divider(height: 32, thickness: 1),

                      // Total keseluruhan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL BAYAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            currencyFormatter.format(widget.transaction.totalAmount),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: primaryColor),
                          ),
                        ],
                      ),
                      
                      // Informasi tunai dan kembalian
                      if (widget.transaction.paymentMethod == 'Tunai' && widget.transaction.cashAmount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tunai Diterima', style: TextStyle(color: Colors.grey)),
                            Text(currencyFormatter.format(widget.transaction.cashAmount)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kembalian', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              currencyFormatter.format(widget.transaction.cashAmount - widget.transaction.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}