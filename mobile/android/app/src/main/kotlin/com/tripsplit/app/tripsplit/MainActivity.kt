package com.tripsplit.app.tripsplit

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
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
    }

    private var cachedPushToken: String? = null
    private var pendingPushTokenResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PUSH_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPushToken" -> requestPushToken(result)
                    "getCachedPushToken" -> result.success(cachedPushToken)
                    else -> result.notImplemented()
                }
            }
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
