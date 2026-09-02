package com.threshold.threshold_mobile

import android.app.admin.DevicePolicyManager
import android.content.ActivityNotFoundException
import android.content.ComponentName
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
            // Same reason as onNewIntent: read once, never replayed.
            intent.removeExtra(UnlockService.ROUTE_EXTRA)
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

                    // ---- the screen-lock power behind "For nothing" ----
                    "canLock" -> result.success(dpm().isAdminActive(admin()))
                    "requestLock" -> {
                        val intent = Intent(
                            DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN
                        ).apply {
                            putExtra(
                                DevicePolicyManager.EXTRA_DEVICE_ADMIN,
                                admin()
                            )
                            putExtra(
                                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                                "So \"For nothing\" can put the screen back " +
                                    "to sleep for you. Threshold asks for " +
                                    "nothing else."
                            )
                        }
                        result.success(launch(intent))
                    }
                    "lockNow" -> {
                        if (dpm().isAdminActive(admin())) {
                            runCatching { dpm().lockNow() }
                                .onSuccess { result.success(true) }
                                .onFailure { result.success(false) }
                        } else {
                            // No grant: go home rather than pretend.
                            moveTaskToBack(true)
                            result.success(false)
                        }
                    }
                    "revokeLock" -> {
                        runCatching { dpm().removeActiveAdmin(admin()) }
                        result.success(null)
                    }

                    // ---- the ritual's errand exits ----
                    "openDialer" -> result.success(
                        launch(
                            Intent(Intent.ACTION_DIAL)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                    )
                    "openWhatsApp" -> {
                        val direct = packageManager
                            .getLaunchIntentForPackage("com.whatsapp")
                            ?: packageManager
                                .getLaunchIntentForPackage("com.whatsapp.w4b")
                        val intent = direct?.addFlags(
                            Intent.FLAG_ACTIVITY_NEW_TASK
                        ) ?: Intent(
                            Intent.ACTION_VIEW,
                            Uri.parse("https://wa.me")
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        result.success(launch(intent))
                    }

                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun doorPrefs() =
        getSharedPreferences(UnlockService.PREFS, Context.MODE_PRIVATE)

    private fun dpm() = getSystemService(DevicePolicyManager::class.java)

    private fun admin() = ComponentName(this, LockAdminReceiver::class.java)

    /// Every outward-facing launch answers honestly: false when nothing on
    /// the phone can handle it, so Dart can say so instead of failing mute.
    private fun launch(intent: Intent): Boolean = try {
        startActivity(intent)
        true
    } catch (_: ActivityNotFoundException) {
        false
    } catch (_: SecurityException) {
        false
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra(UnlockService.ROUTE_EXTRA)?.let { route ->
            // Consume it: the activity's intent is sticky, and a route left
            // on it replays the ritual on some later engine attach the user
            // never unlocked into.
            intent.removeExtra(UnlockService.ROUTE_EXTRA)
            // The app was already alive: hand the route straight over.
            channel?.invokeMethod("route", route) ?: run {
                pendingRoute = route
            }
        }
    }
}
