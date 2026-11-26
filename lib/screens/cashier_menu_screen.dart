import 'dart:async';
import 'package:flutter/material.dart';
import 'cashier_pos_screen.dart';
import 'cash_settlement_sheet.dart';
import '../database/database_helper.dart';

/// Layar Dashboard Menu Utama - Sarjana Degan POS Madiun
/// Desain UI/UX: Terinspirasi dari Chili POS Modern Clean (Off-White, Emerald Green, Card UI)
/// Responsif: Sidebar Navigation untuk Desktop/Tablet & Drawer/Bottom-friendly untuk Mobile.
class CashierMenuScreen extends StatefulWidget {
  final String branchName;
  final String shiftName;
  final bool isOwner;

  const CashierMenuScreen({
    super.key,
    required this.branchName,
    required this.shiftName,
    this.isOwner = false,
  });

  @override
  State<CashierMenuScreen> createState() => _CashierMenuScreenState();
}

class _CashierMenuScreenState extends State<CashierMenuScreen> {
  int _selectedNavIndex = 0;
  String _selectedCategory = 'Semua Menu';
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  // ── Preferensi Notifikasi Lapak ───────────────────────────────────────────
  bool _notifLowStock = true;
  bool _notifShiftEnd = true;
  bool _notifStockIncoming = true;
  bool _notifAdminOrders = true;
  bool _notifSoundChime = true;

  // ── Data Real-time SQLite Kasir & Setoran ─────────────────────────────────
  int _liveDepositCash = 100000;
  int _liveCashRevenue = 0;
  int _liveQrisRevenue = 0;
  int _liveCoconutStock = 0;
  int _liveTxCount = 0;

  // ── Warna Tema (Palet Chili POS Clean Green) ───────────────────────────────
  static const Color _bgCanvas = Color(0xFFF4F6F8);
  static const Color _primaryGreen = Color(0xFF10B981);
  static const Color _primaryDark = Color(0xFF059669);
  static const Color _primaryMint = Color(0xFFDCFCE7);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  // ── Daftar Kategori (Header Cards Model Chili POS) ─────────────────────────
  final List<_CategoryCardData> _categories = const [
    _CategoryCardData('Semua Menu', Icons.apps_rounded, '4 Pilihan'),
    _CategoryCardData('Kelapa Murni', Icons.eco_outlined, '2 Pilihan'),
    _CategoryCardData('Es Cup Degan', Icons.local_drink_outlined, '2 Pilihan'),
    _CategoryCardData('Paket Hemat', Icons.card_giftcard_outlined, 'Segera Hadir'),
    _CategoryCardData('Promo Spesial', Icons.local_offer_outlined, '0 Promo'),
  ];

  // ── Daftar Menu Navigasi Samping (Sidebar) ──────────────────────────────────
  final List<_NavItemData> _navItems = const [
    _NavItemData('Menu Kasir', Icons.point_of_sale_rounded),
    _NavItemData('Antrean Meja', Icons.people_outline_rounded),
    _NavItemData('Distribusi Kelapa', Icons.local_shipping_outlined),
    _NavItemData('Buku Kas & Biaya', Icons.account_balance_wallet_outlined),
    _NavItemData('Pengaturan', Icons.settings_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _loadLiveStats();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  Future<void> _loadLiveStats() async {
    final data = await DatabaseHelper.instance.getShiftCashSettlement();
    if (mounted) {
      setState(() {
        _liveDepositCash = data['depositCash'] as int? ?? 100000;
        _liveCashRevenue = data['cashRevenue'] as int? ?? 0;
        _liveQrisRevenue = data['qrisRevenue'] as int? ?? 0;
        _liveCoconutStock = data['coconutStock'] as int? ?? 0;
        _liveTxCount = data['transactionCount'] as int? ?? 0;
      });
    }
  }

  void _openCashSettlement() {
    CashSettlementSheet.show(
      context,
      branchName: widget.branchName,
      shiftName: widget.shiftName,
      isOwner: widget.isOwner,
      onClosed: _loadLiveStats,
    );
  }

  String _formatRupiah(int nominal) {
    final str = nominal.abs().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) buffer.write('.');
    }
    final formatted = buffer.toString().split('').reversed.join('');
    return nominal < 0 ? '-Rp $formatted' : 'Rp $formatted';
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s WIB';
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  MODAL PAYMENT SUCCESS (Persis Kartu Kiri Referensi Chili POS)
  // ══════════════════════════════════════════════════════════════════════════
  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x200F172A),
                  blurRadius: 36,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lingkaran Centang Hijau Besar
                Container(
                  width: 78,
                  height: 78,
                  decoration: const BoxDecoration(
                    color: _primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4010B981),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Judul & Nominal
                const Text(
                  'Payment Success!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rp 36.000',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _primaryGreen,
                  ),
                ),
                const SizedBox(height: 22),

