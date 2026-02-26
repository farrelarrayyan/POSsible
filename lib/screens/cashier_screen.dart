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

  // State untuk fitur pencarian, filter, dan sorting
  String _searchQuery = '';
  String _selectedCategory = 'Semua Kategori';
  String _sortBy = 'Nama (A-Z)';

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Fungsi untuk memproses data produk (Search, Filter, Sort)
  List<Product> _getProcessedProducts(List<Product> allProducts) {
    // Search
    var processed = allProducts.where((p) => 
      p.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    // Filter kategori
    if (_selectedCategory != 'Semua Kategori') {
      processed = processed.where((p) => p.category == _selectedCategory).toList();
    }

    // Sorting
    switch (_sortBy) {
      case 'Harga Tertinggi':
        processed.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Harga Terendah':
        processed.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Stok Terbanyak':
        processed.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case 'Stok Sedikit':
        processed.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      default: // Nama A-Z
        processed.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return processed;
  }

  // Fungsi untuk menambah barang ke keranjang
  void _addToCart(Product product) {
    // Cek apakah stok asli produk memang sudah 0 sejak awal
    if (product.stock == 0) {
      ScaffoldMessenger.of(context).clearSnackBars(); // Bersihkan snackbar sebelumnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok ${product.name} kosong!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return; // Hentikan eksekusi
    }

    setState(() {
      final currentQty = _cart[product] ?? 0;
      
      // Cek apakah jumlah yang ingin dimasukkan ke keranjang melebihi sisa stok
      if (currentQty < product.stock) {
        _cart[product] = currentQty + 1;
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sisa stok ${product.name} hanya ${product.stock}!'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
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
          // Grid produk dan filters
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Ekstrak semua kategori yang ada secara otomatis
              final categories = ['Semua Kategori'];
              categories.addAll(productProvider.products.map((p) => p.category).toSet().toList());

              if (!categories.contains(_selectedCategory)) {
                _selectedCategory = 'Semua Kategori';
              }

              // Dapatkan daftar produk yang sudah diproses
              final displayedProducts = _getProcessedProducts(productProvider.products);

              return Column(
                children: [
                  // Bagian search dan fitur
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Textfield untuk search
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari nama produk...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // Row untuk filter dan sort
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _selectedCategory,
                                    icon: const Icon(Icons.filter_list),
                                    items: categories.map((String category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedCategory = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _sortBy,
                                    icon: const Icon(Icons.sort),
                                    items: ['Nama (A-Z)', 'Harga Tertinggi', 'Harga Terendah', 'Stok Terbanyak', 'Stok Sedikit']
                                        .map((String sortOption) {
                                      return DropdownMenuItem<String>(
                                        value: sortOption,
                                        child: Text(sortOption, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _sortBy = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bagian daftar produk
                  Expanded(
                    child: productProvider.products.isEmpty
                        ? const Center(child: Text('Belum ada produk untuk dijual.'))
                        : displayedProducts.isEmpty
                            ? const Center(child: Text('Produk tidak ditemukan.'))
                            : GridView.builder(
                                padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 100),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: displayedProducts.length,
                                itemBuilder: (context, index) {
                                  final product = displayedProducts[index]; 
                                  final qtyInCart = _cart[product] ?? 0;

                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => _addToCart(product),
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
                                                  style: TextStyle(
                                                    fontSize: 11, 
                                                    // Beri warna merah pada teks stok jika habis
                                                    color: product.stock == 0 ? Colors.red : Colors.grey.shade600,
                                                    fontWeight: product.stock == 0 ? FontWeight.bold : FontWeight.normal
                                                  ),
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
                                                      product.stock == 0 ? Icons.remove_shopping_cart : Icons.add_shopping_cart, // Ganti ikon jika stok habis
                                                      color: product.stock > 0 ? primaryColor : Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
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