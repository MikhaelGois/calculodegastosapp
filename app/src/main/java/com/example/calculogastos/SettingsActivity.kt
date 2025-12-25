package com.example.calculogastos

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.calculogastos.databinding.ActivitySettingsBinding
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.MobileAds

class SettingsActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySettingsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Inicializar AdMob
        MobileAds.initialize(this) {}
        val adRequest = AdRequest.Builder().build()
        binding.adView.loadAd(adRequest)

        setupSwitches()
        loadSavedValues()

        binding.btnSalvarValores.setOnClickListener {
            salvarValores()
        }

    }

    override fun onResume() {
        super.onResume()
        updateSwitchStates()
    }

    private fun setupSwitches() {
        // Switch Acessibilidade
        binding.switchAcessibilidade.setOnClickListener {
            // Apenas abrimos a tela, o estado visual será atualizado no onResume
            openAccessibilitySettings()
        }

        // Switch Captura de Tela
        binding.switchCapturaTela.setOnCheckedChangeListener { buttonView, isChecked ->
            if (isChecked) {
                // Se o usuário ativou e o serviço não está rodando, inicia o fluxo
                if (!isServiceRunning(ScreenshotService::class.java)) {
                    val intent = Intent(this, CaptureActivity::class.java)
                    startActivity(intent)
                }
            } else {
                // Se o usuário desativou, para o serviço
                stopService(Intent(this, ScreenshotService::class.java))
                Toast.makeText(this, "Captura de tela desativada", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun updateSwitchStates() {
        // Atualiza estado visual do switch de acessibilidade
        binding.switchAcessibilidade.isChecked = isAccessibilityServiceEnabled()
        
        // Atualiza estado visual do switch de captura
        // Nota: isServiceRunning pode não ser 100% preciso em Androids recentes devido a restrições,
        // mas funciona bem para verificar serviços do próprio app.
        // Se preferir, podemos usar um SharedPreferences para persistir a intenção do usuário.
        binding.switchCapturaTela.isChecked = isServiceRunning(ScreenshotService::class.java)
    }

    private fun loadSavedValues() {
        val prefs = getSharedPreferences("RideAnalysisPrefs", Context.MODE_PRIVATE)
        val valorHora = prefs.getFloat("valor_hora", 0f)
        val valorKm = prefs.getFloat("valor_km", 0f)
        val greatValorHora = prefs.getFloat("great_valor_hora", 0f)
        val greatValorKm = prefs.getFloat("great_valor_km", 0f)

        if (valorHora > 0) {
            binding.etValorHora.setText(String.format("%.2f", valorHora))
        }
        if (valorKm > 0) {
            binding.etValorKm.setText(String.format("%.2f", valorKm))
        }
        if (greatValorHora > 0) {
            binding.etValorHoraOtimo.setText(String.format("%.2f", greatValorHora))
        }
        if (greatValorKm > 0) {
            binding.etValorKmOtimo.setText(String.format("%.2f", greatValorKm))
        }
    }

    private fun salvarValores() {
        val valorHoraStr = binding.etValorHora.text.toString().trim()
        val valorKmStr = binding.etValorKm.text.toString().trim()
        val greatValorHoraStr = binding.etValorHoraOtimo.text.toString().trim()
        val greatValorKmStr = binding.etValorKmOtimo.text.toString().trim()

        if (valorHoraStr.isEmpty() || valorKmStr.isEmpty()) {
            Toast.makeText(this, "❌ Preencha pelo menos os valores mínimos!", Toast.LENGTH_SHORT).show()
            return
        }

        try {
            // Converter aceitando ponto ou vírgula
            val valorHora = valorHoraStr.replace(",", ".").toFloat()
            val valorKm = valorKmStr.replace(",", ".").toFloat()
            
            var greatValorHora = 0f
            var greatValorKm = 0f
            
            if (greatValorHoraStr.isNotEmpty()) {
                greatValorHora = greatValorHoraStr.replace(",", ".").toFloat()
            }
            if (greatValorKmStr.isNotEmpty()) {
                greatValorKm = greatValorKmStr.replace(",", ".").toFloat()
            }

            if (valorHora <= 0 || valorKm <= 0) {
                Toast.makeText(this, "❌ Os valores devem ser maiores que zero!", Toast.LENGTH_SHORT).show()
                return
            }

            val prefs = getSharedPreferences("RideAnalysisPrefs", Context.MODE_PRIVATE)
            prefs.edit().apply {
                putFloat("valor_hora", valorHora)
                putFloat("valor_km", valorKm)
                if (greatValorHora > 0) putFloat("great_valor_hora", greatValorHora)
                if (greatValorKm > 0) putFloat("great_valor_km", greatValorKm)
                apply()
            }

            Toast.makeText(this, "✅ Configurações salvas com sucesso!", Toast.LENGTH_SHORT).show()
        } catch (e: NumberFormatException) {
            Toast.makeText(this, "❌ Formato inválido! Use: 10,50 ou 10.50", Toast.LENGTH_SHORT).show()
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

    @Suppress("DEPRECATION")
    private fun isServiceRunning(serviceClass: Class<*>): Boolean {
        val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service in manager.getRunningServices(Int.MAX_VALUE)) {
            if (serviceClass.name == service.service.className) {
                return true
            }
        }
        return false
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
