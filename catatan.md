# 📝 Catatan Progress Harian & Roadmap Proyek
**Proyek:** Kasir POS Sarjana Degan Madiun (Offline-First Flutter)  
**Tanggal Update:** 13 November 2026 (00:50 WIB)  
**Status Terakhir:** 🏆 OPSI 2 (DASHBOARD OWNER 1 PINTU) + KATALOG MENU NETRAL SELESAI  
**Repositori GitHub:** [github.com/masdic/kasir-project-sarjanadegaanmdn](https://github.com/masdic/kasir-project-sarjanadegaanmdn) (Branch `main`)  

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
| 10 | **Tahap 1: Koneksi Menu ke Database SQLite** | Data produk nyata SQLite terhubung, sisa stok real, tombol `[+]` tambah keranjang belanja interaktif, proteksi stok habis, floating bar keranjang, filter kategori aktif, pencarian instan | ✅ Selesai (Commit `419fd48`) |
| 11 | **Dashboard 1 Pintu Owner (Opsi 2)** | Konsol eksekutif Mas Dicky (PIN `8888`) memantau total omset gabungan (Tunai vs QRIS), komparasi Cabang 1 vs Cabang 2, dan distribusi stok | ✅ Selesai (Commit `875169b`) |
| 12 | **Katalog Menu Template Netral** | Penyesuaian sesuai instruksi Mas Dicky: nama produk placeholder (`Menu 1` - `Menu 6`), harga dikosongkan (`Rp —`), kategori netral (`Semua`, `Kategori A`, `Kategori B`), bentuk kartu tetap konsisten | ✅ Selesai |

---

## 🚧 Status & Arahan Strategis Mas Dicky
> ⚠️ **Prinsip Utama:** Database akan difinalisasi di akhir. Fokus saat ini adalah **Alur Fungsi, Logika Bisnis, dan UI/UX**.

1. **Katalog Menu:**
   - Dibuat netral (`Menu 1` s/d `Menu 6`, harga `Rp —`, kategori `Kategori A` & `B`).
   - Siap diisi detail menu dan harga belakangan tanpa merusak tata letak kartu.
2. **Dashboard Owner 1 Pintu (PIN 8888):**
   - Berhasil live di Realme C21Y dengan filter gabungan serta rincian Cabang 1 vs Cabang 2.
3. **Layar Kasir Cabang (PIN 1234 & 5678):**
   - Menampilkan menu kartu dengan sisa stok, pencarian, dan keranjang belanja floating.

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
