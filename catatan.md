# 📝 Catatan Progress Harian & Roadmap Proyek
**Proyek:** Kasir POS Sarjana Degan Madiun (Offline-First Flutter)  
**Tanggal Update:** 13 November 2026 (01:00 WIB)  
**Status Sesi Ini:** 🏆 FASE 6 (DASHBOARD OWNER 1 PINTU + KATALOG MENU NETRAL) SELESAI & LIVE DI HP  
**Repositori GitHub:** [github.com/masdic/kasir-project-sarjanadegaanmdn](https://github.com/masdic/kasir-project-sarjanadegaanmdn) (Branch `main`, Commit `3aad443`)  

---

## 🛑 Status Akhir Sesi Malam Ini (13 Nov 2026)
> ⚠️ **Arahan Strategis Mas Dicky:**  
> Database akan difinalisasi di akhir proyek. Fokus saat ini adalah **Alur Fungsi, Logika Bisnis, dan UI/UX Interaktif**.

### 🌟 Capaian yang Berhasil Diselesaikan & Diverifikasi di Realme C21Y:
1. **Dashboard 1 Pintu Owner (Opsi 2 - PIN 8888):**
   - Layar konsol eksekutif khusus Mas Dicky (`OwnerDashboardScreen`).
   - Filter segmented 1 pintu: `[Semua Cabang (Konsolidasi)]`, `[Cabang 1 - Alun-Alun]`, `[Cabang 2 - Pasar Besar]`.
   - Ringkasan omzet lengkap: Pemisahan Tunai (uang fisik kasir) vs QRIS (rekening bank).
   - Kartu komparasi performa Cabang 1 vs Cabang 2 secara berdampingan.
   - Pemantauan alokasi stok cabang dan jumlah kiriman kelapa yang masih `PENDING`.
2. **Revisi Katalog Menu Netral (Layar Kasir):**
   - Nama produk menggunakan slot placeholder netral: `Menu 1` s/d `Menu 6`.
   - Harga dikosongkan dan tampil netral: `Rp —` (siap diisi nama & harga riil belakangan).
   - Kategori netral: `Semua`, `Kategori A`, `Kategori B`.
   - Bentuk kartu grocery card modern tetap utuh 100% (2 kolom, rounded border, elevation shadow, lencana sisa stok, tombol `[+]` hijau).
   - Keranjang belanja interaktif aktif: Klik `[+]` memicu badge jumlah item dan floating bar belanja di bawah.

---

## 🎯 Agenda Progres Lanjutan untuk Besok

Berikut adalah daftar prioritas fitur dan alur logika yang siap dikerjakan saat sesi berlanjut besok:

### 🥇 AGENDA 1: Alur Quick Checkout / Modal Bayar Langsung dari Layar Menu
- **Tujuan:** Kasir tidak perlu bolak-balik layar untuk menyelesaikan transaksi cepat.
- **Rincian Alur & UI/UX:**
  1. Klik tombol floating bar `[Buka Kasir / Bayar]` memunculkan Bottom Sheet Checkout ringkas.
  2. Menampilkan rincian item belanja yang dipilih beserta subtotal.
  3. Pilihan metode pembayaran: `[💵 Tunai]` atau `[📱 QRIS]`.
  4. Quick Money Button untuk uang tunai pas atau pecahan umum (Rp 10.000, Rp 20.000, Rp 50.000, Rp 100.000) + kalkulator kembalian otomatis.
  5. Konfirmasi pembayaran ➔ Struk digital & reset keranjang belanja.

### 🥈 AGENDA 2: Alur Tutup Kasir / Daily Shift Closing (1-Klik WhatsApp ke Mas Dicky)
- **Tujuan:** Mempermudah kasir melaporkan rekapan harian ke Mas Dicky di akhir shift secara akurat tanpa cloud backend.
- **Rincian Alur & UI/UX:**
  1. Menu Tutup Kasir di akhir shift (Pagi/Sore).
  2. Input Kas Awal + Penjualan Tunai - Pengeluaran Lapak = **Uang Fisik Wajib Setor**.
  3. Rekapan butir kelapa pecah vs cup es terjual (formula: 1 butir kelapa = 3 cup es).
  4. Tombol 1-klik `[📲 Kirim Rekapan ke WhatsApp Mas Dicky]` yang otomatis meng-generate teks chat terformat rapi dan membuka aplikasi WhatsApp Mas Dicky.

### 🥉 AGENDA 3: Fungsionalitas Tab Navigasi Bawah (Stok & Riwayat)
- **Tujuan:** Mengaktifkan tab bawah pada `CashierMenuScreen` agar navigasi kasir semakin lengkap.
- **Rincian Alur & UI/UX:**
  1. **Tab Stok:** Menampilkan sisa stok lapak terkini + tombol cepat untuk `[📦 Verifikasi Kiriman Kelapa dari Owner]`.
  2. **Tab Riwayat:** Menampilkan riwayat nota/struk transaksi yang terjadi hari ini beserta detail jam dan nominal.
  3. **Tab Pengaturan:** Profil cabang, pergantian shift, dan tombol logout / kunci layar.

### 📋 AGENDA 4: Pengisian Data Menu & Harga Asli (Opsional saat Mas Dicky Siap)
- Mengganti placeholder `Menu 1` - `Menu 6` dan `Rp —` dengan daftar menu & harga resmi Sarjana Degan Madiun saat Mas Dicky sudah menghendaki.

---

## 📌 Catatan Teknis & Akses Cepat:
- **Lokasi Proyek:** `c:\proyek\kasir_pos`
- **PIN Akses:**
  - `Cabang 1 (Alun-Alun)`: `1234`
  - `Cabang 2 (Pasar Besar)`: `5678`
  - `Owner (Mas Dicky)`: `8888`
- **Device Target:** Realme C21Y (`1818094110BA0143`)
- **Perintah Pasang Cepat ke HP:**
  ```powershell
  flutter run -d 1818094110BA0143
  ```

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
