package ci.ivorycocoa.biblical_quiz

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    /// Canal « default » visé par le serveur (push_notification_hub) : importance
    /// haute, pour qu'un duel à jouer ou une invitation s'affiche en bandeau.
    /// Recréer un canal existant ne fait que mettre son nom à jour (langue).
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        manager.createNotificationChannel(
            NotificationChannel("default", getString(R.string.notification_channel_name), NotificationManager.IMPORTANCE_HIGH)
        )
    }
}
