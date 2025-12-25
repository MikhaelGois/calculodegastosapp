package com.example.calculogastos

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import android.widget.Toast

class CaptureActivity : Activity() {

    companion object {
        private const val REQUEST_CODE = 100
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Pedir permissão de captura de tela
        val mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        startActivityForResult(mediaProjectionManager.createScreenCaptureIntent(), REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                // Permissão concedida! Iniciar o serviço com os dados da permissão
                val serviceIntent = Intent(this, ScreenshotService::class.java).apply {
                    putExtra("resultCode", resultCode)
                    putExtra("data", data)
                }
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    startForegroundService(serviceIntent)
                } else {
                    startService(serviceIntent)
                }
                Toast.makeText(this, "Monitoramento iniciado!", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "Permissão de captura necessária para analisar corridas.", Toast.LENGTH_SHORT).show()
            }
            finish()
        }
    }
}
