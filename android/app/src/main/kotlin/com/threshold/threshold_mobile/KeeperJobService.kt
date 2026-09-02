package com.threshold.threshold_mobile

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context

/**
 * The doorkeeper's keeper: a persisted 15-minute job that stands the
 * UnlockService back up whenever OneUI has quietly culled it. Jobs survive
 * process death and reboots; only a user's force-stop silences everything,
 * and that is Android's own promise to keep.
 */
class KeeperJobService : JobService() {

    override fun onStartJob(params: JobParameters?): Boolean {
        val prefs =
            getSharedPreferences(UnlockService.PREFS, Context.MODE_PRIVATE)
        if (prefs.getBoolean(UnlockService.KEY_ENABLED, true)) {
            // Idempotent: starting a running foreground service is a no-op.
            UnlockService.start(this)
        }
        return false
    }

    override fun onStopJob(params: JobParameters?): Boolean = false

    companion object {
        private const val JOB_ID = 71

        fun schedule(context: Context) {
            val scheduler =
                context.getSystemService(JobScheduler::class.java)
            if (scheduler.getPendingJob(JOB_ID) != null) return
            scheduler.schedule(
                JobInfo.Builder(
                    JOB_ID,
                    ComponentName(context, KeeperJobService::class.java)
                )
                    .setPeriodic(15L * 60 * 1000)
                    .setPersisted(true)
                    .build()
            )
        }

        fun cancel(context: Context) {
            context.getSystemService(JobScheduler::class.java)
                .cancel(JOB_ID)
        }
    }
}
