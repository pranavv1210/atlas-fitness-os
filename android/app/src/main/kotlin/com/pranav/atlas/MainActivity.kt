package com.pranav.atlas

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onResume() {
        super.onResume()
        AtlasWidgetProvider.updateAll(this)
    }
}
