package com.example.calculogastos

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.calculogastos.databinding.ActivityMainBinding
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.MobileAds
import java.text.NumberFormat
import java.util.*

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val locale = Locale("pt", "BR")
    private val currencyFormat = NumberFormat.getCurrencyInstance(locale)
    private var tipoVeiculo: String = "financiado" // financiado ou quitado

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Inicializar AdMob
        MobileAds.initialize(this) {}
        val adRequest = AdRequest.Builder().build()
        binding.adView.loadAd(adRequest)

        // Receber tipo de veículo
        tipoVeiculo = intent.getStringExtra("tipo") ?: "financiado"

        // Ocultar campo parcela se for quitado
        if (tipoVeiculo == "quitado") {
            binding.layoutParcela.visibility = android.view.View.GONE
        }

        // Atualizar título do header
        val tituloTipo = if (tipoVeiculo == "financiado") "Financiado" else "Quitado"
        binding.tvSubtitulo.text = "Veículo $tituloTipo - Calcule seus ganhos"

        binding.btnBuscarConsumo.setOnClickListener {
            buscarConsumoNaInternet()
        }

        binding.btnCalcular.setOnClickListener {
            calcularGastos()
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

    private fun calcularGastos() {
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
            val parcela = if (tipoVeiculo == "quitado") 0.0 else binding.etParcela.text.toString().toDoubleOrNull() ?: 0.0
            val kmSemanal = binding.etKmSemanal.text.toString().toIntOrNull() ?: 0
            val combustivel = binding.etCombustivel.text.toString().toDoubleOrNull() ?: 0.0
            val tanque = binding.etTanque.text.toString().toDoubleOrNull() ?: 0.0
            val consumoCidade = binding.etConsumoCidade.text.toString().toDoubleOrNull() ?: 0.0
            val consumoRodovia = binding.etConsumoRodovia.text.toString().toDoubleOrNull() ?: 0.0
            val ipva = binding.etIpva.text.toString().toDoubleOrNull() ?: 0.0
            var seguro = binding.etSeguro.text.toString().toDoubleOrNull() ?: 0.0
            val oleo = binding.etOleo.text.toString().toDoubleOrNull() ?: 0.0
            val pneu = binding.etPneu.text.toString().toDoubleOrNull() ?: 0.0
            val manutencao = binding.etManutencao.text.toString().toDoubleOrNull() ?: 0.0
            val lucroDesejado = binding.etLucro.text.toString().toDoubleOrNull() ?: 0.0
            val diasSemana = binding.etDiasSemana.text.toString().toIntOrNull() ?: 0
            val horasDia = binding.etHorasDia.text.toString().toIntOrNull() ?: 0

            // Validação do etanol
            val isEtanol = binding.rbEtanol.isChecked
            if (isEtanol && combustivel > 4.05) {
                android.app.AlertDialog.Builder(this)
                    .setTitle("⚠️ Atenção")
                    .setMessage("O preço do etanol (R$ ${String.format("%.2f", combustivel)}) está acima de R$ 4,05.\n\n" +
                               "A gasolina pode ser uma escolha mais viável economicamente!\n\n" +
                               "Deseja continuar mesmo assim?")
                    .setPositiveButton("Continuar") { _, _ ->
                        continuarCalculo(fabricante, modelo, ano, parcela, kmSemanal, combustivel, tanque,
                            consumoCidade, consumoRodovia, ipva, seguro, oleo, pneu, manutencao,
                            lucroDesejado, diasSemana, horasDia)
                    }
                    .setNegativeButton("Revisar", null)
                    .show()
                return
            }

            continuarCalculo(fabricante, modelo, ano, parcela, kmSemanal, combustivel, tanque,
                consumoCidade, consumoRodovia, ipva, seguro, oleo, pneu, manutencao,
                lucroDesejado, diasSemana, horasDia)

        } catch (e: Exception) {
            Toast.makeText(this, "Erro ao calcular: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun continuarCalculo(
        fabricante: String,
        modelo: String,
        ano: Int,
        parcela: Double,
        kmSemanal: Int,
        combustivel: Double,
        tanque: Double,
        consumoCidade: Double,
        consumoRodovia: Double,
        ipva: Double,
        seguroOriginal: Double,
        oleo: Double,
        pneu: Double,
        manutencao: Double,
        lucroDesejado: Double,
        diasSemana: Int,
        horasDia: Int
    ) {
        var seguro = seguroOriginal

        // Check if monthly insurance and multiply by 12
        if (binding.rbMensal.isChecked) {
            seguro *= 12
        }

        // Validate inputs
        if (diasSemana == 0 || horasDia == 0 || kmSemanal == 0) {
            Toast.makeText(this, "Preencha todos os campos obrigatórios", Toast.LENGTH_SHORT).show()
            return
        }

        // Calculate monthly and weekly costs
        val custoMensalFixo = parcela + (ipva / 12) + (seguro / 12) + (manutencao / 12)
        val custoSemanalFixo = custoMensalFixo / 4.33 // weeks per month

        // Calculate fuel consumption (average between city and highway)
        val consumoMedio = (consumoCidade + consumoRodovia) / 2
        val tanquemLitros = tanque
        val alcanceKm = tanquemLitros * consumoMedio
        val custoPorKm = combustivel / alcanceKm
        val custoSemanalCombustivel = (kmSemanal * custoPorKm)

        // Calculate total weekly cost
        val custoSemanalTotal = custoSemanalFixo + custoSemanalCombustivel

        // Calculate total working hours per week
        val totalHorasSemana = diasSemana * horasDia

        // Calculate required earnings (cost + desired profit)
        val ganhoSemanalNecessario = custoSemanalTotal + lucroDesejado
        val ganhoDiario = ganhoSemanalNecessario / diasSemana
        val ganhoHora = ganhoSemanalNecessario / totalHorasSemana
        val ganhoKm = ganhoSemanalNecessario / kmSemanal

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
