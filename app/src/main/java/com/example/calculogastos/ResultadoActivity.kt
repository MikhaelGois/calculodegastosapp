package com.example.calculogastos

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.calculogastos.databinding.ActivityResultadoBinding
import java.text.NumberFormat
import java.util.*

class ResultadoActivity : AppCompatActivity() {

    private lateinit var binding: ActivityResultadoBinding
    private val locale = Locale("pt", "BR")
    private val currencyFormat = NumberFormat.getCurrencyInstance(locale)
    private lateinit var resultado: ResultadoCalculo

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityResultadoBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Get result from intent
        resultado = intent.getParcelableExtra<ResultadoCalculo>("resultado") ?: run {
            Toast.makeText(this, "Erro ao carregar resultados", Toast.LENGTH_SHORT).show()
            finish()
            return
        }

        displayResults()
        setupButtons()
    }

    private fun displayResults() {
        // Display car info
        binding.tvCarroInfo.text = "${resultado.carro.fabricante} ${resultado.carro.modelo} (${resultado.carro.ano})"

        // Display results
        binding.tvGanhoDia.text = currencyFormat.format(resultado.ganhoDiario)
        binding.tvGanhoSemanal.text = currencyFormat.format(resultado.ganhoSemanal)
        binding.tvValorHR.text = currencyFormat.format(resultado.valorHora)
        binding.tvValorKM.text = currencyFormat.format(resultado.valorKm)
    }

    private fun setupButtons() {
        binding.btnAnalisarCorrida.setOnClickListener {
            abrirAnalisadorCorrida()
        }

        binding.btnVoltar.setOnClickListener {
            finish()
        }

        binding.btnSalvar.setOnClickListener {
            salvarDados()
        }

        binding.btnCopiar.setOnClickListener {
            copiarDados()
        }
    }

    private fun abrirAnalisadorCorrida() {
        // Valores de teste - em produção, viriam de entrada do usuário ou deeplink
        val valuePerHour = resultado.valorHora * 1.1 // Oferta 10% acima do calculado
        val valuePerKm = resultado.valorKm * 0.95 // Oferta 5% abaixo do calculado
        val estimatedDistance = 15.0
        val origin = "Av. Paulista, 1000 - São Paulo, SP"
        val destination = "Av. Brasil, 500 - São Paulo, SP"

        val intent = Intent(this, RideAnalysisActivity::class.java)
        intent.putExtra("resultado", resultado)
        intent.putExtra("valuePerHour", valuePerHour)
        intent.putExtra("valuePerKm", valuePerKm)
        intent.putExtra("distance", estimatedDistance)
        intent.putExtra("origin", origin)
        intent.putExtra("destination", destination)
        startActivity(intent)
    }

    private fun salvarDados() {
        // For now, just show a toast. You can implement SharedPreferences or database later
        val sharedPref = getSharedPreferences("GastosApp", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("ultimo_carro", "${resultado.carro.fabricante} ${resultado.carro.modelo} (${resultado.carro.ano})")
            putString("ultimo_ganho_diario", currencyFormat.format(resultado.ganhoDiario))
            putString("ultimo_ganho_semanal", currencyFormat.format(resultado.ganhoSemanal))
            putString("ultimo_valor_hora", currencyFormat.format(resultado.valorHora))
            putString("ultimo_valor_km", currencyFormat.format(resultado.valorKm))
            apply()
        }
        Toast.makeText(this, "Dados salvos com sucesso!", Toast.LENGTH_SHORT).show()
    }

    private fun copiarDados() {
        val texto = """
            🚗 ${resultado.carro.fabricante} ${resultado.carro.modelo} (${resultado.carro.ano})
            
            💵 SEUS GANHOS
            
            📊 Ganho Diário: ${currencyFormat.format(resultado.ganhoDiario)}
            📈 Ganho Semanal: ${currencyFormat.format(resultado.ganhoSemanal)}
            ⏰ Valor por Hora: ${currencyFormat.format(resultado.valorHora)}
            🛣️ Valor por KM: ${currencyFormat.format(resultado.valorKm)}
        """.trimIndent()

        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("Resultados Ganhos", texto)
        clipboard.setPrimaryClip(clip)
        
        Toast.makeText(this, "Dados copiados para área de transferência!", Toast.LENGTH_SHORT).show()
    }
}
