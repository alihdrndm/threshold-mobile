package com.threshold.threshold_mobile

import android.app.admin.DeviceAdminReceiver

/**
 * The one power Threshold asks for: locking the screen, so "For nothing"
 * can put the phone back down for you.
 *
 * The policy file (res/xml/device_admin.xml) declares force-lock and
 * nothing else, so the grant screen offers exactly that and no more. The
 * grant is revocable from inside Settings → The threshold, which also
 * removes the uninstall friction device admin would otherwise add.
 */
class LockAdminReceiver : DeviceAdminReceiver()
