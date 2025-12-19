package com.example.calculogastos

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.calculogastos.databinding.ActivitySettingsBinding

class SettingsActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySettingsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        updateAccessibilityStatus()
        loadSavedValues()

        binding.btnEnableAccessibility.setOnClickListener {
            openAccessibilitySettings()
        }

        binding.btnSalvarValores.setOnClickListener {
            salvarValores()
        }

        binding.btnVoltar.setOnClickListener {
            finish()
        }
    }

    override fun onResume() {
        super.onResume()
        updateAccessibilityStatus()
    }

    private fun loadSavedValues() {
        val prefs = getSharedPreferences("RideAnalysisPrefs", Context.MODE_PRIVATE)
        val valorHora = prefs.getFloat("valor_hora", 0f)
        val valorKm = prefs.getFloat("valor_km", 0f)

        if (valorHora > 0) {
            binding.etValorHora.setText(String.format("%.2f", valorHora))
        }
        if (valorKm > 0) {
            binding.etValorKm.setText(String.format("%.2f", valorKm))
        }
    }

    private fun salvarValores() {
        val valorHoraStr = binding.etValorHora.text.toString().trim()
        val valorKmStr = binding.etValorKm.text.toString().trim()

        if (valorHoraStr.isEmpty() || valorKmStr.isEmpty()) {
            Toast.makeText(this, "❌ Preencha ambos os valores!", Toast.LENGTH_SHORT).show()
            return
        }

        try {
            // Converter aceitando ponto ou vírgula
            val valorHoraStr2 = valorHoraStr.replace(",", ".")
            val valorKmStr2 = valorKmStr.replace(",", ".")
            
            val valorHora = valorHoraStr2.toFloat()
            val valorKm = valorKmStr2.toFloat()

            if (valorHora <= 0 || valorKm <= 0) {
                Toast.makeText(this, "❌ Os valores devem ser maiores que zero!", Toast.LENGTH_SHORT).show()
                return
            }

            val prefs = getSharedPreferences("RideAnalysisPrefs", Context.MODE_PRIVATE)
            prefs.edit().apply {
                putFloat("valor_hora", valorHora)
                putFloat("valor_km", valorKm)
                apply()
            }

            Toast.makeText(this, "✅ Valores salvos: R$ $valorHora/h e R$ $valorKm/km!", Toast.LENGTH_SHORT).show()
        } catch (e: NumberFormatException) {
            Toast.makeText(this, "❌ Formato inválido! Use: 10,50 ou 10.50", Toast.LENGTH_SHORT).show()
        }
    }

    private fun updateAccessibilityStatus() {
        val isEnabled = isAccessibilityServiceEnabled()
        
        if (isEnabled) {
            binding.tvStatus.text = "✅ Serviço ativo"
            binding.tvStatus.setTextColor(getColor(android.R.color.holo_green_dark))
            binding.btnEnableAccessibility.text = "✅ Serviço habilitado"
            binding.btnEnableAccessibility.isEnabled = false
        } else {
            binding.tvStatus.text = "❌ Serviço inativo"
            binding.tvStatus.setTextColor(getColor(android.R.color.holo_red_dark))
            binding.btnEnableAccessibility.text = "🔧 Habilitar serviço"
            binding.btnEnableAccessibility.isEnabled = true
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val serviceName = "${packageName}/${RideDetectionAccessibilityService::class.java.name}"
        return enabledServices.contains(serviceName)
    }

    private fun openAccessibilitySettings() {
        try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
            Toast.makeText(
                this,
                "Procure por 'Ganhos do Motorista' em Serviços Instalados",
                Toast.LENGTH_LONG
            ).show()
        } catch (e: Exception) {
            Toast.makeText(this, "Erro ao abrir configurações", Toast.LENGTH_SHORT).show()
        }
    }
}
