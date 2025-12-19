package com.example.calculogastos

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import android.widget.ImageButton
import android.speech.tts.TextToSpeech
import java.util.*

class RideOverlayService : Service(), TextToSpeech.OnInitListener {

    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null
    private var textToSpeech: TextToSpeech? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        textToSpeech = TextToSpeech(this, this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val valuePerHour = intent?.getDoubleExtra("valuePerHour", 0.0) ?: 0.0
        val valuePerKm = intent?.getDoubleExtra("valuePerKm", 0.0) ?: 0.0
        val savedHourValue = intent?.getDoubleExtra("savedHourValue", 0.0) ?: 0.0
        val savedKmValue = intent?.getDoubleExtra("savedKmValue", 0.0) ?: 0.0

        showOverlay(valuePerHour, valuePerKm, savedHourValue, savedKmValue)
        return START_STICKY
    }

    private fun showOverlay(valuePerHour: Double, valuePerKm: Double, savedHourValue: Double, savedKmValue: Double) {
        // Remover overlay anterior se existir
        if (overlayView != null) {
            windowManager.removeView(overlayView)
        }

        // Criar view do overlay
        overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_ride_analysis, null)

        // Análise
        val hourIsGood = valuePerHour >= savedHourValue * 0.95
        val kmIsGood = valuePerKm >= savedKmValue * 0.95

        val recommendation = when {
            hourIsGood && kmIsGood -> "ACEITAR"
            !hourIsGood && !kmIsGood -> "RECUSAR"
            else -> "ANALISAR"
        }

        val strokeColor = when (recommendation) {
            "ACEITAR" -> getColor(R.color.gain_green)
            "RECUSAR" -> getColor(R.color.expense_red)
            else -> getColor(R.color.warning_orange)
        }

        val textColor = when (recommendation) {
            "ACEITAR" -> getColor(R.color.gain_green)
            "RECUSAR" -> getColor(R.color.expense_red)
            else -> getColor(R.color.warning_orange)
        }

        val emoji = when (recommendation) {
            "ACEITAR" -> "✅"
            "RECUSAR" -> "❌"
            else -> "⚠️"
        }

        // Calcular diferenças percentuais
        val hourDiff = ((valuePerHour / savedHourValue - 1) * 100).toInt()
        val kmDiff = ((valuePerKm / savedKmValue - 1) * 100).toInt()

        // Cor dos valores (verde se bom, vermelho se ruim)
        val hourColor = if (hourIsGood) getColor(R.color.gain_green) else getColor(R.color.expense_red)
        val kmColor = if (kmIsGood) getColor(R.color.gain_green) else getColor(R.color.expense_red)

        // Atualizar UI
        overlayView?.findViewById<com.google.android.material.card.MaterialCardView>(R.id.cardOverlay)?.strokeColor = strokeColor

        overlayView?.findViewById<TextView>(R.id.tvOverlayRecommendation)?.apply {
            text = "$emoji $recommendation"
            setTextColor(textColor)
        }

        overlayView?.findViewById<TextView>(R.id.tvOverlayHourValue)?.apply {
            text = String.format("%.2f", valuePerHour)
            setTextColor(hourColor)
        }

        overlayView?.findViewById<TextView>(R.id.tvOverlayKmValue)?.apply {
            text = String.format("%.2f", valuePerKm)
            setTextColor(kmColor)
        }

        overlayView?.findViewById<TextView>(R.id.tvOverlayDifference)?.apply {
            val avgDiff = (hourDiff + kmDiff) / 2
            text = "${if (avgDiff > 0) "+" else ""}$avgDiff%"
            setTextColor(if (avgDiff >= 0) getColor(R.color.gain_green) else getColor(R.color.expense_red))
        }

        overlayView?.findViewById<TextView>(R.id.tvOverlayInfo)?.text = "Análise automática • Seus valores"

        overlayView?.findViewById<ImageButton>(R.id.btnCloseOverlay)?.setOnClickListener {
            stopSelf()
        }

        // Adicionar à tela como pop-up flutuante
        val params = WindowManager.LayoutParams().apply {
            type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            }
            format = PixelFormat.TRANSLUCENT
            flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or 
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            width = (resources.displayMetrics.widthPixels * 0.9).toInt()
            height = WindowManager.LayoutParams.WRAP_CONTENT
            gravity = Gravity.CENTER
            x = 0
            y = 0
        }

        try {
            windowManager.addView(overlayView, params)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Falar recomendação
        speak(recommendation)
    }

    private fun speak(text: String) {
        if (textToSpeech != null && !textToSpeech!!.isSpeaking) {
            textToSpeech!!.speak(text, TextToSpeech.QUEUE_FLUSH, null)
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            textToSpeech?.language = Locale("pt", "BR")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (overlayView != null) {
            windowManager.removeView(overlayView)
        }
        textToSpeech?.stop()
        textToSpeech?.shutdown()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
