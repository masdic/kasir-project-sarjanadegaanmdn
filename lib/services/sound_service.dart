import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';

class SoundService {
  SoundService._init();
  static final SoundService instance = SoundService._init();

  static const MethodChannel _channel = MethodChannel('com.sarjanadegan.kasir/sound');

  bool notifLowStock = true;
  bool notifShiftEnd = true;
  bool notifStockIncoming = true;
  bool notifAdminOrders = true;
  bool notifSoundChime = true;

  /// Preset: 'chime' | 'notification' | 'alarm' | 'custom'
  String soundPreset = 'chime';
  String ringtoneUri = '';
  String ringtoneTitle = 'Ting! Kasir Bawaan';

  bool _loaded = false;

  Future<void> loadSettings({bool force = false}) async {
    if (_loaded && !force) return;
    try {
      final db = DatabaseHelper.instance;
      notifLowStock = (await db.getSetting('notif_low_stock')) != '0';
      notifShiftEnd = (await db.getSetting('notif_shift_end')) != '0';
      notifStockIncoming = (await db.getSetting('notif_stock_incoming')) != '0';
      notifAdminOrders = (await db.getSetting('notif_admin_orders')) != '0';
      notifSoundChime = (await db.getSetting('notif_sound_chime')) != '0';
      soundPreset = (await db.getSetting('sound_preset')) ?? 'chime';
      ringtoneUri = (await db.getSetting('sound_ringtone_uri')) ?? '';
      ringtoneTitle = (await db.getSetting('sound_ringtone_title')) ?? 'Ting! Kasir Bawaan';
      _loaded = true;
    } catch (_) {}
  }

  Future<void> saveSettings({
    required bool lowStock,
    required bool shiftEnd,
    required bool stockIncoming,
    required bool adminOrders,
    required bool soundChime,
    required String preset,
    required String uri,
    required String title,
  }) async {
    notifLowStock = lowStock;
    notifShiftEnd = shiftEnd;
    notifStockIncoming = stockIncoming;
    notifAdminOrders = adminOrders;
    notifSoundChime = soundChime;
    soundPreset = preset;
    ringtoneUri = uri;
    ringtoneTitle = title;
    _loaded = true;

    final db = DatabaseHelper.instance;
    await db.setSetting('notif_low_stock', lowStock ? '1' : '0');
    await db.setSetting('notif_shift_end', shiftEnd ? '1' : '0');
    await db.setSetting('notif_stock_incoming', stockIncoming ? '1' : '0');
    await db.setSetting('notif_admin_orders', adminOrders ? '1' : '0');
    await db.setSetting('notif_sound_chime', soundChime ? '1' : '0');
    await db.setSetting('sound_preset', preset);
    await db.setSetting('sound_ringtone_uri', uri);
    await db.setSetting('sound_ringtone_title', title);
  }

  /// Memutar suara sesuai pengaturan aktif
  Future<void> playSelectedSound({String? overridePreset, String? overrideUri}) async {
    if (kIsWeb) return;
    await loadSettings();
    final type = overridePreset ?? soundPreset;
    final uri = overrideUri ?? ringtoneUri;
    try {
      await _channel.invokeMethod('playTone', {
        'type': type,
        'uri': uri,
      });
    } catch (_) {}
  }

  /// Suara kasir saat transaksi berhasil dibayar
  Future<void> playTransactionChime() async {
    await loadSettings();
    if (!notifSoundChime) return;
    await playSelectedSound();
  }

  /// Suara pengingat / alarm stok menipis atau tutup shift
  Future<void> playAlertSound() async {
    await loadSettings();
    if (!notifSoundChime) return;
    await playSelectedSound();
  }

  /// Membuka pemilih nada dering bawaan Android (termasuk file MP3 di tablet)
  Future<Map<String, String>?> pickSystemRingtone() async {
    if (kIsWeb) return null;
    try {
      final result = await _channel.invokeMethod('pickRingtone', {
        'currentUri': ringtoneUri,
      });
      if (result is Map) {
        final uri = result['uri']?.toString() ?? '';
        final title = result['title']?.toString() ?? 'Nada Dering Terpilih';
        if (uri.isNotEmpty) {
          return {'uri': uri, 'title': title};
        }
      }
    } catch (_) {}
    return null;
  }
}
