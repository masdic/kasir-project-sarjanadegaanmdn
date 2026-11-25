# DOKUMEN SPESIFIKASI PRODUK (PRD) & MASTER CONTEXT
# APLIKASI MOBILE POS "SARJANA DEGAN" MADIUN
================================================================================
VERSI DOKUMEN : v1.0.0 (Official Blueprint)
TANGGAL       : 5 November 2026
ENGINE        : ZettBOT Core (System Architect by Zettbos)
STATUS        : DRAFT SIAP REVIEW & EKSEKUSI
================================================================================

================================================================================
ZONA ATAS: SPESIFIKASI KEBUTUHAN PRODUK (BLUEPRINT AWAL)
================================================================================

## 1. NAMA PROJEK & PROBLEM STATEMENT
- **Nama Aplikasi:** Sarjana Degan Mobile POS (Point of Sale)
- **Kategori:** Mobile Kasir & Manajemen Operasional Lapak Offline-First
- **Problem Statement:**
  Usaha agen kelapa dan es cup "Sarjana Degan" di Madiun mengoperasikan 2 cabang harian. Seluruh proses kasir masih menggunakan nota kertas, kalkulator manual, dan buku kasir. Hal ini menimbulkan:
  1. Risiko salah hitung harga & kembalian saat pelanggan ramai.
  2. Ketiadaan pencatatan stok kelapa dan produksi es cup yang terukur (resep 1 butir kelapa = 3 cup es).
  3. Pengeluaran kas kecil (beli es batu, sedotan, plastik) tidak tercatat terpusat.
  4. Waktu rekapitulasi harian staf menyita 1–2 jam per malam.
  5. Sinyal internet lapak pinggir jalan tidak selalu stabil, sehingga aplikasi kasir wajib berjalan mandiri 100% tanpa internet (Offline-First).

---

## 2. PERAN PENGGUNA (USER PERSONA)
1. **Staf Kasir Cabang (Pengguna Utama):**
   - Melayani pembeli dengan antarmuka layar sentuh ramah jempol.
   - Memasukkan transaksi penjualan, input nominal bayar, melihat kembalian otomatis.
   - Mencatat pengeluaran kas operasional harian (es batu, sedotan, kresek).
   - Mencatat produksi es cup harian dengan formula otomatis.
2. **Pemilik Usaha (Dicky / Supervisor):**
   - Mengatur identitas cabang (Cabang 1 / Cabang 2) pada setup awal.
   - Memperbarui harga jual produk jika harga kelapa dari supplier fluktuatif.
   - Melihat rekap total omzet harian, laba kotor, dan sisa stok produk.

---

## 3. ARSITEKTUR & LINGKUNGAN KERJA
- **Target Platform:** Mobile Smartphone (Android 8.0+ API 26+) & Windows Desktop.
- **Framework Frontend:** Flutter 3.x (Dart 3.13+), Material Design 3.
- **Desain UI:** *Clean & Fresh Anti-AI* (Nuansa Emerald Green `#059669`, kartu bersih, font tajam, tanpa emoji berlebihan, ikon SVG/Material modern).
- **Database Engine:** SQLite Lokal (via package `sqflite` & `path_provider`).
- **State Management:** Provider / ChangeNotifier (ringan, stabil, decoupled).
- **Arsitektur Kode:** *Clean Layered Architecture*:
  - `models/` : Definisi entitas data & pemetaan SQLite (`toMap` & `fromMap`).
  - `database/`: `DatabaseHelper` singleton, migrasi tabel, dan query CRUD.
  - `providers/`: State management keranjang belanja, kalkulasi, dan filter transaksi.
  - `screens/`  : Halaman UI (Kasir POS, Riwayat Transaksi, Stok/Produksi, Pengeluaran, Profil).
  - `widgets/`  : Komponen visual modular (ProductCard, CartItem, NumericKeypad, MetricCard).

---

## 4. ALUR KERJA APLIKASI (USER FLOW)
1. **Setup Awal (Onboarding Pertama Kali):**
   - Saat aplikasi pertama kali dipasang, muncul dialog pemilihan identitas toko: Nama Cabang (Cabang 1 / Cabang 2), Alamat, dan No. HP/WA.
   - Data otomatis tersimpan permanen di tabel `StoreProfile`.
