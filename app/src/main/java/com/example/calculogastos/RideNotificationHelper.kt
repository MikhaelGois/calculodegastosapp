package com.example.calculogastos

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class RideNotificationHelper(private val context: Context) {

    companion object {
        private const val CHANNEL_ID = "ride_analysis_channel"
        private const val CHANNEL_NAME = "Análise de Corridas"
        private const val NOTIFICATION_ID = 1001
    }

    init {
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notificações para análise de corridas em tempo real"
                enableLights(true)
                lightColor = Color.GREEN
                enableVibration(true)
                setShowBadge(true)
            }

            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun showRideAnalysisNotification(
        valuePerHour: Double,
        valuePerKm: Double,
        savedHourValue: Double,
        savedKmValue: Double
    ) {
        // Validar valores
        if (valuePerHour <= 0 || valuePerKm <= 0 || savedHourValue <= 0 || savedKmValue <= 0) {
            return
        }

        // Análise mais rigorosa
        val hourDiff = ((valuePerHour / savedHourValue - 1) * 100)
        val kmDiff = ((valuePerKm / savedKmValue - 1) * 100)

        val hourIsGood = hourDiff >= -5  // Aceita até 5% abaixo
        val kmIsGood = kmDiff >= -5      // Aceita até 5% abaixo

        val recommendation = when {
            hourIsGood && kmIsGood -> "ACEITAR ✅"
            hourIsGood || kmIsGood -> "ANALISAR ⚠️"
            else -> "RECUSAR ❌"
        }

        val color = when {
            hourIsGood && kmIsGood -> Color.parseColor("#00C853")
            hourIsGood || kmIsGood -> Color.parseColor("#FF9800")
            else -> Color.parseColor("#E53935")
        }

        // Intent para abrir o app
        val intent = Intent(context, RideAnalysisActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("valuePerHour", valuePerHour)
            putExtra("valuePerKm", valuePerKm)
            putExtra("savedHourValue", savedHourValue)
            putExtra("savedKmValue", savedKmValue)
        }

        val hourDiffPercent = ((valuePerHour / savedHourValue - 1) * 100).toInt()
        val kmDiffPercent = ((valuePerKm / savedKmValue - 1) * 100).toInt()

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Criar notificação com análise detalhada
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(recommendation)
            .setContentText("R$/Km: ${String.format("%.2f", valuePerKm)} | R$/Hora: ${String.format("%.2f", valuePerHour)}")
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(
                        "💰 Análise da Corrida\n\n" +
                        "Seus limites:\n" +
                        "  R$/Km: ${String.format("%.2f", savedKmValue)}\n" +
                        "  R$/Hora: ${String.format("%.2f", savedHourValue)}\n\n" +
                        "Oferta recebida:\n" +
                        "  R$/Km: ${String.format("%.2f", valuePerKm)} ${if (kmIsGood) "✅" else "❌"} (${if (kmDiffPercent >= 0) "+" else ""}$kmDiffPercent%)\n" +
                        "  R$/Hora: ${String.format("%.2f", valuePerHour)} ${if (hourIsGood) "✅" else "❌"} (${if (hourDiffPercent >= 0) "+" else ""}$hourDiffPercent%)\n\n" +
                        "$recommendation"
                    )
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setOngoing(false)
            .setColor(color)
            .setColorized(true)
            .setContentIntent(pendingIntent)
            .setFullScreenIntent(pendingIntent, true)
            .setVibrate(longArrayOf(0, 500, 200, 500))
            .setTimeoutAfter(15000) // 15 segundos
            .build()

        try {
            NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }

    fun cancelNotification() {
        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
    }
}
