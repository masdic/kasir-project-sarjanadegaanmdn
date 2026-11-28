package com.example.kasir_pos

import android.app.Activity
import android.content.Intent
import android.media.AudioManager
import android.media.Ringtone
import android.media.RingtoneManager
import android.media.ToneGenerator
import android.net.Uri
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sarjanadegan.kasir/sound"
    private val RINGTONE_PICKER_REQUEST = 9901

    private var pendingPickerResult: MethodChannel.Result? = null
    private var activeRingtone: Ringtone? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playTone" -> {
                    val type = call.argument<String>("type") ?: "chime"
                    val uriStr = call.argument<String>("uri")
                    playTone(type, uriStr)
                    result.success(true)
                }
                "stopSound" -> {
                    stopCurrentRingtone()
                    result.success(true)
                }
                "pickRingtone" -> {
                    if (pendingPickerResult != null) {
                        result.error("BUSY", "Pemilih nada dering sedang terbuka", null)
                        return@setMethodCallHandler
                    }
                    pendingPickerResult = result
                    val currentUriStr = call.argument<String>("currentUri")
                    val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                        putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALL)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Pilih Nada Dering Kasir & Notifikasi")
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
                        if (!currentUriStr.isNullOrEmpty()) {
                            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, Uri.parse(currentUriStr))
                        }
                    }
                    startActivityForResult(intent, RINGTONE_PICKER_REQUEST)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun stopCurrentRingtone() {
        try {
            activeRingtone?.let {
                if (it.isPlaying) it.stop()
            }
            activeRingtone = null
        } catch (_: Exception) {}
    }

    private fun playTone(type: String, uriStr: String?) {
        stopCurrentRingtone()
        try {
            if (!uriStr.isNullOrEmpty() && type == "custom") {
                val uri = Uri.parse(uriStr)
                val ringtone = RingtoneManager.getRingtone(applicationContext, uri)
                if (ringtone != null) {
                    activeRingtone = ringtone
                    ringtone.play()
                    handler.postDelayed({ stopCurrentRingtone() }, 3000)
                    return
                }
            }

            when (type) {
                "chime" -> {
                    val tg = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100)
                    tg.startTone(ToneGenerator.TONE_PROP_BEEP2, 320)
                    handler.postDelayed({ tg.release() }, 450)
                }
                "alarm" -> {
                    val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                    val ringtone = RingtoneManager.getRingtone(applicationContext, uri)
                    activeRingtone = ringtone
                    ringtone?.play()
                    handler.postDelayed({ stopCurrentRingtone() }, 2500)
                }
                else -> {
                    val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                    val ringtone = RingtoneManager.getRingtone(applicationContext, uri)
                    activeRingtone = ringtone
                    ringtone?.play()
                    handler.postDelayed({ stopCurrentRingtone() }, 2500)
                }
            }
        } catch (_: Exception) {
            try {
                val tg = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 90)
                tg.startTone(ToneGenerator.TONE_PROP_ACK, 250)
                handler.postDelayed({ tg.release() }, 350)
            } catch (_: Exception) {}
        }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == RINGTONE_PICKER_REQUEST) {
            val res = pendingPickerResult
            pendingPickerResult = null
            if (res == null) return

            if (resultCode == Activity.RESULT_OK && data != null) {
                val uri: Uri? = data.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                if (uri != null) {
                    val title = try {
                        RingtoneManager.getRingtone(applicationContext, uri)?.getTitle(applicationContext)
                            ?: "Nada Dering Terpilih"
                    } catch (_: Exception) {
                        "Nada Dering Terpilih"
                    }
                    res.success(mapOf("uri" to uri.toString(), "title" to title))
                } else {
                    res.success(null)
                }
            } else {
                res.success(null)
            }
        }
    }
}
