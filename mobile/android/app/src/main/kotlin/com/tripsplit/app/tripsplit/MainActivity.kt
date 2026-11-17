package com.tripsplit.app.tripsplit

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.firebase.FirebaseApp
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val PUSH_CHANNEL = "app.splyto/push"
        private const val NOTIFICATIONS_PERMISSION_REQUEST_CODE = 13061
        const val PUSH_TAP_MARKER = "splyto_push_tap"
    }

    private var cachedPushToken: String? = null
    private var pendingPushTokenResult: MethodChannel.Result? = null
    private var pushChannel: MethodChannel? = null

    /** A tap that arrived before Flutter asked for it, e.g. the one that opened the app. */
    private var pendingPushTap: Map<String, String>? = null
    private var flutterReadyForPushTaps = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // A restored activity keeps its old intent; that tap was already handled.
        if (savedInstanceState == null) {
            takePushTap(intent)?.let { pendingPushTap = it }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val tap = takePushTap(intent) ?: return
        val channel = pushChannel
        if (flutterReadyForPushTaps && channel != null) {
            channel.invokeMethod("notificationTapped", tap)
        } else {
            pendingPushTap = tap
        }
    }

    /**
     * The data of a tapped notification, from our own notifications or from
     * ones FCM showed while the app was in the background. Null otherwise.
     */
    private fun takePushTap(intent: Intent?): Map<String, String>? {
        val extras = intent?.extras ?: return null
        val fromPush = extras.getBoolean(PUSH_TAP_MARKER, false) ||
            extras.containsKey("google.message_id")
        val type = extras.getString("type")
        if (!fromPush || type.isNullOrBlank()) {
            return null
        }
        val tap = mutableMapOf<String, String>()
        for (key in extras.keySet()) {
            if (key.startsWith("google.") || key == "from" || key == PUSH_TAP_MARKER) {
                continue
            }
            val value = extras.getString(key)
            if (value != null) {
                tap[key] = value
            }
        }
        // Handle each tap once, also after a configuration change.
        intent.replaceExtras(Bundle())
        return tap
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PUSH_CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPushToken" -> requestPushToken(result)
                "getCachedPushToken" -> result.success(cachedPushToken)
                "takePendingNotificationTap" -> {
                    // Flutter listens from now on; later taps are sent right away.
                    flutterReadyForPushTaps = true
                    val tap = pendingPushTap
                    pendingPushTap = null
                    result.success(tap)
                }
                else -> result.notImplemented()
            }
        }
        pushChannel = channel
    }

    private fun requestPushToken(result: MethodChannel.Result) {
        val cached = cachedPushToken
        if (!cached.isNullOrBlank()) {
            result.success(cached)
            return
        }

        if (requiresNotificationPermission() && !hasNotificationPermission()) {
            pendingPushTokenResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                NOTIFICATIONS_PERMISSION_REQUEST_CODE
            )
            return
        }

        fetchFcmToken(result)
    }

    private fun fetchFcmToken(result: MethodChannel.Result) {
        val firebaseApp = try {
            FirebaseApp.initializeApp(applicationContext)
        } catch (_: Throwable) {
            null
        }
        if (firebaseApp == null) {
            result.success(null)
            return
        }

        try {
            FirebaseMessaging.getInstance().token
                .addOnCompleteListener { task ->
                    if (!task.isSuccessful) {
                        result.success(null)
                        return@addOnCompleteListener
                    }
                    val token = task.result?.trim().orEmpty()
                    if (token.isBlank()) {
                        result.success(null)
                        return@addOnCompleteListener
                    }
                    cachedPushToken = token
                    result.success(token)
                }
        } catch (_: Throwable) {
            result.success(null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != NOTIFICATIONS_PERMISSION_REQUEST_CODE) {
            return
        }

        val pending = pendingPushTokenResult ?: return
        pendingPushTokenResult = null

        if (hasNotificationPermission()) {
            fetchFcmToken(pending)
        } else {
            pending.success(null)
        }
    }

    private fun requiresNotificationPermission(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
    }

    private fun hasNotificationPermission(): Boolean {
        if (!requiresNotificationPermission()) {
            return true
        }
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED
    }
}
