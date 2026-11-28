# 📱 Peta Antarmuka APK — Sarjana Degan POS Madiun

> Dokumen ini adalah peta lengkap semua layar (screen) dan komponen UI yang sudah ada di dalam proyek Flutter.
> Update terakhir: 28 November 2026

---

## 🗂️ Daftar File Antarmuka

| File | Lokasi | Deskripsi |
|---|---|---|
| `main.dart` | `lib/` | Layar Login PIN & routing awal |
| `cashier_menu_screen.dart` | `lib/screens/` | Dashboard utama kasir + grid 21 menu |
| `cashier_pos_screen.dart` | `lib/screens/` | Layar transaksi POS (katalog + keranjang) |
| `cash_settlement_sheet.dart` | `lib/screens/` | Modal tutup kasir & hitung setoran |
| `owner_dashboard_screen.dart` | `lib/screens/` | Ruang kontrol owner Mas Dicky |

---

## 🔐 1. Layar Login PIN (`main.dart`)

**Akses:** Layar pertama saat buka APK

```
┌─────────────────────────────────────┐
│   🥥 Sarjana Degan POS — Madiun     │
│   [Foto Kelapa Asli / Banner]       │
├─────────────────────────────────────┤
│  ● Cabang 1 | Cabang 2 | Owner      │  ← Pill Selector
│  ─────────────────────────────────  │
│  [ ● ● ● ● ]  PIN Input Display     │
│  Lupa PIN?                          │
│  [    MASUK    ]                    │
│  ─────────────────────────────────  │
│  or continue with                   │
│  [ Shift Pagi ] [ Shift Sore ]      │
│  Default PIN Cabang 1: 1234         │
└─────────────────────────────────────┘
```

**Routing PIN:**
- `1234` (Cabang 1) → `CashierMenuScreen` (branchName: 'Cabang 1')
- `5678` (Cabang 2) → `CashierMenuScreen` (branchName: 'Cabang 2')
- `8888` (Owner) → `OwnerDashboardScreen`

---

## 🧾 2. Dashboard Kasir (`cashier_menu_screen.dart`)

**Akses:** Setelah login kasir (PIN 1234 atau 5678)

```
┌──────────────────────────────────────────────────────────┐
│ SIDEBAR  │  KONTEN UTAMA                                  │
│──────────│────────────────────────────────────────────────│
│ 📋 Menu  │  [Search Bar]                                  │
│ Kasir    │                                                │
│          │  [Semua] [Es Degan] [Degan Utuh] [Air] [Spesial]│
│ 👥 Meja  │                                                │
│          │  ┌───────┐ ┌───────┐ ┌───────┐               │
│ 🚚 Kirim │  │ Foto  │ │ Foto  │ │ Foto  │               │
│ Kelapa   │  │Produk1│ │Produk2│ │Produk3│               │
│          │  │ Rp 6K │ │ Rp 9K │ │ Rp 8K │               │
│ 💰 Buku  │  └───────┘ └───────┘ └───────┘               │
│ Kas      │  ... (21 produk dalam grid)                    │
│          │────────────────────────────────────────────────│
│ ⚙️ Atur  │  [T1 Shift Pagi · 3 Trx · Cabang 1]          │
│          │  [💰 Rp 150K] [📱 QRIS Rp 0] [🥥 48 Butir]   │
└──────────┴────────────────────────────────────────────────┘
```

**Komponen:**
- Sidebar 5 nav item
- 5 Kartu Kategori horizontal scroll
- Grid 21 produk (foto + nama + harga)
- Search bar produk
- Bottom tracker bar (Setoran | QRIS | Stok Kelapa)
- Panel Pengaturan (Nada Dering, Notifikasi)
- Tombol Tutup Kasir → Cash Settlement Sheet

---

## 💳 3. Layar POS Transaksi (`cashier_pos_screen.dart`)

**Akses:** Klik produk dari Dashboard → buka POS

```
┌────────────────────────────────────────────────────────────┐
│ ← Balik  Kasir POS · SD01 · Shift Pagi         [Trx: 125K]│
├──────────────────────────┬─────────────────────────────────┤
│  KATALOG PRODUK (Kiri)   │   KERANJANG (Kanan)             │
│  ─────────────────────── │  ───────────────────────────    │
│  [Semua][Es Degan][...]  │  Es Degan Gula Merah  x2 Rp12K │
│                          │  Degan Utuh Besar     x1 Rp15K │
│  ┌─────┐ ┌─────┐         │  ─────────────────────────      │
│  │Foto │ │Foto │         │  TOTAL: Rp 27.000               │
│  │ 6K  │ │ 9K  │         │                                 │
│  └─────┘ └─────┘         │  [      BAYAR SEKARANG     ]    │
│  ...                     │                                 │
└──────────────────────────┴─────────────────────────────────┘
```

**Sub-modal: Pembayaran**
```
┌──────────────────────────────┐
│  💳 TOTAL: Rp 27.000         │
│  ──────────────────────────  │
│  [ TUNAI ]  [ QRIS ]         │
│  ──────────────────────────  │
│  [Rp 30K] [Rp 50K] [Rp 100K]│  ← Quick Amount
│  Nominal Custom: [_______]   │
│  Kembalian: Rp 3.000         │
│  ──────────────────────────  │
│  [     PROSES BAYAR    ]     │
└──────────────────────────────┘
```

**Sub-modal: Verifikasi Stok (Kasir)**
```
┌──────────────────────────────┐
│  🚚 Kiriman Stok dari Owner  │
│  Degan Utuh Besar - 30 Butir │
│  [Jumlah Diterima: ____]     │
│  [  KONFIRMASI TERIMA  ]     │
└──────────────────────────────┘
```

