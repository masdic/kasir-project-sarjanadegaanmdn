# RENCANA IMPLEMENTASI & CATATAN REVISI (revisi.md)
# FASE 6 - TAHAP 2 & REVISI MENU KATALOG NETRAL
================================================================================
STATUS: SELESAI & TERVERIFIKASI LIVE DI REALME C21Y
TANGGAL: 13 November 2026
================================================================================

## 1. Status Fitur Terkini
1. **Dashboard 1 Pintu Owner (PIN 8888):**
   - Layar `OwnerDashboardScreen` live.
   - Filter segmented `[Konsolidasi]`, `[Cabang 1]`, `[Cabang 2]`.
   - Ringkasan omset (Tunai vs QRIS), komparasi 2 lapak, dan distribusi stok live.
2. **Katalog Menu Template Netral (Sesuai Permintaan Mas Dicky):**
   - Nama produk: `Menu 1` s/d `Menu 6`.
   - Harga: Dikosongkan (`Rp —`), siap diinput kemudian.
   - Kategori: `Semua`, `Kategori A`, `Kategori B`.
   - Bentuk kartu: Tetap konsisten dengan layout grocery card modern, lencana stok, dan tombol `[+]`.
   - Floating keranjang belanja: Mendukung penambahan item dan kalkulasi jumlah item.

---

## 2. Berkas yang Dimodifikasi & Dibuat
| No | Berkas | Aksi | Keterangan |
|---|---|---|---|
| 1 | `lib/database/database_helper.dart` | Modifikasi | Filter outlet pada `getDailySummary` dan breakdown Tunai/QRIS |
| 2 | `lib/screens/owner_dashboard_screen.dart` | Baru | Layar Dashboard 1 Pintu Owner |
| 3 | `lib/screens/cashier_menu_screen.dart` | Modifikasi | Shell UI Menu Kasir modern + template menu & harga netral |
| 4 | `lib/main.dart` | Modifikasi | Routing PIN: `8888` ke Owner Dashboard, `1234`/`5678` ke Kasir Menu |
| 5 | `catatan.md` | Modifikasi | Sinkronisasi status pengerjaan |
