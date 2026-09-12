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
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.sin
import android.app.AlarmManager
import android.os.Build
import java.util.Calendar

class AtlasWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            runCatching { updateWidget(context, appWidgetManager, appWidgetId) }
        }
        runCatching { scheduleMidnight(context) }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action in listOf(ACTION_MIDNIGHT, Intent.ACTION_DATE_CHANGED,
                Intent.ACTION_TIME_CHANGED, Intent.ACTION_TIMEZONE_CHANGED,
                Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED)) {
            runCatching { updateAll(context) }
            return
        }
        if (intent.action == ACTION_WATER_TAP) {
            val before = hydrationPercent(context)
            addLocalSip(context)
            val after = hydrationPercent(context)
            val pendingResult = goAsync()
            runCatching {
                animateWaterFill(context, before, after) { pendingResult.finish() }
            }.onFailure { pendingResult.finish() }
            return
        }
        super.onReceive(context, intent)
    }

    companion object {
        private const val ACTION_WATER_TAP = "com.pranav.atlas.ACTION_WATER_TAP"
        private const val ACTION_MIDNIGHT = "com.pranav.atlas.ACTION_MIDNIGHT"
        private const val PREFS = "FlutterSharedPreferences"
        private const val WIDGET_STATE_PREFS = "AtlasWidgetState"
        private const val SNAPSHOT_KEY = "flutter.atlas.dashboard_snapshot"
        private const val PENDING_SIPS_KEY = "flutter.atlas.widget_pending_hydration_sips"
        private const val DAILY_SIP_TARGET = 24
        private var animationGeneration = 0
        private fun today() = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())

        fun saveState(
            context: Context,
            date: String?,
            hydration: Int?,
            streak: Int?,
            completedToday: Boolean?,
        ) {
            if (date == null || hydration == null || streak == null || completedToday == null) return
            context.getSharedPreferences(WIDGET_STATE_PREFS, Context.MODE_PRIVATE).edit()
                .putString("date", date)
                .putInt("hydrationToday", hydration.coerceAtLeast(0))
                .putInt("currentStreak", streak.coerceAtLeast(0))
                .putBoolean("completedToday", completedToday)
                .commit()
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, AtlasWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            for (id in ids) {
                runCatching { updateWidget(context, manager, id) }
            }
            if (ids.isNotEmpty()) runCatching { scheduleMidnight(context) }
        }

        private fun scheduleMidnight(context: Context) {
            val alarm = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val next = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
            }
            val operation = PendingIntent.getBroadcast(context, 4103,
                Intent(context, AtlasWidgetProvider::class.java).setAction(ACTION_MIDNIGHT),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            val canScheduleExact = Build.VERSION.SDK_INT < 31 ||
                runCatching { alarm.canScheduleExactAlarms() }.getOrDefault(false)
            if (canScheduleExact) {
                alarm.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next.timeInMillis, operation)
            } else {
                alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next.timeInMillis, operation)
            }
        }

        private fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            widgetId: Int,
            animatedPercent: Int? = null,
            frame: Int = -1,
        ) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val widgetState = context.getSharedPreferences(WIDGET_STATE_PREFS, Context.MODE_PRIVATE)
            val snapshot = prefs.getString(SNAPSHOT_KEY, null)
            val json = snapshot?.let { runCatching { JSONObject(it) }.getOrNull() }
            val currentDate = today()
            val stateIsCurrent = widgetState.getString("date", "") == currentDate
            val snapshotIsCurrent = json?.optString("date") == currentDate
            val hydration = (if (stateIsCurrent)
                widgetState.getInt("hydrationToday", 0)
            else if (snapshotIsCurrent) json?.optInt("hydrationToday", 0) ?: 0 else 0) +
                (if (prefs.getString("${PENDING_SIPS_KEY}_date", "") == currentDate)
                    preferenceNumber(prefs, PENDING_SIPS_KEY) else 0)
            val streak = if (widgetState.contains("currentStreak"))
                widgetState.getInt("currentStreak", 0)
            else json?.optInt("currentStreak", 0) ?: 0
            val percent = ((hydration * 100) / DAILY_SIP_TARGET).coerceIn(0, 100)
            val displayPercent = animatedPercent ?: percent
            val completedToday = if (stateIsCurrent)
                widgetState.getBoolean("completedToday", false)
            else snapshotIsCurrent && json?.optBoolean("completedToday", false) == true

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
            views.setImageViewBitmap(R.id.atlas_widget_water_glass, drawGlass(displayPercent, frame))

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
            val pending = if (prefs.getString("${PENDING_SIPS_KEY}_date", "") == today())
                preferenceNumber(prefs, PENDING_SIPS_KEY) else 0
            prefs.edit().putLong(PENDING_SIPS_KEY, (pending + 1).toLong())
                .putString("${PENDING_SIPS_KEY}_date", today()).commit()
        }

        private fun hydrationPercent(context: Context): Int {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val widgetState = context.getSharedPreferences(WIDGET_STATE_PREFS, Context.MODE_PRIVATE)
            val snapshot = prefs.getString(SNAPSHOT_KEY, null)
            val json = snapshot?.let { runCatching { JSONObject(it) }.getOrNull() }
            val currentDate = today()
            val hydration = (if (widgetState.getString("date", "") == currentDate)
                widgetState.getInt("hydrationToday", 0)
            else if (json?.optString("date") == currentDate)
                json?.optInt("hydrationToday", 0) ?: 0 else 0) +
                (if (prefs.getString("${PENDING_SIPS_KEY}_date", "") == currentDate)
                    preferenceNumber(prefs, PENDING_SIPS_KEY) else 0)
            return ((hydration * 100) / DAILY_SIP_TARGET).coerceIn(0, 100)
        }

        private fun preferenceNumber(
            prefs: android.content.SharedPreferences,
            key: String,
        ): Int = (prefs.all[key] as? Number)?.toInt() ?: 0

        private fun animateWaterFill(context: Context, startPercent: Int, endPercent: Int, finished: () -> Unit) {
            val generation = ++animationGeneration
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, AtlasWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            if (ids.isEmpty()) { finished(); return }

            val safeStart = startPercent.coerceIn(0, 100)
            val safeEnd = endPercent.coerceIn(0, 100)
            val steps = (0..16).map { safeStart + (safeEnd - safeStart) * it / 16 }
            val handler = Handler(Looper.getMainLooper())
            steps.forEachIndexed { index, percent ->
                handler.postDelayed(
                    {
                        for (id in ids) {
                            if (generation == animationGeneration) {
                                runCatching {
                                    updateWidget(context, manager, id, percent, if (index == 16) -1 else index)
                                }
                            }
                        }
                        if (index == 16) finished()
                    },
                    (index * 65L),
                )
            }
        }

        private fun drawGlass(percent: Int, frame: Int): Bitmap {
            val bitmap = Bitmap.createBitmap(150, 174, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)
            val glass = Path().apply {
                moveTo(12f, 18f); lineTo(138f, 18f)
                lineTo(120f, 166f); lineTo(30f, 166f); close()
            }
            canvas.save()
            canvas.clipPath(glass)
            paint.color = Color.argb(24, 255, 255, 255)
            canvas.drawPath(glass, paint)
            val level = 164f - 142f * percent / 100f
            val water = Path().apply {
                moveTo(0f, 174f); lineTo(0f, level)
                for (x in 0..150 step 3) lineTo(x.toFloat(), level +
                    if (frame >= 0) sin(x * 0.09 + frame * 0.7).toFloat() * 3f else 0f)
                lineTo(150f, 174f); close()
            }
            paint.color = Color.rgb(33, 190, 232)
            canvas.drawPath(water, paint)
            if (frame >= 0) {
                paint.color = Color.rgb(135, 232, 255)
                canvas.drawRect(95f, 0f, 102f, level + 3f, paint)
            }
            canvas.restore()
            paint.color = Color.rgb(212, 247, 255)
            paint.style = Paint.Style.STROKE
            paint.strokeWidth = 4f
            paint.strokeJoin = Paint.Join.MITER
            val outline = Path().apply {
                moveTo(12f, 18f); lineTo(30f, 166f)
                lineTo(120f, 166f); lineTo(138f, 18f)
            }
            canvas.drawPath(outline, paint)
            return bitmap
        }

    }
}
