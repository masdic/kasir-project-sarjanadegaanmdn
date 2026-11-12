# RENCANA IMPLEMENTASI (revisi.md)
# FASE 5: FITUR INPUT STOK KELAPA MASUK DARI SUPPLIER KE CABANG
================================================================================
STATUS: SELESAI DITERAPKAN (LIVE ON REALME C21Y)
TANGGAL: 12 November 2026
COMMIT: 91b3ef6
================================================================================

## 1. Latar Belakang & Kebutuhan Pengguna
Pengguna memilih **Pilihan 3: Distribusi Terpusat dari Owner ➔ Verifikasi Fisik Kasir**:
- Owner (Dicky) mengirim stok kelapa ke cabang dengan status `PENDING` (surat jalan digital).
- Kasir menerima notifikasi, hitung fisik kelapa, lalu konfirmasi:
  - Jumlah pas: status `DITERIMA`, stok bertambah sesuai kiriman.
  - Ada selisih (misal pecah di jalan): kasir input jumlah aktual + alasan wajib ➔ status `DITERIMA_SELISIH`.

---

## 2. Berkas yang Dimodifikasi
| No | Berkas | Aksi | Keterangan |
|---|---|---|---|
| 1 | `lib/database/database_helper.dart` | ✅ SELESAI | Tabel `StockTransfers` + method `createStockTransfer`, `getPendingTransfers`, `getAllStockTransfers`, `confirmStockTransfer` (atomic transaction) |
| 2 | `lib/screens/cashier_pos_screen.dart` | ✅ SELESAI | Tombol aksi Owner `[👑 Kirim Kelapa ke Cabang]` & Kasir `[📦 Verifikasi Kiriman (X)]`, banner alert pending, sheet `_OwnerSendTransferSheet`, sheet `_CashierVerifyTransferSheet` |

---

## 3. Business Logic Pilihan 3
- Stok cabang **TIDAK** bertambah sampai kasir verifikasi fisik.
- Transaksi SQLite atomik: histori & stok selalu sinkron.
- Offline-first: semua operasi 100% lokal SQLite, zero cloud dependency.

---

## 4. Status Deploy
- ✅ Build: `flutter build apk --debug` → `app-debug.apk`
- ✅ Install: ADB `Performing Streamed Install Success` ke Realme C21Y (`1818094110BA0143`)
- ✅ Launch: App berjalan di device
- ✅ Commit: `91b3ef6` — `feat(stock): implement Pilihan 3 centralized owner distribution and cashier physical verification`
- ✅ Push: `f374f1c..91b3ef6 main → main` ke GitHub

---

## 5. Next Phase (Phase 6)
**Daily Closing & WhatsApp Recap:**
- Modal `[📲 Kirim Rekapan ke WA Mas Dicky]`
- Hitung total kas masuk (tunai), kelapa terjual (formula 1:3), sisa stok akhir hari
- Kirim via WhatsApp URL scheme (`whatsapp://send?phone=...&text=...`) — offline-first, zero backend
