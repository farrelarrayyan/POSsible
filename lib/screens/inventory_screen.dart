import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'add_product_screen.dart';

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

  @override
  Widget build(BuildContext context) {
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

          // Tampilkan daftar produk
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
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
                  trailing: Text(
                    'Rp ${product.price}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onTap: () {
                    // TODO: form edit produk
                  },
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