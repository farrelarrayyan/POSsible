import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // State untuk fitur pencarian, filter, dan sorting
  String _searchQuery = '';
  String _selectedCategory = 'Semua Kategori';
  String _sortBy = 'Nama (A-Z)'; // default

  @override
  void initState() {
    super.initState();
    // Memuat data produk saat layar dibuka
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).loadProducts());
  }

  // Fungsi untuk search, filter, sort
  List<Product> _getProcessedProducts(List<Product> allProducts) {
    // Search
    var processed = allProducts.where((p) => 
      p.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    // Filter kategori
    if (_selectedCategory != 'Semua Kategori') {
      processed = processed.where((p) => p.category == _selectedCategory).toList();
    }

    // Sort
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
      default: // Nama (A-Z)
        processed.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return processed;
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus
  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Produk?'),
          content: Text('Apakah kamu yakin ingin menghapus "${product.name}"? Data yang dihapus tidak dapat dikembalikan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (product.id != null) {
                  // Panggil fungsi delete dari provider
                  await Provider.of<ProductProvider>(context, listen: false).deleteProduct(product.id!);
                  
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produk berhasil dihapus!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0, 
    );
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk & Inventori'),
        elevation: 0,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // Loading indikator
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Ekstrak semua kategori yang ada secara otomatis
          final categories = ['Semua Kategori'];
          categories.addAll(productProvider.products.map((p) => p.category).toSet().toList());

          // Pastikan kategori pilihan valid
          if (!categories.contains(_selectedCategory)) {
            _selectedCategory = 'Semua Kategori';
          }

          // Dapatkan daftar produk yang sudah diproses
          final displayedProducts = _getProcessedProducts(productProvider.products);

          return Column(
            children: [
              // Bagian search dan filter
              Container(
                padding: const EdgeInsets.all(16.0),
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
                    
                    // Row untuk filyter kategori dan sort
                    Row(
                      children: [
                        // Dropdown filter kategori
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
                        
                        // Dropdown menu sorting
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

              // Daftar produk
              Expanded(
                child: productProvider.products.isEmpty
                    ? _buildEmptyState('Belum ada produk', 'Tekan tombol + di bawah untuk\nmenambahkan produk pertamamu.')
                    : displayedProducts.isEmpty
                        ? _buildEmptyState('Produk tidak ditemukan', 'Coba ubah kata kunci pencarian\natau filter kategori Anda.')
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 88.0),
                            itemCount: displayedProducts.length,
                            itemBuilder: (context, index) {
                              final product = displayedProducts[index];
                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  children: [
                                    // Foto
                                    ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                      leading: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                          image: product.imagePath.isNotEmpty
                                              ? DecorationImage(image: FileImage(File(product.imagePath)), fit: BoxFit.cover)
                                              : null,
                                        ),
                                        child: product.imagePath.isEmpty
                                            ? const Icon(Icons.image_not_supported, color: Colors.grey)
                                            : null,
                                      ),
                                      // Kategori dan stok
                                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Kategori: ${product.category}', style: const TextStyle(fontSize: 12)),
                                            Text(
                                              'Stok: ${product.stock}', 
                                              style: TextStyle(
                                                color: product.stock < 5 ? Colors.red : Colors.green, 
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),             
                                      // Harga (Formatted)
                                      trailing: Text(
                                        currencyFormatter.format(product.price),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                                      ),
                                    ),
                                    
                                    // Tombol edit dan delete
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12.0, bottom: 8.0), 
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                                            tooltip: 'Edit Produk',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditProductScreen(product: product),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                            tooltip: 'Hapus Produk',
                                            onPressed: () => _showDeleteConfirmation(context, product),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      // Tombol tambah produk
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget bantuan untuk menampilkan state kosong
  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}