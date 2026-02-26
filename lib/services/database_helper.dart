import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item.dart';

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

Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // Tabel Produk
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

    // Tabel Transaksi
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        date $textType,
        totalAmount $integerType,
        paymentMethod $textType,
        cashAmount $integerType
      )
    ''');

    // Tabel Item Transaksi
    await db.execute('''
      CREATE TABLE transaction_items (
        id $idType,
        transactionId $integerType,
        productId $integerType,
        productName $textType,
        productPrice $integerType,
        quantity $integerType,
        FOREIGN KEY (transactionId) REFERENCES transactions (id) ON DELETE CASCADE
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

  // Fungsi untuk transaksi kasir
  Future<int> insertTransaction(TransactionModel transaction, List<TransactionItem> items) async {
    final db = await instance.database;
    int transactionId = 0;

    await db.transaction((txn) async {
      // Simpan nota transaksi
      transactionId = await txn.insert('transactions', transaction.toMap());

      // Loop setiap barang yang dibeli
      for (var item in items) {
        // Gabungkan ID Nota ke dalam item
        final itemMap = item.toMap();
        itemMap['transactionId'] = transactionId;
        
        // Simpan item ke database
        await txn.insert('transaction_items', itemMap);

        // Otomatis kurangi stok di tabel produk
        await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          [item.quantity, item.productId]
        );
      }
    });

    return transactionId;
  }

  // Mengambil semua riwayat transaksi
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    // Urutan by id secara desc, transaksi terbaru diatas
    final result = await db.query('transactions', orderBy: 'id DESC');
    
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // Mengambil detail barang dari sebuah transaksi tertentu
  Future<List<TransactionItem>> getTransactionItems(int transactionId) async {
    final db = await instance.database;
    
    final result = await db.query(
      'transaction_items',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
    
    return result.map((json) => TransactionItem.fromMap(json)).toList();
  }

  // Fungsi factory reset (hapus semua data)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('transaction_items');
    await db.delete('transactions');
    await db.delete('products');
  }

  // Menutup database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}