                // Rincian Pembayaran
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE2E8F0), style: BorderStyle.solid),
                      bottom: BorderSide(color: Color(0xFFE2E8F0), style: BorderStyle.solid),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Order ID', 'TRX-SD01-20261115-001'),
                      const SizedBox(height: 8),
                      _buildReceiptRow('Payment Method', 'QRIS / TUNAI'),
                      const SizedBox(height: 8),
                      _buildReceiptRow('Payment Time', _formatTime(_now)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Tombol New Order (Hijau Solid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'New Order',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Tombol Cetak Struk
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🖨️ Mengirim cetak ke Printer Thermal POS...'),
                        backgroundColor: _primaryDark,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.print_outlined, size: 17, color: _textDark),
                  label: const Text(
                    'Print Receipt',
                    style: TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _textMuted, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12.5, color: _textDark, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ROOT BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return Scaffold(
          backgroundColor: _bgCanvas,
          drawer: isWide ? null : Drawer(child: _buildSidebarContent()),
          body: SafeArea(
            child: Row(
              children: [
                // 1. Sidebar Kiri (Tampil Tetap di Layar Lebar)
                if (isWide)
                  Container(
                    width: 240,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(right: BorderSide(color: _borderColor)),
                    ),
                    child: _buildSidebarContent(),
                  ),

                // 2. Konten Utama Dashboard
                Expanded(
                  child: Column(
                    children: [
                      // Bilah Atas (Top Bar)
                      _buildTopBar(isWide),

                      // Area Scrollable Tengah
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kategori Menu (Kartu Horizontal)
                              _buildCategoryHeaderRow(),
                              const SizedBox(height: 20),

                              // Canvas Katalog Bersih (Sesuai Arahan: Belum membuat daftar menu)
                              _buildEmptyCatalogCanvas(),
                            ],
                          ),
                        ),
                      ),

                      // Bilah Status Operasional Bawah
                      _buildBottomTrackerBar(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  1. SIDEBAR CONTENT (Navigasi Samping)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSidebarContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Nama Brand
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: _primaryMint,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'SD',
                    style: TextStyle(
                      color: _primaryDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SARJANA DEGAN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Madiun POS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),

          // Menu List (Pill Vertikal)
          Expanded(
            child: ListView.separated(
              itemCount: _navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) {
                final item = _navItems[i];
                final isActive = _selectedNavIndex == i;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedNavIndex = i);
                    // Index 4 = Pengaturan → tampilkan sub-menu logout
                    if (i == 4) _showSettingsPanel();
                    // Index 3 = Buku Kas & Biaya → buka Sheet Hitung Kas & Setoran
                    if (i == 3) _openCashSettlement();
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? _primaryGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: isActive
                          ? const [
                              BoxShadow(
                                color: Color(0x3510B981),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 19,
                          color: isActive ? Colors.white : _textMuted,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                            color: isActive ? Colors.white : _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Sesi User (info cabang & shift)
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.isOwner ? const Color(0xFFFEF3C7) : _primaryMint,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.isOwner ? '👑' : '👤',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isOwner ? 'Dicky (Owner)' : 'Kasir Lapak',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.branchName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  2. TOP APPLICATION BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopBar(bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          // Tombol Drawer untuk Layar Mobile
          if (!isWide)
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.menu_rounded, color: _textDark),
                tooltip: 'Buka Menu',
              ),
            ),

          // Search Bar
          Expanded(
            child: Container(
              height: 42,
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _borderColor),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 14),
                  Icon(Icons.search, size: 17, color: _textMuted),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cari menu, nota, atau kelapa...',
                      style: TextStyle(fontSize: 12.5, color: _textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Badge Shift & Jam Realtime
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryMint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Shift ${widget.shiftName}',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 8),

          Text(
            _formatTime(_now),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _textDark,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),

          // Tombol Pratinjau Struk (Persis Referensi Kiri)
          ElevatedButton.icon(
            onPressed: _showPaymentSuccessDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: _textDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              elevation: 0,
            ),
            icon: const Icon(Icons.receipt_long, size: 15),
            label: const Text('Contoh Struk', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  3. KARTU KATEGORI MENU (Horizontal Row)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCategoryHeaderRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kategori Menu',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
            ),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _primaryGreen),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _categories.map((cat) {
              final isActive = _selectedCategory == cat.name;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedCategory = cat.name),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 134,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isActive ? _primaryMint : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isActive ? const Color(0xFF86EFAC) : _borderColor,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            cat.icon,
                            color: isActive ? _primaryDark : _primaryGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isActive ? _primaryDark : _textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat.itemCount,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? _primaryDark.withOpacity(0.8) : _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  4. EMPTY CATALOG CANVAS (Instruksi User: Jangan buat daftar menu dulu)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyCatalogCanvas() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge Kerangka Desain
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryMint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '🎨 KERANGKA DESAIN DASHBOARD SIAP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _primaryDark,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Area Katalog Produk & Menu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              'Sesuai arahan Mas Dicky, area ini sengaja disiapkan sebagai layout canvas bersih terlebih dahulu untuk mematangkan tata letak dashboard, navigasi samping, kartu kategori, dan modal struk pembayaran.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: _textMuted,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Buka Kasir POS
          ElevatedButton.icon(
            onPressed: _openPosScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              elevation: 0,
            ),
            icon: const Icon(Icons.point_of_sale_rounded, size: 18),
            label: const Text(
              'Buka Mesin Kasir POS & Transaksi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  5. BILAH STATUS OPERASIONAL BAWAH (Tracker Bar)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBottomTrackerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildTrackerPill('T1', 'Shift ${widget.shiftName} • $_liveTxCount Transaksi', widget.branchName, const Color(0xFFFEF3C7), const Color(0xFFB45309)),
            const SizedBox(width: 10),
            _buildTrackerPill('🥥', 'Stok Kelapa: $_liveCoconutStock Butir', 'Lapak Siap Jual', _primaryMint, _primaryDark),
            const SizedBox(width: 10),
            InkWell(
              onTap: _openCashSettlement,
              borderRadius: BorderRadius.circular(999),
              child: _buildTrackerPill(
                '💰',
                'Wajib Setor: ${_formatRupiah(_liveDepositCash)}',
                'Tunai ${_formatRupiah(_liveCashRevenue)} • QRIS ${_formatRupiah(_liveQrisRevenue)}',
                const Color(0xFFE0F2FE),
                const Color(0xFF0369A1),
              ),
            ),
            const SizedBox(width: 10),
            _buildTrackerPill('✓', 'SQLite Offline', '100% Mandiri Tanpa Internet', _primaryMint, _primaryDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerPill(String badge, String title, String sub, Color badgeBg, Color badgeFg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
            child: Center(
              child: Text(badge, style: TextStyle(color: badgeFg, fontSize: 10.5, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _textDark)),
              Text(sub, style: const TextStyle(fontSize: 9.5, color: _textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  void _openPosScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CashierPosScreen(
          branchName: widget.branchName,
          shiftName: widget.shiftName,
          isOwner: widget.isOwner,
        ),
      ),
    );
    _loadLiveStats();
  }

  // ── Panel Pengaturan (Bottom Sheet) ─────────────────────────────────────────
  void _showSettingsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.settings_outlined, color: Color(0xFF64748B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pengaturan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        Text('Sarjana Degan POS', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),

                // Info sesi aktif
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: widget.isOwner ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text(widget.isOwner ? '👑' : '👤', style: const TextStyle(fontSize: 16))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isOwner ? 'Dicky (Owner)' : 'Kasir Lapak',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              '${widget.branchName} • Shift ${widget.shiftName}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text('Aktif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Menu pengaturan lainnya
                _buildSettingsItem(
                  Icons.notifications_outlined,
                  'Notifikasi Lapak',
                  'Stok menipis, tutup shift, kelapa masuk, pesanan admin',
                  () {
                    Navigator.pop(ctx);
                    _showNotificationSettings();
                  },
                ),
                _buildSettingsItem(Icons.print_outlined, 'Printer Struk', 'Hubungkan printer bluetooth', () {}),
                _buildSettingsItem(Icons.wifi_outlined, 'Sinkronisasi', 'Status koneksi & backup data', () {}),

                const SizedBox(height: 8),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 8),

                // Tombol Logout (Keluar / Ganti Akun)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmLogout();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      backgroundColor: const Color(0xFFFFF5F5),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Keluar / Ganti Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String sub, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF64748B)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  // ── Dialog Konfirmasi Logout ─────────────────────────────────────────────────
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFECACA), width: 2),
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 26),
            ),
            const SizedBox(height: 16),
            const Text('Keluar dari Sesi?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            const Text(
              'Kamu akan kembali ke halaman login.\nPastikan semua transaksi sudah tersimpan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Kembali ke layar Login (pop semua route)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ya, Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Panel Pengaturan Notifikasi Lapak (5 Fitur Permintaan Mas Dicky) ──────────
  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          int activeCount = [
            _notifLowStock,
            _notifShiftEnd,
            _notifStockIncoming,
            _notifAdminOrders,
            _notifSoundChime,
          ].where((b) => b).length;

          return SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _primaryMint,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: _primaryDark,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Notifikasi Lapak',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: _textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _primaryMint,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      '$activeCount/5 Aktif',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: _primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'Alarm & pemberitahuan operasional Sarjana Degan',
                                style: TextStyle(fontSize: 11.5, color: _textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 8),

                    // 1. Peringatan Stok Menipis
                    _buildNotifToggleCard(
                      icon: Icons.inventory_2_outlined,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFB45309),
                      title: 'Peringatan Stok Menipis (< 10 Butir)',
                      subtitle: 'Alarm otomatis berbunyi jika stok kelapa utuh di lapak tersisa di bawah 10 butir.',
                      value: _notifLowStock,
                      onChanged: (val) {
                        setState(() => _notifLowStock = val);
                        setModalState(() {});
                      },
                    ),

                    // 2. Pengingat Tutup Shift & Setoran
                    _buildNotifToggleCard(
                      icon: Icons.alarm_on_rounded,
                      iconBg: const Color(0xFFFFEDD5),
                      iconColor: const Color(0xFFC2410C),
                      title: 'Pengingat Tutup Shift & Setoran',
                      subtitle: 'Alarm pengingat saat jam kerja berakhir untuk hitung uang fisik dan setoran ke Mas Dicky.',
                      value: _notifShiftEnd,
                      onChanged: (val) {
                        setState(() => _notifShiftEnd = val);
                        setModalState(() {});
                      },
                    ),

                    // 3. Pemberitahuan Kelapa Masuk
                    _buildNotifToggleCard(
                      icon: Icons.local_shipping_outlined,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0369A1),
                      title: 'Pemberitahuan Kelapa Masuk',
                      subtitle: 'Notifikasi pop-up saat Mas Dicky mendistribusikan pasokan kelapa baru ke cabang.',
                      value: _notifStockIncoming,
                      onChanged: (val) {
                        setState(() => _notifStockIncoming = val);
                        setModalState(() {});
                      },
                    ),

                    // 4. Pesanan Masuk dari Admin
                    _buildNotifToggleCard(
                      icon: Icons.admin_panel_settings_outlined,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF7E22CE),
                      title: 'Pesanan Masuk dari Admin',
                      subtitle: 'Pemberitahuan seketika jika ada pesanan khusus/online yang diinput langsung oleh Admin/Owner.',
                      value: _notifAdminOrders,
                      onChanged: (val) {
                        setState(() => _notifAdminOrders = val);
                        setModalState(() {});
                      },
                    ),

                    // 5. Suara Kasir (Audio Chime)
                    _buildNotifToggleCard(
                      icon: Icons.volume_up_outlined,
                      iconBg: _primaryMint,
                      iconColor: _primaryDark,
                      title: 'Suara Kasir (Audio Chime "Ting!")',
                      subtitle: 'Memutar efek suara renyah saat pembayaran tunai atau QRIS sukses diverifikasi.',
                      value: _notifSoundChime,
                      onChanged: (val) {
                        setState(() => _notifSoundChime = val);
                        setModalState(() {});
                      },
                    ),

                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),

                    // Tombol Uji Coba & Tombol Simpan
                    Row(
                      children: [
                        // Tombol Tes Notifikasi
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF0F172A),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  content: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF7E22CE),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.notifications_active, color: Colors.white, size: 16),
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '🔔 Pesanan Masuk dari Admin!',
                                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                                            ),
                                            Text(
                                              'Order #ADM-08: 5 Es Degan Cup (Cabang Alun-Alun)',
                                              style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _textDark,
                              side: const BorderSide(color: _borderColor),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                            label: const Text('Tes Notif', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Tombol Simpan
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Pengaturan notifikasi berhasil disimpan dan aktif!'),
                                  backgroundColor: _primaryDark,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Simpan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotifToggleCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? _primaryGreen.withOpacity(0.35) : _borderColor,
          width: value ? 1.4 : 1.0,
        ),
        boxShadow: value
            ? [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: value ? _textDark : _textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: _textMuted, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeColor: _primaryGreen,
            activeTrackColor: _primaryMint,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  DATA HELPERS
// ══════════════════════════════════════════════════════════════════════════
class _CategoryCardData {
  final String name;
  final IconData icon;
  final String itemCount;
  const _CategoryCardData(this.name, this.icon, this.itemCount);
}

class _NavItemData {
  final String label;
  final IconData icon;
  const _NavItemData(this.label, this.icon);
}
