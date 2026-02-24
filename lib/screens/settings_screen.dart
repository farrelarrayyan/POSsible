import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/store_provider.dart';
import '../providers/product_provider.dart';
import 'oobe_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Fungsi untuk memunculkan dialog konfirmasi
  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset Data Toko?'),
          content: const Text(
            'Apakah kamu yakin ingin menghapus nama toko, foto, dan lokasi? '
            'Kamu akan dikembalikan ke layar awal aplikasi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext); 
                
                // Hapus profil toko dari SharedPreferences
                await Provider.of<StoreProvider>(context, listen: false).clearStoreInfo();
                
                // Hapus seluruh isi database
                if (!context.mounted) return;
                await Provider.of<ProductProvider>(context, listen: false).clearAllProducts();
                
                // Kembali ke layar OOBE
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const OobeScreen()),
                  (route) => false, 
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Tampilan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          
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
          
          // Accent color
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

          // Manajemen data (reset toko)
          const SizedBox(height: 30),
          const Text(
            'Manajemen Data', 
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
              )
            ),
          const SizedBox(height: 10),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.restore_page, color: Colors.red),
              title: const Text('Reset Data Toko', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Hapus profil toko dan kembali ke awal'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () => _showResetConfirmation(context),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk tombol warna
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
}