2. **Alur Transaksi Kasir (POS Flow):**
   - Staf membuka tab "Kasir".
   - Layar menampilkan katalog produk: Kelapa Muda Utuh, Kelapa Kupas, Es Cup Degan, dll.
   - Staf mengetuk kartu produk & kuantitas -> masuk ke keranjang belanja bawah/samping.
   - Sistem menjumlahkan subtotal & total belanja secara instan (real-time).
   - Staf menekan tombol "Bayar" -> Muncul pop-up pembayaran:
     - Opsi A: Tunai -> Ketuk nominal uang pembeli (pecahan cepat Rp 20.000, 50.000, 100.000, atau input manual) -> Kembalian otomatis terhitung.
     - Opsi B: QRIS / Transfer -> Langsung pas tanpa kembalian.
   - Staf klik "Simpan & Cetak Struk" -> Transaksi tersimpan ke SQLite -> Stok berkurang otomatis -> Layar struk ringkas muncul.
3. **Alur Produksi Es Cup (Formula 1:3):**
   - Staf membuka menu "Produksi Es Cup".
   - Staf memasukkan jumlah kelapa butir yang dipecah (misal: 10 butir).
   - Sistem otomatis menghitung hasil: 10 butir = 30 cup es.
   - Saat disimpan: Stok Kelapa otomatis berkurang 10, Stok Es Cup otomatis bertambah 30.
4. **Alur Pengeluaran Kas (Expenses):**
   - Staf input pengeluaran operasional (kategori: Es Batu, Cup/Sedotan, Plastik, Lainnya) + nominal rupiah + catatan.
   - Saldo kas harian otomatis memotong omzet kotor.
5. **Alur Laporan Harian (Daily Summary):**
   - Staf / pemilik membuka menu "Laporan".
   - Menampilkan Grid 3 Kolom: Total Omzet, Total Pengeluaran, dan Sisa Kas Bersih hari ini.

---

## 5. DESAIN BASIS DATA (SQLITE RELATIONAL SCHEMA)

Semua nama tabel dibuat bersih tanpa karakter khusus, dengan tipe data SQLite yang baku:

### 1. Tabel `StoreProfile`
Menyimpan konfigurasi identitas cabang:
- `id` (INTEGER PRIMARY KEY)
- `storeName` (TEXT NOT NULL, default: 'Sarjana Degan')
- `branchName` (TEXT NOT NULL, contoh: 'Cabang 1 - Alun-Alun Madiun')
- `address` (TEXT)
- `phone` (TEXT)
- `receiptFooter` (TEXT, default: 'Terima Kasih Atas Kunjungan Anda')

### 2. Tabel `Products`
Master barang dagangan dan stok aktif:
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `productCode` (TEXT UNIQUE NOT NULL, contoh: 'PRD-001')
- `name` (TEXT NOT NULL, contoh: 'Kelapa Muda Ijo', 'Es Degan Gula Jawa')
- `category` (TEXT NOT NULL, 'Kelapa' / 'Es Cup' / 'Lainnya')
- `price` (INTEGER NOT NULL, contoh: 12000)
- `costPrice` (INTEGER DEFAULT 0, modal beli kelapa)
- `stock` (INTEGER NOT NULL DEFAULT 0)
- `unit` (TEXT DEFAULT 'Butir', 'Cup', 'Porsi')
- `isActive` (INTEGER DEFAULT 1)

### 3. Tabel `Transactions`
Header transaksi penjualan:
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `invoiceNumber` (TEXT UNIQUE NOT NULL, format: 'TRX-YYYYMMDD-001')
- `transactionDate` (TEXT NOT NULL, format ISO 8601: '2026-11-05T10:30:00')
- `totalAmount` (INTEGER NOT NULL)
- `paidAmount` (INTEGER NOT NULL)
- `changeAmount` (INTEGER NOT NULL DEFAULT 0)
- `paymentMethod` (TEXT NOT NULL, 'TUNAI' / 'QRIS')
- `cashierName` (TEXT DEFAULT 'Staf Kasir')
- `notes` (TEXT)

### 4. Tabel `TransactionItems`
Rincian per item dalam satu nota:
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `transactionId` (INTEGER NOT NULL, FOREIGN KEY -> Transactions.id)
- `productId` (INTEGER NOT NULL, FOREIGN KEY -> Products.id)
- `productName` (TEXT NOT NULL)
- `priceAtSale` (INTEGER NOT NULL)
- `quantity` (INTEGER NOT NULL)
- `subtotal` (INTEGER NOT NULL)

### 5. Tabel `ProductionLogs`
Catatan konversi produksi kelapa -> es cup (Formula 1:3):
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `productionDate` (TEXT NOT NULL)
- `coconutUsed` (INTEGER NOT NULL, butir kelapa yang dipotong)
- `cupProduced` (INTEGER NOT NULL, cup es yang dihasilkan = coconutUsed * 3)
- `notes` (TEXT)

