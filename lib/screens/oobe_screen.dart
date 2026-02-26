import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../providers/theme_provider.dart';
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
      _pageController.jumpToPage(1);
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
            _buildThemePage(context),
          ],
        ),
      ),
    );
  }

  // Halaman 1: intro
  Widget _buildWelcomePage(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(
            'assets/images/logo.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
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

  // Halaman 2: info toko
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
              onPressed: () {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama toko tidak boleh kosong!')),
                  );
                  return;
                }
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Selanjutnya', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // Halaman 3: pilih tema
  Widget _buildThemePage(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Pilih Tema',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sesuaikan tampilan aplikasi dengan selera Anda.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),

          // Toggle Dark Mode
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Mode Gelap'),
              secondary: const Icon(Icons.dark_mode),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Warna Aksen
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Warna Aksen',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      _buildColorOption(context, Colors.blue, 'Biru'),
                      _buildColorOption(context, Colors.green, 'Hijau'),
                      _buildColorOption(context, Colors.orange, 'Oranye'),
                      _buildColorOption(context, Colors.purple, 'Ungu'),
                      _buildColorOption(context, Colors.red, 'Merah'),
                      _buildColorOption(context, Colors.teal, 'Teal'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _saveAndContinue,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk opsi warna
  Widget _buildColorOption(BuildContext context, Color color, String tooltip) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isSelected = themeProvider.accentColor.value == color.value;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => themeProvider.changeAccentColor(color),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
            ],
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white)
              : null,
        ),
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