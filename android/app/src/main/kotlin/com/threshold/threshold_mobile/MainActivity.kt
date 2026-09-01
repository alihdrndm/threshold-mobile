package com.threshold.threshold_mobile

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var channel: MethodChannel? = null
    private var pendingRoute: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        intent?.getStringExtra(UnlockService.ROUTE_EXTRA)?.let {
            pendingRoute = it
        }
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, "threshold/unlock"
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    // Flutter asks once at startup which door it came
                    // through; the answer is consumed so a rebuild never
                    // replays it.
                    "consumeRoute" -> {
                        result.success(pendingRoute)
                        pendingRoute = null
                    }
                    "hasOverlayPermission" ->
                        result.success(
                            Settings.canDrawOverlays(this@MainActivity)
                        )
                    "requestOverlayPermission" -> {
                        startActivity(
                            Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            )
                        )
                        result.success(null)
                    }
                    "startDoorkeeper" -> {
                        doorPrefs().edit()
                            .putBoolean(UnlockService.KEY_ENABLED, true)
                            .apply()
                        UnlockService.start(this@MainActivity)
                        KeeperJobService.schedule(this@MainActivity)
                        result.success(null)
                    }
                    "stopDoorkeeper" -> {
                        doorPrefs().edit()
                            .putBoolean(UnlockService.KEY_ENABLED, false)
                            .apply()
                        // The keeper would only resurrect a door the user
                        // just closed.
                        KeeperJobService.cancel(this@MainActivity)
                        UnlockService.stop(this@MainActivity)
                        result.success(null)
                    }
                    "doorkeeperEnabled" -> result.success(
                        doorPrefs().getBoolean(UnlockService.KEY_ENABLED, true)
                    )
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun doorPrefs() =
        getSharedPreferences(UnlockService.PREFS, Context.MODE_PRIVATE)

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra(UnlockService.ROUTE_EXTRA)?.let { route ->
            // The app was already alive: hand the route straight over.
            channel?.invokeMethod("route", route) ?: run {
                pendingRoute = route
            }
        }
    }
}