---

## 💰 4. Cash Settlement / Tutup Kasir (`cash_settlement_sheet.dart`)

**Akses:** Tombol "Tutup Kasir" di Dashboard Kasir

```
┌──────────────────────────────────────┐
│  🔐 TUTUP KASIR — SETORAN KAS FISIK  │
│  Jumat, 28 November 2026             │
│  ─────────────────────────────────── │
│  Modal Awal Laci    :   Rp 100.000   │
│  + Penjualan Tunai  :   Rp 150.000   │
│  - Pengeluaran      :   Rp  25.000   │
│  ─────────────────────────────────── │
│  ⭐ WAJIB SETOR KE MAS DICKY:        │
│       Rp 225.000                     │
│  ─────────────────────────────────── │
│  QRIS (ke rekening): Rp 50.000       │
│  Total Omzet       : Rp 200.000      │
│  ─────────────────────────────────── │
│  [+ Tambah Pengeluaran Baru]         │
│  [📋 Salin Laporan WA ke Mas Dicky]  │
└──────────────────────────────────────┘
```

**Formula resmi:**
```
Setoran Fisik = Modal Awal + Omzet Tunai - Pengeluaran Lapak
```

---

## 👑 5. Ruang Owner (`owner_dashboard_screen.dart`)

**Akses:** PIN 8888

```
┌──────────────────────────────────────────────────────────┐
│ 👑 Ruang Kontrol Owner · Mas Dicky        [🔄] [Keluar]  │
├──────────────────────────────────────────────────────────┤
│ [Ringkasan & Laba] [Kirim Kelapa] [Kelola Menu] [Audit]  │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  TAB 1: RINGKASAN & LABA                                 │
│  ┌────────────────────────────────────────────┐          │
│  │ ESTIMASI LABA BERSIH HARI INI              │          │
│  │ Rp 125.000                                 │          │
│  │ Omzet Rp300K − HPP Rp150K − Biaya Rp25K   │          │
│  └────────────────────────────────────────────┘          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                  │
│  │Total Omz │ │Laba Kotor│ │Wajib Setor│                 │
│  │ Rp 300K  │ │ Rp 150K  │ │ Rp 225K  │                 │
│  └──────────┘ └──────────┘ └──────────┘                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                  │
│  │Omzet Tun │ │Omzet QRIS│ │Stok Kelpa│                 │
│  │ Rp 250K  │ │  Rp 50K  │ │ 48 Butir │                 │
│  └──────────┘ └──────────┘ └──────────┘                  │
│                                                          │
│  TAB 2: KIRIM KELAPA                                     │
│  [+ Kirim Kelapa Baru]                                   │
│  TRF-20261128-001 · Cabang 1 · 30 Butir · PENDING        │
│                                                          │
│  TAB 3: KELOLA 21 MENU & HARGA                           │
│  [Foto] Es Degan Gula Merah · Jual: 6K · Modal: 2.5K    │
│         Untung: 3.5K · Stok: 50 Cup            [✏️ Edit] │
│  ...                                                     │
│                                                          │
│  TAB 4: AUDIT NOTA & BIAYA                               │
│  TRX-SD01-20261128-001 · Rp 27.000 · TUNAI   [✓]        │
│  Pengeluaran: Es Batu Kristal · Rp 15.000               │
└──────────────────────────────────────────────────────────┘
```

---

## 🏗️ Struktur File Proyek

```
kasir_pos/
├── lib/
│   ├── main.dart                        ← Login PIN Screen
│   ├── assets/
│   │   └── coconut_image.dart           ← Foto kelapa (embedded bytes)
│   ├── database/
│   │   └── database_helper.dart         ← SQLite singleton (semua query)
│   ├── models/
│   │   ├── product.dart                 ← Model produk + imagePath
│   │   ├── transaction_model.dart       ← Model transaksi
│   │   ├── transaction_item.dart        ← Model item transaksi
│   │   ├── expense.dart                 ← Model pengeluaran
│   │   ├── production_log.dart          ← Model log produksi kelapa
│   │   └── store_profile.dart           ← Model profil toko
│   ├── screens/
│   │   ├── cashier_menu_screen.dart     ← Dashboard kasir (21 menu)
│   │   ├── cashier_pos_screen.dart      ← POS transaksi
│   │   ├── cash_settlement_sheet.dart   ← Tutup kasir / setoran
│   │   └── owner_dashboard_screen.dart  ← Ruang owner (4 tab)
│   └── services/
│       └── sound_service.dart           ← Nada dering / ringtone
├── android/
│   ├── app/src/main/kotlin/.../
│   │   └── MainActivity.kt              ← Native sound MethodChannel
│   └── gradle.properties               ← Build config (parallel, cache)
└── assets/
    └── images/menu/                     ← 21 foto produk menu
        ├── es_degan_gula_merah.jpg
        ├── es_degan_original.jpg
        └── ... (21 file total)
```

---

## ⏳ Fitur UI Yang Belum Dikerjakan

| Fitur | Keterangan |
|---|---|
| Filter cabang di Owner Dashboard | Tambah chip filter: Semua / Cabang 1 / Cabang 2 |
| Kartu perbandingan Cabang 1 vs Cabang 2 | Head-to-head omzet & laba |
| `outletCode` di Transactions & Expenses | Migrasi DB diperlukan |
| Cash Settlement per cabang | Filter `outletCode` di query |

---

*Dibuat oleh ZettBOT · Sarjana Degan POS Madiun · 2026*
