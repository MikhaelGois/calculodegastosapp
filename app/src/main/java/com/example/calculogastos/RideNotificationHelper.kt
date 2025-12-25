package com.example.calculogastos

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.graphics.drawable.IconCompat

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
                setBypassDnd(true) // Ignorar Não Perturbe
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            }

            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun showRideAnalysisNotification(
        rideInfo: RideInfo,
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
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("resultado", ResultadoCalculo(
                ganhoDiario = 0.0, 
                ganhoSemanal = 0.0, 
                valorHora = savedHourValue, 
                valorKm = savedKmValue, 
                carro = Carro("", "", 0)
            ))
            putExtra("valuePerHour", valuePerHour)
            putExtra("valuePerKm", valuePerKm)
            putExtra("distance", rideInfo.distanceKm)
            putExtra("origin", rideInfo.origin)
            putExtra("destination", rideInfo.destination)
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val hourDiffPercent = ((valuePerHour / savedHourValue - 1) * 100).toInt()
        val kmDiffPercent = ((valuePerKm / savedKmValue - 1) * 100).toInt()

        // Google Maps Actions
        val addressText = when {
            rideInfo.destination.isNotEmpty() -> rideInfo.destination
            rideInfo.origin.isNotEmpty() -> rideInfo.origin
            else -> ""
        }
        
        val mapsIntent = if (addressText.isNotEmpty()) {
            val gmmIntentUri = Uri.parse("geo:0,0?q=${Uri.encode(addressText)}")
            Intent(Intent.ACTION_VIEW, gmmIntentUri).apply {
                setPackage("com.google.android.apps.maps")
            }
        } else null

        val mapsPendingIntent = if (mapsIntent != null) {
            PendingIntent.getActivity(
                context, 
                1, 
                mapsIntent, 
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
        } else null

        // Texto adicional
        val ratingText = if (rideInfo.rating.isNotEmpty()) "\n⭐ Avaliação: ${rideInfo.rating}" else ""
        val durationText = if (rideInfo.durationMin > 0) "\n⏱️ Duração: ${rideInfo.durationMin.toInt()} min" else ""
        val addressInfo = if (addressText.isNotEmpty()) "\n📍 ${addressText.take(30)}..." else ""

        // Criar notificação com análise detalhada
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(IconCompat.createWithResource(context, R.drawable.ic_stat_name))
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
                        "  R$/Hora: ${String.format("%.2f", valuePerHour)} ${if (hourIsGood) "✅" else "❌"} (${if (hourDiffPercent >= 0) "+" else ""}$hourDiffPercent%)" +
                        durationText +
                        ratingText +
                        addressInfo + "\n\n" +
                        "$recommendation"
                    )
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH) // Para Heads-up
            .setCategory(NotificationCompat.CATEGORY_CALL) // Categoria importante
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setOngoing(false)
            .setColor(color)
            .setColorized(true)
            .setContentIntent(pendingIntent)
            .setFullScreenIntent(pendingIntent, true) // Crucial para acordar o app
            .setVibrate(longArrayOf(0, 500, 200, 500))
            .setTimeoutAfter(25000)

        if (mapsPendingIntent != null) {
            val mapsIcon = IconCompat.createWithResource(context, R.drawable.ic_maps_icon)
            builder.addAction(NotificationCompat.Action.Builder(mapsIcon, "📍 Ver no Maps", mapsPendingIntent).build())
        }

        try {
            NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, builder.build())
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }

    fun cancelNotification() {
        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
    }
}
