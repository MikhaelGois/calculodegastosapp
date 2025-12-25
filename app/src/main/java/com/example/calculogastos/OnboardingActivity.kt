package com.example.calculogastos

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.calculogastos.databinding.ActivityOnboardingBinding
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.MobileAds

class OnboardingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityOnboardingBinding
    private val NOTIFICATION_PERMISSION_CODE = 100

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityOnboardingBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Inicializar AdMob
        MobileAds.initialize(this) {}
        val adRequest = AdRequest.Builder().build()
        binding.adView.loadAd(adRequest)

        // Verificar se é primeira vez
        val prefs = getSharedPreferences("OnboardingPrefs", Context.MODE_PRIVATE)
        val isFirstTime = prefs.getBoolean("first_time", true)

        if (!isFirstTime && isAllPermissionsGranted()) {
            // Se já foi onboarded e tem permissões, ir direto
            goToMain()
            return
        }

        setupUI()
    }

    private fun setupUI() {
        // Habilitar Notificações
        binding.btnEnableNotifications.setOnClickListener {
            requestNotificationPermission()
        }

        // Habilitar Acessibilidade
        binding.btnEnableAccessibility.setOnClickListener {
            openAccessibilitySettings()
        }

        // Continuar quando tudo estiver pronto
        binding.btnContinue.setOnClickListener {
            if (isAllPermissionsGranted() && isAccessibilityServiceEnabled()) {
                markOnboardingDone()
                goToMain()
            } else {
                val missing = mutableListOf<String>()
                if (!isNotificationPermissionGranted()) missing.add("Notificações")
                if (!isAccessibilityServiceEnabled()) missing.add("Acessibilidade")
                Toast.makeText(this, "❌ Ative: ${missing.joinToString(", ")}", Toast.LENGTH_SHORT).show()
            }
        }

        updateStatusUI()
    }

    private fun updateStatusUI() {
        // Status Notificações
        val notificationGranted = isNotificationPermissionGranted()
        binding.tvNotificationStatus.text = if (notificationGranted) "✅ Ativado" else "❌ Desativado"
        binding.tvNotificationStatus.setTextColor(
            if (notificationGranted) getColor(R.color.gain_green) else getColor(R.color.expense_red)
        )
        binding.btnEnableNotifications.isEnabled = !notificationGranted

        // Status Acessibilidade
        val accessibilityEnabled = isAccessibilityServiceEnabled()
        binding.tvAccessibilityStatus.text = if (accessibilityEnabled) "✅ Ativado" else "❌ Desativado"
        binding.tvAccessibilityStatus.setTextColor(
            if (accessibilityEnabled) getColor(R.color.gain_green) else getColor(R.color.expense_red)
        )
        binding.btnEnableAccessibility.isEnabled = !accessibilityEnabled

        // Habilitar botão continuar se tudo estiver ativo
        binding.btnContinue.isEnabled = notificationGranted && accessibilityEnabled
    }

    override fun onResume() {
        super.onResume()
        updateStatusUI()
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_CODE
                )
            }
        } else {
            Toast.makeText(this, "✅ Notificações já ativadas", Toast.LENGTH_SHORT).show()
            updateStatusUI()
        }
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
        Toast.makeText(
            this,
            "👉 Procure por 'Ganhos do Motorista' em 'Serviços Instalados'",
            Toast.LENGTH_LONG
        ).show()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_CODE) {
            updateStatusUI()
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "✅ Notificações ativadas!", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun isNotificationPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true // Versions anteriores a Android 13 não precisam dessa permissão
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val serviceName = "${packageName}/${RideDetectionAccessibilityService::class.java.name}"
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )
        return enabledServices?.contains(serviceName) == true
    }

    private fun isAllPermissionsGranted(): Boolean {
        return isNotificationPermissionGranted()
    }

    private fun markOnboardingDone() {
        val prefs = getSharedPreferences("OnboardingPrefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("first_time", false).apply()
    }

    private fun goToMain() {
        val intent = Intent(this, SelecaoTipoActivity::class.java)
        startActivity(intent)
        finish()
    }
}
