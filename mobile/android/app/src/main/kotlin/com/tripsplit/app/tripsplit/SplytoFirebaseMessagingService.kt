package com.tripsplit.app.tripsplit

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import kotlin.random.Random

class SplytoFirebaseMessagingService : FirebaseMessagingService() {
    companion object {
        private const val CHANNEL_ID = "splyto_general"
        private const val CHANNEL_NAME = "Splyto"
        private const val CHANNEL_DESCRIPTION = "Trip activity and settlement updates."
    }

    override fun onMessageReceived(message: RemoteMessage) {
        val data = message.data
        val title = data["title"]?.trim().takeUnless { it.isNullOrEmpty() } ?: "Splyto"
        val body = data["body"]?.trim().takeUnless { it.isNullOrEmpty() }
            ?: message.notification?.body?.trim()

        if (body.isNullOrEmpty()) {
            return
        }

        ensureChannel()
        val notificationId = Random.nextInt()
        // Same extras as a notification that FCM shows itself, so MainActivity
        // reads both the same way when it is tapped.
        val launchIntent = (packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent(this, MainActivity::class.java)).apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            for ((key, value) in data) {
                putExtra(key, value)
            }
            putExtra(MainActivity.PUSH_TAP_MARKER, true)
        }

        val pendingIntentFlags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        // One request code per notification, so each keeps its own extras.
        val pendingIntent = PendingIntent.getActivity(
            this,
            notificationId,
            launchIntent,
            pendingIntentFlags
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_notify)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)

        val largeIcon = BitmapFactory.decodeResource(resources, R.drawable.push_large_icon)
        if (largeIcon != null) {
            builder.setLargeIcon(largeIcon)
        }

        val richImage = BitmapFactory.decodeResource(resources, R.drawable.push_rich_image)
        if (richImage != null) {
            builder.setStyle(
                NotificationCompat.BigPictureStyle()
                    .bigPicture(richImage)
                    .setSummaryText(body)
            )
        } else {
            builder.setStyle(NotificationCompat.BigTextStyle().bigText(body))
        }

        NotificationManagerCompat.from(this).notify(notificationId, builder.build())
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val manager = getSystemService(NotificationManager::class.java) ?: return
        val existing = manager.getNotificationChannel(CHANNEL_ID)
        if (existing != null) {
            return
        }
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = CHANNEL_DESCRIPTION
        }
        manager.createNotificationChannel(channel)
    }
}
