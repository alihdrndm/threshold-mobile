package com.threshold.threshold_mobile

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.provider.Settings

/**
 * The doorkeeper: a quiet foreground service that watches the screen lock
 * and unlock. Android refuses manifest receivers for SCREEN_OFF and
 * USER_PRESENT, so someone has to stay awake to hear them - this is that
 * someone.
 *
 * On unlock: away >= 30 minutes -> the full ritual; less -> the quote
 * threshold. Launching a screen from the background needs the user's
 * one-time "Display over other apps" grant; without it this service stays
 * silent rather than half-working.
 */
class UnlockService : Service() {

    companion object {
        const val CHANNEL_ID = "threshold_door"
        const val NOTIF_ID = 7001
        const val PREFS = "threshold_unlock"
        const val KEY_LOCKED_AT = "locked_at"
        const val KEY_ENABLED = "enabled"
        const val QUIET_GAP_MS = 30L * 60 * 1000
        const val ROUTE_EXTRA = "threshold_route"

        fun start(context: Context) {
            val intent = Intent(context, UnlockService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, UnlockService::class.java))
        }
    }

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                Intent.ACTION_SCREEN_OFF ->
                    prefs().edit()
                        .putLong(KEY_LOCKED_AT, System.currentTimeMillis())
                        .apply()
                Intent.ACTION_USER_PRESENT -> onUnlocked()
            }
        }
    }

    private fun prefs() = getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun onUnlocked() {
        if (!prefs().getBoolean(KEY_ENABLED, true)) return
        if (!Settings.canDrawOverlays(this)) return
        val lockedAt = prefs().getLong(KEY_LOCKED_AT, 0L)
        val away = System.currentTimeMillis() - lockedAt
        // A pocket-bounce is not a threshold.
        if (lockedAt != 0L && away < 3_000) return
        // The user's decision, in full: the ENTIRE ritual meets every
        // unlock. (A running session or an owed check-in still outranks
        // it — that judgment lives on the Dart side.)
        val launch = Intent(this, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
            putExtra(ROUTE_EXTRA, "ritual")
        }
        startActivity(launch)
    }

    override fun onCreate() {
        super.onCreate()
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Standing at the door",
                NotificationManager.IMPORTANCE_MIN
            ).apply {
                description =
                    "Keeps Threshold listening for the moment you unlock."
                setShowBadge(false)
            }
        )
        val open = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )
        val notification: Notification =
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Threshold is at the door")
                .setContentText("The ritual meets you when you unlock.")
                .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
                .setContentIntent(open)
                .setOngoing(true)
                .build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIF_ID, notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(NOTIF_ID, notification)
        }
        registerReceiver(receiver, IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
        })
    }

    override fun onStartCommand(
        intent: Intent?, flags: Int, startId: Int
    ): Int = START_STICKY

    override fun onDestroy() {
        runCatching { unregisterReceiver(receiver) }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
