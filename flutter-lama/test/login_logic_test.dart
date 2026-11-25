import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_pos/main.dart';

void main() {
  group('Uji Logika Lengkap Sistem Login PIN Kasir', () {
    testWidgets('1. Login Sukses Cabang 1 dengan PIN 1234', (tester) async {
      await tester.pumpWidget(const KasirPinApp());

      // Pastikan Cabang 1 default aktif
      expect(find.text('Kasir • Cabang 1'), findsOneWidget);

      // Tekan tombol 1, 2, 3, 4
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi snackbar sukses muncul
      expect(find.textContaining('Selamat bertugas Kasir Cabang 1'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('2. Login Sukses Cabang 2 dengan PIN 5678', (tester) async {
      await tester.pumpWidget(const KasirPinApp());

      // Ketuk tombol Cabang 2
      await tester.tap(find.text('Cabang 2'));
      await tester.pumpAndSettle();
      expect(find.text('Kasir • Cabang 2'), findsOneWidget);

      // Tekan tombol 5, 6, 7, 8
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('6'));
      await tester.pump();
      await tester.tap(find.text('7'));
      await tester.pump();
      await tester.tap(find.text('8'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi snackbar sukses Cabang 2
      expect(find.textContaining('Selamat bertugas Kasir Cabang 2'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('3. Proteksi Salah Cabang: PIN 5678 diketik di Cabang 1', (tester) async {
      await tester.pumpWidget(const KasirPinApp());

      // Masukkan PIN Cabang 2 saat masih di mode Cabang 1
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('6'));
      await tester.pump();
      await tester.tap(find.text('7'));
      await tester.pump();
      await tester.tap(find.text('8'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi pesan peringatan salah cabang muncul
      expect(find.textContaining('PIN 5678 adalah milik Cabang 2'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('4. Login Owner 8888 Berhasil di Cabang 1 maupun 2', (tester) async {
      await tester.pumpWidget(const KasirPinApp());

      // Ketuk 8, 8, 8, 8
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('8'));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi Owner diterima
      expect(find.textContaining('Owner (Dicky)'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('5. PIN Sembarang (9999) Ditolak dengan Notifikasi Error', (tester) async {
      await tester.pumpWidget(const KasirPinApp());

      // Ketuk 9, 9, 9, 9
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('9'));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi pesan salah
      expect(find.textContaining('PIN Salah'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('6. Fungsi Tombol Backspace dan Clear', (tester) async {
      await tester.pumpWidget(const KasirPinApp());

      // Ketuk 1, 2
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();

      // Tekan Clear 'C'
      await tester.tap(find.text('C'));
      await tester.pump();

      // Coba ketuk 3, lalu Backspace
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}
