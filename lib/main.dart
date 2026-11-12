import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kasir_pos/assets/coconut_image.dart';

import 'screens/cashier_pos_screen.dart';
import 'screens/cashier_menu_screen.dart';
import 'screens/owner_dashboard_screen.dart';

void main() {
  runApp(const KasirPinApp());
}

/// Root Aplikasi - Terminal Kasir POS Sarjana Degan Madiun
class KasirPinApp extends StatelessWidget {
  const KasirPinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kasir POS Sarjana Degan Madiun',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: const PinLoginScreen(),
    );
  }
}

/// Layar Utama Login Berdasarkan Referensi Fresh Kelapa Muda
class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  // Pilihan aktif: 'Cabang 1', 'Cabang 2', 'Owner'
  String _selectedRole = 'Cabang 1';

  // Pilihan Shift: 'Pagi' atau 'Sore'
  String _selectedShift = 'Pagi';

  String _enteredPin = '';
  String? _errorMessage;
  bool _isError = false;

  late Timer _clockTimer;
  DateTime _currentDateTime = DateTime.now();

  bool get _isOwnerMode => _selectedRole == 'Owner';

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentDateTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final dayName = days[dt.weekday - 1];
    final day = dt.day.toString();
    final monthName = months[dt.month - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$dayName, $day $monthName • $hour:$minute:$second WIB';
  }

  void _onRoleChanged(String role) {
    if (_selectedRole != role) {
      setState(() {
        _selectedRole = role;
        _enteredPin = '';
        _errorMessage = null;
        _isError = false;
      });
    }
  }

  void _onShiftChanged(String shift) {
    if (_selectedShift != shift) {
      setState(() {
        _selectedShift = shift;
      });
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _errorMessage = null;
        _isError = false;
      });

      if (_enteredPin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
        _isError = false;
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _enteredPin = '';
      _errorMessage = null;
      _isError = false;
    });
  }

  void _validatePin() async {
    if (_enteredPin.isEmpty) {
      setState(() {
        _errorMessage = 'Silakan masukkan 4 digit PIN kasir.';
      });
      return;
    }

    if (_enteredPin.length < 4) {
      setState(() {
        _errorMessage = 'PIN belum lengkap (harus 4 digit).';
      });
      return;
    }

    await Future.delayed(const Duration(milliseconds: 150));

    bool isValid = false;
    String greeting = '';

    if (_isOwnerMode) {
      if (_enteredPin == '8888') {
        isValid = true;
        greeting =
            'Selamat datang, Pemilik Usaha (Dicky). Kontrol penuh aktif.';
      } else if (_enteredPin == '1234' || _enteredPin == '5678') {
        setState(() {
          _isError = true;
          _errorMessage = 'Ini adalah PIN Kasir. Silakan beralih ke tab Cabang 1 atau Cabang 2.';
        });
        _scheduleAutoReset();
        return;
      }
    } else if (_selectedRole == 'Cabang 1') {
      if (_enteredPin == '1234') {
        isValid = true;
        greeting =
            'Berhasil! Selamat bertugas Kasir Cabang 1 (Shift $_selectedShift).';
      } else if (_enteredPin == '5678') {
        setState(() {
          _isError = true;
          _errorMessage =
              'PIN 5678 adalah milik Cabang 2. Silakan pilih tab Cabang 2.';
        });
        _scheduleAutoReset();
        return;
      } else if (_enteredPin == '8888') {
        isValid = true;
        greeting = 'Halo Owner (Dicky)! Masuk di mode Cabang 1.';
      }
    } else if (_selectedRole == 'Cabang 2') {
      if (_enteredPin == '5678') {
        isValid = true;
        greeting =
            'Berhasil! Selamat bertugas Kasir Cabang 2 (Shift $_selectedShift).';
      } else if (_enteredPin == '1234') {
        setState(() {
          _isError = true;
          _errorMessage =
              'PIN 1234 adalah milik Cabang 1. Silakan pilih tab Cabang 1.';
        });
        _scheduleAutoReset();
        return;
      } else if (_enteredPin == '8888') {
        isValid = true;
        greeting = 'Halo Owner (Dicky)! Masuk di mode Cabang 2.';
      }
    }

    if (!mounted) return;

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            greeting,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
          backgroundColor: const Color(0xFF15803D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          duration: const Duration(seconds: 2),
        ),
      );

      final branch = _selectedRole;
      final shift = _selectedShift;
      final isOwner = _isOwnerMode;

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => _enteredPin = '');
        if (isOwner) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OwnerDashboardScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CashierMenuScreen(
                branchName: branch,
                shiftName: shift,
                isOwner: false,
              ),
            ),
          );
        }
      });
    } else {
      setState(() {
        _isError = true;
        _errorMessage = 'PIN Salah! Silakan coba lagi.';
      });
      _scheduleAutoReset();
    }
  }

  void _scheduleAutoReset() {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _enteredPin = '';
          _isError = false;
        });
      }
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Color(0xFF15803D),
                size: 22.0,
              ),
            ),
            const SizedBox(width: 10.0),
            const Text(
              'Bantuan & Lupa PIN',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Untuk keamanan operasional toko, reset PIN dilakukan langsung oleh Pemilik Usaha.',
              style: TextStyle(
                fontSize: 13.0,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'SUPERVISOR / OWNER:',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Dicky (Sarjana Degan Madiun)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    'WhatsApp: 0812-3456-7890\nWilayah: Madiun (Alun-Alun & Pasar Besar)',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF475569),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF15803D),
            ),
            child: const Text(
              'Tutup',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2F5E6),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410.0),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(38.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22164E2E),
                      blurRadius: 36.0,
                      offset: Offset(0, 14),
                    ),
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1B6B38), // Hijau daun kelapa tua (atas)
                        Color(0xFF22C55E), // Hijau kelapa segar
                        Color(0xFF86EFAC), // Hijau mint muda
                        Color(0xFFE8F9EE), // Latar bawah lembut
                      ],
                      stops: [0.0, 0.28, 0.65, 1.0],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Header Visual Buah Kelapa Muda (Persis Foto Referensi Atas)
                      _buildFreshCoconutHeader(),

                      // 2. Konten Login Form dengan Komponen Rounded Pill
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          24.0,
                          0.0,
                          24.0,
                          24.0,
                        ),
                        child: Column(
                          children: [
                            // Jam Realtime
                            _buildRealtimeClockChip(),
                            const SizedBox(height: 14.0),

                            // Field 1: Pill Selektor Cabang (Cabang 1, Cabang 2, Owner)
                            _buildPillBranchSelector(),
                            const SizedBox(height: 12.0),

                            // Field 2: Pill Input PIN Kasir (Mirip input Password di referensi)
                            _buildPillPinInputDisplay(),
                            const SizedBox(height: 8.0),

                            // Tautan Lupa PIN (Sebelah Kanan, persis referensi)
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: _showHelpDialog,
                                borderRadius: BorderRadius.circular(8.0),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    'Forgot Password / Lupa PIN?',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),

                            // Area Pesan Validasi / Error
                            if (_errorMessage != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 6.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: Colors.red.shade300,
                                  ),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                            ],

                            // 3. Tombol Utama Login Khas (Juicy Green Rounded Pill)
                            _buildJuicyLoginPillButton(),
                            const SizedBox(height: 16.0),

                            // 4. Keypad Numerik Kasir Tactile
                            _buildTactileKeypadSection(),
                            const SizedBox(height: 18.0),

                            // 5. Divider "Or continue with" (Persis Referensi Bawah)
                            _buildOrContinueWithSection(),
                            const SizedBox(height: 12.0),

                            // 6. Tombol Bawah (Shift Pagi & Shift Sore dalam Pill Putih)
                            _buildShiftOptionPills(),
                            const SizedBox(height: 12.0),

                            // Petunjuk PIN Default
                            Text(
                              _isOwnerMode
                                  ? 'Default PIN Master: 8888'
                                  : (_selectedRole == 'Cabang 1'
                                        ? 'Default PIN Cabang 1: 1234'
                                        : 'Default PIN Cabang 2: 5678'),
                              style: const TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E3A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 1. Banner Visual Buah Kelapa Asli dengan Bayangan Presisi ke Bawah
  Widget _buildFreshCoconutHeader() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.0)),
        boxShadow: [
          // Bayangan presisi tajam & bayangan difusi lembut
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 18.0,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x2214532D),
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30.0),
        ),
        child: SizedBox(
          height: 205.0,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Foto Buah Kelapa Asli
              Image.memory(
                kRealCoconutImageBytes,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),

              // Gradient Vignette Bawah untuk Kontras Teks
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x10000000),
                      Colors.transparent,
                      Color(0x95000000),
                    ],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // Teks Judul Singkat, Padat & Rapi
              Positioned(
                left: 20.0,
                right: 20.0,
                bottom: 14.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sarjana Degan POS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Color(0xB3000000),
                            blurRadius: 10.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        'Madiun',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2. Chip Status & Jam Realtime yang Rapi, Kompak, & Anti-Overflow
  Widget _buildRealtimeClockChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7.0,
              height: 7.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isOwnerMode
                    ? const Color(0xFFD97706)
                    : const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 7.0),
            Text(
              _isOwnerMode ? 'Owner (Dicky)' : 'Kasir • $_selectedRole',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF166534),
              ),
            ),
            Container(
              height: 11.0,
              width: 1.0,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              color: const Color(0xFFCBD5E1),
            ),
            const Icon(
              Icons.access_time_rounded,
              size: 13.0,
              color: Color(0xFF15803D),
            ),
            const SizedBox(width: 4.0),
            Text(
              _formatDateTime(_currentDateTime),
              style: const TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Field 1: Pill Selektor Cabang (Cabang 1, Cabang 2, Owner)
  Widget _buildPillBranchSelector() {
    return Container(
      height: 52.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBranchSegmentItem(
              title: 'Cabang 1',
              subtitle: 'Alun-Alun',
              isSelected: _selectedRole == 'Cabang 1',
              onTap: () => _onRoleChanged('Cabang 1'),
            ),
          ),
          Expanded(
            child: _buildBranchSegmentItem(
              title: 'Cabang 2',
              subtitle: 'Pasar Besar',
              isSelected: _selectedRole == 'Cabang 2',
              onTap: () => _onRoleChanged('Cabang 2'),
            ),
          ),
          Expanded(
            child: _buildBranchSegmentItem(
              title: 'Owner',
              subtitle: 'Dicky',
              isSelected: _selectedRole == 'Owner',
              onTap: () => _onRoleChanged('Owner'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSegmentItem({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF22C55E) : Colors.transparent,
          borderRadius: BorderRadius.circular(22.0),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x2816A34A),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Field 2: Pill PIN Display (Persis Desain Input Password Putih Bersih di Referensi)
  Widget _buildPillPinInputDisplay() {
    return Container(
      height: 52.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _isOwnerMode ? Icons.shield_outlined : Icons.lock_outline_rounded,
            color: const Color(0xFF94A3B8),
            size: 20.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: _enteredPin.isEmpty
                ? Text(
                    _isOwnerMode
                        ? 'Ketik PIN Master Owner...'
                        : 'Ketik 4 digit PIN Kasir...',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Row(
                    children: List.generate(4, (index) {
                      final isFilled = index < _enteredPin.length;
                      return Container(
                        margin: const EdgeInsets.only(right: 10.0),
                        width: 12.0,
                        height: 12.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled
                              ? (_isError
                                    ? Colors.red
                                    : const Color(0xFF16A34A))
                              : const Color(0xFFE2E8F0),
                        ),
                      );
                    }),
                  ),
          ),
          if (_enteredPin.isNotEmpty)
            GestureDetector(
              onTap: _onClearPressed,
              child: const Icon(
                Icons.cancel_rounded,
                color: Color(0xFF94A3B8),
                size: 20.0,
              ),
            ),
        ],
      ),
    );
  }

  /// 3. Tombol Login Khas (Juicy Green Rounded Pill Button)
  Widget _buildJuicyLoginPillButton() {
    return Container(
      width: double.infinity,
      height: 54.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4ADE80), // Highlight hijau terang di atas
            Color(0xFF22C55E),
            Color(0xFF16A34A), // Bayangan hijau di bawah
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40166534),
            blurRadius: 16.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28.0),
          onTap: _validatePin,
          child: const Center(
            child: Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Color(0x33000000),
                    blurRadius: 4.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 4. Keypad Numerik Kasir Ergonomis
  Widget _buildTactileKeypadSection() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadTile('1'),
              _buildKeypadTile('2'),
              _buildKeypadTile('3'),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadTile('4'),
              _buildKeypadTile('5'),
              _buildKeypadTile('6'),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadTile('7'),
              _buildKeypadTile('8'),
              _buildKeypadTile('9'),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionTile(
                label: 'C',
                color: const Color(0xFFDC2626),
                onTap: _onClearPressed,
              ),
              _buildKeypadTile('0'),
              _buildActionTile(
                icon: Icons.backspace_outlined,
                color: const Color(0xFF334155),
                onTap: _onBackspacePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadTile(String digit) {
    return Container(
      width: 72.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.0),
          onTap: () => _onNumberPressed(digit),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: 21.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    String? label,
    IconData? icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 72.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.0),
          onTap: onTap,
          child: Center(
            child: label != null
                ? Text(
                    label,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  )
                : Icon(icon, color: color, size: 20.0),
          ),
        ),
      ),
    );
  }

  /// 5. Garis Pembagi "Or continue with" (Persis Referensi Bawah)
  Widget _buildOrContinueWithSection() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color(0xFF166534), thickness: 0.8)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'Shift Kerja Kasir',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF166534),
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFF166534), thickness: 0.8)),
      ],
    );
  }

  /// 6. Pill Pilihan Shift Kerja (Pagi & Sore, Posisi Seperti Google & Apple di Referensi)
  Widget _buildShiftOptionPills() {
    return Row(
      children: [
        // Pill Shift Pagi
        Expanded(
          child: InkWell(
            onTap: () => _onShiftChanged('Pagi'),
            borderRadius: BorderRadius.circular(22.0),
            child: Container(
              height: 44.0,
              decoration: BoxDecoration(
                color: _selectedShift == 'Pagi'
                    ? const Color(0xFF15803D)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    size: 16.0,
                    color: _selectedShift == 'Pagi'
                        ? Colors.white
                        : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Shift Pagi',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: _selectedShift == 'Pagi'
                          ? Colors.white
                          : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12.0),

        // Pill Shift Sore
        Expanded(
          child: InkWell(
            onTap: () => _onShiftChanged('Sore'),
            borderRadius: BorderRadius.circular(22.0),
            child: Container(
              height: 44.0,
              decoration: BoxDecoration(
                color: _selectedShift == 'Sore'
                    ? const Color(0xFF15803D)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.nightlight_outlined,
                    size: 16.0,
                    color: _selectedShift == 'Sore'
                        ? Colors.white
                        : const Color(0xFF4F46E5),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Shift Sore',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: _selectedShift == 'Sore'
                          ? Colors.white
                          : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom Painter Khusus Melukis Visual Buah Kelapa Muda Hijau Segar
class CoconutArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF14532D);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 1. Daun Kelapa Tropis di Latar Belakang (Deep Palm Green)
    final leafPaint = Paint()
      ..color = const Color(0xFF166534)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 7; i++) {
      final path = Path();
      final startX = size.width * (i / 6.0);
      path.moveTo(startX, 0);
      path.quadraticBezierTo(startX + 30, 70, startX - 20, 130);
      path.quadraticBezierTo(startX - 10, 60, startX, 0);
      canvas.drawPath(path, leafPaint);
    }

    // 2. Buah Kelapa Muda Utama di Tengah (Bulat Segar Hijau)
    final coconutCenter = Offset(size.width * 0.5, 68.0);
    final coconutRadius = 44.0;

    // Bayangan kelapa
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(
      coconutCenter.translate(0, 8),
      coconutRadius,
      shadowPaint,
    );

    // Gradasi kulit kelapa muda segar
    final coconutGradient = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      colors: const [
        Color(0xFF86EFAC), // Highlight hijau muda
        Color(0xFF22C55E), // Hijau kelapa segar
        Color(0xFF15803D), // Hijau bayangan bawah
        Color(0xFF14532D),
      ],
      stops: const [0.0, 0.45, 0.85, 1.0],
    );

    final coconutPaint = Paint()
      ..shader = coconutGradient.createShader(
        Rect.fromCircle(center: coconutCenter, radius: coconutRadius),
      );
    canvas.drawCircle(coconutCenter, coconutRadius, coconutPaint);

    // Tangkai kelapa di atas
    final stemPaint = Paint()
      ..color = const Color(0xFF14532D)
      ..style = PaintingStyle.fill;
    final stemPath = Path()
      ..moveTo(coconutCenter.dx - 6, coconutCenter.dy - coconutRadius + 4)
      ..lineTo(coconutCenter.dx + 6, coconutCenter.dy - coconutRadius + 4)
      ..lineTo(coconutCenter.dx + 2, coconutCenter.dy - coconutRadius - 10)
      ..lineTo(coconutCenter.dx - 2, coconutCenter.dy - coconutRadius - 10)
      ..close();
    canvas.drawPath(stemPath, stemPaint);

    // 3. Kelapa Muda Belah di Sebelah Kanan (Menampilkan Daging Kelapa & Air Segar)
    final halfCenter = Offset(size.width * 0.8, 80.0);
    final halfRadius = 38.0;

    // Kulit luar hijau
    final greenShellPaint = Paint()..color = const Color(0xFF15803D);
    canvas.drawCircle(halfCenter, halfRadius, greenShellPaint);

    // Sabut kelapa putih
    final innerHuskPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawCircle(halfCenter, halfRadius - 4, innerHuskPaint);

    // Daging kelapa muda putih bersih
    final meatPaint = Paint()..color = Colors.white;
    canvas.drawCircle(halfCenter, halfRadius - 7, meatPaint);

    // Air kelapa segar di tengah
    final waterGradient = RadialGradient(
      colors: const [
        Color(0xFFE0F2FE), // Biru bening air kelapa
        Color(0xFFBAE6FD),
      ],
    );
    final waterPaint = Paint()
      ..shader = waterGradient.createShader(
        Rect.fromCircle(center: halfCenter, radius: halfRadius - 13),
      );
    canvas.drawCircle(halfCenter, halfRadius - 13, waterPaint);

    // 4. Buah Kelapa Utuh Kedua di Sebelah Kiri
    final leftCenter = Offset(size.width * 0.2, 75.0);
    final leftRadius = 36.0;

    final leftCoconutGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: const [Color(0xFF4ADE80), Color(0xFF16A34A), Color(0xFF14532D)],
    );
    final leftPaint = Paint()
      ..shader = leftCoconutGradient.createShader(
        Rect.fromCircle(center: leftCenter, radius: leftRadius),
      );
    canvas.drawCircle(leftCenter, leftRadius, leftPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
