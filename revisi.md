# RENCANA IMPLEMENTASI (revisi.md)
# FASE 4: MODAL PEMBAYARAN CEPAT (QUICK PAY), SIMPAN TRANSAKSI & PEMOTONGAN STOK
================================================================================
STATUS: SELESAI DITERAPKAN & LIVE DI REALME C21Y ✅
TANGGAL: 11 November 2026
PERANGKAT: Realme C21Y (Android 11, API 30) via USB
================================================================================

## 1. Hasil Implementasi Fitur Pembayaran (Phase 4)
- ✅ **Prefiks Invoice Kode Outlet:** `DatabaseHelper.generateInvoiceNumber([String outletCode = 'SD01'])` menghasilkan nomor nota unik `TRX-SD01-YYYYMMDD-001` (Cabang 1) dan `TRX-SD02-YYYYMMDD-001` (Cabang 2).
- ✅ **Modal Pembayaran Cepat (`_PaymentModalSheet`):**
  - Tagihan besar jelas format Rupiah.
  - Tab Selektor: **TUNAI (CASH)** dan **QRIS / TRANSFER**.
  - Tombol pecahan cepat: `[ Uang Pas ]`, `[ Rp 10.000 ]`, `[ Rp 20.000 ]`, `[ Rp 50.000 ]`, `[ Rp 100.000 ]`.
  - Input nominal fleksibel jika pembeli membayar nominal pecahan lain.
  - Kalkulator kembalian instan otomatis (Hijau jika pas/lebih, Merah jika uang kurang dan tombol proses dinonaktifkan).
- ✅ **Simpan SQLite & Pemotongan Stok Otomatis:**
  - Header transaksi tersimpan di tabel `Transactions`.
  - Rincian belanja tersimpan di tabel `TransactionItems`.
  - Stok produk di tabel `Products` terpotong secara otomatis via atomic transaction.
- ✅ **Dialog Struk Nota Sukses (`_showReceiptDialog`):**
  - Tampilan struk digital lengkap dengan nomor nota, rincian barang, total, bayar, dan kembalian.
  - Tombol `SELESAI / TRANSAKSI BARU` otomatis mengosongkan keranjang dan me-refresh sisa stok di katalog.

---

## 2. Berkas yang Dimodifikasi
| No | Berkas | Deskripsi |
|---|---|---|
| 1 | `lib/database/database_helper.dart` | Support parameter `outletCode` di `generateInvoiceNumber` |
| 2 | `lib/screens/cashier_pos_screen.dart` | Implementasi `_openPaymentModal`, `_PaymentModalSheet`, `_showReceiptDialog`, & integrasi tombol BAYAR |

---

## 3. Langkah Selanjutnya (Next Step)
- Melanjutkan ke **Tahap 2: Layar Rekapan Harian & Tombol Kirim WhatsApp ke Mas Dicky**.
