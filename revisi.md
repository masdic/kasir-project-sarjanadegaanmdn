# RENCANA IMPLEMENTASI (revisi.md)
# DESAIN UI/UX DASHBOARD MENU KASIR POS (REFERENSI CHILI POS CLEAN GREEN)
================================================================================
STATUS: SELESAI DITERAPKAN KE KODE FLUTTER (DART)
TANGGAL: 15 November 2026
BERKAS: lib/screens/cashier_menu_screen.dart
================================================================================

## 1. Latar Belakang & Kebutuhan Pengguna
- Pengguna memilih desain modern ala **Chili POS** (Off-White `#F4F6F8`, Clean White Cards, Emerald Green `#10B981` & `#15803D`).
- Instruksi khusus: Membangun struktur tata letak dashboard terlebih dahulu dan **tidak membuat daftar menu produk dulu** (area katalog disiapkan sebagai canvas bersih).
- Pengguna memberikan persetujuan eksplisit: *"oke terapkan jadi seterusnya menggunakan flutter"*.

---

## 2. Berkas yang Dimodifikasi
| No | Berkas | Aksi | Status | Keterangan |
|---|---|---|:---:|---|
| 1 | `lib/screens/cashier_menu_screen.dart` | Refactor / Rewrite | ✅ SELESAI | Mengadopsi 100% Widget Flutter murni: Sidebar navigasi vertikal, Top search bar, Horizontal Category Cards, Empty State Canvas, Bottom Operational Bar, dan Dialog Modal Payment Success |
| 2 | `lib/screens/cashier_pos_screen.dart` | Terhubung | ✅ SIAP | Terintegrasi via tombol `[⚡ Buka Mesin Kasir POS]` & Tab `Menu Kasir` |
| 3 | `prd.md` | Master Context Sync | ✅ TERUPDATE | Pencatatan versi v1.12.0 di Zona Bawah Master Context |

---

## 3. Komponen Visual Flutter yang Diterapkan
1. **Left Sidebar Navigation:**
   - Brand Header: Logo circular kelapa muda `SD` + `SARJANA DEGAN POS Madiun`.
   - Vertical Navigation Pills: Menu Kasir (Pill hijau solid aktif), Antrean Meja, Distribusi Kelapa, Buku Kas & Biaya, Pengaturan.
   - Sesi Kasir & Kunci Layar di bagian bawah sidebar.
2. **Top Application Bar:**
   - Responsive Drawer toggle `☰` untuk layar mobile HP.
   - Rounded Search Bar: `🔍 Cari menu, nota, atau kelapa...`.
   - Chip `Shift Pagi/Sore` & Jam WIB realtime berdetak per detik.
   - Tombol `[🧾 Contoh Struk]` untuk memicu dialog Payment Success.
3. **Category Header Row:**
   - Kartu kategori interaktif: *Semua Menu (Aktif Mint Green)*, *Kelapa Murni*, *Es Cup Degan*, *Paket Hemat*, *Promo Spesial*.
4. **Empty State Canvas:**
   - Frame layout canvas bersih bertanda `🎨 KERANGKA DESAIN DASHBOARD SIAP` dengan tombol `[Buka Mesin Kasir POS & Transaksi]`.
5. **Bottom Operational Status Bar:**
   - Kapsul status: Sesi Shift, Sisa Stok Kelapa Lapak, Saldo Kas Fisik (Tunai vs QRIS), dan status SQLite Offline.
6. **Modal Struk "Payment Success!" (Dialog Flutter):**
   - Kartu popup putih berlingkaran hijau centang besar `✓`, nominal Rp 36.000, rincian Order ID/Metode/Waktu, tombol `New Order` & `Print Receipt`.

---

## 4. Langkah Selanjutnya (Next Steps)
- Pengujian langsung di perangkat Android fisik Realme C21Y (`flutter run`).
- Menghubungkan kartu metrik & kategori dengan data SQLite riil saat Mas Dicky siap mengisi daftar menu.
