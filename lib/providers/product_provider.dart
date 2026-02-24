import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/database_helper.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  // Getter agar variabel bisa dibaca oleh UI
  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // Mengambil semua produk saat aplikasi dibuka
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners(); // Notify UI untuk menampilkan loading indicator

    _products = await DatabaseHelper.instance.getAllProducts();

    _isLoading = false;
    notifyListeners(); // Notify UI bahwa data sudah siap ditampilkan
  }

  // Mengambil produk berdasarkan kategori
  Future<void> loadProductsByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    _products = await DatabaseHelper.instance.getProductsByCategory(category);

    _isLoading = false;
    notifyListeners();
  }

  // Menambah produk baru
  Future<void> addProduct(Product product) async {
    await DatabaseHelper.instance.insertProduct(product);
    await loadProducts(); // Reload
  }

  // Mengubah data produk
  Future<void> updateProduct(Product product) async {
    await DatabaseHelper.instance.updateProduct(product);
    await loadProducts();
  }

  // Menghapus produk
  Future<void> deleteProduct(int id) async {
    await DatabaseHelper.instance.deleteProduct(id);
    await loadProducts();
  }
}