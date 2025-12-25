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
        
        val greatHourValue = intent?.getDoubleExtra("greatHourValue", 0.0) ?: (savedHourValue * 1.2)
        val greatKmValue = intent?.getDoubleExtra("greatKmValue", 0.0) ?: (savedKmValue * 1.2)
        
        val duration = intent?.getDoubleExtra("duration", 0.0) ?: 0.0
        val distance = intent?.getDoubleExtra("distance", 0.0) ?: 0.0
        val address = intent?.getStringExtra("address") ?: ""

        showOverlay(valuePerHour, valuePerKm, savedHourValue, savedKmValue, greatHourValue, greatKmValue, duration, distance, address)
        return START_STICKY
    }

    private fun showOverlay(
        valuePerHour: Double, 
        valuePerKm: Double, 
        savedHourValue: Double, 
        savedKmValue: Double,
        greatHourValue: Double,
        greatKmValue: Double,
        duration: Double,
        distance: Double,
        address: String
    ) {
        // Remover overlay anterior se existir
        if (overlayView != null) {
            windowManager.removeView(overlayView)
        }

        // Criar view do overlay
        overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_ride_analysis, null)

        // Lógica de Categorização
        // Aceitável = Saved Values (Minimum)
        // Ótimo = Great Values
        // Ruim = Abaixo de Saved Values
        
        // Vamos considerar bom se AMBOS forem pelo menos Aceitáveis
        // E Ótimo se AMBOS forem Ótimos
        
        val hourIsGreat = valuePerHour >= greatHourValue
        val kmIsGreat = valuePerKm >= greatKmValue
        
        val hourIsGood = valuePerHour >= savedHourValue
        val kmIsGood = valuePerKm >= savedKmValue

        val recommendation = when {
            hourIsGreat && kmIsGreat -> "ÓTIMO 🌟"
            hourIsGood && kmIsGood -> "ACEITÁVEL ✅"
            hourIsGood || kmIsGood -> "ANALISAR ⚠️"
            else -> "RUIM ❌"
        }

        val strokeColor = when {
            recommendation.contains("ÓTIMO") -> getColor(R.color.gain_green) // Verde forte
            recommendation.contains("ACEITÁVEL") -> getColor(R.color.pacific_blue) // Azul/Verde
            recommendation.contains("ANALISAR") -> getColor(R.color.warning_orange) // Laranja
            else -> getColor(R.color.expense_red) // Vermelho
        }

        val textColor = strokeColor

        // Calcular diferenças percentuais em relação à meta mínima
        val hourDiff = ((valuePerHour / savedHourValue - 1) * 100).toInt()
        val kmDiff = ((valuePerKm / savedKmValue - 1) * 100).toInt()

        // Cor dos valores
        val hourColor = if (hourIsGood) getColor(R.color.gain_green) else getColor(R.color.expense_red)
        val kmColor = if (kmIsGood) getColor(R.color.gain_green) else getColor(R.color.expense_red)

        // Atualizar UI
        overlayView?.findViewById<com.google.android.material.card.MaterialCardView>(R.id.cardOverlay)?.strokeColor = strokeColor

        overlayView?.findViewById<TextView>(R.id.tvOverlayRecommendation)?.apply {
            text = recommendation
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

        val infoText = StringBuilder()
        if (duration > 0) infoText.append("${duration.toInt()} min • ")
        if (distance > 0) infoText.append("${String.format("%.1f", distance)} km")
        if (address.isNotEmpty()) infoText.append("\n📍 ${address.take(20)}...")
        
        overlayView?.findViewById<TextView>(R.id.tvOverlayInfo)?.text = infoText.toString()

        overlayView?.findViewById<ImageButton>(R.id.btnCloseOverlay)?.setOnClickListener {
            stopSelf()
        }

        // Adicionar à tela
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

        // Falar recomendação (Apenas a palavra chave)
        val speechText = when {
            recommendation.contains("ÓTIMO") -> "Corrida ótima"
            recommendation.contains("ACEITÁVEL") -> "Corrida aceitável"
            recommendation.contains("ANALISAR") -> "Analise com cuidado"
            else -> "Corrida ruim"
        }
        speak(speechText)
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
