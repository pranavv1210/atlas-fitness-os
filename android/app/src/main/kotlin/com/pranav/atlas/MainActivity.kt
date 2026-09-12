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
                val values = call.arguments as? Map<*, *>
                AtlasWidgetProvider.saveState(
                    applicationContext,
                    date = values?.get("date") as? String,
                    hydration = (values?.get("hydrationToday") as? Number)?.toInt(),
                    streak = (values?.get("currentStreak") as? Number)?.toInt(),
                    completedToday = values?.get("completedToday") as? Boolean,
                )
                AtlasWidgetProvider.updateAll(applicationContext)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // A launcher or OEM RemoteViews failure must never prevent Atlas from opening.
        runCatching { AtlasWidgetProvider.updateAll(applicationContext) }
    }
}
