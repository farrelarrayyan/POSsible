import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StoreProvider extends ChangeNotifier {
  String _storeName = '';
  String _storeLocation = '';
  String _imagePath = '';
  bool _isConfigured = false;

  String get storeName => _storeName;
  String get storeLocation => _storeLocation;
  String get imagePath => _imagePath;
  bool get isConfigured => _isConfigured;

  StoreProvider() {
    loadStoreInfo();
  }

  // Fungsi untuk memuat data dari memori saat aplikasi dibuka
  Future<void> loadStoreInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _storeName = prefs.getString('store_name') ?? '';
    _storeLocation = prefs.getString('store_location') ?? '';
    _imagePath = prefs.getString('store_image_path') ?? '';
    _isConfigured = prefs.getBool('is_configured') ?? false;
    
    notifyListeners();
  }

  // Fungsi untuk menyimpan data dari layar OOBE
  Future<void> saveStoreInfo(String name, String location, File? imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Simpan Teks
    await prefs.setString('store_name', name);
    await prefs.setString('store_location', location);
    _storeName = name;
    _storeLocation = location;

    // Simpan gambar ke penyimpanan permanen aplikasi
    if (imageFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(imageFile.path);
      final targetPath = '${directory.path}/$fileName';
      
      File savedImage = imageFile;

      // Bugfix: hanya copy file jika path asalnya berbeda dengan path tujuan
      if (imageFile.path != targetPath) {
        savedImage = await imageFile.copy(targetPath);
      }
      
      // Simpan path
      await prefs.setString('store_image_path', savedImage.path);
      _imagePath = savedImage.path;
    }

    // Tandai bahwa OOBE setup sudah selesai
    await prefs.setBool('is_configured', true);
    _isConfigured = true;

    notifyListeners();
  }

  // Fungsi untuk reset data toko
  Future<void> clearStoreInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('store_name');
    await prefs.remove('store_location');
    await prefs.remove('store_image_path');
    await prefs.setBool('is_configured', false);
    
    _storeName = '';
    _storeLocation = '';
    _imagePath = '';
    _isConfigured = false;
    
    notifyListeners();
  }
}