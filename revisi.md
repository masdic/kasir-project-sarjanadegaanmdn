# RENCANA IMPLEMENTASI (revisi.md)
# FASE 5: FITUR INPUT STOK KELAPA MASUK DARI SUPPLIER KE CABANG
================================================================================
STATUS: SEDANG DITERAPKAN (EXECUTING)
TANGGAL: 12 November 2026
TARGET: Modal Input Stok Kelapa Masuk Supplier, Pencatatan Tabel SQLite, & Auto-Refresh Katalog
================================================================================

## 1. Latar Belakang & Kebutuhan Pengguna
Pengguna ingin kasir/cabang dapat langsung mencatat kiriman buah kelapa baru yang datang dari supplier ke lapak (Cabang 1 Alun-Alun / Cabang 2 Pasar Besar):
1. **Selektor Jenis Kelapa:** Kasir dapat memilih jenis kelapa yang datang (Kelapa Muda Ijo Utuh, Kelapa Muda Wulung, dll).
2. **Jumlah Butir Cepat:** Tombol cepat (+20, +30, +50, +100 butir) serta input angka fleksibel.
3. **Catatan Supplier:** Menyimpan nama supir / supplier pengirim (misal: "Pak Slamet").
4. **Pembaruan Stok Seketika:** Stok di tabel SQLite `Products` otomatis bertambah, dan riwayat kiriman tersimpan di tabel `SupplierDeliveries`.
5. **Real-time Feedback:** Tampilan sisa stok di kartu katalog kasir langsung bertambah tanpa perlu keluar aplikasi.

---

## 2. Rencana Berkas yang Dimodifikasi
| No | Berkas | Aksi | Deskripsi |
|---|---|---|---|
| 1 | `lib/database/database_helper.dart` | Modifikasi | Buat tabel `SupplierDeliveries` & method `recordSupplierDelivery` (atomic transaction update stock) |
| 2 | `lib/screens/cashier_pos_screen.dart` | Modifikasi | Tambah tombol aksi `[+ Terima Kelapa]` di header kasir, bangun widget modal `_ReceiveCoconutSheet`, dan sinkronisasi refresh katalog |
| 3 | `test/database_test.dart` | Validasi | Tambah unit test untuk verifikasi kiriman supplier dan penambahan stok |

---

## 3. Estimasi Dampak & Keamanan Sistem
- **Keamanan Data:** Menggunakan transaksi atomik SQLite sehingga riwayat pengiriman dan penambahan stok selalu sinkron (tidak ada risiko stok bertambah tapi histori hilang).
- **Pengalaman Pengguna (UX):** Kasir cukup 3 ketukan (Pilih kelapa ➔ Pilih jumlah ➔ Simpan) untuk menyelesaikan pencatatan restock di bawah 10 detik.
