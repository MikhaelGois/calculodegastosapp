package com.example.calculogastos

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class ResultadoCalculo(
    val ganhoDiario: Double,
    val ganhoSemanal: Double,
    val valorHora: Double,
    val valorKm: Double,
    val carro: Carro
) : Parcelable
