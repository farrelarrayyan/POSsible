import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product product; // Data produk yang akan diedit

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _weightController;
  late TextEditingController _stockController;
  late TextEditingController _priceController;
  
  File? _selectedImage;
  String _existingImagePath = '';

  @override
  void initState() {
    super.initState();
    // Isi form dengan data produk yang sudah ada
    _nameController = TextEditingController(text: widget.product.name);
    _categoryController = TextEditingController(text: widget.product.category);
    _weightController = TextEditingController(text: widget.product.weight.toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _priceController = TextEditingController(text: widget.product.price.toString());
    
    _existingImagePath = widget.product.imagePath;
    if (_existingImagePath.isNotEmpty) {
      _selectedImage = File(_existingImagePath);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      String finalImagePath = _existingImagePath;
      
      // Jika pengguna memilih gambar baru
      if (_selectedImage != null && _selectedImage!.path != _existingImagePath) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(_selectedImage!.path);
        final savedImage = await _selectedImage!.copy('${directory.path}/$fileName');
        finalImagePath = savedImage.path;
      }

      // Buat object Product dengan ID yang sama
      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : 'Umum',
        imagePath: finalImagePath,
        weight: int.tryParse(_weightController.text) ?? 0,
        stock: int.tryParse(_stockController.text) ?? 0,
        price: int.tryParse(_priceController.text) ?? 0,
      );

      // Panggil fungsi update
      if (!mounted) return;
      await Provider.of<ProductProvider>(context, listen: false).updateProduct(updatedProduct);

      // Kembali ke layar inventori
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
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
            const Center(child: Text('Ketuk untuk ubah foto', style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Nama produk wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty ? 'Isi stok' : null,
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
              decoration: const InputDecoration(labelText: 'Harga Jual (Rp)', border: OutlineInputBorder(), prefixText: 'Rp '),
              validator: (value) => value == null || value.isEmpty ? 'Harga wajib diisi' : null,
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _updateProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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