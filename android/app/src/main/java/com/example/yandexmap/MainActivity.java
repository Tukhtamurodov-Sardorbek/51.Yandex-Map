package com.example.yandexmap;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.yandex.mapkit.MapKitFactory;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        MapKitFactory.setApiKey("52ceaaea-d467-4ccc-9684-69187663e607");
        super.configureFlutterEngine(flutterEngine);
    }
}