### 6. Tabel `Expenses`
Catatan pengeluaran operasional toko:
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `expenseDate` (TEXT NOT NULL)
- `category` (TEXT NOT NULL, 'Es Batu', 'Cup & Sedotan', 'Plastik/Kresek', 'Operasional')
- `amount` (INTEGER NOT NULL)
- `notes` (TEXT)

---

## 6. ATURAN VALIDASI & LOGIKA KHUSUS
1. **Penomoran Kode Invoice Otomatis:**
   - Format: `TRX-YYYYMMDD-XXX` (contoh: `TRX-20261105-001`, `TRX-20261105-002`).
   - Nomor urut dihitung dari transaksi tertinggi pada hari yang sama + 1.
2. **Validasi Pembayaran Tunai:**
   - Jika pembayaran 'TUNAI', `paidAmount` wajib >= `totalAmount`.
   - `changeAmount` = `paidAmount` - `totalAmount`.
   - Jika 'QRIS', `paidAmount` otomatis = `totalAmount`, `changeAmount` = 0.
3. **Logika Resep Produksi Otomatis:**
   - Input: $X$ butir kelapa.
   - Hasil: $3 \times X$ cup es.
   - Mutasi stok dalam satu database transaction (Atomic):
     `UPDATE Products SET stock = stock - X WHERE name LIKE '%Kelapa%'`
     `UPDATE Products SET stock = stock + (3 * X) WHERE name LIKE '%Es Cup%'`
4. **Pencegahan Data Hilang:**
   - Menggunakan mode SQLite WAL (Write-Ahead Logging) untuk transaksi aman & cepat.

---

## 7. RENCANA ANTARMUKA PENGGUNA (UI/UX)
- **Halaman 1: Kasir POS (Home Screen):**
  - Header: Nama Cabang, Jam, Tanggal.
  - Bagian Tengah: Grid Produk (Foto/Inisial, Nama, Harga, Badge Sisa Stok).
  - Bagian Bawah: Ringkasan Keranjang Belanja & Tombol Hijau Besar "BAYAR SEKARANG (Rp X)".
  - Modal Bayar: Tombol cepat uang pas, 20k, 50k, 100k, dan kalkulator kembalian instan.
- **Halaman 2: Riwayat Transaksi & Struk:**
  - Daftar transaksi harian berurutan waktu.
  - Klik transaksi -> Muncul struk digital lengkap dengan opsi share / print.
- **Halaman 3: Stok & Produksi Es Cup:**
  - Kartu sisa stok kelapa & sisa cup es.
  - Tombol aksi cepat: "Konversi Produksi Es Cup" (input 1 kelapa -> 3 cup).
- **Halaman 4: Buku Pengeluaran (Kas Keluar):**
  - Form input cepat pengeluaran lapak (es batu, sedotan, dll) & daftar hari ini.
- **Halaman 5: Laporan & Ringkasan Harian:**
  - Kartu Metrik: Total Penjualan, Total Pengeluaran, Kas Bersih.

---

## 8. KRITERIA PENGUJIAN (TESTING CHECKLIST)
- [ ] Berhasil input transaksi kelapa muda & es cup, total otomatis terhitung benar.
- [ ] Pembayaran tunai otomatis menghitung kembalian uang dengan presisi.
- [ ] Transaksi tersimpan ke database lokal SQLite dan stok produk berkurang.
- [ ] Input produksi kelapa (misal 5 butir) otomatis menambah 15 cup es dan mengurangi 5 butir kelapa.
- [ ] Input pengeluaran es batu berhasil memotong ringkasan kas bersih harian.
- [ ] Aplikasi tetap berjalan normal 100% saat koneksi data internet/WiFi dimatikan total.

---

================================================================================
ZONA BAWAH: MASTER CONTEXT & LOGIKA SISTEM TERKINI (LIVING CONTEXT)
================================================================================

### Status Arsitektur Aktif
- Framework: Flutter 3.x / Dart 3.13+
- Database: SQLite lokal via `sqflite` (Database: `sarjana_degan_pos.db`)
- Platform: Android Smartphone & Windows Desktop
- Mode Operasi: 100% Offline-First

