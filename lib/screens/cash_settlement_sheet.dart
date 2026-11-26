import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';

/// Modal / Bottom Sheet Hitung Kas & Setoran Tutup Shift
/// Rumus Resmi: Modal Awal + Omzet Tunai - Pengeluaran Lapak = Uang Fisik Disetor ke Mas Dicky
class CashSettlementSheet extends StatefulWidget {
  final String branchName;
  final String shiftName;
  final bool isOwner;

  const CashSettlementSheet({
    super.key,
    required this.branchName,
    required this.shiftName,
    this.isOwner = false,
  });

  /// Helper statis untuk membuka sheet ini dari mana saja
  static Future<void> show(
    BuildContext context, {
    required String branchName,
    required String shiftName,
    bool isOwner = false,
    VoidCallback? onClosed,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CashSettlementSheet(
        branchName: branchName,
        shiftName: shiftName,
        isOwner: isOwner,
      ),
    );
    if (onClosed != null) onClosed();
  }

  @override
  State<CashSettlementSheet> createState() => _CashSettlementSheetState();
}

class _CashSettlementSheetState extends State<CashSettlementSheet> {
  bool _isLoading = true;
  int _initialCash = 100000; // Default modal awal uang kembalian kasir (Rp 100.000)
  Map<String, dynamic> _data = {};
  List<Expense> _expenses = [];

  // Warna tema (Emerald Green Chili POS)
  static const Color _primaryGreen = Color(0xFF10B981);
  static const Color _primaryDark = Color(0xFF059669);
  static const Color _primaryMint = Color(0xFFDCFCE7);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final settlement = await DatabaseHelper.instance.getShiftCashSettlement(
      initialCash: _initialCash,
    );
    final expensesList = await DatabaseHelper.instance.getExpenses(
      date: DateTime.now(),
    );

    if (mounted) {
      setState(() {
        _data = settlement;
        _expenses = expensesList;
        _isLoading = false;
      });
    }
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

