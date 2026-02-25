import 'dart:io';
import '../providers/store_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'inventory_screen.dart';
import 'cashier_screen.dart';
import 'history_screen.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POSsible', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () {
              // Navigasi ke halaman edit profil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // --- BAGIAN HEADER (Foto & Nama Toko) ---
          Consumer<StoreProvider>(
            builder: (context, storeProvider, child) {
              return Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    // Cek apakah ada path foto yang tersimpan
                    backgroundImage: storeProvider.imagePath.isNotEmpty 
                        ? FileImage(File(storeProvider.imagePath)) 
                        : null,
                    child: storeProvider.imagePath.isEmpty
                        ? const Icon(Icons.storefront, size: 50)
                        : null, 
                  ),
                  const SizedBox(height: 16),
                  Text(
                    // Menampilkan nama toko
                    storeProvider.storeName.isNotEmpty 
                        ? storeProvider.storeName 
                        : 'Nama Toko',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Menampilkan lokasi toko
                  if (storeProvider.storeLocation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      storeProvider.storeLocation,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ]
                ],
              );
            },
          ),
          
          const SizedBox(height: 40),

          // --- BAGIAN DAFTAR MENU ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuCard(
                  context: context,
                  icon: Icons.point_of_sale,
                  title: 'Mode Kasir',
                  description: 'Mulai transaksi dan catat penjualan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CashierScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context: context,
                  icon: Icons.inventory_2,
                  title: 'Produk & Inventori',
                  description: 'Kelola daftar barang, harga, dan stok',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context: context,
                  icon: Icons.receipt_long,
                  title: 'Riwayat Transaksi',
                  description: 'Lihat riwayat penjualan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context: context,
                  icon: Icons.settings,
                  title: 'Pengaturan',
                  description: 'Ubah tampilan dan preferensi lainnya',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget kotak menu
  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    // Membaca warna primary dari tema agar ikon menyatu dengan tema aplikasi
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: primaryColor),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(description),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}