### Skema Tabel Aktif
1. `StoreProfile` (id, storeName, branchName, address, phone, receiptFooter)
2. `Products` (id, productCode, name, category, price, costPrice, stock, unit, isActive)
3. `Transactions` (id, invoiceNumber, transactionDate, totalAmount, paidAmount, changeAmount, paymentMethod, cashierName, notes)
4. `TransactionItems` (id, transactionId, productId, productName, priceAtSale, quantity, subtotal)
5. `ProductionLogs` (id, productionDate, coconutUsed, cupProduced, notes)
6. `Expenses` (id, expenseDate, category, amount, notes)

### Formula Bisnis & Logika Aktif
- Konversi Produksi: 1 butir kelapa = 3 cup es degan.
- Penomoran Transaksi: `TRX-YYYYMMDD-XXX`
- Kas Bersih Harian: $\sum \text{Total Penjualan} - \sum \text{Total Pengeluaran}$

### Riwayat Log Pembaruan
- v1.0.0 (5 Nov 2026): Blueprint awal disetujui, mencakup 6 tabel SQLite relasional, formula produksi es cup 1:3, sistem kasir cepat, dan pencatatan kas harian.
- v1.1.0 (5 Nov 2026): Layar Login resmi diperbarui ke Quick PIN 4-Digit (PIN 1234, 5678, 8888), terintegrasi langsung dengan Layar Kasir POS, katalog produk, keranjang belanja, kalkulator kembalian, dan tombol pergantian shift kasir.
- v1.2.0 (5 Nov 2026): Penambahan Tombol Selektor Cabang Interaktif (Cabang 1 Alun-Alun & Cabang 2 Pasar Besar) di Layar Login PIN dengan validasi cerdas per cabang.
- v1.3.0 (5 Nov 2026): Penambahan Tab Ke-3 khusus "👑 Owner" (Dicky) dengan PIN Master (8888), transisi tema visual Deep Navy eksekutif, dan proteksi pemisahan hak akses kasir vs pemilik.

- v1.4.0 (5 Nov 2026): Redesain tampilan Login PIN menyeluruh dengan standar estetika Human-Crafted POS (Square Terminal / Apple UI). Mengeliminasi seluruh emoji norak, mengadopsi palet Artisan Forest Green (#164E2E) dan Slate Obsidian (#0F172A), Segmented Tab selector bergaya iOS/Stripe, keypad sentuh ergonomis kasir, dan indikator status dot minimalis.
- v1.5.0 (5 Nov 2026): Penambahan elemen lengkap operasional kasir: Latar belakang kanvas hijau muda segar (#EFF8F1), jam & tanggal realtime berdetak per detik, logo toko kustom artisan "SD" Sarjana Degan, tombol selektor shift kerja (Pagi 08:00-15:00 & Sore 15:00-22:00), serta pop-up dialog bantuan / lupa PIN kasir.
- v1.6.0 (5 Nov 2026): Transformasi UI Login mengadopsi referensi mockup mobile modern: Banner buah kelapa muda hijau segar CustomPainter di bagian atas dengan fade gradient ke kanvas hijau zamrud, rounded pill input fields, tombol kapsul "Login" khas bergradasi hijau cerah, tombol pill Shift Pagi & Sore di bagian bawah, serta keypad terintegrasi.
- v1.7.0 (5 Nov 2026): Penggantian header visual ilustrasi sintetis dengan foto buah kelapa muda asli berembun (hasil unggahan pengguna), dibundel secara offline-first dalam assets/images/kelapa_asli.jpg & lib/assets/coconut_image.dart dengan efek smooth gradient fade ke kanvas hijau segar.
- v1.8.0 (5 Nov 2026): Simplifikasi judul menjadi "Sarjana Degan POS (Madiun • Terminal Kasir)", format bar waktu dan tanggal yang kompak horizontal satu baris, serta penambahan dual-layer precision drop shadow pada batas lengkungan bawah foto kelapa asli.
- v1.9.0 (5 Nov 2026): Pembersihan teks status menjadi "Kasir • Cabang X" / "Owner (Dicky)", penambahan proteksi FittedBox pada status bar chip sehingga 100% bebas dari layout RenderFlex overflow dan garis belang kuning-hitam.
- v1.10.0 (5 Nov 2026): Simplifikasi subtitle header toko menjadi "Madiun" saja (menghapus label "Terminal Kasir").
- v1.11.0 (11 Nov 2026): Sukses deployment langsung (live test) ke perangkat fisik Realme C21Y (Android 11, API 30). Mengeliminasi dependensi CMake/JNI dari path_provider, menyelaraskan arsitektur SQLite offline-first 100% murni Java/Dart, dan merealisasikan Layar Utama Kasir POS (split-screen katalog & keranjang belanja).
