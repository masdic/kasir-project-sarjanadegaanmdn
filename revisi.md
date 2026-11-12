# RENCANA IMPLEMENTASI (revisi.md)
# FASE 6 - TAHAP 2: DASHBOARD 1 PINTU OWNER (MAS DICKY - PIN 8888)
================================================================================
STATUS: SEDANG DIKERJAKAN (IN PROGRESS)
TANGGAL: 13 November 2026
TARGET: Bangun Layar Khusus OwnerDashboardScreen untuk Pantau Omset Gabungan & Stok Cabang 1 & Cabang 2
================================================================================

## 1. Lingkup Pekerjaan Opsi 2 (Khusus Owner 8888)
Fokus 100% pada Opsi 2 sesuai instruksi:
1. **Layar Mandiri `OwnerDashboardScreen` (`lib/screens/owner_dashboard_screen.dart`):**
   - Dibuka otomatis saat login sebagai Owner (PIN `8888`).
   - Header bertema Royal Emerald/Amber (`👑 Pemilik Usaha - Mas Dicky`).
2. **Selektor 1 Pintu (Segmented Filter):**
   - Tombol Filter: `[Semua Cabang (Konsolidasi)]`, `[Cabang 1 - Alun-Alun]`, `[Cabang 2 - Pasar Besar]`.
   - Data omzet, transaksi, dan histori otomatis tersaring sesuai cabang yang dipilih.
3. **Kartu Metrik Finansial Konsolidasi:**
   - Total Omzet Penjualan (Rupiah).
   - Pemisahan Pembayaran: Total Tunai (Fisik di kasir) vs Total QRIS (Masuk rekening).
   - Total Transaksi & Estimasi Kas Bersih.
4. **Pemantauan Stok & Kiriman Kelapa Terpusat:**
   - Stok live seluruh produk (Kelapa Utuh, Wulung, Kupas, Es Cup).
   - Status Kiriman / Distribusi Stok (`StockTransfers`): Memantau berapa butir yang sedang dikirim (`PENDING`) dan berapa yang sudah sampai di lapak kasir.
   - Tombol cepat `[👑 Kirim Kelapa ke Cabang]`.
5. **Daftar Transaksi Lintas Cabang:**
   - Menampilkan transaksi terbaru dengan lencana cabang (`SD01` vs `SD02`).
6. **Routing di `lib/main.dart`:**
   - Login Owner (PIN `8888`) langsung membuka `OwnerDashboardScreen`.
   - Kasir (PIN `1234` / `5678`) tetap membuka `CashierMenuScreen`.

---

## 2. Berkas yang Dimodifikasi & Dibuat
| No | Berkas | Aksi | Keterangan |
|---|---|---|---|
| 1 | `lib/database/database_helper.dart` | Modifikasi | Tambah parameter filter outlet pada `getDailySummary` dan breakdown Tunai/QRIS |
| 2 | `lib/screens/owner_dashboard_screen.dart` | Baru | Layar Dashboard 1 Pintu Owner lengkap dengan konsolidasi cabang |
| 3 | `lib/main.dart` | Modifikasi | Arahkan login Owner (`8888`) langsung ke `OwnerDashboardScreen` |
