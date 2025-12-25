package com.example.calculogastos

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.calculogastos.databinding.ActivityAluguelBinding
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.MobileAds
import java.text.NumberFormat
import java.util.*

class AluguelActivity : AppCompatActivity() {

    private lateinit var binding: ActivityAluguelBinding
    private val locale = Locale("pt", "BR")
    private val currencyFormat = NumberFormat.getCurrencyInstance(locale)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityAluguelBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Inicializar AdMob
        MobileAds.initialize(this) {}
        val adRequest = AdRequest.Builder().build()
        binding.adView.loadAd(adRequest)

        binding.btnBuscarConsumo.setOnClickListener {
            buscarConsumoNaInternet()
        }

        binding.btnCalcular.setOnClickListener {
            calcularGanhos()
        }
    }

    private fun buscarConsumoNaInternet() {
        val fabricante = binding.etFabricante.text.toString().trim()
        val modelo = binding.etModelo.text.toString().trim()
        val anoStr = binding.etAno.text.toString().trim()
        val tipoCombustivel = if (binding.rbGasolina.isChecked) "gasolina" else "etanol"

        if (fabricante.isEmpty() || modelo.isEmpty() || anoStr.isEmpty()) {
            Toast.makeText(this, "Preencha os dados do veículo primeiro", Toast.LENGTH_SHORT).show()
            return
        }

        // Montar query de busca
        val query = "consumo $fabricante $modelo $anoStr $tipoCombustivel cidade rodovia"
        val encodedQuery = Uri.encode(query)
        val searchUrl = "https://www.google.com/search?q=$encodedQuery"

        // Abrir navegador
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(searchUrl))
        startActivity(intent)
    }

    private fun calcularGanhos() {
        try {
            // Get car data
            val fabricante = binding.etFabricante.text.toString().trim()
            val modelo = binding.etModelo.text.toString().trim()
            val anoStr = binding.etAno.text.toString().trim()

            // Validate car data
            if (fabricante.isEmpty() || modelo.isEmpty() || anoStr.isEmpty()) {
                Toast.makeText(this, "Preencha os dados do veículo", Toast.LENGTH_SHORT).show()
                return
            }

            val ano = anoStr.toIntOrNull() ?: run {
                Toast.makeText(this, "Ano inválido", Toast.LENGTH_SHORT).show()
                return
            }

            // Get inputs
            val valorAluguel = binding.etAluguel.text.toString().toDoubleOrNull() ?: 0.0
            val limiteKmSemanal = binding.etLimiteKm.text.toString().toIntOrNull() ?: 0
            val combustivel = binding.etCombustivel.text.toString().toDoubleOrNull() ?: 0.0
            val tanque = binding.etTanque.text.toString().toDoubleOrNull() ?: 0.0
            val consumoCidade = binding.etConsumoCidade.text.toString().toDoubleOrNull() ?: 0.0
            val consumoRodovia = binding.etConsumoRodovia.text.toString().toDoubleOrNull() ?: 0.0
            val lucroDesejado = binding.etLucro.text.toString().toDoubleOrNull() ?: 0.0
            val diasSemana = binding.etDiasSemana.text.toString().toIntOrNull() ?: 0
            val horasDia = binding.etHorasDia.text.toString().toIntOrNull() ?: 0

            // Validate inputs
            if (diasSemana == 0 || horasDia == 0 || limiteKmSemanal == 0) {
                Toast.makeText(this, "Preencha todos os campos obrigatórios", Toast.LENGTH_SHORT).show()
                return
            }

            // Validação do etanol
            val isEtanol = binding.rbEtanol.isChecked
            if (isEtanol && combustivel > 4.05) {
                android.app.AlertDialog.Builder(this)
                    .setTitle("⚠️ Atenção")
                    .setMessage("O preço do etanol (R$ ${String.format("%.2f", combustivel)}) está acima de R$ 4,05.\n\n" +
                               "A gasolina pode ser uma escolha mais viável economicamente!\n\n" +
                               "Deseja continuar mesmo assim?")
                    .setPositiveButton("Continuar") { _, _ ->
                        continuarCalculo(fabricante, modelo, ano, valorAluguel, limiteKmSemanal, 
                            combustivel, tanque, consumoCidade, consumoRodovia, lucroDesejado, 
                            diasSemana, horasDia)
                    }
                    .setNegativeButton("Revisar", null)
                    .show()
                return
            }

            continuarCalculo(fabricante, modelo, ano, valorAluguel, limiteKmSemanal, 
                combustivel, tanque, consumoCidade, consumoRodovia, lucroDesejado, 
                diasSemana, horasDia)

        } catch (e: Exception) {
            Toast.makeText(this, "Erro ao calcular: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun continuarCalculo(
        fabricante: String,
        modelo: String,
        ano: Int,
        valorAluguel: Double,
        limiteKmSemanal: Int,
        combustivel: Double,
        tanque: Double,
        consumoCidade: Double,
        consumoRodovia: Double,
        lucroDesejado: Double,
        diasSemana: Int,
        horasDia: Int
    ) {
        // Calculate fuel consumption (average between city and highway)
        val consumoMedio = (consumoCidade + consumoRodovia) / 2
        val tanquemLitros = tanque
        val alcanceKm = tanquemLitros * consumoMedio
        val custoPorKm = combustivel / alcanceKm
        
        // Calculate weekly fuel cost (baseado no limite de KM)
        val custoSemanalCombustivel = limiteKmSemanal * custoPorKm

        // Calculate total weekly cost (aluguel + combustível)
        val custoSemanalTotal = valorAluguel + custoSemanalCombustivel

        // Calculate total working hours per week
        val totalHorasSemana = diasSemana * horasDia

        // Calculate required earnings (cost + desired profit)
        val ganhoSemanalNecessario = custoSemanalTotal + lucroDesejado
        val ganhoDiario = ganhoSemanalNecessario / diasSemana
        val ganhoHora = ganhoSemanalNecessario / totalHorasSemana
        val ganhoKm = ganhoSemanalNecessario / limiteKmSemanal

        // Create car object
        val carro = Carro(fabricante, modelo, ano)

        // Create result object
        val resultado = ResultadoCalculo(
            ganhoDiario = ganhoDiario,
            ganhoSemanal = ganhoSemanalNecessario,
            valorHora = ganhoHora,
            valorKm = ganhoKm,
            carro = carro
        )

        // Navigate to result activity
        val intent = Intent(this, ResultadoActivity::class.java)
        intent.putExtra("resultado", resultado)
        startActivity(intent)
    }
}
