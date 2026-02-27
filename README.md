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
* `change_app_package_name`: Untuk mengganti nama package aplikasi di Android.
* `flutter_launcher_icons`: Untuk mengganti icon aplikasi.

## 🏃‍♀️‍➡️ Cara Menjalankan Aplikasi

Pastikan Anda sudah menginstal **[Flutter SDK](https://docs.flutter.dev/get-started/install)** di perangkat Anda beserta *code editor* pilihan (seperti VS Code atau Android Studio).

Ikuti langkah-langkah berikut untuk menjalankan aplikasi POSsible:

**1. Clone Repository**

Buka terminal Anda, lalu *clone repository* ini dan masuk ke dalam foldernya:
```bash
git clone https://github.com/farrelarrayyan/POSsible.git
cd possible
```
**2. Unduh Dependencies**

Jalankan perintah ini untuk mengunduh semua package pihak ketiga yang digunakan oleh aplikasi:
```bash
flutter pub get
```

**3. Siapkan Perangkat (Opsional)**

Jika anda ingin menjalankan aplikasi ini langsung dalam lingkungan Android, anda dapat menggunakan:
* Emulator Android: Buka dan jalankan Android Emulator melalui Android Studio.
* Perangkat Fisik: Sambungkan Perangkat Android Anda melalui ADB *(Android Debug Bride)* menggunakan *USB Debugging*.

**4. Jalankan Aplikasi**

Jalankan perintah ini:
```bash
flutter run
```
Jika anda menghubungkan Emulator atau perangkat fisik, flutter akan otomatis menginstal aplikasi ke Android. Jika tidak, pilihlah opsi perangkat pilihan Anda (Windows/Linux/Chrome/Lainnya) menggunakan nomor yang ditampilkan di terminal.

## 👨‍💻 Tentang Pengembangan Aplikasi

Dikembangkan oleh **Farrel Arrayyan Adrianshah** sebagai tugas Open Recruitent **SIG Mobile Development RISTEK 2026** dan sebagai bentuk eksplorasi pengembangan aplikasi *mobile* menggunakan Flutter.

## 📝 Lesson Learned

Pengembangan aplikasi ini menjadi pengalaman berharga dalam mengasah keterampilan mobile development saya. Proyek ini tidak hanya mengembangkan pengetahuan dasar Flutter dari kuliah, tetapi juga menantang saya mengeksplorasi manajemen data secara mendalam. Saya berhasil mengimplementasikan penyimpanan offline menggunakan `SharedPreferences` untuk data ringan dan `sqflite` untuk data kompleks. Walaupun pengimplementasian basis data tersebut masih dibantu LLM, saya rasa ini adalah langkah yang tepat agar kedepannya saya tahu apa saja yang harus diterapkan dalam membangun aplikasi dengan penyimpanan kompleks. Ide aplikasi POS ini berawal dari observasi sehari-hari saat membeli kopi, di mana saya sering memperhatikan layar tablet kasir. Saya juga menjadikan Moka POS sebagai inspirasi untuk mode kasir yang mudah digunakan, dengan ukuran tampilan produk yang besar.

Pelajaran paling berharga justru datang dari sebuah momen tidak terduga di pertengahan masa pengembangan. Disela kuliah, saya memberikan handphone kepada teman untuk mencoba aplikasi ini. Saya tidak menyangka ia akan menguji aplikasi secara "kasar", dengan memasukkan angka yang tidak masuk akal, menekan tombol secara acak, dan menguji batas tampilan dengan nama toko yang sangat panjang. Ia menunjukkan banyak masalah UI dan celah validasi data, seperti stok yang bisa bernilai negatif hingga layout yang rusak karena teks panjang.

Momen tersebut menyadarkan saya bahwa proses pembuatan produk digital tidak semudah menuangkan ide dan alur logika dari otak ke dalam baris kode. Sebagai pengembang aplikasi, kita tidak bisa berasumsi pengguna akan selalu menggunakan aplikasi sesuai ekspektasi kita. Pengalaman ini mengajarkan pentingnya mengantisipasi skenario penggunaan yang salah atau ekstrem. Validasi input yang ketat dan desain antarmuka yang tahan banting dan adaptif adalah elemen penting yang membedakan aplikasi yang sekedar jalan dengan aplikasi yang robust dan siap dipakai pengguna. Saya harap pengalaman ini membuat saya lebih siap untuk melakukan proyek lainnya yang lebih kompleks.