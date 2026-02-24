import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _weightController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _saveProduct() async {
    // Validasi form
    if (_formKey.currentState!.validate()) {
      String imagePath = '';
      
      // Jika ada gambar, simpan ke memori permanen
      if (_selectedImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(_selectedImage!.path);
        final savedImage = await _selectedImage!.copy('${directory.path}/$fileName');
        imagePath = savedImage.path;
      }

      // Buat object Product baru
      final newProduct = Product(
        name: _nameController.text.trim(),
        category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : 'Umum',
        imagePath: imagePath,
        weight: int.tryParse(_weightController.text) ?? 0,
        stock: int.tryParse(_stockController.text) ?? 0,
        price: int.tryParse(_priceController.text) ?? 0,
      );

      // Simpan ke sqflite
      if (!mounted) return;
      await Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);

      // Tutup layar form
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk Baru'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Pilih Foto Produk
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    image: _selectedImage != null
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Icon(Icons.add_a_photo, size: 40, color: primaryColor)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('Foto Produk', style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Nama produk wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder(), hintText: 'Contoh: Makanan, Minuman'),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty ? 'Stok wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Berat (gram)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Jual (Rp) *', border: OutlineInputBorder(), prefixText: 'Rp '),
              validator: (value) => value == null || value.isEmpty ? 'Harga wajib diisi' : null,
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _weightController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}