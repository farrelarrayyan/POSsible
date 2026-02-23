import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import 'home_screen.dart';

class OobeScreen extends StatefulWidget {
  const OobeScreen({super.key});

  @override
  State<OobeScreen> createState() => _OobeScreenState();
}

class _OobeScreenState extends State<OobeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _selectedImage;
  
  final PageController _pageController = PageController();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _saveAndContinue() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama toko tidak boleh kosong!')),
      );
      return;
    }

    await Provider.of<StoreProvider>(context, listen: false).saveStoreInfo(
      _nameController.text.trim(),
      _locationController.text.trim(),
      _selectedImage,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildWelcomePage(context),
            _buildFormPage(context),
          ],
        ),
      ),
    );
  }

  // --- HALAMAN 1: WELCOME SCREEN ---
  Widget _buildWelcomePage(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // logo App (placeholder)
          Icon(Icons.storefront, size: 100, color: primaryColor),
          const SizedBox(height: 24),
          const Text(
            'POSsible',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kelola penjualan dan inventaris toko Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Text(
            'Lengkap. Mudah. Tanpa Internet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              child: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }

  // --- HALAMAN 2: FORM INFO TOKO ---
  Widget _buildFormPage(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Profil Toko',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Mari siapkan profil tokomu sebelum mulai.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),

          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: primaryColor.withOpacity(0.1),
              backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
              child: _selectedImage == null
                  ? Icon(Icons.add_a_photo, size: 40, color: primaryColor)
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          const Text('Ketuk untuk tambah foto'),
          const SizedBox(height: 40),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Toko *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.store),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Lokasi / Alamat',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Simpan!', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}