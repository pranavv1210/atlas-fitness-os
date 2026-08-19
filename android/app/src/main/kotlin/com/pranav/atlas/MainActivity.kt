package com.pranav.atlas

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.pranav.atlas/widget",
        ).setMethodCallHandler { call, result ->
            if (call.method == "updateAtlasWidget") {
                AtlasWidgetProvider.updateAll(this)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        AtlasWidgetProvider.updateAll(this)
    }
}
