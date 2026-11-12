# RENCANA IMPLEMENTASI (revisi.md)
# FASE 6 - TAHAP 1: KONEKSI DATABASE SQLITE KE MENU KASIR BARU & SISTEM KERANJANG
================================================================================
STATUS: SEDANG DIKERJAKAN (IN PROGRESS)
TANGGAL: 12 November 2026
TARGET: Hubungkan CashierMenuScreen ke SQLite Products, Kartu Statistik Real, Filter Kategori, & Tombol Tambah Belanja [+]
================================================================================

## 1. Lingkup Pekerjaan Tahap 1
Fokus 100% pada Tahap 1 sesuai instruksi Mas Dicky:
1. **Load Data Produk Real:**
   - Membaca data langsung dari tabel SQLite `Products` via `DatabaseHelper.instance.getProducts()`.
   - Menampilkan stok butir/cup secara nyata dari database.
2. **Kalkulasi Kartu Statistik Real-time:**
   - *Penjualan Hari Ini*: Total Rupiah transaksi hari ini di cabang aktif (`Transactions`).
   - *Stok Tersedia*: Total akumulasi butir kelapa & cup tersedia di lapak.
   - *Transaksi*: Total jumlah nota yang berhasil dicetak hari ini.
3. **Filter Kategori & Pencarian Aktif:**
   - Chip kategori (`Semua`, `Kelapa`, `Es Cup`) memfilter produk secara instan.
   - Kolom pencarian di Top Bar menyaring produk berdasarkan nama atau kode menu.
4. **Fungsionalitas Tombol Belanja `[+]`:**
   - Klik `[+]` pada kartu produk memasukkan item ke dalam keranjang (`_cart`).
   - Proteksi stok: jika stok 0, tombol memberikan feedback peringatan stok habis.
   - Menampilkan indikator keranjang belanja (Floating Cart Bar) di bawah dengan ringkasan: `Total Item • Total Rp` dan tombol aksi cepat untuk lanjut bayar atau buka Kasir POS.
5. **Navigasi Tab Kasir:**
   - Bottom Nav tab `Kasir` langsung membuka antarmuka kasir `CashierPosScreen`.

---

## 2. Berkas yang Dimodifikasi
| No | Berkas | Aksi | Keterangan |
|---|---|---|---|
| 1 | `lib/screens/cashier_menu_screen.dart` | Modifikasi | Koneksi `DatabaseHelper`, `Product`, filter dinamis, keranjang aktif, dan floating checkout bar |
