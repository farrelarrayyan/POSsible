import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import 'about_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  File? _selectedImage;
  String _existingImagePath = '';

  @override
  void initState() {
    super.initState();
    // Ambil data profil saat ini
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    _nameController = TextEditingController(text: storeProvider.storeName);
    _locationController = TextEditingController(text: storeProvider.storeLocation);
    _existingImagePath = storeProvider.imagePath;

    // Jika sudah ada foto sebelumnya, masukkan ke _selectedImage biar bisa dikirim lagi kalau gak diganti
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

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      
      // Update data di Provider
      if (!mounted) return;
      await Provider.of<StoreProvider>(context, listen: false).saveStoreInfo(
        _nameController.text.trim(),
        _locationController.text.trim(),
        _selectedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil toko berhasil diperbarui!')),
      );
      Navigator.pop(context); // Balik ke homescrene
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil Toko'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Area foto
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle, 
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
            const Center(child: Text('Ketuk untuk ubah logo', style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 32),

            // Form nama toko dan lokasi toko
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Toko',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Nama toko wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi Toko',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol simpan perubahan
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 48),

            // Tombol menu about me
            const Divider(),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.info_outline, color: Colors.blue),
                ),
                title: const Text('Tentang Pembuat Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('About me :D'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}