package io.flutter.plugins;

import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import android.util.Log;

public class NotificationListener extends NotificationListenerService {
    private static final String TAG = "NotificationListener";
    
    // Apps de corrida que queremos monitorar
    private static final String[] RIDE_SHARING_APPS = {
        "com.ubercab",
        "br.com.ninjado taxi",
        "com.taxis99",
        "com.inDriver",
        "com.u90101963.m",
        "com.app.taxi",
        "com.tz.call.driver.brasil"
    };

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        String packageName = sbn.getPackageName();
        
        // Verificar se a notificação vem de um app de corrida
        if (isRideSharingApp(packageName)) {
            Log.d(TAG, "Notificação recebida de: " + packageName);
            
            // Aqui você pode extrair informações da notificação
            String title = sbn.getNotification().extras.getString("android.title");
            String text = sbn.getNotification().extras.getString("android.text");
            
            Log.d(TAG, "Título: " + title);
            Log.d(TAG, "Texto: " + text);
            
            // Aqui você pode chamar o Flutter para processar a notificação
            // Por exemplo, usando MethodChannel para enviar os dados para o Flutter
            processRideNotification(packageName, title, text);
        }
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        // Chamado quando uma notificação é removida
        Log.d(TAG, "Notificação removida: " + sbn.getPackageName());
    }

    private boolean isRideSharingApp(String packageName) {
        for (String appPackage : RIDE_SHARING_APPS) {
            if (appPackage.equals(packageName)) {
                return true;
            }
        }
        return false;
    }

    private void processRideNotification(String packageName, String title, String text) {
        // Esta função seria responsável por comunicar com o Flutter
        // para processar a notificação de corrida
        Log.d(TAG, "Processando notificação de corrida: " + packageName);
        
        // Aqui você pode usar um MethodChannel para enviar os dados para o Flutter
        // Isso permitirá que o Flutter processe a notificação e mostre o overlay
    }
}