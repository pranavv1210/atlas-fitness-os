package com.pranav.atlas

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.widget.RemoteViews
import org.json.JSONObject

class AtlasWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_WATER_TAP) {
            val before = hydrationPercent(context)
            addLocalSip(context)
            val after = hydrationPercent(context)
            animateWaterFill(context, before, after)
            return
        }
        super.onReceive(context, intent)
    }

    companion object {
        private const val ACTION_WATER_TAP = "com.pranav.atlas.ACTION_WATER_TAP"
        private const val PREFS = "FlutterSharedPreferences"
        private const val SNAPSHOT_KEY = "flutter.atlas.dashboard_snapshot"
        private const val PENDING_SIPS_KEY = "flutter.atlas.widget_pending_hydration_sips"
        private const val DAILY_SIP_TARGET = 24

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, AtlasWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            for (id in ids) updateWidget(context, manager, id)
        }

        private fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            widgetId: Int,
            animatedPercent: Int? = null,
        ) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val snapshot = prefs.getString(SNAPSHOT_KEY, null)
            val json = snapshot?.let { runCatching { JSONObject(it) }.getOrNull() }
            val hydration = (json?.optInt("hydrationToday", 0) ?: 0) +
                prefs.getInt(PENDING_SIPS_KEY, 0)
            val streak = json?.optInt("currentStreak", 0) ?: 0
            val percent = ((hydration * 100) / DAILY_SIP_TARGET).coerceIn(0, 100)
            val displayPercent = animatedPercent ?: percent
            val completedToday = json?.optBoolean("completedToday", false) ?: false

            val views = RemoteViews(context.packageName, R.layout.atlas_home_widget)
            views.setInt(
                R.id.atlas_widget_root,
                "setBackgroundResource",
                if (completedToday) R.drawable.atlas_widget_background_done else R.drawable.atlas_widget_background,
            )
            views.setTextViewText(R.id.atlas_widget_water_percent, "$displayPercent%")
            views.setTextViewText(R.id.atlas_widget_streak, "$streak")
            views.setTextViewText(
                R.id.atlas_widget_status,
                if (completedToday) "Workout completed" else "Missing workout?",
            )
            views.setInt(
                R.id.atlas_widget_water_glass,
                "setBackgroundResource",
                waterGlassFor(displayPercent),
            )

            val waterIntent = Intent(context, AtlasWidgetProvider::class.java).apply {
                action = ACTION_WATER_TAP
            }
            val waterPendingIntent = PendingIntent.getBroadcast(
                context,
                4101,
                waterIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.atlas_widget_water_button, waterPendingIntent)

            val openIntent = Intent(context, MainActivity::class.java)
            val openPendingIntent = PendingIntent.getActivity(
                context,
                4102,
                openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.atlas_widget_root, openPendingIntent)
            manager.updateAppWidget(widgetId, views)
        }

        private fun addLocalSip(context: Context) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val pending = prefs.getInt(PENDING_SIPS_KEY, 0)
            prefs.edit().putInt(PENDING_SIPS_KEY, pending + 1).apply()
        }

        private fun hydrationPercent(context: Context): Int {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val snapshot = prefs.getString(SNAPSHOT_KEY, null)
            val json = snapshot?.let { runCatching { JSONObject(it) }.getOrNull() }
            val hydration = (json?.optInt("hydrationToday", 0) ?: 0) +
                prefs.getInt(PENDING_SIPS_KEY, 0)
            return ((hydration * 100) / DAILY_SIP_TARGET).coerceIn(0, 100)
        }

        private fun animateWaterFill(context: Context, startPercent: Int, endPercent: Int) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, AtlasWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            if (ids.isEmpty()) return

            val safeStart = startPercent.coerceIn(0, 100)
            val safeEnd = endPercent.coerceIn(0, 100)
            val steps = listOf(
                safeStart + ((safeEnd - safeStart) * 0.35f).toInt(),
                safeStart + ((safeEnd - safeStart) * 0.7f).toInt(),
                safeEnd,
            ).map { it.coerceIn(0, 100) }.distinct()
            val handler = Handler(Looper.getMainLooper())
            steps.forEachIndexed { index, percent ->
                handler.postDelayed(
                    {
                        for (id in ids) {
                            updateWidget(context, manager, id, percent)
                        }
                    },
                    (index * 90L),
                )
            }
        }

        private fun waterGlassFor(percent: Int): Int {
            return when {
                percent >= 90 -> R.drawable.atlas_widget_water_glass_100
                percent >= 65 -> R.drawable.atlas_widget_water_glass_75
                percent >= 40 -> R.drawable.atlas_widget_water_glass_50
                percent >= 15 -> R.drawable.atlas_widget_water_glass_25
                else -> R.drawable.atlas_widget_water_glass_0
            }
        }
    }
}
