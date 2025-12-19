package com.example.calculogastos

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import kotlinx.coroutines.*

class RideDetectionAccessibilityService : AccessibilityService() {

    private val scope = CoroutineScope(Dispatchers.Main + Job())
    private var lastAnalysisTime = 0L
    private val ANALYSIS_DEBOUNCE_MS = 8000

    companion object {
        private const val TAG = "RideDetection"
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED ||
            event.eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) {
            
            val currentTime = System.currentTimeMillis()
            if (currentTime - lastAnalysisTime < ANALYSIS_DEBOUNCE_MS) {
                return
            }

            try {
                val packageName = event.packageName?.toString() ?: return
                Log.d(TAG, "App ativo: $packageName")

                if (isRideApp(packageName)) {
                    lastAnalysisTime = currentTime
                    analyzeRideWithOCR()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Erro ao analisar evento", e)
            }
        }
    }

    private fun isRideApp(packageName: String): Boolean {
        val rideApps = listOf("com.ubercab", "com.uber.client", "br.com.taxi99", "com.99app", "com.waze")
        return rideApps.any { packageName.contains(it, ignoreCase = true) }
    }

    private fun analyzeRideWithOCR() {
        scope.launch {
            try {
                Log.d(TAG, "=== Iniciando análise com OCR ===")
                
                // Extrair texto via accessibility
                val screenText = getScreenTextViaAccessibility()
                Log.d(TAG, "Texto extraído (${screenText.length} chars)")

                if (screenText.isEmpty()) {
                    Log.w(TAG, "Nenhum texto encontrado")
                    return@launch
                }

                // Extrair valores
                val values = extractRideValues(screenText)
                Log.d(TAG, "Valores extraídos - Hora: ${values.first}, Km: ${values.second}")

                if (values.first > 0 && values.second > 0) {
                    showNotificationIfValid(values.first, values.second)
                } else {
                    Log.w(TAG, "Valores inválidos: ${values.first} / ${values.second}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Erro ao analisar com OCR", e)
                e.printStackTrace()
            }
        }
    }

    private fun getScreenTextViaAccessibility(): String {
        val rootNode = rootInActiveWindow ?: return ""
        val textBuilder = StringBuilder()
        extractTextFromNode(rootNode, textBuilder)
        return textBuilder.toString()
    }

    private fun extractTextFromNode(node: android.view.accessibility.AccessibilityNodeInfo?, textBuilder: StringBuilder) {
        if (node == null) return

        try {
            val text = node.text?.toString() ?: ""
            if (text.isNotEmpty() && !text.startsWith("android.")) {
                textBuilder.append(text).append("\n")
            }

            val contentDesc = node.contentDescription?.toString() ?: ""
            if (contentDesc.isNotEmpty()) {
                textBuilder.append(contentDesc).append("\n")
            }

            if (node.childCount > 0 && textBuilder.length < 10000) {
                for (i in 0 until node.childCount) {
                    try {
                        extractTextFromNode(node.getChild(i), textBuilder)
                    } catch (e: Exception) {
                        Log.e(TAG, "Erro ao acessar filho $i", e)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Erro em extractTextFromNode", e)
        }
    }

    private fun extractRideValues(text: String): Pair<Double, Double> {
        Log.d(TAG, "Analisando texto: '${text.take(300)}...'")

        // Padrões de busca
        val kmPattern = """([\d]+[.,]?[\d]*)\s*km""".toRegex(RegexOption.IGNORE_CASE)
        val minPattern = """([\d]+)\s*min""".toRegex(RegexOption.IGNORE_CASE)
        val rValuePattern = """R\$\s*([\d.]+[,][\d]{2})""".toRegex()

        val kmMatch = kmPattern.find(text)
        val minMatch = minPattern.find(text)
        val priceMatch = rValuePattern.find(text)

        var distanceKm = kmMatch?.groupValues?.get(1)
            ?.replace(".", "")
            ?.replace(",", ".")
            ?.toDoubleOrNull() ?: 0.0

        var timeMin = minMatch?.groupValues?.get(1)?.toDoubleOrNull() ?: 0.0

        var totalPrice = priceMatch?.groupValues?.get(1)
            ?.replace(".", "")
            ?.replace(",", ".")
            ?.toDoubleOrNull() ?: 0.0

        Log.d(TAG, "Regex: Km=$distanceKm, Min=$timeMin, Preço=$totalPrice")

        var valuePerKm = 0.0
        var valuePerHour = 0.0

        if (distanceKm > 0 && totalPrice > 0) {
            valuePerKm = totalPrice / distanceKm
        }

        if (timeMin > 0 && totalPrice > 0) {
            valuePerHour = (totalPrice / timeMin) * 60
        }

        if (valuePerKm > 0 && valuePerHour == 0.0) {
            valuePerHour = valuePerKm * 10
        }

        Log.d(TAG, "Resultado: R$/Km=$valuePerKm, R$/Hora=$valuePerHour")
        return Pair(valuePerHour, valuePerKm)
    }

    private fun showNotificationIfValid(valuePerHour: Double, valuePerKm: Double) {
        val prefs = getSharedPreferences("RideAnalysisPrefs", MODE_PRIVATE)
        val savedHourValue = prefs.getFloat("valor_hora", 0f).toDouble()
        val savedKmValue = prefs.getFloat("valor_km", 0f).toDouble()

        Log.d(TAG, "Limites: Hora=$savedHourValue, Km=$savedKmValue")

        if (savedHourValue > 0 && savedKmValue > 0) {
            val notificationHelper = RideNotificationHelper(this@RideDetectionAccessibilityService)
            notificationHelper.showRideAnalysisNotification(
                valuePerHour = valuePerHour,
                valuePerKm = valuePerKm,
                savedHourValue = savedHourValue,
                savedKmValue = savedKmValue
            )
            Log.d(TAG, "✅ Notificação enviada!")
        }
    }

    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }
}
