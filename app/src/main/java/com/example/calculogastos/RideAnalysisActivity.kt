package com.example.calculogastos

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.calculogastos.databinding.ActivityRideAnalysisBinding
import java.io.File
import java.io.FileOutputStream
import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.*

class RideAnalysisActivity : AppCompatActivity(), TextToSpeech.OnInitListener {

    private lateinit var binding: ActivityRideAnalysisBinding
    private var textToSpeech: TextToSpeech? = null
    private var resultado: ResultadoCalculo? = null
    
    // Dados da corrida sendo analisada
    private var offeredValuePerHour: Double = 0.0
    private var offeredValuePerKm: Double = 0.0
    private var estimatedDistance: Double = 0.0
    private var originAddress: String = ""
    private var destinationAddress: String = ""
    
    private val locale = Locale("pt", "BR")
    private val currencyFormat = NumberFormat.getCurrencyInstance(locale)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityRideAnalysisBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Recuperar dados passados
        resultado = intent.getParcelableExtra("resultado")
        offeredValuePerHour = intent.getDoubleExtra("valuePerHour", 0.0)
        offeredValuePerKm = intent.getDoubleExtra("valuePerKm", 0.0)
        estimatedDistance = intent.getDoubleExtra("distance", 0.0)
        originAddress = intent.getStringExtra("origin") ?: ""
        destinationAddress = intent.getStringExtra("destination") ?: ""

        // Inicializar TTS
        textToSpeech = TextToSpeech(this, this)

        // Analisar corrida
        analyzeRide()

        // Botões de ação
        binding.btnAcceptRide.setOnClickListener {
            takeScreenshot()
            Toast.makeText(this, "Corrida aceita!", Toast.LENGTH_SHORT).show()
            finish()
        }

        binding.btnRejectRide.setOnClickListener {
            Toast.makeText(this, "Corrida recusada", Toast.LENGTH_SHORT).show()
            finish()
        }

        binding.btnOpenMaps.setOnClickListener {
            openMapsWithLocations()
        }

        binding.btnOpenWaze.setOnClickListener {
            openWazeWithLocations()
        }
    }

    private fun analyzeRide() {
        if (resultado == null) {
            Toast.makeText(this, "Dados da corrida não carregados", Toast.LENGTH_SHORT).show()
            return
        }

        val calculatedValuePerHour = resultado!!.valorHora
        val calculatedValuePerKm = resultado!!.valorKm
        
        // Calcular ganho líquido estimado
        val estimatedNetGain = (offeredValuePerHour + offeredValuePerKm * estimatedDistance) - 30 // -30 de taxa estimada

        // Análise: comparar valores
        val hourIsGood = offeredValuePerHour >= calculatedValuePerHour * 0.95 // Aceita 5% abaixo
        val kmIsGood = offeredValuePerKm >= calculatedValuePerKm * 0.95 // Aceita 5% abaixo

        // Exibir dados no card
        binding.tvOfferedHourValue.text = "R$${String.format("%.2f", offeredValuePerHour)}/hr"
        binding.tvCalculatedHourValue.text = "(Mínimo: R$${String.format("%.2f", calculatedValuePerHour)})"
        
        binding.tvOfferedKmValue.text = "R$${String.format("%.2f", offeredValuePerKm)}/km"
        binding.tvCalculatedKmValue.text = "(Mínimo: R$${String.format("%.2f", calculatedValuePerKm)})"
        
        binding.tvNetGain.text = currencyFormat.format(estimatedNetGain)

        // Determinar recomendação baseado em prioridade
        val recommendation = when {
            // Valor/hora é prioridade: se bom, aceitar com atenção
            calculatedValuePerHour > calculatedValuePerKm && hourIsGood -> {
                RideRecommendation.ANALYZE // Amarelo - atenção
            }
            // Ambos bom
            hourIsGood && kmIsGood -> {
                RideRecommendation.ACCEPT // Verde - aceitar
            }
            // Ambos ruins
            !hourIsGood && !kmIsGood -> {
                RideRecommendation.REJECT // Vermelho - recusar
            }
            else -> {
                RideRecommendation.ANALYZE // Amarelo - análise
            }
        }

        // Aplicar estilo baseado em recomendação
        applyRecommendationStyle(recommendation)
    }

    private fun applyRecommendationStyle(recommendation: RideRecommendation) {
        when (recommendation) {
            RideRecommendation.ACCEPT -> {
                binding.cardRideRecommendation.strokeColor = getColor(android.R.color.holo_green_light)
                binding.tvRecommendation.text = "✅ ACEITAR CORRIDA"
                binding.tvRecommendation.setTextColor(getColor(android.R.color.holo_green_dark))
                binding.btnAcceptRide.visibility = View.VISIBLE
                binding.btnRejectRide.visibility = View.VISIBLE
                speak("Aceitar corrida")
            }
            RideRecommendation.REJECT -> {
                binding.cardRideRecommendation.strokeColor = getColor(android.R.color.holo_red_light)
                binding.tvRecommendation.text = "❌ RECUSAR CORRIDA"
                binding.tvRecommendation.setTextColor(getColor(android.R.color.holo_red_dark))
                binding.btnAcceptRide.visibility = View.GONE
                binding.btnRejectRide.visibility = View.VISIBLE
                speak("Recusar corrida")
            }
            RideRecommendation.ANALYZE -> {
                binding.cardRideRecommendation.strokeColor = getColor(android.R.color.holo_orange_light)
                binding.tvRecommendation.text = "⚠️ ANALISAR CORRIDA"
                binding.tvRecommendation.setTextColor(getColor(android.R.color.holo_orange_dark))
                binding.btnAcceptRide.visibility = View.VISIBLE
                binding.btnRejectRide.visibility = View.VISIBLE
                speak("Analisar corrida")
            }
        }
    }

    private fun openMapsWithLocations() {
        if (originAddress.isEmpty() || destinationAddress.isEmpty()) {
            Toast.makeText(this, "Endereços não disponíveis", Toast.LENGTH_SHORT).show()
            return
        }
        val mapsUrl = "https://maps.google.com/?q=$originAddress&saddr=$originAddress&daddr=$destinationAddress"
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(mapsUrl))
        startActivity(intent)
    }

    private fun openWazeWithLocations() {
        if (destinationAddress.isEmpty()) {
            Toast.makeText(this, "Endereço de destino não disponível", Toast.LENGTH_SHORT).show()
            return
        }
        val wazeUrl = "https://waze.com/ul?q=$destinationAddress"
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(wazeUrl))
        startActivity(intent)
    }

    private fun takeScreenshot() {
        val view = binding.cardRideRecommendation
        view.isDrawingCacheEnabled = true
        val bitmap = Bitmap.createBitmap(view.drawingCache)
        view.isDrawingCacheEnabled = false

        val fileName = "ride_analysis_${SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())}.jpg"
        val file = File(getExternalFilesDir(null), fileName)

        try {
            FileOutputStream(file).use {
                bitmap.compress(Bitmap.CompressFormat.JPEG, 95, it)
                Toast.makeText(this, "Screenshot salvo: ${file.absolutePath}", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            Toast.makeText(this, "Erro ao salvar screenshot: ${e.message}", Toast.LENGTH_SHORT).show()
        }
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
        if (textToSpeech != null) {
            textToSpeech!!.stop()
            textToSpeech!!.shutdown()
        }
        super.onDestroy()
    }

    enum class RideRecommendation {
        ACCEPT, REJECT, ANALYZE
    }
}
