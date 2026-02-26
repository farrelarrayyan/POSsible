import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item.dart';
import '../services/database_helper.dart';
import '../providers/product_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<Product, int> cart; // Data keranjang

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'Tunai'; // Default tunai
  final TextEditingController _cashController = TextEditingController();
  int _cashGiven = 0;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  int get _totalPrice {
    return widget.cart.entries.fold(0, (total, entry) {
      return total + (entry.key.price * entry.value);
    });
  }

  int get _change {
    if (_paymentMethod == 'Tunai') {
      return _cashGiven - _totalPrice;
    }
    return 0; // QRIS
  }

  bool get _isPaymentValid {
    if (_paymentMethod == 'QRIS') return true;
    return _cashGiven >= _totalPrice;
  }

  // Menyimpan transaksi ke database
  Future<void> _processTransaction() async {
    if (!_isPaymentValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uang tunai kurang dari total belanja!')),
      );
      return;
    }

    // Buat Nota Utama
    final newTransaction = TransactionModel(
      date: DateTime.now().toIso8601String(), // Simpan waktu dengan format ISO
      totalAmount: _totalPrice,
      paymentMethod: _paymentMethod,
      cashAmount: _paymentMethod == 'Tunai' ? _cashGiven : 0,
    );

    // Buat Daftar Item yang Dibeli
    final List<TransactionItem> items = widget.cart.entries.map((entry) {
      return TransactionItem(
        productId: entry.key.id!,
        productName: entry.key.name,
        productPrice: entry.key.price,
        quantity: entry.value,
      );
    }).toList();

    // Masukkan ke Database
    await DatabaseHelper.instance.insertTransaction(newTransaction, items);

    // Memuat ulang data produk agar stok terbaru muncul di layar
    if (!mounted) return;
    await Provider.of<ProductProvider>(context, listen: false).loadProducts();

    // Pindah ke Halaman Sukses
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          total: _totalPrice,
          paymentMethod: _paymentMethod,
          change: _change,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Ringkasan pesanan
          const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Looping isi keranjang
                  ...widget.cart.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${entry.value}x ${entry.key.name}'),
                          ),
                          Text(currencyFormatter.format(entry.key.price * entry.value)),
                        ],
                      ),
                    );
                  }),
                  
                  // Widget total bayar
                  const Divider(height: 24, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        currencyFormatter.format(_totalPrice),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Pilihan metode pembayaran
          const Text('Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Tunai'),
                  value: 'Tunai',
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                  contentPadding: EdgeInsets.zero,
                  activeColor: primaryColor,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('QRIS'),
                  value: 'QRIS',
                  groupValue: _paymentMethod,
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                  contentPadding: EdgeInsets.zero,
                  activeColor: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Area input tunai atau QR dummy
          if (_paymentMethod == 'Tunai') ...[
            TextField(
              controller: _cashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Uang Tunai Diterima (Rp)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments),
              ),
              onChanged: (value) {
                setState(() {
                  _cashGiven = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 16),
            
            Card(
              color: _change >= 0 
                  ? (isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50) 
                  : (isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_change >= 0 ? 'Kembalian:' : 'Uang Kurang:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      currencyFormatter.format(_change.abs()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _change >= 0 
                            ? (isDark ? Colors.green.shade400 : Colors.green.shade700) 
                            : (isDark ? Colors.red.shade400 : Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(Icons.qr_code_2, size: 120, color: Colors.grey.shade800),
                  const SizedBox(height: 8),
                  const Text('Minta pelanggan scan QR ini untuk membayar', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),

          // Tombol proses transaksi
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _processTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Proses Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }
}

// Halaman transaksi sukses
class SuccessScreen extends StatelessWidget {
  final int total;
  final String paymentMethod;
  final int change;

  const SuccessScreen({
    super.key,
    required this.total,
    required this.paymentMethod,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Icon(Icons.check_circle, size: 100, color: Colors.green),
                const SizedBox(height: 24),
                const Text('Transaksi Berhasil!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Pembayaran melalui $paymentMethod', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                
                const SizedBox(height: 32),
                
                Card(
                  elevation: 0,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Belanja:', style: TextStyle(fontSize: 16)),
                            Text(currencyFormatter.format(total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (paymentMethod == 'Tunai') ...[
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Kembalian:', style: TextStyle(fontSize: 16)),
                              Text(
                                currencyFormatter.format(change), 
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.green.shade400 : Colors.green)
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Tombol kembali
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // kembali ke homescreen
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}