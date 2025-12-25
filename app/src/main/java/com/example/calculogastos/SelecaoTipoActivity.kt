package com.example.calculogastos

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.calculogastos.databinding.ActivitySelecaoTipoBinding
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.MobileAds

class SelecaoTipoActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySelecaoTipoBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySelecaoTipoBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Inicializar AdMob
        MobileAds.initialize(this) {}
        val adRequest = AdRequest.Builder().build()
        binding.adView.loadAd(adRequest)

        binding.btnFinanciado.setOnClickListener {
            val intent = Intent(this, MainActivity::class.java)
            intent.putExtra("tipo", "financiado")
            startActivity(intent)
        }

        binding.btnQuitado.setOnClickListener {
            val intent = Intent(this, MainActivity::class.java)
            intent.putExtra("tipo", "quitado")
            startActivity(intent)
        }

        binding.btnAlugado.setOnClickListener {
            val intent = Intent(this, AluguelActivity::class.java)
            startActivity(intent)
        }

        binding.btnConfiguracoes.setOnClickListener {
            val intent = Intent(this, SettingsActivity::class.java)
            startActivity(intent)
        }
    }
}
