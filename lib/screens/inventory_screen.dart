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
  @override
  void initState() {
    super.initState();
    // Memuat data produk saat layar dibuka
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).loadProducts());
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

          // Tampilkan pesan kosong jika tidak ada produk
          if (productProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada produk',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tekan tombol + di bawah untuk\nmenambahkan produk pertamamu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Tampilan daftar produk
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          const SizedBox(width: 16), // Jarak antar tombol
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
}