  String _formatDateHuman(DateTime dt) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[dt.weekday % 7];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  // ── Dialog Ubah Modal Awal ──────────────────────────────────────────────────
  void _showEditInitialCashDialog() {
    final controller = TextEditingController(text: _initialCash.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.account_balance_wallet_rounded, color: _primaryDark, size: 22),
            SizedBox(width: 8),
            Text(
              'Ubah Modal Awal Kasir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan nominal uang fisik modal kembalian di laci kasir saat awal shift:',
              style: TextStyle(fontSize: 12.5, color: _textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: '100000',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primaryGreen, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text) ?? _initialCash;
              Navigator.pop(ctx);
              setState(() => _initialCash = val);
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ── Dialog Tambah Pengeluaran Kas Kecil ──────────────────────────────────────
  void _showAddExpenseDialog() {
    String selectedCategory = 'Es Batu Kristal';
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    final categories = [
      'Es Batu Kristal',
      'Cup Plastik & Sedotan',
      'Gula Jawa & Sirup',
      'Kantong Kresek',
      'Gas & Bahan Bakar',
      'Operasional Lapak',
      'Lain-lain',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFEF4444), size: 22),
              SizedBox(width: 8),
              Text(
                'Catat Pengeluaran Lapak',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Uang yang dikeluarkan dari laci kasir untuk keperluan belanja operasional hari ini:',
                  style: TextStyle(fontSize: 12, color: _textMuted),
                ),
                const SizedBox(height: 14),
                const Text('Kategori Pengeluaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCategory = val);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Nominal Pengeluaran (Rp)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
                const SizedBox(height: 6),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    hintText: '10000',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Catatan / Keterangan (Opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    hintText: 'Misal: Beli 1 sak es batu kristal',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: _textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final nominal = int.tryParse(amountController.text) ?? 0;
                if (nominal <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nominal harus lebih dari 0!'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final newExpense = Expense(
                  expenseDate: DateTime.now(),
                  category: selectedCategory,
                  amount: nominal,
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );
                await DatabaseHelper.instance.insertExpense(newExpense);
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Simpan Biaya'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Salin & Rangkai Pesan WhatsApp ke Mas Dicky ──────────────────────────────
  void _shareToWhatsApp() {
    final now = DateTime.now();
    final dateStr = _formatDateHuman(now);
    final initialCashStr = _formatRupiah(_data['initialCash'] as int? ?? _initialCash);
    final cashStr = _formatRupiah(_data['cashRevenue'] as int? ?? 0);
    final qrisStr = _formatRupiah(_data['qrisRevenue'] as int? ?? 0);
    final totalRevStr = _formatRupiah(_data['totalRevenue'] as int? ?? 0);
    final expStr = _formatRupiah(_data['totalExpenses'] as int? ?? 0);
    final depositStr = _formatRupiah(_data['depositCash'] as int? ?? 0);
    final txCount = _data['transactionCount'] as int? ?? 0;
    final coconutStock = _data['coconutStock'] as int? ?? 0;

    final buffer = StringBuffer();
    buffer.writeln('🥥 *LAPORAN TUTUP KASIR - SARJANA DEGAN MADIUN* 🥥');
    buffer.writeln('📅 Tanggal: $dateStr');
    buffer.writeln('🏪 Lokasi: ${widget.branchName}');
    buffer.writeln('⏰ Shift: Shift ${widget.shiftName}');
    buffer.writeln('👤 Kasir: ${widget.isOwner ? 'Mas Dicky (Owner)' : 'Staf Kasir Lapak'}');
    buffer.writeln('────────────────────────────────');
    buffer.writeln('💰 *PERHITUNGAN KAS & SETORAN FISIK:*');
    buffer.writeln('  • Modal Awal Laci  : $initialCashStr');
    buffer.writeln('  • Penjualan Tunai  : +$cashStr');
    buffer.writeln('  • Pengeluaran Lapak: -$expStr');
    buffer.writeln('--------------------------------');
    buffer.writeln('👉 *UANG FISIK WAJIB SETOR KE MAS DICKY:*');
    buffer.writeln('⭐ *$depositStr* ⭐');
    buffer.writeln('────────────────────────────────');
    buffer.writeln('📱 *TRANSAKSI QRIS / NON-TUNAI:*');
    buffer.writeln('  • Omzet QRIS : $qrisStr (Langsung Rekening)');
    buffer.writeln('  • Total Omzet Toko : $totalRevStr');
    buffer.writeln('  • Total Nota / Pembeli: $txCount Transaksi');

    if (_expenses.isNotEmpty) {
      buffer.writeln('────────────────────────────────');
      buffer.writeln('💸 *RINCIAN PENGELUARAN LAPAK HARI INI:*');
      for (final exp in _expenses) {
        final note = exp.notes != null && exp.notes!.isNotEmpty ? ' (${exp.notes})' : '';
        buffer.writeln('  - ${exp.category}: ${_formatRupiah(exp.amount)}$note');
      }
    }

    buffer.writeln('────────────────────────────────');
    buffer.writeln('🥥 *STOK BAHAN BAKU:*');
    buffer.writeln('  • Sisa Stok Kelapa Butir: $coconutStock Butir');
    buffer.writeln('────────────────────────────────');
    buffer.writeln('_Laporan otomatis dari Sistem Kasir POS Sarjana Degan Madiun_');

    final messageText = buffer.toString();

    // 1. Salin ke clipboard
    Clipboard.setData(ClipboardData(text: messageText));

    // 2. Tampilkan dialog sukses dengan preview pesan
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 24),
            SizedBox(width: 8),
            Text('Laporan Berhasil Disusun!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teks laporan lengkap sudah otomatis disalin ke Clipboard! Mas Dicky bisa langsung tempel (Paste) di WhatsApp.',
              style: TextStyle(fontSize: 12.5, color: _textDark),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _borderColor),
              ),
              child: SingleChildScrollView(
                child: Text(
                  messageText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: _textDark),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Teks disalin! Silakan buka aplikasi WhatsApp dan Paste.'),
                  backgroundColor: _primaryDark,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Buka / Salin WA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.90;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: _primaryGreen),
                ),
              )
            : Column(
                children: [
                  // ── Handle Bar ───────────────────────────────────────────
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),

                  // ── Header Modal ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primaryMint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calculate_rounded, color: _primaryDark, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hitung Kas & Setoran Tutup Shift',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                ),
                              ),
                              Text(
                                '${widget.branchName} • Shift ${widget.shiftName} • ${_formatDateHuman(DateTime.now())}',
                                style: const TextStyle(fontSize: 11, color: _textMuted),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: _textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: _borderColor, height: 1),

                  // ── Body Konten ──────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. KARTU HERO: UANG FISIK WAJIB SETOR
                          _buildHeroDepositCard(),
                          const SizedBox(height: 16),

                          // 2. GRID 4 KOMPONEN PERHITUNGAN
                          _buildComponentsGrid(),
                          const SizedBox(height: 20),

                          // 3. DAFTAR PENGELUARAN LAPAK HARI INI
                          _buildExpensesSection(),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom Action Bar ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: _borderColor)),
                    ),
                    child: Row(
                      children: [
                        // Tombol Tambah Biaya
                        OutlinedButton.icon(
                          onPressed: _showAddExpenseDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Catat Biaya'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _textDark,
                            side: const BorderSide(color: _borderColor),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Tombol Kirim WhatsApp
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareToWhatsApp,
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text(
                              'Kirim Rekap ke WA Mas Dicky',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Kartu Hero Uang Fisik Wajib Setor ────────────────────────────────────────
  Widget _buildHeroDepositCard() {
    final deposit = _data['depositCash'] as int? ?? 0;
    final initial = _data['initialCash'] as int? ?? _initialCash;
    final cash = _data['cashRevenue'] as int? ?? 0;
    final exp = _data['totalExpenses'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.payments_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'UANG FISIK WAJIB DISETOR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Wajib Pas',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatRupiah(deposit),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Rumus: Modal Awal (${_formatRupiah(initial)}) + Tunai (${_formatRupiah(cash)}) - Biaya (${_formatRupiah(exp)})',
                    style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid 4 Komponen Perhitungan ─────────────────────────────────────────────
  Widget _buildComponentsGrid() {
    final initial = _data['initialCash'] as int? ?? _initialCash;
    final cash = _data['cashRevenue'] as int? ?? 0;
    final cashTx = _data['cashTxCount'] as int? ?? 0;
    final qris = _data['qrisRevenue'] as int? ?? 0;
    final qrisTx = _data['qrisTxCount'] as int? ?? 0;
    final exp = _data['totalExpenses'] as int? ?? 0;

    return Column(
      children: [
        Row(
          children: [
            // 1. Modal Awal Kasir
            Expanded(
              child: _buildMetricTile(
                title: 'Modal Awal Kasir',
                amount: _formatRupiah(initial),
                subtitle: 'Uang kembalian di laci',
                icon: Icons.account_balance_wallet_outlined,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                actionLabel: 'Ubah',
                onAction: _showEditInitialCashDialog,
              ),
            ),
            const SizedBox(width: 12),
            // 2. Omzet Tunai
            Expanded(
              child: _buildMetricTile(
                title: 'Penjualan Tunai',
                amount: '+${_formatRupiah(cash)}',
                subtitle: '$cashTx Nota Pembeli',
                icon: Icons.money_rounded,
                iconBg: _primaryMint,
                iconColor: _primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 3. Pengeluaran Lapak
            Expanded(
              child: _buildMetricTile(
                title: 'Pengeluaran Lapak',
                amount: '-${_formatRupiah(exp)}',
                subtitle: '${_expenses.length} Catatan Biaya',
                icon: Icons.shopping_bag_outlined,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFDC2626),
                actionLabel: '+ Catat',
                onAction: _showAddExpenseDialog,
              ),
            ),
            const SizedBox(width: 12),
            // 4. Penjualan QRIS (Non-Tunai)
            Expanded(
              child: _buildMetricTile(
                title: 'Penjualan QRIS',
                amount: _formatRupiah(qris),
                subtitle: '$qrisTx Transaksi (Rekening)',
                icon: Icons.qr_code_scanner_rounded,
                iconBg: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0284C7),
                badgeText: 'Non-Tunai',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    String? actionLabel,
    VoidCallback? onAction,
    String? badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              if (actionLabel != null && onAction != null)
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _primaryMint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _primaryDark),
                    ),
                  ),
                ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: _textMuted),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: _textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: _textMuted)),
        ],
      ),
    );
  }

  // ── Daftar Rincian Pengeluaran Lapak Hari Ini ───────────────────────────────
  Widget _buildExpensesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.receipt_long_rounded, size: 16, color: _textDark),
                  SizedBox(width: 6),
                  Text(
                    'Rincian Pengeluaran Kas Kecil Hari Ini',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _textDark),
                  ),
                ],
              ),
              Text(
                'Total: ${_formatRupiah(_data['totalExpenses'] as int? ?? 0)}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_expenses.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Column(
                children: const [
                  Icon(Icons.check_circle_outline_rounded, size: 28, color: _primaryGreen),
                  SizedBox(height: 6),
                  Text(
                    'Belum ada pengeluaran kas kecil hari ini.',
                    style: TextStyle(fontSize: 11.5, color: _textMuted),
                  ),
                  Text(
                    'Gunakan tombol "Catat Biaya" jika membeli es batu / kresek.',
                    style: TextStyle(fontSize: 10.5, color: _textMuted),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _expenses.length,
              separatorBuilder: (_, __) => const Divider(height: 8, color: _borderColor),
              itemBuilder: (ctx, i) {
                final exp = _expenses[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.remove, size: 14, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exp.category,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark),
                            ),
                            if (exp.notes != null && exp.notes!.isNotEmpty)
                              Text(exp.notes!, style: const TextStyle(fontSize: 10.5, color: _textMuted)),
                          ],
                        ),
                      ),
                      Text(
                        _formatRupiah(exp.amount),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 16, color: _textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          if (exp.id != null) {
                            await DatabaseHelper.instance.deleteExpense(exp.id!);
                            _loadData();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
