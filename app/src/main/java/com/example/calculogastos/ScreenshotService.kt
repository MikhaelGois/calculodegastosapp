package com.example.calculogastos

import android.accessibilityservice.AccessibilityService
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast
import androidx.core.app.NotificationCompat
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.*

class ScreenshotService : AccessibilityService() {

    private var mediaProjection: MediaProjection? = null
    private var imageReader: ImageReader? = null
    private val handler = Handler(Looper.getMainLooper())
    private val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
    private var lastAnalysisTime = 0L
    private val ANALYSIS_DEBOUNCE_MS = 1500L

    companion object {
        private const val NOTIFICATION_ID = 2
        private const val CHANNEL_ID = "ScreenshotChannel"
        var isServiceRunning = false
        var mediaProjectionData: Intent? = null
        var mediaProjectionResultCode: Int = 0
    }

    // Métodos de AccessibilityService
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Verifica se temos permissão de captura antes de tentar qualquer coisa
        if (mediaProjectionData == null) return
        
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
             val currentTime = System.currentTimeMillis()
            if (currentTime - lastAnalysisTime < ANALYSIS_DEBOUNCE_MS) {
                return 
            }

            val packageName = event.packageName?.toString()
            if (packageName != null && isRideApp(packageName)) {
                lastAnalysisTime = currentTime
                Log.d("ScreenshotService", "App de corrida detectado: $packageName. Capturando tela.")
                // Pequeno delay para garantir que a tela carregou completamente (ex: animações)
                handler.postDelayed({ takeScreenshot() }, 500) 
            }
        }
    }

    override fun onInterrupt() {}

    private fun isRideApp(packageName: String): Boolean {
        val rideApps = listOf("com.ubercab", "com.uber.client", "br.com.taxi99", "com.99app")
        return rideApps.any { packageName.contains(it, ignoreCase = true) }
    }
    
    // Removido override de onBind pois é final em AccessibilityService
    // O sistema fará o bind automaticamente para acessibilidade.

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isServiceRunning = true
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)

        if (intent != null) {
            // Se o intent tem dados de projeção, configuramos o MediaProjection
            val resultCode = intent.getIntExtra("resultCode", 0)
            val data = intent.getParcelableExtra<Intent>("data")

            if (resultCode != 0 && data != null) {
                mediaProjectionResultCode = resultCode
                mediaProjectionData = data
                
                val mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
                mediaProjection = mediaProjectionManager.getMediaProjection(mediaProjectionResultCode, mediaProjectionData!!)
                setupImageReader()
                Toast.makeText(this, "Monitoramento ativo e pronto!", Toast.LENGTH_SHORT).show()
            }
        }

        // Se o serviço foi reiniciado e temos dados salvos estáticos, tentamos recuperar
        if (mediaProjection == null && mediaProjectionData != null) {
             val mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
             mediaProjection = mediaProjectionManager.getMediaProjection(mediaProjectionResultCode, mediaProjectionData!!)
             setupImageReader()
        }

        return START_STICKY
    }
    
    private fun setupImageReader() {
        val displayMetrics = resources.displayMetrics
        val width = displayMetrics.widthPixels
        val height = displayMetrics.heightPixels

        // Fecha anterior se existir
        imageReader?.close()

        imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
        mediaProjection?.createVirtualDisplay(
            "ScreenCapture",
            width, height, displayMetrics.densityDpi,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            imageReader?.surface, null, null
        )
    }

    private fun takeScreenshot() {
        if (mediaProjection == null) {
            Log.e("ScreenshotService", "MediaProjection não inicializado")
            return
        }
        
        try {
            val image = imageReader?.acquireLatestImage() 
            if (image == null) {
                Log.w("ScreenshotService", "Nenhuma imagem disponível no buffer")
                return
            }
            
            val planes = image.planes
            val buffer = planes[0].buffer
            val pixelStride = planes[0].pixelStride
            val rowStride = planes[0].rowStride
            val rowPadding = rowStride - pixelStride * image.width

            val bitmap = Bitmap.createBitmap(
                image.width + rowPadding / pixelStride, 
                image.height, 
                Bitmap.Config.ARGB_8888
            )
            bitmap.copyPixelsFromBuffer(buffer)
            image.close()
            
            // Salva para debug (opcional, pode ser removido em produção para performance)
            saveBitmap(bitmap)
            
            // Processa
            processImageWithOCR(bitmap)
        } catch (e: Exception) {
            Log.e("ScreenshotService", "Erro ao capturar tela", e)
        }
    }
    
    private fun saveBitmap(bitmap: Bitmap) {
        val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
        val fileName = "screenshot_$timestamp.png"
        val dirPath = getExternalFilesDir(Environment.DIRECTORY_PICTURES)?.absolutePath ?: ""
        val file = File(dirPath, fileName)

        try {
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }
            Log.d("ScreenshotService", "Screenshot salvo em: ${file.absolutePath}")
        } catch (e: Exception) {
            Log.e("ScreenshotService", "Erro ao salvar screenshot", e)
        }
    }
    
    private fun processImageWithOCR(bitmap: Bitmap) {
        val image = InputImage.fromBitmap(bitmap, 0)
        recognizer.process(image)
            .addOnSuccessListener { visionText ->
                val fullText = visionText.text
                Log.d("ScreenshotService", "Texto OCR: $fullText")
                val rideInfo = extractRideValues(fullText)
                
                // Só notifica se tivermos dados mínimos válidos
                if (rideInfo.price > 0 && (rideInfo.distanceKm > 0 || rideInfo.durationMin > 0)) {
                    showNotificationAndOverlay(rideInfo)
                }
            }
            .addOnFailureListener { e ->
                Log.e("ScreenshotService", "Erro no OCR", e)
            }
    }
    
    private fun extractRideValues(text: String): RideInfo {
        var price = 0.0
        var distanceKm = 0.0
        var durationMin = 0.0
        var rating = ""
        var origin = ""
        var destination = ""

        // Padrão Preço (R$ ou BRL)
        val pricePattern = """(?:R\$|BRL)\s*([\d]+[.,]?[\d]*)""".toRegex(RegexOption.IGNORE_CASE)
        val priceMatch = pricePattern.find(text)
        price = priceMatch?.groupValues?.get(1)?.replace(",", ".")?.toDoubleOrNull() ?: 0.0

        // Padrão Avaliação (ex: 4.9 ★)
        val ratingPattern = """\b([3-5][.,][0-9])\b(\s*★)?""".toRegex()
        rating = ratingPattern.find(text)?.groupValues?.get(1)?.replace(",", ".") ?: ""

        // Detecção específica para 99 vs Uber
        val is99 = text.contains("99", ignoreCase = true) || text.contains("Distância:", ignoreCase = true)
        
        if (is99) {
            // Lógica 99 (Busca explícita por etiquetas)
            val distMatch = """Distância:?\s*([\d]+[.,]?[\d]*)""".toRegex(RegexOption.IGNORE_CASE).find(text)
            val durMatch = """Duração:?\s*([\d]+)""".toRegex(RegexOption.IGNORE_CASE).find(text)
            
            distanceKm = distMatch?.groupValues?.get(1)?.replace(",", ".")?.toDoubleOrNull() ?: 0.0
            durationMin = durMatch?.groupValues?.get(1)?.toDoubleOrNull() ?: 0.0
        } else {
            // Lógica Uber (Soma de trechos)
            // Procura padrões como "11 min (5.3 km)"
            val uberPairPattern = """([\d]+)\s*min\s*\(([\d]+[.,]?[\d]*)\s*km\)""".toRegex(RegexOption.IGNORE_CASE)
            val matches = uberPairPattern.findAll(text)
            
            for (match in matches) {
                val min = match.groupValues[1].toDoubleOrNull() ?: 0.0
                val km = match.groupValues[2].replace(",", ".").toDoubleOrNull() ?: 0.0
                durationMin += min
                distanceKm += km
            }

            // Fallback: Se não achou pares, tenta achar valores soltos e somar
            if (distanceKm == 0.0 && durationMin == 0.0) {
                 val kmPattern = """([\d]+[.,]?[\d]*)\s*(?:km|KM)""".toRegex(RegexOption.IGNORE_CASE)
                 val minPattern = """([\d]+)\s*(?:min|MIN)""".toRegex(RegexOption.IGNORE_CASE)
                 
                 kmPattern.findAll(text).forEach { 
                     val v = it.groupValues[1].replace(",", ".").toDoubleOrNull() ?: 0.0
                     // Ignora valores muito pequenos que podem ser versão do app
                     if (v > 0.1) distanceKm += v
                 }
                 minPattern.findAll(text).forEach {
                     val v = it.groupValues[1].toDoubleOrNull() ?: 0.0
                     if (v > 0) durationMin += v
                 }
            }
        }

        // Tentativa de endereços
        val lines = text.split("\n")
        val addressKeywords = listOf("Rua", "Av", "Avenida", "Travessa", "Rodovia", "Estrada", "Praça", "Alameda")
        val potentialAddresses = lines.filter { line ->
            val hasKeyword = addressKeywords.any { line.contains(it, ignoreCase = true) }
            val isLongEnough = line.length > 8
            val isNotValue = !line.contains("R$") && !line.contains("km") && !line.contains("min")
            hasKeyword && isLongEnough && isNotValue
        }.take(2)

        if (potentialAddresses.isNotEmpty()) {
            origin = potentialAddresses.first()
            if (potentialAddresses.size > 1) {
                destination = potentialAddresses[1]
            }
        }

        return RideInfo(price, distanceKm, durationMin, rating, origin, destination)
    }
    
    private fun showNotificationAndOverlay(rideInfo: RideInfo) {
        val prefs = getSharedPreferences("RideAnalysisPrefs", Context.MODE_PRIVATE)
        val savedHourValue = prefs.getFloat("valor_hora", 0f).toDouble()
        val savedKmValue = prefs.getFloat("valor_km", 0f).toDouble()
        
        val greatHourValue = prefs.getFloat("great_valor_hora", 0f).toDouble().let { if (it > 0) it else savedHourValue * 1.2 }
        val greatKmValue = prefs.getFloat("great_valor_km", 0f).toDouble().let { if (it > 0) it else savedKmValue * 1.2 }

        if (savedHourValue > 0 && savedKmValue > 0) {
            val valuePerKm = if (rideInfo.distanceKm > 0) rideInfo.price / rideInfo.distanceKm else 0.0
            val valuePerHour = if (rideInfo.durationMin > 0) (rideInfo.price / rideInfo.durationMin) * 60 else 0.0

            val notificationHelper = RideNotificationHelper(this)
            notificationHelper.showRideAnalysisNotification(
                rideInfo = rideInfo,
                valuePerHour = valuePerHour,
                valuePerKm = valuePerKm,
                savedHourValue = savedHourValue,
                savedKmValue = savedKmValue
            )
            
            if (android.provider.Settings.canDrawOverlays(this)) {
                val overlayIntent = Intent(this, RideOverlayService::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    putExtra("valuePerHour", valuePerHour)
                    putExtra("valuePerKm", valuePerKm)
                    putExtra("savedHourValue", savedHourValue)
                    putExtra("savedKmValue", savedKmValue)
                    putExtra("greatHourValue", greatHourValue)
                    putExtra("greatKmValue", greatKmValue)
                    putExtra("duration", rideInfo.durationMin)
                    putExtra("distance", rideInfo.distanceKm)
                    val address = if (rideInfo.destination.isNotEmpty()) rideInfo.destination else rideInfo.origin
                    putExtra("address", address)
                }
                startService(overlayIntent)
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "Monitoramento de Tela", NotificationManager.IMPORTANCE_LOW)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Monitoramento Ativo")
            .setContentText("Aguardando corridas Uber/99...")
            .setSmallIcon(R.drawable.ic_stat_name) 
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaProjection?.stop()
        imageReader?.close()
        isServiceRunning = false
    }
}
