# RENCANA IMPLEMENTASI (revisi.md)
# FIX BUILD ANDROID: ELIMINASI DEPENDENSI CMAKE DENGAN MELEPAS PATH_PROVIDER
================================================================================
STATUS: SELESAI DITERAPKAN & SUKSES BERJALAN DI REALME C21Y ✅
TANGGAL: 11 November 2026
PERANGKAT: Realme C21Y (RMX3261, Android 11, API 30) via USB
================================================================================

## 1. Hasil Eksekusi & Pembuktian
- ✅ Platform Android SDK `android-35` & `android-36` berhasil dikenali Gradle.
- ✅ Menghapus `path_provider` yang menarik library CMake & C++ (:jni) yang tidak dibutuhkan.
- ✅ Inisialisasi SQLite database di `lib/database/database_helper.dart` kini 100% native murni Java di Android (`getDatabasesPath()`) dan aman di Windows (`APPDATA`).
- ✅ Build APK `app-debug.apk` sukses (140 MB).
- ✅ Streaming install via ADB ke Realme C21Y sukses.
- ✅ Aplikasi aktif berjalan (PID terverifikasi), tampilan layar Login Kasir Sarjana Degan POS langsung tampil segar di layar fisik Realme C21Y.

---

## 2. Berkas yang Dimodifikasi
| No | Berkas | Deskripsi |
|---|---|---|
| 1 | `pubspec.yaml` & `pubspec.lock` | Melepas dependensi `path_provider: ^2.1.2` |
| 2 | `lib/database/database_helper.dart` | Migrasi path dokumen Windows/Linux ke standar `dart:io` `Platform.environment` |
| 3 | `android/app/build.gradle.kts` | Menambahkan `packaging.jniLibs.keepDebugSymbols` dan menonaktifkan task strip symbols pada debug |

---

## 3. Langkah Selanjutnya (Next Agenda)
1. Uji coba masukkan PIN di layar HP:
   - Cabang 1: **1234**
   - Cabang 2: **5678**
   - Owner (Dicky): **8888**
2. Masuk ke Layar Utama Kasir POS (Katalog Produk & Keranjang Belanja).
3. Melanjutkan ke Phase 4: Modal Pembayaran Cepat & Pengurangan Stok Otomatis.
