package com.guillot.phylactere

import android.media.MediaScannerConnection
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.guillot.phylactere/media"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanFile" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrBlank()) {
                        result.error("missing_path", "Path argument is required.", null)
                        return@setMethodCallHandler
                    }

                    MediaScannerConnection.scanFile(
                        this,
                        arrayOf(path),
                        null,
                        null
                    )
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
