# 📝 Catatan Progress Harian & Roadmap Proyek
**Proyek:** Kasir POS Sarjana Degan Madiun (Offline-First Flutter)  
**Tanggal Update:** 12 November 2026 (23:25 WIB)  
**Status Terakhir:** 🏆 FASE 5 SELESAI + FASE 6 AKTIF (SHELL UI MENU BARU & ARSITEKTUR 1 PINTU DISIAPKAN)  
**Repositori GitHub:** [github.com/masdic/kasir-project-sarjanadegaanmdn](https://github.com/masdic/kasir-project-sarjanadegaanmdn) (Branch `main`, Commit `4d36d6b`)  

---

## ✅ Pencapaian yang Sudah Selesai 100%

| No | Modul / Fitur | Rincian Pencapaian | Status |
|---|---|---|:---:|
| 1 | **Dokumen Tugas 1 (PDF)** | Dokumen Analisis Kebutuhan format Majalah (`TUGAS_1_ANALISIS_KEBUTUHAN_KASIR_POS.pdf`) | ✅ Selesai |
| 2 | **PRD & Master Context** | `prd.md` terstruktur standar ZettBOT v1.11.0 sebagai Single Source of Truth | ✅ Selesai |
| 3 | **Database SQLite Offline** | Model data: `StoreProfile`, `Product`, `Transaction`, `TransactionItem`, `ProductionLog`, `Expense`, `SupplierDeliveries`, `StockTransfers` | ✅ Selesai |
| 4 | **Visual Login & Header Asli** | Foto kelapa muda berembun asli + dual shadow + jam realtime WIB anti-overflow | ✅ Selesai |
| 5 | **Sistem Login 3 Peran (PIN)** | Cabang 1 Alun-Alun (`1234`), Cabang 2 Pasar Besar (`5678`), Owner Dicky (`8888`) | ✅ Selesai |
| 6 | **Build & Deploy Realme C21Y** | APK Debug mandiri (bebas CMake/NDK) terpasang via ADB ke Realme C21Y fisik | ✅ Selesai |
| 7 | **Transaksi & Potong Stok** | Modal bayar Tunai/QRIS, kalkulator kembalian, struk digital, potong stok otomatis | ✅ Selesai |
| 8 | **Distribusi Stok (Pilihan 3)** | Owner kirim stok (`PENDING`) ➔ Kasir verifikasi fisik (`DITERIMA` / `DITERIMA_SELISIH` + alasan wajib) ➔ Stok cabang bertambah atomik | ✅ Selesai (Live HP) |
| 9 | **UI Shell Menu Kasir Baru** | Tampilan modern adaptasi dashboard grocery (`cashier_menu_screen.dart`): Top bar, Date-Time bar hijau, 3 kartu statistik, chip kategori horizontal, grid produk 2 kolom, dan bottom nav bar 5 tab | ✅ Selesai (Commit `4d36d6b`) |
| 10 | **Arsitektur 1 Pintu Owner** | Konsep transaksi outlet 1 & 2 terisolasi per cabang (`outletCode: SD01 / SD02`), bermuara konsolidasi otomatis ke Akun Owner Mas Dicky | ✅ Selesai Dirancang |

---

## 🚧 Status Saat Ini (Sedang Berjalan)

1. **Layar Menu Kasir Baru (`cashier_menu_screen.dart`):**
   - Kerangka tampilan (UI Shell) sudah selesai dan dites kompilasi via Chrome (`http://localhost:8080`).
   - Langkah berikutnya: Menyambungkan data produk asli dari SQLite, fungsionalitas tombol belanja `[+]`, serta kartu statistik penjualan real-time.

2. **Logika 1 Pintu Akun Owner:**
   - Kasir Cabang 1 hanya mengelola data lapak Alun-Alun (`SD01`).
   - Kasir Cabang 2 hanya mengelola data lapak Pasar Besar (`SD02`).
   - Akun Owner (`8888`) memiliki tab filter: `[Semua Cabang] [Cabang 1] [Cabang 2]` untuk melihat omzet, transaksi, dan stok secara terpusat.

---

## 🎯 Target Langkah Selanjutnya (Roadmap Eksekusi)

### 🥇 LANGKAH 1: Sambungkan Menu Baru ke Database SQLite
- Mengganti data dummy produk kelapa & es dengan data tabel `Products`.
- Mengaktifkan filter kategori dinamis (Semua, Kelapa, Es Cup).
- Mengaktifkan tombol `[+]` agar memasukkan item ke keranjang kasir.

### 🥈 LANGKAH 2: Dashboard Konsolidasi 1 Pintu untuk Owner
- Menampilkan total omset harian gabungan di kartu atas saat login sebagai Owner.
- Menyediakan selector cabang `[Semua] [Cabang 1] [Cabang 2]`.

### 🥉 LANGKAH 3: Rekapan Harian & 1-Klik Kirim WhatsApp ke Mas Dicky
- Modal Laporan Tutup Kasir (Kas Awal + Tunai - Pengeluaran = Wajib Setor).
- Rekap butir kelapa pecah (formula 1 butir = 3 cup es degan).
- Tombol `[📲 Kirim Rekapan ke WA Mas Dicky]` membuka template chat WA otomatis tanpa perlu cloud backend.

---

## 📌 Catatan Teknis & Akses Cepat:
- **Lokasi Proyek:** `c:\proyek\kasir_pos`
- **PIN Cabang 1 (Alun-Alun):** `1234`
- **PIN Cabang 2 (Pasar Besar):** `5678`
- **PIN Owner (Mas Dicky):** `8888`
- **Cara Review Cepat Lokal di Chrome:**
  ```powershell
  flutter run -d chrome --web-port 8080
  ```
- **Cara Pasang ke HP Realme C21Y:**
  ```powershell
  flutter run -d 1818094110BA0143
  ```
