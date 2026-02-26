# POSsible: *POS SImple moBiLE* 📱

Sebuah aplikasi POS (*Point-Of-Sales*) sederhana untuk platform Android yang dirancang khusus untuk membantu mencatat aktivitas operasional toko Anda. POSsible memudahkan pengelolaan inventori produk, menghitung total transaksi, hingga merekam riwayat penjualan.

Seluruh sistem beroperasi **100% secara lokal (offline)** di perangkat Anda tanpa memerlukan akses internet, menjaga data Anda tetap privat dan aman.

**"With POSsible, it's possible!"**

## 📋 Fitur Utama

* **OOBE (Out-Of-Box Experience)**
  Mulai pengalaman dengan mengatur identitas toko Anda (Nama, Lokasi, dan Logo/Foto) dan mengatur tema aplikasi sesuai selera Anda.
* **Profil Toko**
  Identitas toko anda akan ditampilkan di halaman utama dan tercetak di setiap struk transaksi. Selain melalui OOBE, profil toko Anda bisa disesuaikan melalui menu edit profil di bagian atas kanan *homescreen* aplikasi.
* **Pengelolaan Inventori Cerdas**
  Tambahkan, ubah, dan hapus produk sesuai stok fisik toko. Dilengkapi dengan fitur **Pencarian**, **Filter Kategori**, dan **Penyortiran** (berdasarkan Abjad, Harga, atau Stok) untuk memantau semua barang dengan mudah.
* **Mode Kasir Responsif**
  Dilengkapi tampilan *grid* yang menyesuaikan ukuran layar. Kasir cukup menekan kotak produk untuk menambahkannya ke keranjang. Aplikasi akan menghitung total harga dan total produk secara otomatis. Saat transaksi selesai, catatan stok produk akan berkurang secara otomatis.
* **Sistem Pembayaran**
  Mendukung dua metode pembayaran:
  * **Tunai:** Pembayaran tunai yang dilengkapi kalkulator yang akan menghitung uang kembalian atau memberi peringatan jika uang pelanggan kurang.
  * **QRIS:** Pembayaran QR (*masih dummy untuk sekarang :D*) untuk pembayaran *cashless*.
* **Riwayat & Detail Transaksi**
  Semua penjualan terekam rapi dengan ID Transaksi, waktu pembelian, dan total harga bayar. Ketuk pada salah satu riwayat untuk melihat **Struk Belanja** yang secara detail memuat daftar barang yang dibeli.

## 📦 *Packages*

Aplikasi ini dibangun menggunakan **Flutter** dengan bantuan *package*:

* `provider`: Untuk menyediakan *State Management* aplikasi (menangani keranjang belanja dan pembaruan data produk secara *real-time*).
* `sqflite`: Operasi basis data SQLite lokal untuk menyimpan data produk dan riwayat transaksi secara permanen.
* `shared_preferences`: Penyimpanan lokal ringan untuk status OOBE dan identitas profil toko.
* `intl`: *Formatting* angka menjadi mata uang Rupiah dan *formatting* waktu yang rapi.
* `image_picker` & `path_provider`: Untuk mengambil foto produk/toko dari galeri perangkat dan menyimpannya di direktori internal aplikasi.
* `url_launcher`: Untuk menangani pembukaan/*routing* tautan eksternal ke media sosial pada menu *About Me*.

## 👨‍💻 Tentang Pengembangan Aplikasi

Dikembangkan oleh **Farrel Arrayyan Adrianshah** sebagai tugas Open Recruitent **SIG Mobile Development RISTEK 2026** dan sebagai bentuk eksplorasi pengembangan aplikasi *mobile* menggunakan Flutter.

## 📝 Lesson Learned

Placeholder