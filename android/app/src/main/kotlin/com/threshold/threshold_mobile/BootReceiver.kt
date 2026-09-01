package com.threshold.threshold_mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/// The doorkeeper survives a reboot: BOOT_COMPLETED is one of the few
/// broadcasts a manifest receiver may still hear, and starting a
/// foreground service from it is exempted.
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val prefs = context.getSharedPreferences(
                UnlockService.PREFS, Context.MODE_PRIVATE
            )
            if (prefs.getBoolean(UnlockService.KEY_ENABLED, true)) {
                UnlockService.start(context)
            }
        }
    }
}
