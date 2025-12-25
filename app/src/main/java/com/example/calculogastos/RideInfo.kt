package com.example.calculogastos

data class RideInfo(
    val price: Double = 0.0,
    val distanceKm: Double = 0.0,
    val durationMin: Double = 0.0,
    val rating: String = "",
    val origin: String = "",
    val destination: String = ""
)
