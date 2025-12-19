package com.example.calculogastos

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class Carro(
    val fabricante: String,
    val modelo: String,
    val ano: Int
) : Parcelable
