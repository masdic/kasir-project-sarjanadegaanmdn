# RENCANA IMPLEMENTASI (revisi.md)
# FASE 3: LAYAR UTAMA KASIR POS (KATALOG PRODUK & KERANJANG SPLIT-SCREEN)
================================================================================
STATUS: SELESAI DITERAPKAN (IMPLEMENTED & READY FOR TESTING)
TANGGAL: 10 November 2026
TARGET VIEWPORT: Opsi A (Tablet / Desktop Landscape Split-Screen)
================================================================================

## 1. Latar Belakang & Kebutuhan Pengguna
Setelah kasir berhasil memasukkan PIN (Cabang 1: 1234, Cabang 2: 5678, Owner: 8888), aplikasi harus langsung berpindah secara mulus dari layar login menuju **Layar Utama Kasir POS**.
Sesuai pilihan **Opsi A**, tata letak didesain khusus ramah layar tablet (Huawei MatePad) dan PC dalam mode split-screen 2 kolom (Katalog Produk di kiri dan Struk Keranjang Belanja di kanan).

---

## 2. Rincian Komponen Antarmuka (UI/UX Anti-AI Human-Crafted)

### A. Bilah Navigasi Atas (Top Header Bar)
- **Identitas Brand:** `Sarjana Degan POS` + label lokasi `Madiun`.
- **Badge Sesi Kasir:** Menampilkan cabang aktif (contoh: `Cabang 1 - Alun-Alun`), Shift aktif (`Shift Pagi` / `Shift Sore`), dan status role.
- **Jam Realtime Detak:** Jam WIB real-time (hari, tanggal, jam, menit, detik).
- **Tombol Keluar / Kunci Kasir:** Tombol minimalis di pojok kanan untuk kembali ke Layar Login PIN (logout) dengan dialog konfirmasi agar tidak tertekan tidak sengaja.

### B. Panel Kiri: Katalog Menu Cepat (62% Lebar Layar)
- **Tab Kategori Cepat:** Tombol kapsul filter: `[Semua]`, `[Kelapa]`, `[Es Cup]`.
- **Kolom Pencarian Instan:** Input pencarian cepat nama produk.
- **Grid Kartu Produk:**
  - Kartu produk modern bersudut lengkung halus (16px), latar putih bersih, soft drop shadow.
  - Nama produk tebal dan jelas (contoh: `Kelapa Muda Ijo Utuh`, `Es Degan Gula Jawa`).
  - Badge harga hijau emerald (contoh: `Rp 12.000`, `Rp 6.000`).
  - Indikator sisa stok lokal dari SQLite.
  - Aksi sentuh: Sekali ketuk langsung menambahkan 1 item ke keranjang dengan efek visual halus.

### C. Panel Kanan: Struk Keranjang Belanja (38% Lebar Layar)
- **Header Keranjang:** Tanggal & label antrian/order baru.
- **Daftar Item Terpilih:**
  - Menampilkan baris pesanan: Nama produk, harga satuan.
  - Stepper tombol kuantitas ramah sentuh: `[-]` `[Qty]` `[+]`.
  - Subtotal terhitung otomatis per baris.
  - Tombol hapus baris.
- **Kondisi Kosong (Empty State):** Animasi/ikon bersih dan teks ramah: *"Keranjang masih kosong. Sentuh produk di sebelah kiri untuk menambah pesanan."*
- **Panel Pembayaran Bawah:**
  - Rincian Total Kuantitas (misal: `Total 3 Item`).
  - Total Belanja (Font besar, tebal, format rupiah `Rp 24.000`).
  - Tombol aksi:
    - `[Batal / Kosongkan]` (tombol sekunder abu-abu lembut).
    - `[BAYAR]` (tombol hijau emerald besar "juicy pill", siap menuju modal pembayaran).

### D. Fleksibilitas Responsif (Tablet & HP Fallback)
- Menggunakan `LayoutBuilder`:
  - Jika layar lebar (>= 720px): Mode Split-Screen 2 kolom.
  - Jika layar sempit (< 720px): Katalog satu kolom penuh dengan sticky bar keranjang di bawah.

---

## 3. Rencana Berkas yang Dibuat / Dimodifikasi

| No | Berkas | Aksi | Deskripsi Perubahan |
|---|---|---|---|
| 1 | `lib/screens/cashier_pos_screen.dart` | **Buat Baru** | Layar utama POS kasir (split-screen katalog & keranjang, filter kategori, kalkulasi subtotal). |
| 2 | `lib/main.dart` | **Modifikasi Presisi** | Hubungkan aksi `_validatePin` sukses agar memanggil `Navigator.pushReplacement` ke `CashierPosScreen` dengan membawa data cabang & shift. |
| 3 | `test/widget_test.dart` | **Penyelarasan** | Pastikan unit test tetap hijau dan valid. |

---

## 4. Estimasi Dampak & Risiko
- **Stabilitas Kode:** Modul login yang sudah selesai tidak diubah perilakunya, hanya ditambahkan transisi navigasi saat PIN valid.
- **Performa:** Pengambilan data produk terintegrasi langsung dengan `DatabaseHelper.instance` (SQLite lokal offline-first).
- **Integritas Git:** Semua perubahan baru dapat di-commit rapi ke GitHub branch `main`.
