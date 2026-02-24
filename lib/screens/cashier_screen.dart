import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'checkout_screen.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  // Menyimpan keranjang belanja (key = produk, value = jumlah)
  final Map<Product, int> _cart = {};

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Fungsi untuk menambah barang ke keranjang
  void _addToCart(Product product) {
    setState(() {
      final currentQty = _cart[product] ?? 0;
      if (currentQty < product.stock) {
        _cart[product] = currentQty + 1;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stok ${product.name} tidak mencukupi!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  // Fungsi untuk mengurangi barang dari keranjang
  void _removeFromCart(Product product) {
    setState(() {
      final currentQty = _cart[product] ?? 0;
      if (currentQty > 1) {
        _cart[product] = currentQty - 1;
      } else {
        _cart.remove(product); // Hapus dari keranjang jika jumlahnya 0
      }
    });
  }

  // Menghitung total harga di keranjang
  int get _totalPrice {
    return _cart.entries.fold(0, (total, entry) {
      return total + (entry.key.price * entry.value);
    });
  }

  // Menghitung total jumlah barang di keranjang
  int get _totalItems {
    return _cart.values.fold(0, (total, qty) => total + qty);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    // Menentukan lebar layar dan jumlah kolom
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = (screenWidth / 160).floor().clamp(2, 10);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Kasir'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Gird produk
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productProvider.products.isEmpty) {
                return const Center(child: Text('Belum ada produk untuk dijual.'));
              }

              return GridView.builder(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 100),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  final qtyInCart = _cart[product] ?? 0;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      // Jika stok ada, tap seluruh card akan menambah produk ke keranjang
                      onTap: product.stock > 0 ? () => _addToCart(product) : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Foto Produk
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                image: product.imagePath.isNotEmpty
                                    ? DecorationImage(
                                        image: FileImage(File(product.imagePath)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: product.imagePath.isEmpty
                                  ? const Icon(Icons.image_not_supported, color: Colors.grey, size: 40)
                                  : null,
                            ),
                          ),
                          
                          // Info Produk
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${product.weight}g • Stok: ${product.stock}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormatter.format(product.price),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                          // Tombol + dan -
                          Container(
                            decoration: BoxDecoration(
                              color: qtyInCart > 0 ? primaryColor.withOpacity(0.1) : Colors.transparent,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            ),
                            child: qtyInCart > 0
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        color: primaryColor,
                                        iconSize: 28,
                                        onPressed: () => _removeFromCart(product),
                                      ),
                                      Text(
                                        '$qtyInCart',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        color: primaryColor,
                                        iconSize: 28,
                                        onPressed: () => _addToCart(product),
                                      ),
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Icon(
                                      Icons.add_shopping_cart,
                                      color: product.stock > 0 ? primaryColor : Colors.grey,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Bottom bar
          if (_totalItems > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Total harga dan produk
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currencyFormatter.format(_totalPrice),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Total: $_totalItems produk',
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      
                      // Tombol lanjut checkout
                      Card(
                        elevation: 2,
                        color: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Mengirim data keranjang ke checkooutscreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutScreen(cart: _cart),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  'Checkout',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}