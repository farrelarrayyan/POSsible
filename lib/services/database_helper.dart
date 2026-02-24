import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  // Membuat instance singleton agar database hanya dibuka sekali
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Membuka koneksi database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('possible_pos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Mencari lokasi default database di sistem
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Membuka database, jika belum ada akan memanggil _createDB
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Mengeksekusi query pembuatan tabel saat database pertama kali dibuat
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        category $textType,
        imagePath $textType,
        weight $integerType,
        stock $integerType,
        price $integerType
      )
    ''');
  }

  // --- Fungsi CRUD ---
  
  // Menambahkan produk baru ke database
  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', product.toMap()); 
  }

  // Mengambil semua produk dari database
  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    
    // Query untuk mengambil semua baris data
    final result = await db.query('products');
    
    // Mengubah data SQLite (List<Map>) kembali menjadi List<Product>
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // Mengambil produk berdasarkan kategori tertentu
  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await instance.database;
    
    final result = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );
    
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // Mengubah data produk yang sudah ada
  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Menghapus produk berdasarkan ID
  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menutup database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}