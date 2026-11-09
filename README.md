# 🥥 Sarjana Degan POS - Madiun

> **Sistem Kasir Pintar Offline-First Berbasis Flutter untuk Usaha Minuman Kelapa Muda "Sarjana Degan" Madiun**  
> Didesain khusus untuk operasional cepat multi-cabang (Cabang 1 Alun-Alun & Cabang 2 Pasar Besar Madiun), mendukung perangkat Tablet Android & PC Desktop.

---

## 🌟 Fitur Utama

### 1. 🔐 Sistem Keamanan & Login PIN Multi-Peran
- **Cabang 1 (Alun-Alun):** PIN Kasir `1234`
- **Cabang 2 (Pasar Besar):** PIN Kasir `5678`
- **Owner (Dicky):** PIN Pengawas `8888`
- Proteksi lintas cabang otomatis (mencegah salah tab/salah cabang).
- Pilihan shift kerja: **Shift Pagi (08:00 - 15:00)** & **Shift Sore (15:00 - 22:00)**.
- Jam digital realtime WIB berdetak per detik dengan proteksi anti-overflow layar.
- Desain header foto kelapa asli berembun dengan *precision drop-shadow* elegan (estetika Anti-AI Human-Crafted).

### 2. 🛒 Layar Utama Kasir POS (Split-Screen Tablet/Desktop)
- **Panel Kiri (Katalog Menu Cepat):**
  - Filter kategori kapsul: `Semua`, `Kelapa`, `Es Cup`.
  - Kolom pencarian instan nama menu atau kode produk.
  - Kartu produk ramah sentuhan jempol dilengkapi harga format Rupiah, sisa stok real, dan indikator jumlah di keranjang.
- **Panel Kanan (Struk Keranjang Belanja):**
  - Rincian item pesanan pembeli.
  - Stepper tombol kuantitas sentuh cepat `[-]` `[Qty]` `[+]`.
  - Subtotal terhitung otomatis secara instan.
  - Tombol kosongkan keranjang & hapus per item.
  - Total belanja besar & tombol hijau **`BAYAR`**.
- **Tombol Kunci Layar (Logout):** Dilengkapi konfirmasi aman untuk mengunci terminal saat pergantian kasir.

### 3. 💾 Arsitektur Data Offline-First (SQLite)
Aplikasi beroperasi 100% tanpa internet menggunakan basis data lokal SQLite:
- `StoreProfile`: Profil cabang & footer struk.
- `Products`: Master produk kelapa muda & es cup dengan manajemen stok.
- `Transactions` & `TransactionItems`: Riwayat penjualan dan rincian belanja.
- `ProductionLogs`: Pencatatan konversi produksi kelapa utuh ke cup (formula 1 butir = 3 cup es).
- `Expenses`: Kas kecil pengeluaran lapak operasional harian.

---

## 🚀 Panduan Menjalankan Aplikasi

### Persyaratan:
- Flutter SDK (v3.13.7+)
- Web Browser (Chrome / Edge) atau Perangkat Android (Tablet / Ponsel)

### 1. Mode Web Preview (PC & Tablet via Wi-Fi):
```bash
# Jalankan server web lokal
flutter run -d web-server --web-port 5000 --web-hostname 0.0.0.0
```
- Akses di PC: `http://localhost:5000`
- Akses di Tablet (dalam satu jaringan Wi-Fi): `http://192.168.1.8:5000`

### 2. Jalankan Pengujian Unit:
```bash
flutter test
```

---

## 📁 Struktur Direktori
```text
kasir_pos/
├── assets/images/       # Aset foto kelapa asli & ikon
├── lib/
│   ├── assets/          # Embedded image data (base64)
│   ├── database/        # DatabaseHelper (SQLite & mock fallback)
│   ├── models/          # Model data (Product, Transaction, StoreProfile, dll)
│   ├── screens/         # Layar aplikasi (CashierPosScreen)
│   └── main.dart        # Entrypoint aplikasi & Layar Login PIN
├── test/                # Unit test (Login logic, widget, database)
├── catatan.md           # Log progress harian & agenda tindak lanjut
├── prd.md               # Product Requirements Document (Single Source of Truth)
├── revisi.md            # Rencana teknis implementasi bertahap (ZettBOT standard)
└── ZettBOT.md           # Sistem Arsitek & Mentor Coding Engine (by Zettbos)
```

---

## 👥 Pengembang & Hak Cipta
- **Pemilik Usaha:** Dicky (Sarjana Degan Madiun)
- **Sistem Arsitek & Desain:** ZettBOT by Zettbos
- **Repositori:** [github.com/masdic/kasir-project-sarjanadegaanmdn](https://github.com/masdic/kasir-project-sarjanadegaanmdn)
